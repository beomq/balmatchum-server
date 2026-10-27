import 'dart:async';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/account/account_endpoint.dart';
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/profile/profile_endpoint.dart';
import 'package:balmatchum_server/src/records/records_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

const _ownedTables = [
  'dog_profile',
  'gps_record',
  'step_revision',
  'product_day',
  'point_entry',
  'quiz_state',
  'theme_ownership',
  'outfit_ownership',
  'product_request',
  'product_account',
];
const _bound = Duration(seconds: 10);

void main() {
  group('Atomic self account deletion with real authentication', () {
    late Directory directory;
    late Serverpod pod;
    late Session admin;
    var started = false;
    final clients = <api.Client>[];
    final sessions = <Session>[];

    Future<({api.Client client, Session session, UuidValue id, String token})>
    user() async {
      final auth = AuthServices.instance;
      final user = await auth.authUsers.create(admin);
      final token = await auth.tokenManager.issueToken(
        admin,
        authUserId: user.id,
        method: 'account-test',
      );
      final client = api.Client('http://localhost:${pod.server.port}/')
        ..authKeyProvider = _Token(token.token);
      clients.add(client);
      final session = await pod.createSession(enableLogging: false);
      sessions.add(session);
      // Capture the actual token authentication before either race starts.
      session.updateAuthenticated(
        await auth.authenticationHandler(session, token.token),
      );
      expect(session.authenticated!.userIdentifier, user.id.uuid);
      return (
        client: client,
        session: session,
        id: user.id,
        token: token.token,
      );
    }

    Future<Map<String, Object?>> snapshot(UuidValue id) async {
      final result = <String, Object?>{};
      final parameters = QueryParameters.named({'owner': id.uuid});
      for (final table in _ownedTables) {
        result[table] = (await admin.db.unsafeQuery(
          'SELECT row_to_json(t)::text FROM "$table" t '
          'WHERE owner = @owner ORDER BY id',
          parameters: parameters,
        )).map((r) => r[0]).toList();
      }
      // Inspect every actual SDK auth FK table, including currently unused IDPs.
      final tables = await admin.db.unsafeQuery(
        "SELECT table_name FROM information_schema.columns "
        "WHERE table_schema = 'public' AND column_name = 'authUserId' "
        'ORDER BY table_name',
      );
      for (final row in tables) {
        final table = row[0] as String;
        result[table] = (await admin.db.unsafeQuery(
          'SELECT row_to_json(t)::text FROM "$table" t '
          'WHERE "authUserId" = CAST(@owner AS uuid) ORDER BY id',
          parameters: parameters,
        )).map((r) => r[0]).toList();
      }
      result['serverpod_auth_core_user'] = (await admin.db.unsafeQuery(
        'SELECT row_to_json(t)::text FROM serverpod_auth_core_user t '
        'WHERE id = CAST(@owner AS uuid)',
        parameters: parameters,
      )).map((r) => r[0]).toList();
      result['serverpod_auth_core_profile_image'] = (await admin.db.unsafeQuery(
        'SELECT row_to_json(t)::text FROM serverpod_auth_core_profile_image t '
        'WHERE "storageId" = @owner ORDER BY id',
        parameters: parameters,
      )).map((r) => r[0]).toList();
      return result;
    }

    Future<void> seed(Session session, UuidValue id) async {
      final owner = id.uuid;
      await ProfileEndpoint().createProfile(
        session,
        ProfileInput(
          breedId: 'jindo',
          name: '친구',
          sex: 'male',
          dailyGoal: 7000,
        ),
        'profile',
      );
      await ProductEndpoint().registerStepStream(session, 'stream', 0);
      await ProductEndpoint().submitSteps(
        session,
        DailyStepInput(
          date: '2026-10-14',
          streamGeneration: 1,
          revision: 1,
          windowStart: dayStart('2026-10-14'),
          windowEnd: dayStart('2026-10-15'),
          observedAt: DateTime.utc(2026, 10, 14),
          total: 7000,
          availability: 'confirmed',
        ),
      );
      await RecordsEndpoint().saveConfirmed(session, record());
      await ProductService.run(session, (s) async {
        await PointEntry.db.insertRow(
          session,
          PointEntry(
            owner: owner,
            entryKey: 'seed',
            kind: 'quiz',
            amount: 2,
            policyVersion: 'test',
            createdAt: DateTime.utc(2026),
          ),
          transaction: s.tx,
        );
        await QuizState.db.insertRow(
          session,
          QuizState(owner: owner, date: '2026-10-14', questionId: 'test'),
          transaction: s.tx,
        );
        await ThemeOwnership.db.insertRow(
          session,
          ThemeOwnership(
            owner: owner,
            themeId: 'cloudy',
            purchasedAt: DateTime.utc(2026),
          ),
          transaction: s.tx,
        );
        await OutfitOwnership.db.insertRow(
          session,
          OutfitOwnership(
            owner: owner,
            outfitId: 'vest-low-v',
            purchasedAt: DateTime.utc(2026),
          ),
          transaction: s.tx,
        );
      });
      await ExternalIdentity.db.insertRow(
        admin,
        ExternalIdentity(
          provider: 'kakao',
          issuer: 'https://kauth.kakao.com',
          audience: 'test',
          subjectNamespace: 'oidc',
          subject: owner,
          authUserId: id,
        ),
      );
      // SDK profile and image metadata exercise the transitive auth cascade.
      await admin.db.unsafeExecute(
        'INSERT INTO serverpod_auth_core_profile ("authUserId", "userName") '
        'VALUES (CAST(@owner AS text)::uuid, CAST(@owner AS text))',
        parameters: QueryParameters.named({'owner': owner}),
      );
      await admin.db.unsafeExecute(
        'INSERT INTO serverpod_auth_core_profile_image '
        '("userProfileId", "storageId", path, url) '
        'SELECT id, CAST(@owner AS text), CAST(@owner AS text), CAST(@owner AS text) '
        'FROM serverpod_auth_core_profile '
        'WHERE "authUserId" = CAST(@owner AS text)::uuid',
        parameters: QueryParameters.named({'owner': owner}),
      );
      // A second token must be revoked as well, not only the calling token.
      await AuthServices.instance.tokenManager.issueToken(
        admin,
        authUserId: id,
        method: 'second-device',
      );
    }

    Future<void> empty(UuidValue id) async {
      for (final entry in (await snapshot(id)).entries) {
        expect(entry.value, isEmpty, reason: entry.key);
      }
    }

    setUpAll(() async {
      directory = await Directory.systemTemp.createTemp('account-http-');
      pod = generated.Serverpod(
        ['--mode=test', '--apply-migrations'],
        configOverride: (config) => config.copyWith(
          database: PostgresDatabaseConfig(
            host: '127.0.0.1',
            port: 0,
            user: 'postgres',
            password: 'local-disposable-test-only',
            dataPath: '${directory.path}/pgdata',
            name: 'account_test',
          ),
        ),
      );
      configureAuth(pod, sessionPepper: 'public-account-test-only');
      try {
        await pod.start(runInGuardedZone: false);
        admin = await pod.createSession(enableLogging: false);
        started = true;
      } catch (_) {
        await pod.shutdown(exitProcess: false);
        await directory.delete(recursive: true);
        rethrow;
      }
    });
    tearDown(() async {
      for (final client in clients) {
        client.close();
      }
      clients.clear();
      for (final session in sessions) {
        await session.close();
      }
      sessions.clear();
    });
    tearDownAll(() async {
      if (!started) return;
      await admin.close();
      await pod.shutdown(exitProcess: false);
      await directory.delete(recursive: true);
    });

    test(
      'real token deletes all A data, returns 401 thereafter, preserves B',
      () async {
        final a = await user();
        final b = await user();
        await seed(a.session, a.id);
        await seed(b.session, b.id);
        final beforeA = await snapshot(a.id);
        for (final table in _ownedTables) {
          expect(beforeA[table], isNotEmpty, reason: table);
        }
        final beforeB = await snapshot(b.id);
        final anonymous = api.Client('http://localhost:${pod.server.port}/');
        clients.add(anonymous);
        await expectLater(
          anonymous.account.deleteAccount(),
          throwsA(isA<api.ServerpodClientUnauthorized>()),
        );
        expect(await snapshot(a.id), beforeA);
        await a.client.account.deleteAccount();
        await empty(a.id);
        await expectLater(
          a.client.profile.getProfile(),
          throwsA(isA<api.ServerpodClientUnauthorized>()),
        );
        await expectLater(
          a.client.account.deleteAccount(),
          throwsA(isA<api.ServerpodClientUnauthorized>()),
        );
        expect(await snapshot(b.id), beforeB);
        expect((await b.client.profile.getProfile())!.name, '친구');
      },
    );

    test(
      'deletion first rejects already authenticated product profile and GPS writes',
      () async {
        final a = await user();
        await seed(a.session, a.id);
        final purged = Completer<void>();
        final release = Completer<void>();
        final deletion = admin.db.transaction((tx) async {
          await deleteAccountData(a.session, a.id.uuid, tx);
          purged.complete();
          await release.future.timeout(_bound);
        });
        await purged.future.timeout(_bound);
        final rejected = Future.wait([
          expectLater(
            ProductEndpoint().registerStepStream(a.session, 'stale', 1),
            throwsA(isA<NotAuthorizedException>()),
          ),
          expectLater(
            ProfileEndpoint().createProfile(
              a.session,
              ProfileInput(
                breedId: 'jindo',
                name: '새친구',
                sex: 'male',
                dailyGoal: 1,
              ),
              'stale-profile',
            ),
            throwsA(isA<NotAuthorizedException>()),
          ),
          expectLater(
            RecordsEndpoint().saveConfirmed(a.session, record()),
            throwsA(isA<NotAuthorizedException>()),
          ),
        ]);
        release.complete();
        await deletion.timeout(_bound);
        await rejected.timeout(_bound);
        await empty(a.id);
      },
    );

    test('mutation first commits then deletion purges that mutation', () async {
      final a = await user();
      final locked = Completer<void>();
      final release = Completer<void>();
      final mutation = ProductService.run(a.session, (s) async {
        locked.complete();
        await release.future.timeout(_bound);
        return s.registerStream('in-flight', 0);
      });
      await locked.future.timeout(_bound);
      // NOWAIT is a deterministic database-level oracle: this fails unless the
      // mutation holds the AuthUser lock, even when ProductAccount was absent.
      await expectLater(
        admin.db.transaction(
          (tx) => admin.db.unsafeQuery(
            'SELECT id FROM serverpod_auth_core_user '
            'WHERE id = CAST(@owner AS uuid) FOR UPDATE NOWAIT',
            parameters: QueryParameters.named({'owner': a.id.uuid}),
            transaction: tx,
          ),
        ),
        throwsA(
          isA<DatabaseQueryException>().having((e) => e.code, 'code', '55P03'),
        ),
      );
      final deletion = a.client.account.deleteAccount();
      release.complete();
      expect(await mutation.timeout(_bound), 1);
      await deletion.timeout(_bound);
      await empty(a.id);
    });

    test(
      'failure at final auth deletion rolls back all data and valid tokens',
      () async {
        final a = await user();
        final b = await user();
        await seed(a.session, a.id);
        await seed(b.session, b.id);
        final beforeA = await snapshot(a.id);
        final beforeB = await snapshot(b.id);
        await admin.db.unsafeExecute(
          'CREATE FUNCTION reject_account_delete() RETURNS trigger LANGUAGE plpgsql '
          "AS 'BEGIN RAISE EXCEPTION ''test deletion failure''; END'",
        );
        await admin.db.unsafeExecute(
          'CREATE TRIGGER reject_account_delete BEFORE DELETE ON serverpod_auth_core_user '
          'FOR EACH ROW EXECUTE FUNCTION reject_account_delete()',
        );
        try {
          await expectLater(
            a.client.account.deleteAccount(),
            throwsA(isA<api.ServerpodClientInternalServerError>()),
          );
          expect(await snapshot(a.id), beforeA);
          expect(await snapshot(b.id), beforeB);
          expect((await a.client.profile.getProfile())!.name, '친구');
        } finally {
          await admin.db.unsafeExecute(
            'DROP TRIGGER reject_account_delete ON serverpod_auth_core_user',
          );
          await admin.db.unsafeExecute('DROP FUNCTION reject_account_delete()');
        }
        await a.client.account.deleteAccount();
        await empty(a.id);
      },
    );
  });
}

GpsRecordInput record() => GpsRecordInput(
  schemaVersion: 1,
  clientRecordId: const Uuid().v4obj(),
  startedAt: DateTime.utc(2026, 10, 14),
  endedAt: DateTime.utc(2026, 10, 14, 0, 1),
  source: 'watch',
  routePoints: [
    RoutePoint(
      recordedAt: DateTime.utc(2026, 10, 14),
      latitude: 37,
      longitude: 127,
    ),
  ],
);
