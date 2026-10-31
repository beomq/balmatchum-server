import 'dart:io';

import 'package:postgres/postgres.dart' as pg;
import 'package:serverpod/serverpod.dart'
    show PostgresDatabaseConfig, ServerpodRunMode;
import 'package:serverpod_database/embedded.dart';
import 'package:serverpod_test/serverpod_test.dart' show EphemeralTestDatabase;

/// Pre-normalization schema: the last migration before this plan.
const oldDefinitionSql = 'migrations/20261027051944103/definition.sql';
const step1Id = '20261031074250432-normalization-step1';
const step1MigrationSql = 'migrations/$step1Id/migration.sql';
const step1DefinitionSql = 'migrations/$step1Id/definition.sql';
const step2Id = '20261031133033603-normalization-step2';
const step2MigrationSql = 'migrations/$step2Id/migration.sql';

const _preludeBegin = '-- NORMALIZATION-STEP2 SELF-VERIFICATION BEGIN';
const _preludeEnd = '-- NORMALIZATION-STEP2 SELF-VERIFICATION END';

/// The self-verifying SQL that step2 runs before its first ALTER.
String step2Prelude() {
  final sql = File(step2MigrationSql).readAsStringSync();
  final begin = sql.indexOf(_preludeBegin);
  final end = sql.indexOf(_preludeEnd);
  final firstAlter = sql.indexOf('ALTER TABLE');
  if (begin < 0 || end < begin || firstAlter < end) {
    throw StateError('step2 prelude must precede the first ALTER');
  }
  return sql.substring(begin, end);
}

/// The same migration with every orphan DELETE removed, to prove the NULL
/// check aborts it.
String step2WithoutDeletes() => File(step2MigrationSql)
    .readAsStringSync()
    .split('\n')
    .where((line) {
      return !line.trimLeft().startsWith('DELETE FROM');
    })
    .join('\n');

void scratchLog(String tag, String line) => stdout.writeln('[$tag] $line');

/// A database this test owns on the embedded test PostgreSQL. Falls back to a
/// schema in the test database when the role may not create databases.
class ScratchDatabase {
  ScratchDatabase._(
    this.name,
    this.target,
    this.usesSchema,
    this._admin,
    this.db,
    this._stop,
  );

  final String name;

  /// Connection coordinates of the running embedded PostgreSQL.
  final PostgresDatabaseConfig target;
  final bool usesSchema;
  final pg.Connection? _admin;
  final pg.Connection db;
  final Future<void> Function()? _stop;

  static Future<ScratchDatabase> create(String name, String tag) async {
    final project =
        EphemeralTestDatabase.resolveProjectDatabaseConfig(
              runMode: ServerpodRunMode.test,
              serverDirectory: Directory.current.path,
            )!.withResolvedLocalPath(Directory.current.path)
            as PostgresDatabaseConfig;
    final embedded = await startOrAttachEmbeddedPostgres(project);
    final target = embedded?.connectivity ?? project;

    Future<pg.Connection> open(String database) => pg.Connection.open(
      pg.Endpoint(
        host: target.host,
        port: target.port,
        database: database,
        username: target.user,
        password: target.password,
        isUnixSocket: target.isUnixSocket,
      ),
      settings: const pg.ConnectionSettings(
        sslMode: pg.SslMode.disable,
        queryTimeout: Duration(seconds: 60),
      ),
    );

    final admin = await open('postgres');
    final privileges = await admin.execute(
      'SELECT rolsuper OR rolcreatedb FROM pg_roles '
      'WHERE rolname = current_user',
    );
    final useSchema = privileges.first[0] != true;
    scratchLog(
      tag,
      'scratch=${useSchema ? 'schema' : 'database'} "$name" '
      'on ${target.isUnixSocket ? 'unix socket' : 'tcp'} ${target.host}',
    );
    final pg.Connection db;
    if (useSchema) {
      await admin.close();
      db = await open(project.name);
      await db.execute('DROP SCHEMA IF EXISTS "$name" CASCADE');
      await db.execute('CREATE SCHEMA "$name"');
      await db.execute('SET search_path TO "$name"');
    } else {
      await admin.execute('DROP DATABASE IF EXISTS "$name" WITH (FORCE)');
      await admin.execute('CREATE DATABASE "$name"');
      db = await open(name);
    }
    final scratch = ScratchDatabase._(
      name,
      target,
      useSchema,
      useSchema ? null : admin,
      db,
      embedded?.stop,
    );
    final stale = await scratch.count(
      'SELECT count(*)::int FROM information_schema.tables '
      'WHERE table_schema = current_schema()',
    );
    scratchLog(tag, 'tables before schema load: $stale');
    if (stale != 0) throw StateError('scratch target must start empty');
    return scratch;
  }

  Future<int> count(String sql) async =>
      (await db.execute(sql)).first[0] as int;

  Future<void> runFile(String path) => runSql(File(path).readAsStringSync());

  /// Simple-query mode runs a whole migration file, BEGIN/COMMIT included.
  Future<void> runSql(String sql) =>
      db.execute(sql, queryMode: pg.QueryMode.simple);

  /// Drops the scratch target and stops PostgreSQL only if this process
  /// launched it.
  Future<void> dispose(String tag) async {
    if (usesSchema) {
      await db.execute('DROP SCHEMA IF EXISTS "$name" CASCADE');
      final left = await count(
        "SELECT count(*)::int FROM pg_namespace WHERE nspname = '$name'",
      );
      scratchLog(tag, 'cleanup: scratch schema remaining=$left');
      await db.close();
    } else {
      await db.close();
      final admin = _admin!;
      await admin.execute('DROP DATABASE IF EXISTS "$name" WITH (FORCE)');
      final left = await admin.execute(
        "SELECT count(*)::int FROM pg_database WHERE datname = '$name'",
      );
      scratchLog(tag, 'cleanup: scratch database remaining=${left.first[0]}');
      await admin.close();
    }
    await _stop?.call();
  }
}
