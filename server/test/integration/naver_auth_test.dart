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
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../test_utils/kakao_test_keys.dart';
import '../test_utils/social_test_config.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.token);
  final String token;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $token';
}

const _verifier = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFG';
const _redirect = 'https://example.test/naver/callback';
const _bound = Duration(seconds: 10);
final _challenge = base64UrlEncode(
  sha256.convert(ascii.encode(_verifier)).bytes,
).replaceAll('=', '');

Matcher _error(String code) => throwsA(
  isA<api.LoginException>().having((e) => e.code, 'code', code),
);
final _unauthorized = throwsA(isA<api.ServerpodClientUnauthorized>());

void main() {
  late generated.Serverpod pod;
  late Session admin;
  late Directory database;
  late DateTime now;
  late Clock clock;
  final clients = <api.Client>[];
  final claimsByCode = <String, Map<String, dynamic>>{};
  final revoked = <String>{};
  final revokeStatuses = <String, int>{};
  final calls = <String>[];
  Map<String, dynamic>? header;
  var exchangeStatus = 200;
  var jwksStatus = 200;
  var revokeStatus = 200;
  var missingIdToken = false;
  var missingRefreshToken = false;
  var forged = false;
  var cleanupFails = false;
  var exchangeCount = 0;
  var revokeCount = 0;
  Completer<void>? exchangeEntered;
  Completer<void>? releaseExchange;
  Completer<void>? revokeEntered;
  Completer<void>? releaseRevoke;

  Map<String, String> passwords() => {
    ...socialTestPasswords(),
    'naverClientId': 'test-naver-client',
    'naverClientSecret': 'public-test-secret',
    'naverRedirectUri': _redirect,
  };

  Future<http.Response> external(http.Request request) async {
    calls.add(request.url.toString());
    if (request.url.toString() == 'https://nid.naver.com/oauth2/jwks' ||
        request.url.toString() ==
            'https://www.googleapis.com/oauth2/v3/certs' ||
        request.url.toString() == 'https://appleid.apple.com/auth/keys') {
      expect(request.method, 'GET');
      return http.Response(jsonEncode(KakaoTestKeys.jwks()), jwksStatus);
    }
    final fields = request.bodyFields;
    if (request.url.toString() == 'https://nid.naver.com/oauth2/token') {
      exchangeCount++;
      expect(request.method, 'POST');
      expect(request.followRedirects, isFalse);
      expect(fields.keys.toSet(), {
        'grant_type',
        'client_id',
        'client_secret',
        'redirect_uri',
        'code',
        'code_verifier',
      });
      expect(fields['grant_type'], 'authorization_code');
      expect(fields['client_id'], 'test-naver-client');
      expect(fields['client_secret'], 'public-test-secret');
      expect(fields['redirect_uri'], _redirect);
      expect(fields['code_verifier'], _verifier);
      if (exchangeEntered != null && !exchangeEntered!.isCompleted) {
        exchangeEntered!.complete();
        await releaseExchange!.future.timeout(_bound);
      }
      if (exchangeStatus != 200) {
        return http.Response(
          'private-token-response',
          exchangeStatus,
          headers: {'location': 'https://attacker.test/steal'},
        );
      }
      final claims = claimsByCode[fields['code']]!;
      final signed = KakaoTestKeys.sign(
        claims,
        header: header,
        algorithm: forged ? JWTAlgorithm.HS256 : JWTAlgorithm.RS256,
        key: forged ? SecretKey('not-the-private-key') : null,
      );
      return http.Response(
        jsonEncode({
          if (!missingIdToken) 'id_token': signed,
          if (!missingRefreshToken)
            'refresh_token': 'refresh-${fields['code']}',
          'access_token': 'unused-access-token',
          'token_type': 'Bearer',
        }),
        200,
      );
    }
    if (request.url.toString() == 'https://nid.naver.com/oauth2/revoke') {
      revokeCount++;
      expect(request.method, 'POST');
      expect(request.followRedirects, isFalse);
      expect(fields['client_id'], 'test-naver-client');
      expect(fields['client_secret'], 'public-test-secret');
      expect(fields['token_type_hint'], 'refresh_token');
      if (revokeEntered != null && !revokeEntered!.isCompleted) {
        revokeEntered!.complete();
        await releaseRevoke!.future.timeout(_bound);
      }
      final status = revokeStatuses[fields['token']] ?? revokeStatus;
      if (status != 200) {
        return http.Response('private-revocation-response', status);
      }
      revoked.add(fields['token']!);
      return http.Response('', 200);
    }
    if (request.url.toString() == 'https://appleid.apple.com/auth/token') {
      return http.Response(
        jsonEncode({
          'id_token': KakaoTestKeys.sign({
            'iss': 'https://appleid.apple.com',
            'aud': 'test.apple.bundle',
            'sub': fields['code'],
            'iat': now.millisecondsSinceEpoch ~/ 1000,
            'exp':
                now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
                1000,
          }),
          'refresh_token': 'apple-test-refresh',
          'access_token': 'apple-test-access',
          'expires_in': 3600,
        }),
        200,
      );
    }
    throw StateError('Unexpected external request host/path');
  }

  api.Client client([String? token]) {
    final value = api.Client('http://localhost:${pod.server.port}/');
    if (token != null) value.authKeyProvider = _Token(token);
    clients.add(value);
    return value;
  }

  Future<void> start({
    bool configured = true,
    String pepper = 'naver-test-pepper',
  }) async {
    database = await Directory.systemTemp.createTemp('naver-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        database: PostgresDatabaseConfig.embedded(
          dataPath: '${database.path}/pgdata',
          name: 'naver_http',
          maxConnectionCount: 10,
        ),
      ),
    );
    configureAuth(
      pod,
      sessionPepper: pepper,
      audience: 'test-kakao-client',
      issuer: 'https://kauth.kakao.com',
      loadJwks: () async => KakaoTestKeys.jwks(),
      providerPassword: (key) => configured ? passwords()[key] : null,
      clock: clock,
      cleanupSessions: (session, owner) async {
        if (cleanupFails) throw StateError('injected cleanup failure');
        await removeOlderSessions(session, owner);
      },
    );
    await http.runWithClient(
      () => withClock(clock, () => pod.start(runInGuardedZone: false)),
      () => MockClient(external),
    );
    admin = await pod.createSession(enableLogging: false);
  }

  Future<api.NaverLoginChallenge> begin(
    api.Client caller,
    String code, {
    String subject = 'same-subject',
    Map<String, dynamic> changes = const {},
  }) async {
    final attempt = await caller.naver.beginLogin(codeChallenge: _challenge);
    final query = Uri.parse(attempt.authorizationUrl).queryParameters;
    claimsByCode[code] = {
      'iss': 'https://nid.naver.com',
      'aud': 'test-naver-client',
      'azp': 'test-naver-client',
      'sub': subject,
      'nonce': query['nonce'],
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp':
          now.add(const Duration(minutes: 10)).millisecondsSinceEpoch ~/ 1000,
      ...changes,
    };
    return attempt;
  }

  Future<AuthSuccess> complete(
    api.Client caller,
    api.NaverLoginChallenge attempt,
    String code,
  ) async => AuthSuccess.fromJson(
    (await caller.naver.completeLogin(
      attemptId: attempt.attemptId,
      code: code,
      state: attempt.state,
      codeVerifier: _verifier,
    )).toJson(),
  );

  Future<AuthSuccess> login(
    String code, {
    String subject = 'same-subject',
  }) async {
    final caller = client();
    return complete(caller, await begin(caller, code, subject: subject), code);
  }

  Future<void> noAccount() async {
    expect(await AuthUser.db.count(admin), 0);
    expect(await ServerSideSession.db.count(admin), 0);
    expect(await ExternalIdentity.db.count(admin), 0);
    expect(await NaverGrant.db.count(admin), 0);
  }

  setUp(() {
    now = DateTime.now().toUtc();
    clock = Clock(() => now);
    claimsByCode.clear();
    calls.clear();
    revoked.clear();
    revokeStatuses.clear();
    header = null;
    exchangeStatus = jwksStatus = revokeStatus = 200;
    missingIdToken = missingRefreshToken = forged = cleanupFails = false;
    exchangeCount = revokeCount = 0;
    exchangeEntered = releaseExchange = revokeEntered = releaseRevoke = null;
  });
  tearDown(() async {
    for (final caller in clients) {
      caller.close();
    }
    clients.clear();
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await database.delete(recursive: true);
  });

  for (final missing in ['provider', 'pepper']) {
    test('missing $missing is fail closed over actual HTTP', () async {
      await start(
        configured: missing != 'provider',
        pepper: missing == 'pepper' ? '' : 'public-test-pepper',
      );
      final caller = client();
      expect(await caller.naver.isConfigured(), isFalse);
      await expectLater(
        caller.naver.beginLogin(codeChallenge: _challenge),
        _error('configurationMissing'),
      );
      await expectLater(
        caller.naver.completeLogin(
          attemptId: const Uuid().v4obj(),
          code: 'x',
          state: 'x',
          codeVerifier: _verifier,
        ),
        _error('configurationMissing'),
      );
      await noAccount();
      expect(calls, isEmpty);
    });
  }

  group('generated HTTP with isolated PostgreSQL and real signatures', () {
    setUp(start);

    test(
      'begin pins URL, hashes secrets and issues 90 day server session',
      () async {
        final caller = client();
        expect(await caller.naver.isConfigured(), isTrue);
        final attempt = await begin(caller, 'valid');
        final url = Uri.parse(attempt.authorizationUrl);
        expect(
          '${url.scheme}://${url.host}${url.path}',
          'https://nid.naver.com/oauth2/authorize',
        );
        expect(url.queryParameters['scope'], 'openid');
        expect(url.queryParameters['redirect_uri'], _redirect);
        expect(url.queryParameters['code_challenge'], _challenge);
        expect(url.queryParameters['code_challenge_method'], 'S256');
        expect(url.queryParameters['state'], attempt.state);
        expect(url.queryParameters, isNot(contains('client_secret')));
        expect(url.queryParameters, isNot(contains('code_verifier')));
        final stored = (await NaverLoginAttempt.db.find(admin)).single;
        expect(
          stored.stateHash,
          sha256.convert(utf8.encode(attempt.state)).toString(),
        );
        expect(
          stored.nonceHash,
          sha256.convert(utf8.encode(url.queryParameters['nonce']!)).toString(),
        );
        expect(stored.expiresAt, now.add(const Duration(minutes: 5)));
        final auth = await complete(caller, attempt, 'valid');
        final row = (await ServerSideSession.db.find(admin)).single;
        expect(row.authUserId, auth.authUserId);
        expect(row.expiresAt, isNull);
        expect(row.expireAfterUnusedFor, const Duration(days: 90));
        expect(
          (await NaverGrant.db.find(admin)).single.refreshToken,
          'refresh-valid',
        );
        expect(
          (await ExternalIdentity.db.find(admin)).single.provider,
          'naver',
        );
        expect(
          calls.any((url) => url.contains('userinfo') || url.contains('/me')),
          isFalse,
        );
      },
    );

    test(
      'invalid S256, state and verifier never exchange or consume',
      () async {
        final caller = client();
        for (final challenge in [
          '',
          'short',
          '$_challenge=',
          '${'A' * 42}B',
        ]) {
          await expectLater(
            caller.naver.beginLogin(codeChallenge: challenge),
            _error('invalidAttempt'),
          );
        }
        final attempt = await begin(caller, 'bound');
        for (final (state, verifier) in [
          ('', _verifier),
          ('A' * 43, _verifier),
          (attempt.state, ''),
          (attempt.state, 'B' * 43),
          (attempt.state, 'A' * 129),
        ]) {
          await expectLater(
            caller.naver.completeLogin(
              attemptId: attempt.attemptId,
              code: 'bound',
              state: state,
              codeVerifier: verifier,
            ),
            _error('invalidAttempt'),
          );
        }
        expect(exchangeCount, 0);
        expect(
          (await NaverLoginAttempt.db.findById(
            admin,
            attempt.attemptId,
          ))!.consumedAt,
          isNull,
        );
        await complete(caller, attempt, 'bound');
      },
    );

    test('absent and expired attempts reject before any exchange', () async {
      final caller = client();
      final attempt = await begin(caller, 'expired');
      now = attempt.expiresAt;
      await expectLater(
        complete(caller, attempt, 'expired'),
        _error('invalidAttempt'),
      );
      await expectLater(
        caller.naver.completeLogin(
          attemptId: const Uuid().v4obj(),
          code: 'unknown',
          state: attempt.state,
          codeVerifier: _verifier,
        ),
        _error('invalidAttempt'),
      );
      expect(exchangeCount, 0);
      await noAccount();
    });

    test(
      'forged, missing and malformed claims fail without identities',
      () async {
        final caller = client();
        final changes = <Map<String, dynamic>>[
          {'iss': 'https://attacker.test'},
          {'iss': null},
          {'aud': 'another-client'},
          {'aud': null},
          {'azp': 'another-client'},
          {'nonce': 'wrong'},
          {'nonce': null},
          {'sub': ''},
          {'sub': null},
          {
            'exp':
                now
                    .subtract(const Duration(minutes: 2))
                    .millisecondsSinceEpoch ~/
                1000,
          },
          {'exp': null},
          {
            'iat':
                now.add(const Duration(minutes: 2)).millisecondsSinceEpoch ~/
                1000,
          },
          {'iat': null},
        ];
        for (var index = 0; index < changes.length; index++) {
          final code = 'bad-$index';
          final attempt = await begin(caller, code, changes: changes[index]);
          await expectLater(
            complete(caller, attempt, code),
            _error('invalidToken'),
          );
          await expectLater(
            complete(caller, attempt, code),
            _error('invalidAttempt'),
          );
        }
        forged = true;
        final forgedAttempt = await begin(caller, 'forged');
        await expectLater(
          complete(caller, forgedAttempt, 'forged'),
          _error('invalidToken'),
        );
        forged = false;
        header = {'kid': 'unknown', 'jku': 'https://attacker.test/jwks'};
        final unknown = await begin(caller, 'unknown-key');
        await expectLater(
          complete(caller, unknown, 'unknown-key'),
          _error('invalidToken'),
        );
        expect(calls.any((url) => url.contains('attacker')), isFalse);
        await noAccount();
      },
    );

    test(
      'missing ID or revocable refresh token is not profile authentication',
      () async {
        for (final missing in ['id', 'refresh']) {
          missingIdToken = missing == 'id';
          missingRefreshToken = missing == 'refresh';
          final caller = client();
          final attempt = await begin(caller, missing);
          await expectLater(
            complete(caller, attempt, missing),
            _error('invalidToken'),
          );
        }
        await noAccount();
      },
    );

    test('token from another attempt fails nonce binding', () async {
      final caller = client();
      final first = await begin(caller, 'first');
      await begin(caller, 'second');
      await expectLater(
        complete(caller, first, 'second'),
        _error('invalidToken'),
      );
      await noAccount();
    });

    test(
      'credential SQL failure is sanitized and cannot replay the code',
      () async {
        await admin.db.unsafeQuery(
          'ALTER TABLE naver_grant ADD CONSTRAINT test_secret_guard CHECK (false)',
        );
        final caller = client();
        final attempt = await begin(caller, 'private-credential-marker');
        await expectLater(
          complete(caller, attempt, 'private-credential-marker'),
          _error('temporarilyUnavailable'),
        );
        await expectLater(
          complete(caller, attempt, 'private-credential-marker'),
          _error('invalidAttempt'),
        );
        expect(exchangeCount, 1);
        await noAccount();
      },
    );

    test(
      'exchange errors and redirects consume once without leaking bodies',
      () async {
        for (final status in [400, 302, 503]) {
          exchangeStatus = status;
          final caller = client();
          final attempt = await begin(caller, '$status');
          await expectLater(
            complete(caller, attempt, '$status'),
            _error(status == 503 ? 'temporarilyUnavailable' : 'invalidToken'),
          );
          await expectLater(
            complete(caller, attempt, '$status'),
            _error('invalidAttempt'),
          );
        }
        expect(exchangeCount, 3);
        expect(
          calls.every((url) => url.startsWith('https://nid.naver.com/')),
          isTrue,
        );
        await noAccount();
      },
    );

    test('JWKS failure rejects and consumes code attempt', () async {
      jwksStatus = 503;
      final caller = client();
      final attempt = await begin(caller, 'outage');
      await expectLater(
        complete(caller, attempt, 'outage'),
        _error('temporarilyUnavailable'),
      );
      await expectLater(
        complete(caller, attempt, 'outage'),
        _error('invalidAttempt'),
      );
      await noAccount();
    });

    test('concurrent replay makes exactly one code exchange', () async {
      final caller = client();
      final attempt = await begin(caller, 'single');
      exchangeEntered = Completer<void>();
      releaseExchange = Completer<void>();
      final pending = complete(caller, attempt, 'single');
      await exchangeEntered!.future.timeout(_bound);
      await expectLater(
        complete(client(), attempt, 'single'),
        _error('invalidAttempt'),
      );
      releaseExchange!.complete();
      await pending;
      expect(exchangeCount, 1);
      expect(await ServerSideSession.db.count(admin), 1);
      await expectLater(
        complete(caller, attempt, 'single'),
        _error('invalidAttempt'),
      );
    });

    test(
      'same identity concurrent login converges and older session is revoked',
      () async {
        final results = await Future.wait([
          login('concurrent-a'),
          login('concurrent-b'),
        ]);
        expect(results.first.authUserId, results.last.authUserId);
        expect(await AuthUser.db.count(admin), 1);
        expect(await ExternalIdentity.db.count(admin), 1);
        expect(await NaverGrant.db.count(admin), 1);
        expect(await ServerSideSession.db.count(admin), 1);
        final current = (await ServerSideSession.db.find(admin)).single;
        String sessionId(String token) => UuidValue.fromByteList(
          base64Url.decode(token).sublist(3, 19),
        ).toString();
        expect(
          current.id.toString(),
          (results.map((e) => sessionId(e.token)).toList()..sort()).last,
        );
      },
    );

    test(
      'cleanup failure preserves success and subsequent login retries',
      () async {
        final first = await login('old');
        cleanupFails = true;
        now = now.add(const Duration(seconds: 1));
        final second = await login('middle');
        expect(second.authUserId, first.authUserId);
        expect(await ServerSideSession.db.count(admin), 2);
        cleanupFails = false;
        now = now.add(const Duration(seconds: 1));
        final third = await login('latest');
        expect(third.authUserId, first.authUserId);
        expect(await ServerSideSession.db.count(admin), 1);
        await expectLater(
          client(first.token).account.deleteAccount(),
          _unauthorized,
        );
        await expectLater(
          client(second.token).account.deleteAccount(),
          _unauthorized,
        );
      },
    );

    test('four providers and equal emails never link identities', () async {
      final caller = client();
      final attempt = await begin(
        caller,
        'naver',
        changes: {'email': 'same@example.test'},
      );
      final naver = await complete(caller, attempt, 'naver');
      final kakaoChallenge = await caller.kakao.beginLogin(provider: 'kakao');
      final kakao = await caller.kakao.loginKakao(
        attemptId: kakaoChallenge.attemptId,
        idToken: KakaoTestKeys.sign({
          ...claimsByCode['naver']!,
          'iss': 'https://kauth.kakao.com',
          'aud': 'test-kakao-client',
          'azp': 'test-kakao-client',
          'nonce': kakaoChallenge.nonce,
        }),
      );
      final google = await caller.googleIdp.login(
        idToken: KakaoTestKeys.sign({
          ...claimsByCode['naver']!,
          'iss': 'https://accounts.google.com',
          'aud': 'test-google-client',
          'azp': 'test-google-client',
          'email_verified': true,
        }),
        accessToken: null,
      );
      final apple = await caller.appleIdp.login(
        identityToken: KakaoTestKeys.sign({
          ...claimsByCode['naver']!,
          'iss': 'https://appleid.apple.com',
          'aud': 'test.apple.bundle',
          'azp': 'test.apple.bundle',
        }),
        authorizationCode: 'same-subject',
        isNativeApplePlatformSignIn: true,
      );
      expect({
        naver.authUserId,
        kakao.authUserId,
        google.authUserId,
        apple.authUserId,
      }, hasLength(4));
      expect(await AuthUser.db.count(admin), 4);
      await client(naver.token).account.deleteAccount();
      expect(await AuthUser.db.count(admin), 3);
      expect(await NaverGrant.db.count(admin), 0);
      expect(await ServerSideSession.db.count(admin), 3);
    });

    test(
      'returning login retains only the latest grant without unlinking',
      () async {
        // Given.
        final first = await login('latest-old');
        // When.
        final latest = await login('latest-new');
        // Then: revoking the old grant here would unlink the new login too.
        expect(latest.authUserId, first.authUserId);
        expect(
          (await NaverGrant.db.find(admin)).map((g) => g.refreshToken),
          ['refresh-latest-new'],
        );
        expect(revokeCount, 0);
      },
    );

    for (final newestFails in [false, true]) {
      test(
        'legacy grant deletion newest first fallback=$newestFails',
        () async {
          // Given: pre-fix accounts can still have multiple grants.
          final auth = await login('legacy-old');
          await NaverGrant.db.insertRow(
            admin,
            NaverGrant(
              authUserId: auth.authUserId,
              clientId: 'test-naver-client',
              refreshToken: 'legacy-newest',
            ),
          );
          if (newestFails) revokeStatuses['legacy-newest'] = 503;

          // When.
          await client(auth.token).account.deleteAccount();

          // Then: success unlinks the app, so no subsequent grant is queried.
          expect(revokeCount, newestFails ? 2 : 1);
          expect(revoked, {
            newestFails ? 'refresh-legacy-old' : 'legacy-newest',
          });
          await noAccount();
        },
      );
    }

    test('all legacy revocations failing preserve every local grant', () async {
      // Given.
      final auth = await login('legacy-preserved');
      await NaverGrant.db.insertRow(
        admin,
        NaverGrant(
          authUserId: auth.authUserId,
          clientId: 'test-naver-client',
          refreshToken: 'legacy-preserved-new',
        ),
      );
      revokeStatus = 503;
      // When.
      await expectLater(
        client(auth.token).account.deleteAccount(),
        _error('naverRevocationFailed'),
      );
      // Then.
      expect(await NaverGrant.db.count(admin), 2);
      expect(await AuthUser.db.count(admin), 1);
      expect(await ServerSideSession.db.count(admin), 1);
    });

    test('failed returning login preserves the previous grant', () async {
      // Given.
      await login('previous');
      await admin.db.unsafeExecute(
        'ALTER TABLE naver_grant ADD CONSTRAINT test_replacement_guard '
        'CHECK ("refreshToken" <> \'refresh-replacement\')',
      );
      // When.
      await expectLater(login('replacement'), _error('temporarilyUnavailable'));
      // Then: replacing the row is atomic with issuing the new server session.
      expect(
        (await NaverGrant.db.find(admin)).single.refreshToken,
        'refresh-previous',
      );
      expect(await ServerSideSession.db.count(admin), 1);
      expect(revokeCount, 0);
    });

    test(
      'stalled revocation exhausts one shared budget and keeps grants',
      () async {
        // Given: completion signals, not sleeps, hold the real HTTP transport.
        final auth = await login('bounded-old');
        await NaverGrant.db.insertRow(
          admin,
          NaverGrant(
            authUserId: auth.authUserId,
            clientId: 'test-naver-client',
            refreshToken: 'bounded-new',
          ),
        );
        revokeEntered = Completer<void>();
        releaseRevoke = Completer<void>();
        // When.
        final failed = expectLater(
          client(auth.token).account.deleteAccount().timeout(
            const Duration(seconds: 12),
          ),
          _error('naverRevocationFailed'),
        );
        await revokeEntered!.future.timeout(_bound);
        await failed;
        // Then: no fresh ten second budget for a second credential.
        releaseRevoke!.complete();
        expect(revokeCount, 1);
        expect(await NaverGrant.db.count(admin), 2);
        expect(await AuthUser.db.count(admin), 1);
        expect(await ServerSideSession.db.count(admin), 1);
      },
    );

    test(
      'deletion revokes latest grant, cascades and new login creates new identity',
      () async {
        final first = await login('grant-a');
        final second = await login('grant-b');
        final other = await login('other', subject: 'other');
        await client(second.token).account.deleteAccount();
        expect(revoked, {'refresh-grant-b'});
        expect(await NaverGrant.db.count(admin), 1);
        expect(await ExternalIdentity.db.count(admin), 1);
        expect((await AuthUser.db.find(admin)).single.id, other.authUserId);
        await expectLater(
          client(first.token).account.deleteAccount(),
          _unauthorized,
        );
        await expectLater(
          client(second.token).account.deleteAccount(),
          _unauthorized,
        );
        final recreated = await login('recreated');
        expect(recreated.authUserId, isNot(first.authUserId));
      },
    );

    test(
      'revocation failure preserves local account and allows retry',
      () async {
        final auth = await login('retry');
        revokeStatus = 503;
        await expectLater(
          client(auth.token).account.deleteAccount(),
          _error('naverRevocationFailed'),
        );
        expect(await AuthUser.db.count(admin), 1);
        expect(await NaverGrant.db.count(admin), 1);
        expect(await ServerSideSession.db.count(admin), 1);
        revokeStatus = 200;
        await client(auth.token).account.deleteAccount();
        expect(revokeCount, 2);
        await noAccount();
      },
    );

    test(
      'revocation holds account lock and DB rollback retains retry token',
      () async {
        final auth = await login('rollback');
        await admin.db.unsafeQuery(
          'CREATE TABLE naver_delete_guard (owner uuid REFERENCES serverpod_auth_core_user(id) ON DELETE RESTRICT)',
        );
        await admin.db.unsafeQuery(
          'INSERT INTO naver_delete_guard VALUES (CAST(@owner AS uuid))',
          parameters: QueryParameters.named({'owner': auth.authUserId.uuid}),
        );
        revokeEntered = Completer<void>();
        releaseRevoke = Completer<void>();
        final deleting = client(auth.token).account.deleteAccount();
        final failed = expectLater(
          deleting,
          throwsA(isA<api.ServerpodClientException>()),
        );
        await revokeEntered!.future.timeout(_bound);
        await expectLater(
          admin.db.transaction(
            (tx) => AuthUser.db.findFirstRow(
              admin,
              where: (t) => t.id.equals(auth.authUserId),
              transaction: tx,
              lockMode: LockMode.forUpdate,
              lockBehavior: LockBehavior.noWait,
            ),
          ),
          throwsA(
            isA<DatabaseQueryException>().having(
              (e) => e.code,
              'SQL state',
              '55P03',
            ),
          ),
        );
        releaseRevoke!.complete();
        await failed;
        expect(revoked, {'refresh-rollback'});
        expect(await NaverGrant.db.count(admin), 1);
        expect(await AuthUser.db.count(admin), 1);
        expect(await ServerSideSession.db.count(admin), 1);
        await admin.db.unsafeQuery('DROP TABLE naver_delete_guard');
        await client(auth.token).account.deleteAccount();
        await noAccount();
      },
    );

    test('expired attempts cleanup preserves one day boundary', () async {
      final caller = client();
      final attempt = await begin(caller, 'retention');
      now = attempt.expiresAt.add(expiredAttemptRetention);
      expect(await deleteStaleLoginAttempts(admin, clock: clock), 0);
      now = now.add(const Duration(microseconds: 1));
      expect(await deleteStaleLoginAttempts(admin, clock: clock), 1);
      expect(await NaverLoginAttempt.db.count(admin), 0);
    });

    test('90 day inactivity expires the Naver server session', () async {
      final auth = await login('idle');
      now = now.add(const Duration(days: 90, microseconds: 1));
      await expectLater(
        client(auth.token).account.deleteAccount(),
        _unauthorized,
      );
      expect(revokeCount, 0);
    });
  });
}
