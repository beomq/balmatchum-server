import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/auth/kakao_provider.dart';
import 'package:balmatchum_server/src/auth/login_attempt_cleanup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:clock/clock.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../test_utils/kakao_test_keys.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.token);
  final String token;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $token';
}

api.GpsRecordInput _record() => api.GpsRecordInput(
  schemaVersion: 1,
  clientRecordId: const Uuid().v4obj(),
  startedAt: DateTime.utc(2026, 10, 12),
  endedAt: DateTime.utc(2026, 10, 12, 0, 1),
  source: 'phone',
  routePoints: [],
);

Matcher _loginError(String code) => throwsA(
  isA<api.LoginException>().having((e) => e.code, 'code', code),
);
final _unauthorized = throwsA(
  isA<api.ServerpodClientUnauthorized>().having(
    (e) => e.statusCode,
    'statusCode',
    401,
  ),
);

void main() {
  late generated.Serverpod pod;
  late Directory database;
  late Session session;
  late DateTime now;
  late Clock fakeClock;
  final clients = <api.Client>[];
  api.Client client([String? token]) {
    final result = api.Client('http://localhost:${pod.server.port}/');
    if (token != null) result.authKeyProvider = _Token(token);
    clients.add(result);
    return result;
  }

  Map<String, dynamic> claims(String nonce, String subject) => {
    'iss': 'https://kauth.kakao.com',
    'aud': 'test-native-key',
    'sub': subject,
    'nonce': nonce,
    'iat': now.millisecondsSinceEpoch ~/ 1000,
    'exp': now.add(const Duration(minutes: 10)).millisecondsSinceEpoch ~/ 1000,
  };

  Future<AuthSuccess> login(api.Client caller, String subject) async {
    final attempt = await caller.kakao.beginLogin(provider: 'kakao');
    final result = await caller.kakao.loginKakao(
      attemptId: attempt.attemptId,
      idToken: KakaoTestKeys.sign(claims(attempt.nonce, subject)),
    );
    return AuthSuccess.fromJson(result.toJson());
  }

  Future<void> start({
    String? audience = 'test-native-key',
    String? pepper = 'public-test-only',
    String? issuer = 'https://kauth.kakao.com',
    Future<Map<String, dynamic>> Function()? loadJwks,
    Future<void> Function(Session, UuidValue) cleanupSessions =
        removeOlderSessions,
  }) async {
    database = await Directory.systemTemp.createTemp('kakao-http-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        database: PostgresDatabaseConfig.embedded(
          dataPath: '${database.path}/pgdata',
          name: 'kakao_http',
          maxConnectionCount: 10,
        ),
      ),
    );
    configureAuth(
      pod,
      audience: audience,
      issuer: issuer,
      sessionPepper: pepper,
      clock: fakeClock,
      cleanupSessions: cleanupSessions,
      loadJwks: loadJwks ?? () async => KakaoTestKeys.jwks(),
    );
    await withClock(fakeClock, () => pod.start(runInGuardedZone: false));
    session = await pod.createSession();
  }

  setUp(() {
    now = DateTime.utc(2026, 10, 12);
    fakeClock = Clock(() => now);
  });
  tearDown(() async {
    for (final caller in clients) {
      caller.close();
    }
    clients.clear();
    await session.close();
    await pod.shutdown(exitProcess: false);
    await database.delete(recursive: true);
  });

  // First in this isolate: no previous AuthServices singleton may hide a
  // missing pepper. An explicit empty value cannot fall back to environment.
  test('missing pepper rejects login without issuing a session', () async {
    await start(pepper: '');
    await expectLater(
      client().kakao.loginKakao(
        attemptId: const Uuid().v4obj(),
        idToken: 'invalid',
      ),
      _loginError('configurationMissing'),
    );
    expect(await ServerSideSession.db.count(session), 0);
  });

  test('missing audience rejects begin and login without sessions', () async {
    await start(audience: '');
    final caller = client();
    await expectLater(
      caller.kakao.beginLogin(provider: 'kakao'),
      _loginError('configurationMissing'),
    );
    await expectLater(
      caller.kakao.loginKakao(
        attemptId: const Uuid().v4obj(),
        idToken: 'invalid',
      ),
      _loginError('configurationMissing'),
    );
    expect(await ServerSideSession.db.count(session), 0);
  });

  test('missing issuer rejects login without sessions', () async {
    await start(issuer: '');
    await expectLater(
      client().kakao.loginKakao(
        attemptId: const Uuid().v4obj(),
        idToken: 'invalid',
      ),
      _loginError('configurationMissing'),
    );
    expect(await ServerSideSession.db.count(session), 0);
  });

  test('JWKS outage is temporary and does not consume the attempt', () async {
    var unavailable = true;
    await start(
      loadJwks: () async {
        if (unavailable) throw const SocketException('injected outage');
        return KakaoTestKeys.jwks();
      },
    );
    final caller = client();
    final attempt = await caller.kakao.beginLogin(provider: 'kakao');
    final token = KakaoTestKeys.sign(claims(attempt.nonce, 'outage'));
    await expectLater(
      caller.kakao.loginKakao(attemptId: attempt.attemptId, idToken: token),
      _loginError('temporarilyUnavailable'),
    );
    expect(await ServerSideSession.db.count(session), 0);
    expect(
      (await LoginAttempt.db.findById(session, attempt.attemptId))!.consumedAt,
      isNull,
    );
    unavailable = false;
    final auth = await caller.kakao.loginKakao(
      attemptId: attempt.attemptId,
      idToken: token,
    );
    await client(auth.token).records.saveConfirmed(_record());
  });

  test(
    'cleanup failure preserves committed login and next login retries',
    () async {
      var failCleanup = true;
      await start(
        cleanupSessions: (session, owner) async {
          if (failCleanup) throw StateError('injected cleanup failure');
          await removeOlderSessions(session, owner);
        },
      );
      final first = await login(client(), 'cleanup');
      await client(first.token).records.saveConfirmed(_record());
      failCleanup = false;
      now = now.add(const Duration(seconds: 1));
      final second = await login(client(), 'cleanup');
      await client(second.token).records.saveConfirmed(_record());
      await expectLater(
        client(first.token).records.saveConfirmed(_record()),
        _unauthorized,
      );
      expect(await ServerSideSession.db.count(session), 1);
    },
  );

  group('real generated client HTTP authentication', () {
    setUp(start);

    test('identity FK rejects missing user and restricts deletion', () async {
      final auth = await login(client(), 'foreign-key');
      final identity = (await ExternalIdentity.db.find(session)).single;
      final violation = throwsA(
        isA<DatabaseQueryException>().having(
          (error) => error.code,
          'sqlstate',
          '23503',
        ),
      );
      await expectLater(
        ExternalIdentity.db.insertRow(
          session,
          identity.copyWith(
            id: null,
            subject: 'orphan',
            authUserId: const Uuid().v4obj(),
          ),
        ),
        violation,
      );
      await expectLater(
        AuthUser.db.deleteWhere(
          session,
          where: (t) => t.id.equals(auth.authUserId),
        ),
        violation,
      );
      expect(await ExternalIdentity.db.count(session), 1);
    });

    test(
      'stale attempts delete only beyond expiry retention boundary',
      () async {
        final boundary = now.subtract(expiredAttemptRetention);
        for (final expiry in [
          boundary.subtract(const Duration(microseconds: 1)),
          boundary,
          now,
          now.add(const Duration(minutes: 5)),
        ]) {
          await LoginAttempt.db.insertRow(
            session,
            LoginAttempt(nonceHash: 'test-digest', expiresAt: expiry),
          );
        }
        expect(await deleteStaleLoginAttempts(session, clock: fakeClock), 1);
        expect(await LoginAttempt.db.count(session), 3);
        expect(await deleteStaleLoginAttempts(session, clock: fakeClock), 0);
        now = now.add(const Duration(microseconds: 1));
        expect(await deleteStaleLoginAttempts(session, clock: fakeClock), 1);
      },
    );

    test('authenticated HTTP upload rejects location coordinates', () async {
      // Given.
      final auth = await login(client(), 'location-rejected');
      final input = _record();
      // When.
      await expectLater(
        client(auth.token).records.saveConfirmed(
          input.copyWith(
            routePoints: [
              api.RoutePoint(
                recordedAt: input.startedAt,
                latitude: 37.5,
                longitude: 127,
              ),
            ],
          ),
        ),
        throwsA(
          isA<api.RecordException>().having(
            (e) => e.code,
            'code',
            'invalidRoute',
          ),
        ),
      );
      // Then.
      expect(await StoredGpsRecord.db.count(session), 0);
    });

    test('valid signed token saves and queries owner records', () async {
      final auth = await login(client(), 'valid');
      final owner = client(auth.token);
      final input = _record();
      final receipt = await owner.records.saveConfirmed(input);
      final saved = await owner.records.getMine(receipt.recordId);
      expect(saved.payload.toJson(), input.toJson());
      expect(await StoredGpsRecord.db.count(session), 1);
      expect(await AuthUser.db.count(session), 1);
      expect(await ExternalIdentity.db.count(session), 1);
      final row = (await ServerSideSession.db.find(session)).single;
      expect(row.authUserId, auth.authUserId);
      expect(row.expiresAt, isNull);
      expect(row.expireAfterUnusedFor, const Duration(days: 90));
    });

    for (final field in ['iss', 'aud', 'exp', 'nonce', 'kid', 'alg']) {
      test('rejects invalid $field without a user or session', () async {
        final caller = client();
        final attempt = await caller.kakao.beginLogin(provider: 'kakao');
        final payload = claims(attempt.nonce, 'bad-$field');
        if (['iss', 'aud', 'nonce'].contains(field)) payload[field] = 'wrong';
        if (field == 'exp') {
          payload[field] =
              now
                  .subtract(const Duration(seconds: 60))
                  .millisecondsSinceEpoch ~/
              1000;
        }
        final token = KakaoTestKeys.sign(
          payload,
          header: field == 'kid' ? {'kid': 'unknown'} : null,
          algorithm: field == 'alg' ? JWTAlgorithm.RS512 : JWTAlgorithm.RS256,
        );
        await expectLater(
          caller.kakao.loginKakao(attemptId: attempt.attemptId, idToken: token),
          _loginError('invalidToken'),
        );
        expect(await ServerSideSession.db.count(session), 0);
        expect(await AuthUser.db.count(session), 0);
        expect(
          (await LoginAttempt.db.findById(
            session,
            attempt.attemptId,
          ))!.consumedAt,
          isNull,
        );
      });
    }

    test(
      'attempt can only be consumed once including concurrent reuse',
      () async {
        final caller = client();
        final attempt = await caller.kakao.beginLogin(provider: 'kakao');
        final token = KakaoTestKeys.sign(claims(attempt.nonce, 'reuse'));
        final results = await Future.wait(
          List.generate(2, (_) async {
            try {
              return await caller.kakao.loginKakao(
                attemptId: attempt.attemptId,
                idToken: token,
              );
            } on api.LoginException catch (e) {
              return e;
            }
          }),
        );
        expect(
          results.whereType<api.LoginException>().single.code,
          'invalidAttempt',
        );
        expect(await ServerSideSession.db.count(session), 1);
        await expectLater(
          caller.kakao.loginKakao(attemptId: attempt.attemptId, idToken: token),
          _loginError('invalidAttempt'),
        );
        expect(await ServerSideSession.db.count(session), 1);
      },
    );

    test('expired attempt rejects otherwise valid token', () async {
      final caller = client();
      final attempt = await caller.kakao.beginLogin(provider: 'kakao');
      now = attempt.expiresAt;
      await expectLater(
        caller.kakao.loginKakao(
          attemptId: attempt.attemptId,
          idToken: KakaoTestKeys.sign(claims(attempt.nonce, 'expired')),
        ),
        _loginError('invalidAttempt'),
      );
      expect(await ServerSideSession.db.count(session), 0);
    });

    test(
      'sequential login revokes old token and keeps latest session',
      () async {
        final first = await login(client(), 'sequential');
        now = now.add(const Duration(seconds: 1));
        final second = await login(client(), 'sequential');
        await expectLater(
          client(first.token).records.saveConfirmed(_record()),
          _unauthorized,
        );
        await client(second.token).records.saveConfirmed(_record());
        expect(await ServerSideSession.db.count(session), 1);
        expect(first.authUserId, second.authUserId);
      },
    );

    test(
      'concurrent first login has one identity user and max UUID session',
      () async {
        final results = await Future.wait([
          login(client(), 'concurrent'),
          login(client(), 'concurrent'),
        ]);
        expect(results.first.authUserId, results.last.authUserId);
        expect(await AuthUser.db.count(session), 1);
        expect(await ExternalIdentity.db.count(session), 1);
        final row = (await ServerSideSession.db.find(session)).single;
        final tokens = results.map((e) => e.token).toList();
        // Session keys encode the session ID; inspect real returned IDs rather
        // than assuming HTTP response order equals database creation order.
        String sessionId(String token) => UuidValue.fromByteList(
          base64Url.decode(token).sublist(3, 19),
        ).toString();
        final ids = tokens.map(sessionId).toList()..sort();
        expect(row.id.toString(), ids.last);
        for (final token in tokens) {
          if (sessionId(token) == row.id.toString()) {
            await client(token).records.saveConfirmed(_record());
          } else {
            await expectLater(
              client(token).records.saveConfirmed(_record()),
              _unauthorized,
            );
          }
        }
      },
    );

    test(
      'late cleanup preserves newer rows and equal-time UUID tie-break',
      () async {
        await login(client(), 'late');
        final latest = (await ServerSideSession.db.find(session)).single;
        await ServerSideSession.db.deleteWhere(
          session,
          where: (t) => t.authUserId.equals(latest.authUserId),
        );
        final low = UuidValue.fromString(
          '00000000-0000-4000-8000-000000000001',
        );
        final high = UuidValue.fromString(
          'ffffffff-ffff-4fff-bfff-ffffffffffff',
        );
        await ServerSideSession.db.insertRow(
          session,
          latest.copyWith(id: high),
        );
        // Model an older login that commits after the newer login's cleanup.
        await ServerSideSession.db.insertRow(
          session,
          latest.copyWith(
            id: const Uuid().v4obj(),
            createdAt: now.subtract(const Duration(seconds: 1)),
          ),
        );
        await ServerSideSession.db.insertRow(session, latest.copyWith(id: low));
        await removeOlderSessions(session, latest.authUserId);
        expect((await ServerSideSession.db.find(session)).single.id, high);
        await removeOlderSessions(session, latest.authUserId);
        expect((await ServerSideSession.db.find(session)).single.id, high);
      },
    );

    test(
      'anonymous and damaged tokens are 401; other owner is notFound',
      () async {
        final owner = await login(client(), 'owner');
        final other = await login(client(), 'other');
        final receipt = await client(
          owner.token,
        ).records.saveConfirmed(_record());
        for (final caller in [client(), client('${owner.token}damaged')]) {
          await expectLater(
            caller.records.saveConfirmed(_record()),
            _unauthorized,
          );
          await expectLater(
            caller.records.getMine(receipt.recordId),
            _unauthorized,
          );
        }
        await expectLater(
          client(other.token).records.getMine(receipt.recordId),
          throwsA(
            isA<api.RecordException>().having(
              (e) => e.code,
              'code',
              'notFound',
            ),
          ),
        );
      },
    );

    test('idle past 90 days is rejected with fake server clock', () async {
      final auth = await login(client(), 'idle');
      now = now.add(const Duration(days: 90, microseconds: 1));
      await expectLater(
        client(auth.token).records.saveConfirmed(_record()),
        _unauthorized,
      );
    });

    test(
      'activity renews idle deadline and no absolute expiry exists',
      () async {
        final auth = await login(client(), 'active');
        final owner = client(auth.token);
        for (var period = 0; period < 5; period++) {
          now = now.add(const Duration(days: 89));
          await owner.records.saveConfirmed(_record());
          final row = (await ServerSideSession.db.find(session)).single;
          expect(row.lastUsedAt, now);
          expect(row.expiresAt, isNull);
        }
        now = now.add(const Duration(days: 90, microseconds: 1));
        await expectLater(
          owner.records.saveConfirmed(_record()),
          _unauthorized,
        );
      },
    );
  });
}
