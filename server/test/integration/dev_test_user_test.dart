import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/auth/dev_test_user.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../../bin/dev_test_user.dart' as cli;
import 'test_tools/serverpod_test_tools.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.token);
  final String token;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $token';
}

void main() {
  withServerpod('Outside the fixture database', (builder, endpoints) {
    test('bootstrap refuses to create users or credits', () async {
      // Given a normal test database, not the isolated development fixture.
      final session = builder.build();
      configureAuth(
        session.server.serverpod,
        sessionPepper: 'public-test-only',
      );
      // When bootstrap is attempted outside the fixture gate.
      await expectLater(
        bootstrapDevTestUser(session),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Requires development mode and isolated loopback dev DB.',
          ),
        ),
      );
      // Then neither an identity nor a point entry is created.
      expect(await AuthUser.db.count(session), 0);
      expect(await ExternalIdentity.db.count(session), 0);
      expect(await PointEntry.db.count(session), 0);
      expect(
        await PointEntry.db.count(
          session,
          where: (t) => t.entryKey.equals('dev-harness-starter-v1'),
        ),
        0,
      );
    });
  });

  test('guard refuses every nondevelopment mode and shared/remote DB', () {
    final config = ServerpodConfig(
      runMode: 'development',
      apiServer: ServerConfig(
        port: 0,
        publicHost: 'localhost',
        publicPort: 0,
        publicScheme: 'http',
      ),
      database: PostgresDatabaseConfig(
        host: 'localhost',
        port: 8090,
        name: devTestDatabaseName,
        user: 'postgres',
        password: 'public-test-only',
      ),
    );
    requireDevTestDatabase(config);
    for (final mode in ['test', 'staging', 'production']) {
      expect(
        () => requireDevTestDatabase(config.copyWith(runMode: mode)),
        throwsStateError,
      );
    }
    for (final database in [
      PostgresDatabaseConfig(
        host: 'localhost',
        port: 8090,
        name: 'balmatchum',
        user: 'postgres',
        password: 'public-test-only',
      ),
      PostgresDatabaseConfig(
        host: 'example.com',
        port: 8090,
        name: devTestDatabaseName,
        user: 'postgres',
        password: 'public-test-only',
      ),
    ]) {
      expect(
        () => requireDevTestDatabase(config.copyWith(database: database)),
        throwsStateError,
      );
    }
  });

  test(
    'output is ignored with private directory and file permissions',
    () async {
      final directory = await cli.prepareDevTestOutput();
      try {
        final file = File('${directory.path}/session.json');
        expect((await directory.stat()).mode & 0x1ff, 0x1c0); // 0700
        expect((await file.stat()).mode & 0x1ff, 0x180); // 0600
        expect(await file.length(), 0);
        expect(
          (await Process.run('git', [
            'check-ignore',
            '--quiet',
            file.path,
          ])).exitCode,
          0,
        );
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );

  test('one virtual user issues real sessions enforced over HTTP', () async {
    final database = await Directory.systemTemp.createTemp('dev-user-http-');
    final pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        runMode: 'development',
        database: PostgresDatabaseConfig(
          host: '127.0.0.1',
          port: 0,
          user: 'postgres',
          password: 'local-disposable-test-only',
          dataPath: '${database.path}/pgdata',
          name: devTestDatabaseName,
        ),
      ),
    );
    configureAuth(pod, sessionPepper: 'public-test-only');
    final clients = <api.Client>[];
    Session? session;
    api.Client client([String? token]) {
      final caller = api.Client('http://localhost:${pod.server.port}/');
      if (token != null) caller.authKeyProvider = _Token(token);
      clients.add(caller);
      return caller;
    }

    try {
      await pod.start(runInGuardedZone: false);
      session = await pod.createSession(enableLogging: false);
      // Given a new fixture user.
      final other = await pod.createSession(enableLogging: false);
      late AuthSuccess first;
      try {
        final results = await Future.wait([
          bootstrapDevTestUser(session),
          bootstrapDevTestUser(other),
        ]);
        expect(results[0].authUserId, results[1].authUserId);
        first = results.first;
      } finally {
        await other.close();
      }
      final initialCredits = await PointEntry.db.find(session);
      expect(initialCredits.single.amount, 10);
      expect(initialCredits.single.policyVersion, productFixtureLabel);
      expect(initialCredits.single.owner, first.authUserId.toString());
      final account = (await ProductAccount.db.find(session)).single;
      expect(account.balance, 0);
      expect(account.fixtureBalance, 10);
      expect(await reconcilePointBalances(session), isEmpty);
      // When the same fixture user connects again.
      final second = await bootstrapDevTestUser(session);
      // Then the starter credit is not granted again or added to the wallet.
      expect(await PointEntry.db.count(session), 1);
      expect(
        (await ProductAccount.db.find(session)).single.fixtureBalance,
        10,
      );
      expect(await reconcilePointBalances(session), isEmpty);
      expect((await client(second.token).product.listThemes()).balance, 10);
      expect((await client(second.token).product.getWallet()).balance, 0);
      expect(first.authUserId, second.authUserId);
      expect(await AuthUser.db.count(session), 1);
      expect(await ExternalIdentity.db.count(session), 1);
      expect(await ServerSideSession.db.count(session), 1);
      expect(
        await ExternalIdentity.db.count(
          session,
          where: (t) => t.provider.equals('kakao'),
        ),
        0,
      );
      expect(
        await AuthServices.instance.tokenManager.validateToken(
          session,
          first.token,
        ),
        isNull,
      );
      final record = api.GpsRecordInput(
        schemaVersion: 1,
        clientRecordId: const Uuid().v4obj(),
        startedAt: DateTime.utc(2026, 10, 14),
        endedAt: DateTime.utc(2026, 10, 14, 0, 1),
        source: 'phone',
        routePoints: [],
      );
      await expectLater(
        client().records.saveConfirmed(record),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
      await expectLater(
        client(first.token).records.saveConfirmed(record),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
      final receipt = await client(second.token).records.saveConfirmed(record);
      expect(receipt, isA<api.RecordReceipt>());

      // Exercise the actual no-start CLI against this disposable DB. Capture
      // its output privately; only the filename, never the token, may appear.
      final result = await Process.run(
        Platform.resolvedExecutable,
        ['run', 'bin/dev_test_user.dart', '--mode=development'],
        environment: {
          'SERVERPOD_RUN_MODE': 'development',
          'SERVERPOD_DATABASE_HOST': '127.0.0.1',
          'SERVERPOD_DATABASE_PORT': '0',
          'SERVERPOD_DATABASE_DATA_PATH': '${database.path}/pgdata',
          'SERVERPOD_DATABASE_NAME': devTestDatabaseName,
          'SERVERPOD_DATABASE_USER': 'postgres',
          'SERVERPOD_PASSWORD_database': 'local-disposable-test-only',
          'SERVERPOD_PASSWORD_serverSideSessionKeyHashPepper':
              'public-test-only',
        },
      );
      expect(result.exitCode, 0);
      final match = RegExp(
        r'^Dev test session saved to (.+)$',
        multiLine: true,
      ).firstMatch(result.stdout as String);
      expect(match, isNotNull);
      final output = File(match!.group(1)!);
      try {
        final json =
            jsonDecode(await output.readAsString()) as Map<String, dynamic>;
        final token = json['token'] as String;
        // Boolean assertions cannot render the secret in a failure message.
        expect((result.stdout as String).contains(token), isFalse);
        expect((result.stderr as String).contains(token), isFalse);
        expect((await output.stat()).mode & 0x1ff, 0x180);
        final saved = await client(token).records.getMine(receipt.recordId);
        expect(saved.receipt.recordId, receipt.recordId);
        expect(await AuthUser.db.count(session), 1);
        expect(await ServerSideSession.db.count(session), 1);
      } finally {
        await output.parent.delete(recursive: true);
      }
    } finally {
      for (final caller in clients) {
        caller.close();
      }
      await session?.close();
      await pod.shutdown(exitProcess: false);
      await database.delete(recursive: true);
    }
  });
}
