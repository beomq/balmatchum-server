@Timeout(Duration(minutes: 8))
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/maintenance/schema_guard.dart';
import 'package:test/test.dart';

import 'support/scratch_database.dart';

// Starts the real server (bin/main.dart) once per case against a scratch
// database and observes the process from outside: exit code, output, port.
const _tag = 'schema-guard-process';
const _passed = 'Schema check passed: requests are accepted.';
const _user = '0190c000-0000-7000-8000-00000000000a';

void _log(String line) => scratchLog(_tag, line);

const _fixture =
    '''
INSERT INTO "serverpod_auth_core_user" ("id", "createdAt", "scopeNames",
  "blocked") VALUES ('$_user', now(), '[]', false);
INSERT INTO "product_account" ("owner") VALUES ('$_user');
INSERT INTO "point_entry" ("owner", "entryKey", "kind", "date", "amount",
  "policyVersion", "createdAt") VALUES ('$_user', 'steps:1', 'grant',
  '2026-10-30', 30, 'steps-v1-20261019', now());
INSERT INTO "gps_record" ("id", "owner", "clientRecordId", "persistedAt",
  "payload", "deleted") VALUES ('0190c000-0000-7000-8000-000000000101',
  '$_user', '0190c000-0000-7000-8000-000000000101', now(),
  '{"startedAt":"2026-10-30T14:59:59.000Z","endedAt":"2026-10-30T15:00:00.000Z"}',
  false);
''';

Future<int> _freePort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

Future<bool> _accepts(int port) async {
  try {
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      port,
      timeout: const Duration(seconds: 5),
    );
    socket.destroy();
    return true;
  } on SocketException {
    return false;
  }
}

/// One `dart run bin/main.dart` with output captured line by line.
class _Server {
  _Server._(this.process, this.port, this.label) {
    Future<void> pipe(
      Stream<List<int>> stream,
      List<String> into,
      String name,
    ) {
      return stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach((line) {
            into.add(line);
            _log('$label $name| $line');
            if (line == _passed && !_ready.isCompleted) _ready.complete(true);
          });
    }

    _stdoutDone = pipe(process.stdout, stdoutLines, 'out');
    _stderrDone = pipe(process.stderr, stderrLines, 'err');
    process.exitCode.then((code) {
      if (!_ready.isCompleted) _ready.complete(false);
    });
  }

  static Future<_Server> start(String database, String label) async {
    final port = await _freePort();
    final process = await Process.start(
      Platform.resolvedExecutable,
      ['run', 'bin/main.dart', '--mode', 'test', '--apply-migrations'],
      environment: {
        'SERVERPOD_DATABASE_NAME': database,
        'SERVERPOD_API_SERVER_PORT': '$port',
      },
    );
    _log('$label started pid=${process.pid} apiPort=$port db=$database');
    return _Server._(process, port, label);
  }

  final Process process;
  final int port;
  final String label;
  final stdoutLines = <String>[];
  final stderrLines = <String>[];
  final _ready = Completer<bool>();
  late final Future<void> _stdoutDone;
  late final Future<void> _stderrDone;

  /// Completes true once the schema check passed, false if the process
  /// exited first.
  Future<bool> get ready => _ready.future.timeout(const Duration(minutes: 3));

  /// Process exit alone does not guarantee that buffered output was delivered.
  Future<int> get exitCode async {
    final code = await process.exitCode.timeout(const Duration(minutes: 3));
    await Future.wait([
      _stdoutDone.timeout(const Duration(minutes: 3)),
      _stderrDone.timeout(const Duration(minutes: 3)),
    ]);
    return code;
  }

  /// Graceful SIGTERM, escalating to SIGKILL so nothing outlives the test.
  Future<int> stop() async {
    process.kill(ProcessSignal.sigterm);
    try {
      await process.exitCode.timeout(const Duration(seconds: 60));
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
    }
    return exitCode;
  }
}

void main() {
  final scratches = <ScratchDatabase>[];
  final servers = <_Server>[];

  tearDownAll(() async {
    for (final server in servers) {
      final killed = server.process.kill(ProcessSignal.sigkill);
      _log(
        'cleanup: ${server.label} pid=${server.process.pid} '
        'still running=$killed',
      );
    }
    // The first scratch may have launched PostgreSQL; stop it last.
    for (final scratch in scratches.reversed) {
      await scratch.dispose(_tag);
    }
  });

  test('A: one start on the old schema applies step1 and step2, passes the '
      'guard and opens the port', () async {
    final scratch = await ScratchDatabase.create('balmatchum_process_a', _tag);
    scratches.add(scratch);
    expect(scratch.usesSchema, isFalse, reason: 'the server needs a database');
    await scratch.runFile(oldDefinitionSql);
    await scratch.runSql(_fixture);

    final server = await _Server.start(scratch.name, 'A');
    servers.add(server);
    final passed = await server.ready;
    final open = await _accepts(server.port);
    _log('A schema check passed=$passed port ${server.port} accepts=$open');
    final code = await server.stop();
    servers.remove(server);
    expect(passed, isTrue, reason: server.stderrLines.join('\n'));
    expect(open, isTrue);

    final out = server.stdoutLines.join('\n');
    final applied = RegExp(
      r'Applied database migrations?:((?:\n.*- .*)+)',
    ).firstMatch(out);
    _log('A applied=${applied?.group(1)?.trim()}');
    expect(applied?.group(1), contains(step1Id));
    expect(applied?.group(1), contains(step2Id));

    final db = scratch.db;
    final version = (await db.execute(
      "SELECT version FROM serverpod_migrations WHERE module = 'balmatchum'",
    )).first[0];
    final backfill = (await db.execute(
      'SELECT (SELECT "authUserId"::text FROM product_account), '
      '(SELECT balance FROM product_account), '
      '(SELECT "firstLocalDay" FROM gps_record), '
      '(SELECT "lastLocalDay" FROM gps_record)',
    )).first;
    final guard = schemaMismatchesFrom(await db.execute(schemaGuardQuery));
    _log('A version=$version backfill=$backfill guard=$guard');
    expect(version, step2Id);
    expect(backfill, [_user, 30, 20756, 20757]);
    expect(guard, isEmpty);

    _log(
      'A stopped exitCode=$code port accepts=${await _accepts(server.port)}',
    );
  });

  test('B: a step2 version row over a step1 schema exits 1 with the '
      'mismatch list', () async {
    final scratch = await ScratchDatabase.create('balmatchum_process_b', _tag);
    scratches.add(scratch);
    expect(scratch.usesSchema, isFalse, reason: 'the server needs a database');
    await scratch.runFile(oldDefinitionSql);
    await scratch.runSql(_fixture);
    await scratch.runFile(step1MigrationSql);
    await scratch.db.execute(
      "UPDATE serverpod_migrations SET version = '$step2Id' "
      "WHERE module = 'balmatchum'",
    );

    final server = await _Server.start(scratch.name, 'B');
    servers.add(server);
    final passed = await server.ready;
    final code = await server.exitCode;
    servers.remove(server);
    final open = await _accepts(server.port);
    final err = server.stderrLines.join('\n');
    _log('B schema check passed=$passed exitCode=$code port accepts=$open');
    expect(passed, isFalse);
    expect(code, 1);
    expect(err, contains('schema guard:'));
    expect(err, contains('product_account.authUserId is nullable'));
    expect(err, contains('product_account.owner still exists'));
    expect(err, contains('quiz_assignment.snapshot still exists'));
    expect(open, isFalse);
    expect(server.stdoutLines, isNot(contains(_passed)));
  });
}
