@Timeout(Duration(minutes: 3))
library;

import 'dart:io';

import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:serverpod/serverpod.dart'
    show PostgresDatabaseConfig, ServerpodRunMode;
import 'package:serverpod_database/embedded.dart';
import 'package:serverpod_test/serverpod_test.dart' show EphemeralTestDatabase;
import 'package:test/test.dart';

// Fresh test databases are created from the latest definition.sql, so the
// normal suite never runs the step-1 backfill. This test replays it on the
// pre-normalization schema in a scratch database it owns.
const _scratch = 'balmatchum_migration_replay';
const _oldDefinition = 'migrations/20261027051944103/definition.sql';
const _step1Migration =
    'migrations/20261031074250432-normalization-step1/migration.sql';

const _userA = '0190a000-0000-7000-8000-00000000000a';
const _userB = '0190a000-0000-7000-8000-00000000000b';
const _orphan = '0190a000-0000-7000-8000-0000000000cc';

const _ownerTables = [
  'ad_intent',
  'billing_account',
  'billing_purchase',
  'dog_profile',
  'gps_record',
  'outfit_ownership',
  'point_entry',
  'product_account',
  'product_day',
  'product_request',
  'quiz_assignment',
  'quiz_state',
  'step_revision',
  'theme_ownership',
];

// Every index the step-1 migration creates (todo 7).
const _step1Indexes = [
  'ad_intent_auth_user_target',
  'billing_account_auth_user',
  'billing_purchase_auth_user_id',
  'billing_purchase_auth_user_identity',
  'dog_profile_auth_user',
  'external_identity_auth_user',
  'gps_record_auth_user_client',
  'gps_record_auth_user_day',
  'login_attempt_expires_at',
  'naver_grant_owner',
  'naver_login_attempt_expires_at',
  'outfit_ownership_auth_user_key',
  'point_entry_auth_user_key',
  'point_entry_auth_user_date',
  'product_account_auth_user',
  'product_day_auth_user_date',
  'product_day_auth_user_deleted',
  'product_request_auth_user_key',
  'product_request_created_at',
  'quiz_assignment_auth_user_slot',
  'quiz_assignment_auth_user_question',
  'quiz_assignment_auth_user_id',
  'quiz_state_auth_user_key',
  'step_revision_auth_user_key',
  'theme_ownership_auth_user_key',
];

class _Gps {
  const _Gps(this.id, this.owner, this.startedAt, this.endedAt, this.deleted);
  final String id;
  final String owner;
  final String? startedAt;
  final String? endedAt;
  final bool deleted;
}

const _gpsRows = [
  // Crosses KST midnight: 23:59:59 on 10-30 -> 00:00:00 on 10-31.
  _Gps(
    '0190a000-0000-7000-8000-000000000101',
    _userA,
    '2026-10-30T14:59:59.000Z',
    '2026-10-30T15:00:00.000Z',
    false,
  ),
  _Gps(
    '0190a000-0000-7000-8000-000000000102',
    _userA,
    '2026-10-31T00:30:00.000Z',
    '2026-10-31T01:00:00.000Z',
    false,
  ),
  // Before the epoch: the day number must floor, not truncate.
  _Gps(
    '0190a000-0000-7000-8000-000000000103',
    _userB,
    '1969-12-31T14:59:59.000Z',
    '1969-12-31T15:00:01.000Z',
    false,
  ),
  _Gps(
    '0190a000-0000-7000-8000-000000000104',
    _orphan,
    '2026-10-29T20:00:00.000Z',
    '2026-10-29T21:00:00.000Z',
    false,
  ),
  // Deleted tombstone without payload is left alone by the backfill.
  _Gps('0190a000-0000-7000-8000-000000000105', _userA, null, null, true),
];

class _Point {
  const _Point(this.owner, this.key, this.amount, this.policy);
  final String owner;
  final String key;
  final int amount;
  final String policy;
}

const _points = [
  _Point(_userA, 'steps:1', 30, stepPolicyVersion),
  _Point(_userA, 'quiz:1', 10, 'quiz-v1-20261019'),
  _Point(_userA, 'theme:1', -20, themePurchasePolicyVersion),
  _Point(_userA, 'outfit:1', -5, outfitPurchasePolicyVersion),
  _Point(_userA, 'fixture:1', 50, productFixtureLabel),
  _Point(_userA, 'fixture:2', 7, productFixtureLabel),
  _Point(_userA, 'legacy:1', 1000, 'unknown-policy-v0'),
  _Point(_userB, 'steps:1', 4, stepPolicyVersion),
];

const _balancePolicies = {
  stepPolicyVersion,
  'quiz-v1-20261019',
  themePurchasePolicyVersion,
  outfitPurchasePolicyVersion,
};

void _log(String line) => stdout.writeln('[migration-replay] $line');

String _fixtureSql() {
  final b = StringBuffer();
  for (final user in [_userA, _userB]) {
    b.writeln(
      'INSERT INTO "serverpod_auth_core_user" ("id", "createdAt", '
      '"scopeNames", "blocked") VALUES (\'$user\', now(), \'[]\', false);',
    );
  }
  for (final g in _gpsRows) {
    final payload = g.startedAt == null
        ? 'NULL'
        : '\'{"clientRecordId":"${g.id}","startedAt":"${g.startedAt}",'
              '"endedAt":"${g.endedAt}","distanceMeters":1200}\'';
    b.writeln(
      'INSERT INTO "gps_record" ("id", "owner", "clientRecordId", '
      '"persistedAt", "payload", "deleted") VALUES (\'${g.id}\', '
      '\'${g.owner}\', \'${g.id}\', now(), $payload, ${g.deleted});',
    );
  }
  for (final p in _points) {
    b.writeln(
      'INSERT INTO "point_entry" ("owner", "entryKey", "kind", "date", '
      '"amount", "policyVersion", "createdAt") VALUES (\'${p.owner}\', '
      '\'${p.key}\', \'grant\', \'2026-10-30\', ${p.amount}, '
      '\'${p.policy}\', now());',
    );
  }
  b.writeln('''
INSERT INTO "product_account" ("owner") VALUES ('$_userA'), ('$_userB');
INSERT INTO "ad_intent" ("owner", "nonce", "purpose", "targetDate",
  "targetRevision", "adUnit", "rewardItem", "rewardAmount", "createdAt",
  "eventExpiresAt", "acceptUntil")
  VALUES ('$_userA', 'n1', 'steps', '2026-10-30', 1, 'unit', 'item', '1',
  now(), now(), now());
INSERT INTO "billing_account" ("owner", "binding") VALUES ('$_userA', 'b1');
INSERT INTO "billing_purchase" ("owner", "identityHash", "store",
  "environment", "productId", "kind", "purchaseReference", "state",
  "sequence", "observedAt", "acknowledgementPending")
  VALUES ('$_userA', 'h1', 'apple', 'sandbox', 'p1', 'subscription', 'r1',
  'active', 1, now(), false);
INSERT INTO "dog_profile" ("owner", "breedId", "name", "sex", "dailyGoal",
  "firstMetAt") VALUES ('$_userA', 'maltese', 'Bori', 'female', 5000, now());
INSERT INTO "outfit_ownership" ("owner", "outfitId", "purchasedAt")
  VALUES ('$_userA', 'scarf', now());
INSERT INTO "product_day" ("owner", "date", "windows")
  VALUES ('$_userA', '2026-10-30', '[]');
INSERT INTO "product_request" ("owner", "requestId", "digest", "result")
  VALUES ('$_userA', 'req-1', 'd1', '{}');
INSERT INTO "quiz_assignment" ("owner", "date", "slot", "questionId",
  "version", "snapshot", "policyVersion", "issuedAt")
  VALUES ('$_userA', '2026-10-30', 'first', 'q1', 1, '{}', 'quiz-v1-20261019',
  now());
INSERT INTO "quiz_state" ("owner", "date", "questionId")
  VALUES ('$_userB', '2026-10-30', 'q1');
INSERT INTO "step_revision" ("owner", "date", "generation", "revision",
  "digest") VALUES ('$_userB', '2026-10-30', 1, 1, 'd1');
INSERT INTO "theme_ownership" ("owner", "themeId", "purchasedAt")
  VALUES ('$_userB', 'night', now());
''');
  return b.toString();
}

String _inList(Iterable<String> names) =>
    names.map((name) => "'$name'").join(', ');

void main() {
  late pg.Connection db;
  pg.Connection? admin;
  Future<void> Function()? stopLaunchedPostgres;
  var useSchema = false;

  Future<int> count(String sql) async {
    final rows = await db.execute(sql);
    return rows.first[0] as int;
  }

  setUpAll(() async {
    final project =
        EphemeralTestDatabase.resolveProjectDatabaseConfig(
              runMode: ServerpodRunMode.test,
              serverDirectory: Directory.current.path,
            )!.withResolvedLocalPath(Directory.current.path)
            as PostgresDatabaseConfig;
    final embedded = await startOrAttachEmbeddedPostgres(project);
    stopLaunchedPostgres = embedded?.stop;
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

    final adminConnection = await open('postgres');
    admin = adminConnection;
    final privileges = await adminConnection.execute(
      'SELECT rolsuper OR rolcreatedb FROM pg_roles '
      'WHERE rolname = current_user',
    );
    useSchema = privileges.first[0] != true;
    _log(
      'scratch=${useSchema ? 'schema' : 'database'} "$_scratch" '
      'on ${target.isUnixSocket ? 'unix socket' : 'tcp'} ${target.host}',
    );

    if (useSchema) {
      await adminConnection.close();
      admin = null;
      db = await open(project.name);
      await db.execute('DROP SCHEMA IF EXISTS "$_scratch" CASCADE');
      await db.execute('CREATE SCHEMA "$_scratch"');
      await db.execute('SET search_path TO "$_scratch"');
    } else {
      await adminConnection.execute(
        'DROP DATABASE IF EXISTS "$_scratch" WITH (FORCE)',
      );
      await adminConnection.execute('CREATE DATABASE "$_scratch"');
      db = await open(_scratch);
    }

    final staleTables = await count(
      'SELECT count(*)::int FROM information_schema.tables '
      'WHERE table_schema = current_schema()',
    );
    _log('tables before old schema load: $staleTables');
    expect(staleTables, 0, reason: 'scratch target must start empty');

    await db.execute(
      File(_oldDefinition).readAsStringSync(),
      queryMode: pg.QueryMode.simple,
    );
    final seenVersionBefore = await count(
      "SELECT count(*)::int FROM pg_indexes WHERE schemaname = "
      "current_schema() AND indexname = 'quiz_assignment_seen_version'",
    );
    _log('old schema quiz_assignment_seen_version present: $seenVersionBefore');
    expect(seenVersionBefore, 1, reason: 'old schema must be loaded');

    await db.execute(_fixtureSql(), queryMode: pg.QueryMode.simple);
    for (final table in _ownerTables) {
      final rows = await count('SELECT count(*)::int FROM "$table"');
      _log('fixture rows $table=$rows');
      expect(rows, greaterThanOrEqualTo(1), reason: table);
    }

    await db.execute(
      File(_step1Migration).readAsStringSync(),
      queryMode: pg.QueryMode.simple,
    );
    final version = await db.execute(
      "SELECT version FROM serverpod_migrations WHERE module = 'balmatchum'",
    );
    _log('serverpod_migrations balmatchum=${version.first[0]}');
    expect(version.first[0], '20261031074250432-normalization-step1');
  });

  tearDownAll(() async {
    if (useSchema) {
      await db.execute('DROP SCHEMA IF EXISTS "$_scratch" CASCADE');
      final left = await count(
        "SELECT count(*)::int FROM pg_namespace WHERE nspname = '$_scratch'",
      );
      _log('cleanup: scratch schema remaining=$left');
      await db.close();
    } else {
      await db.close();
      final a = admin!;
      await a.execute('DROP DATABASE IF EXISTS "$_scratch" WITH (FORCE)');
      final left = await a.execute(
        "SELECT count(*)::int FROM pg_database WHERE datname = '$_scratch'",
      );
      _log('cleanup: scratch database remaining=${left.first[0]}');
      await a.close();
    }
    await stopLaunchedPostgres?.call();
  });

  test(
    '(a) live gps_record rows all have payload and ordered day numbers',
    () async {
      final rows = await db.execute(
        'SELECT count(*) FILTER (WHERE NOT deleted)::int, '
        'count(*) FILTER (WHERE NOT deleted AND (payload IS NULL OR '
        '"firstLocalDay" IS NULL OR "lastLocalDay" IS NULL OR '
        '"firstLocalDay" > "lastLocalDay"))::int, '
        'count(*) FILTER (WHERE deleted AND "firstLocalDay" IS NOT NULL)::int '
        'FROM gps_record',
      );
      final [live, broken, deletedFilled] = rows.first;
      _log('(a) live=$live broken=$broken deletedBackfilled=$deletedFilled');
      expect(live, 4);
      expect(broken, 0);
      expect(deletedFilled, 0);
    },
  );

  test('(b) authUserId is backfilled wherever the AuthUser exists', () async {
    for (final table in _ownerTables) {
      final rows = await db.execute(
        'SELECT '
        'count(*) FILTER (WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 '
        'FROM serverpod_auth_core_user u WHERE u.id = t.owner::uuid))::int, '
        'count(*) FILTER (WHERE "authUserId" IS NULL)::int, '
        'count(*) FILTER (WHERE "authUserId" IS NOT NULL AND '
        '"authUserId" <> owner::uuid)::int '
        'FROM "$table" t',
      );
      final [missing, nulls, wrong] = rows.first;
      _log('(b) $table missingWithUser=$missing null=$nulls mismatched=$wrong');
      expect(missing, 0, reason: table);
      expect(wrong, 0, reason: table);
      expect(nulls, table == 'gps_record' ? 1 : 0, reason: table);
    }
    final orphan = await db.execute(
      'SELECT owner FROM gps_record WHERE "authUserId" IS NULL',
    );
    _log('(b) null authUserId owners=${orphan.map((r) => r[0]).toList()}');
    expect(orphan.map((r) => r[0]), [_orphan]);
  });

  test(
    '(c) product_account balances equal the per-policy point sums',
    () async {
      final rows = await db.execute(
        'SELECT owner, balance, "fixtureBalance" FROM product_account '
        'ORDER BY owner',
      );
      expect(rows, hasLength(2));
      for (final row in rows) {
        final owner = row[0] as String;
        final mine = _points.where((p) => p.owner == owner);
        final expectedBalance = mine
            .where((p) => _balancePolicies.contains(p.policy))
            .fold<int>(0, (sum, p) => sum + p.amount);
        final expectedFixture = mine
            .where((p) => p.policy == productFixtureLabel)
            .fold<int>(0, (sum, p) => sum + p.amount);
        _log(
          '(c) $owner balance=${row[1]} expected=$expectedBalance '
          'fixtureBalance=${row[2]} expected=$expectedFixture',
        );
        expect(row[1], expectedBalance, reason: owner);
        expect(row[2], expectedFixture, reason: owner);
      }
    },
  );

  test(
    '(d) SQL day backfill matches Dart localDayNumber for every row',
    () async {
      final rows = await db.execute(
        'SELECT id::text, "firstLocalDay", "lastLocalDay" FROM gps_record',
      );
      final byId = {for (final r in rows) r[0] as String: r};
      for (final g in _gpsRows) {
        final row = byId[g.id]!;
        if (g.startedAt == null) {
          _log('(d) ${g.id} deleted first=${row[1]} last=${row[2]}');
          expect(row[1], isNull);
          expect(row[2], isNull);
          continue;
        }
        final first = localDayNumber(DateTime.parse(g.startedAt!));
        final last = localDayNumber(DateTime.parse(g.endedAt!));
        _log(
          '(d) ${g.id} sql=${row[1]}..${row[2]} dart=$first..$last '
          '(${g.startedAt} .. ${g.endedAt})',
        );
        expect(row[1], first, reason: '${g.id} firstLocalDay');
        expect(row[2], last, reason: '${g.id} lastLocalDay');
      }
    },
  );

  test('(e) step-1 indexes exist and the seen-version index is gone', () async {
    final rows = await db.execute(
      'SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = '
      'current_schema() AND indexname IN '
      "(${_inList([..._step1Indexes, 'quiz_assignment_seen_version'])})",
    );
    final found = {for (final r in rows) r[0] as String: r[1] as String};
    final missing = _step1Indexes.where((n) => !found.containsKey(n)).toList();
    _log(
      '(e) found=${found.length}/${_step1Indexes.length} missing=$missing '
      'seenVersion=${found.containsKey('quiz_assignment_seen_version')}',
    );
    _log('(e) naver_grant_owner: ${found['naver_grant_owner']}');
    expect(missing, isEmpty);
    expect(found.containsKey('quiz_assignment_seen_version'), isFalse);
    expect(found['naver_grant_owner'], contains('"authUserId"'));
  });

  test('(f) authUserId stays nullable on the 14 owner tables', () async {
    final rows = await db.execute(
      'SELECT table_name, is_nullable FROM information_schema.columns '
      "WHERE table_schema = current_schema() AND column_name = 'authUserId' "
      'AND table_name IN (${_inList(_ownerTables)}) ORDER BY table_name',
    );
    final nullable = {for (final r in rows) r[0] as String: r[1] as String};
    _log('(f) $nullable');
    expect(nullable.keys.toSet(), _ownerTables.toSet());
    expect(nullable.values.toSet(), {'YES'});
  });
}
