import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/auth/kakao_provider.dart';
import 'package:balmatchum_server/src/auth/social_auth.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as idp;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_auth_idp_server/providers/apple.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:test/test.dart';

import '../test_utils/kakao_test_keys.dart';
import '../test_utils/social_test_config.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.token);
  final String token;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $token';
}

const _bound = Duration(seconds: 10);
const _picture = 'https://example.test/picture.png';
// A valid 1x1 PNG, so an unblocked SDK import would really store a file.
const _png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

void main() {
  late generated.Serverpod pod;
  late Session admin;
  late Directory directory;
  final clients = <api.Client>[];
  var cleanupCalls = 0;
  final committedCounts = <int>[];
  var cleanupFails = false;
  Completer<void>? cleanupEntered;
  Completer<void>? releaseCleanup;
  var revokeFails = false;
  var stillValid = false;
  var revokeCalls = 0;
  var exchanges = 0;
  final revoked = <String>{};
  final seenClientIds = <String>[];
  var pictureRequests = 0;

  String token(
    String provider,
    String subject, {
    String? audience,
    Map<String, Object?> claims = const {},
  }) {
    final now = DateTime.now().toUtc();
    return KakaoTestKeys.sign({
      'iss': provider == 'google'
          ? 'https://accounts.google.com'
          : 'https://appleid.apple.com',
      'aud':
          audience ??
          (provider == 'google' ? 'test-google-client' : 'test.apple.bundle'),
      'sub': subject,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      if (provider == 'google') 'email': 'same@example.test',
      if (provider == 'google') 'email_verified': false,
      ...claims,
    });
  }

  Future<http.Response> external(http.Request request) async {
    if (request.url.toString() ==
            'https://www.googleapis.com/oauth2/v3/certs' ||
        request.url.toString() == 'https://appleid.apple.com/auth/keys') {
      return http.Response(jsonEncode(KakaoTestKeys.jwks()), 200);
    }
    if (request.url.toString() == _picture) {
      pictureRequests++;
      return http.Response.bytes(base64Decode(_png), 200);
    }
    final fields = request.method == 'POST'
        ? request.bodyFields
        : <String, String>{};
    if (request.url.toString() == 'https://oauth2.googleapis.com/token') {
      expect(fields['code_verifier'], 'test-verifier');
      expect(fields['redirect_uri'], 'https://example.test/callback');
      expect(fields['client_id'], 'test-google-client');
      return http.Response(
        jsonEncode({
          'id_token': token('google', fields['code']!),
          'access_token': fields['code'],
        }),
        200,
      );
    }
    if (request.url.toString() ==
        'https://www.googleapis.com/oauth2/v3/userinfo') {
      return http.Response(
        jsonEncode({
          'sub': request.headers['Authorization']!.substring(7),
        }),
        200,
      );
    }
    if (request.url.toString() == 'https://appleid.apple.com/auth/token') {
      seenClientIds.add(fields['client_id']!);
      if (fields['grant_type'] == 'authorization_code') {
        exchanges++;
        return http.Response(
          jsonEncode({
            'refresh_token': 'refresh-${fields['code']}',
            'access_token': 'public-test-access',
            'id_token': token('apple', fields['code']!),
            'expires_in': 3600,
          }),
          200,
        );
      }
      if (!stillValid && revoked.contains(fields['refresh_token'])) {
        return http.Response('{"error":"invalid_grant"}', 400);
      }
      return http.Response(
        jsonEncode({
          'access_token': 'still-valid',
          'id_token': 'still-valid',
          'expires_in': 3600,
        }),
        200,
      );
    }
    if (request.url.toString() == 'https://appleid.apple.com/auth/revoke') {
      revokeCalls++;
      seenClientIds.add(fields['client_id']!);
      expect(fields['token_type_hint'], 'refresh_token');
      if (revokeFails) return http.Response('injected private response', 503);
      revoked.add(fields['token']!);
      return http.Response('', 200);
    }
    throw StateError('Unexpected external request: ${request.url}');
  }

  api.Client client([String? token]) {
    final client = api.Client('http://localhost:${pod.server.port}/');
    if (token != null) client.authKeyProvider = _Token(token);
    clients.add(client);
    return client;
  }

  Future<void> start({
    required bool configured,
    String pepper = 'test-social-pepper',
  }) async {
    directory = await Directory.systemTemp.createTemp('social-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        database: PostgresDatabaseConfig.embedded(
          dataPath: '${directory.path}/pgdata',
          name: 'social_test',
          maxConnectionCount: 10,
        ),
      ),
    );
    configureAuth(
      pod,
      sessionPepper: pepper,
      providerPassword: (key) => configured ? socialTestPasswords()[key] : null,
      cleanupSessions: (session, owner) async {
        cleanupCalls++;
        // Independent session sees committed SDK rows before cleanup runs.
        committedCounts.add(
          await ServerSideSession.db.count(
            admin,
            where: (t) => t.authUserId.equals(owner),
          ),
        );
        if (cleanupFails) throw StateError('injected cleanup failure');
        final entered = cleanupEntered;
        final release = releaseCleanup;
        if (entered != null && !entered.isCompleted) {
          entered.complete();
          await release!.future.timeout(_bound);
        }
        await removeOlderSessions(session, owner);
      },
    );
    // Only outbound transport is replaced. The real SDK verifies signatures,
    // creates accounts/profiles, commits tokens, and runs endpoint cleanup.
    await http.runWithClient(
      () => pod.start(runInGuardedZone: false),
      () => MockClient(external),
    );
    admin = await pod.createSession(enableLogging: false);
  }

  Future<void> stop() async {
    for (final caller in clients) {
      caller.close();
    }
    clients.clear();
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  }

  Future<AuthSuccess> google(String subject, {bool code = false}) async {
    final result = code
        ? await client().googleIdp.loginWithCode(
            code: subject,
            codeVerifier: 'test-verifier',
            redirectUri: 'https://example.test/callback',
          )
        : await client().googleIdp.login(
            idToken: token('google', subject),
            accessToken: null,
          );
    return AuthSuccess.fromJson(result.toJson());
  }

  Future<AuthSuccess> apple(String subject, {bool native = true}) async {
    final result = await client().appleIdp.login(
      identityToken: token(
        'apple',
        subject,
        audience: native ? 'test.apple.bundle' : 'test.apple.service',
      ),
      authorizationCode: subject,
      isNativeApplePlatformSignIn: native,
    );
    return AuthSuccess.fromJson(result.toJson());
  }

  Future<void> valid(String value, bool expected) async {
    final check = await pod.createSession(enableLogging: false);
    try {
      expect(
        await AuthServices.instance.authenticationHandler(check, value),
        expected ? isNotNull : isNull,
      );
    } finally {
      await check.close();
    }
  }

  final missing = throwsA(
    isA<api.LoginException>().having(
      (e) => e.code,
      'code',
      'configurationMissing',
    ),
  );

  for (final pepper in ['', 'test-social-pepper']) {
    group('absent configuration with pepper=${pepper.isNotEmpty}', () {
      setUpAll(() => start(configured: false, pepper: pepper));
      tearDownAll(stop);
      test(
        'all generated provider APIs fail closed and report disabled',
        () async {
          final caller = client();
          expect(await caller.googleIdp.isConfigured(), false);
          expect(await caller.appleIdp.isConfigured(), false);
          await expectLater(
            caller.googleIdp.login(idToken: 'invalid', accessToken: null),
            missing,
          );
          await expectLater(
            caller.googleIdp.loginWithCode(
              code: 'invalid',
              codeVerifier: 'invalid',
              redirectUri: 'invalid',
            ),
            missing,
          );
          await expectLater(
            caller.appleIdp.login(
              identityToken: 'invalid',
              authorizationCode: 'invalid',
              isNativeApplePlatformSignIn: true,
            ),
            missing,
          );
          await expectLater(caller.googleIdp.hasAccount(), missing);
          await expectLater(caller.appleIdp.hasAccount(), missing);
          expect(await AuthUser.db.count(admin), 0);
          expect(await ServerSideSession.db.count(admin), 0);
        },
      );
    });
  }

  group('real SDK providers with deterministic external transport', () {
    setUpAll(() => start(configured: true));
    tearDownAll(stop);

    test('invalid tokens cannot create accounts or sessions', () async {
      expect(await client().googleIdp.isConfigured(), true);
      expect(await client().appleIdp.isConfigured(), true);
      for (final provider in ['google', 'apple']) {
        for (final value in [
          'invalid',
          token(provider, 'bad-audience', audience: 'wrong'),
        ]) {
          await expectLater(
            provider == 'google'
                ? client().googleIdp.login(idToken: value, accessToken: null)
                : client().appleIdp.login(
                    identityToken: value,
                    authorizationCode: 'bad',
                    isNativeApplePlatformSignIn: true,
                  ),
            provider == 'google'
                ? throwsA(isA<idp.GoogleIdTokenVerificationException>())
                : throwsA(isA<api.ServerpodClientInternalServerError>()),
          );
        }
      }
      expect(await AuthUser.db.count(admin), 0);
      expect(await GoogleAccount.db.count(admin), 0);
      expect(await AppleAccount.db.count(admin), 0);
      expect(await ServerSideSession.db.count(admin), 0);
    });

    test('no names required and same email never links identities', () async {
      final first = await google('distinct-one');
      final second = await google('distinct-two');
      expect(first.authUserId, isNot(second.authUserId));
      final profile = await UserProfile.db.findFirstRow(
        admin,
        where: (t) => t.authUserId.equals(first.authUserId),
      );
      expect(profile!.fullName, isNull);
      expect(await client(first.token).googleIdp.hasAccount(), true);
      expect(await client(first.token).appleIdp.hasAccount(), false);
    });

    test('provider names and pictures are never stored', () async {
      final claims = {
        'name': 'Real Name',
        'given_name': 'Real',
        'picture': _picture,
      };
      final storedFiles = await admin.db.unsafeQuery(
        'SELECT count(*) FROM serverpod_cloud_storage',
      );
      // The second login takes the SDK's returning-user picture path.
      for (var i = 0; i < 2; i++) {
        await client().googleIdp.login(
          idToken: token('google', 'with-profile', claims: claims),
          accessToken: null,
        );
      }
      final appleResult = await client().appleIdp.login(
        identityToken: token('apple', 'apple-with-name'),
        authorizationCode: 'apple-with-name',
        isNativeApplePlatformSignIn: true,
        firstName: 'Real',
        lastName: 'Name',
      );
      final appleUser = AuthSuccess.fromJson(appleResult.toJson()).authUserId;
      final googleUser = (await GoogleAccount.db.findFirstRow(
        admin,
        where: (t) => t.userIdentifier.equals('with-profile'),
      ))!.authUserId;
      for (final owner in [googleUser, appleUser]) {
        final profile = await UserProfile.db.findFirstRow(
          admin,
          where: (t) => t.authUserId.equals(owner),
        );
        expect(profile!.fullName, isNull);
        expect(profile.userName, isNull);
        expect(profile.imageId, isNull);
      }
      final appleAccount = await AppleAccount.db.findFirstRow(
        admin,
        where: (t) => t.authUserId.equals(appleUser),
      );
      expect(appleAccount!.firstName, isNull);
      expect(appleAccount.lastName, isNull);
      expect(pictureRequests, 0);
      expect(await UserProfileImage.db.count(admin), 0);
      expect(
        (await admin.db.unsafeQuery(
          'SELECT count(*) FROM serverpod_cloud_storage',
        )).single.single,
        storedFiles.single.single,
      );
    });

    for (final method in ['google', 'googleCode', 'apple']) {
      test(
        '$method cleans every returning login and retains real SDK session policy',
        () async {
          Future<AuthSuccess> login() => method == 'apple'
              ? apple(method)
              : google(method, code: method == 'googleCode');
          final before = cleanupCalls;
          final exchangesBefore = exchanges;
          final first = await login();
          final second = await login();
          expect(cleanupCalls - before, 2);
          expect(committedCounts.skip(before), everyElement(greaterThan(0)));
          expect(first.authUserId, second.authUserId);
          final rows = await ServerSideSession.db.find(
            admin,
            where: (t) => t.authUserId.equals(first.authUserId),
          );
          expect(rows, hasLength(1));
          expect(rows.single.expiresAt, isNull);
          expect(rows.single.expireAfterUnusedFor, const Duration(days: 90));
          await valid(first.token, false);
          await valid(second.token, true);
          if (method == 'apple') expect(exchanges - exchangesBefore, 1);
        },
      );
    }

    test(
      'cross-method sessions are removed, not only Google sessions',
      () async {
        final first = await google('cross-method');
        final old = await AuthServices.instance.tokenManager.issueToken(
          admin,
          authUserId: first.authUserId,
          method: 'kakao',
        );
        final other = await apple('unrelated');
        final newest = await google('cross-method', code: true);
        await valid(first.token, false);
        await valid(old.token, false);
        await valid(newest.token, true);
        await valid(other.token, true);
      },
    );

    test(
      'cleanup failure preserves committed login; next login retries',
      () async {
        cleanupFails = true;
        late AuthSuccess first;
        late AuthSuccess second;
        try {
          first = await google('cleanup-failure');
          second = await google('cleanup-failure', code: true);
          await valid(first.token, true);
          await valid(second.token, true);
        } finally {
          cleanupFails = false;
        }
        final latest = await google('cleanup-failure');
        await valid(first.token, false);
        await valid(second.token, false);
        await valid(latest.token, true);
      },
    );

    test('late cleanup cannot revoke a newer committed login', () async {
      final previous = await google('overlap');
      cleanupEntered = Completer<void>();
      releaseCleanup = Completer<void>();
      final older = google('overlap');
      await cleanupEntered!.future.timeout(_bound);
      try {
        // The documented non-atomic window is observable, not assumed away.
        expect(
          await ServerSideSession.db.count(
            admin,
            where: (t) => t.authUserId.equals(previous.authUserId),
          ),
          2,
        );
        await valid(previous.token, true);
        final newer = await google('overlap', code: true);
        releaseCleanup!.complete();
        final old = await older.timeout(_bound);
        await valid(previous.token, false);
        await valid(old.token, false);
        await valid(newer.token, true);
      } finally {
        if (!releaseCleanup!.isCompleted) releaseCleanup!.complete();
        cleanupEntered = null;
        releaseCleanup = null;
      }
    });

    test(
      'pod configuration guard does not leak a stale global provider',
      () async {
        final original = socialAuthSettings[pod]!;
        socialAuthSettings[pod] = SocialAuthSettings(
          google: original.google,
          apple: original.apple,
          sessionsEnabled: false,
        );
        try {
          expect(await client().googleIdp.isConfigured(), false);
          await expectLater(google('disabled'), missing);
          await expectLater(apple('disabled'), missing);
        } finally {
          socialAuthSettings[pod] = original;
        }
      },
    );

    for (final native in [true, false]) {
      test(
        'Apple deletion revokes persisted $native token then cascades',
        () async {
          final auth = await apple('delete-$native', native: native);
          final caller = client(auth.token);
          final count = revokeCalls;
          await caller.account.deleteAccount();
          expect(revokeCalls, count + 1);
          expect(
            seenClientIds.last,
            native ? 'test.apple.bundle' : 'test.apple.service',
          );
          expect(
            await AppleAccount.db.count(
              admin,
              where: (t) => t.authUserId.equals(auth.authUserId),
            ),
            0,
          );
          expect(await AuthUser.db.findById(admin, auth.authUserId), isNull);
          await valid(auth.token, false);
        },
      );
    }

    test(
      'Apple revoke failure and false success preserve local account/token',
      () async {
        final auth = await apple('failed-revoke');
        final caller = client(auth.token);
        for (final transportFails in [true, false]) {
          revokeFails = transportFails;
          stillValid = !transportFails;
          try {
            await expectLater(
              caller.account.deleteAccount(),
              throwsA(
                isA<api.LoginException>().having(
                  (e) => e.code,
                  'code',
                  'appleRevocationFailed',
                ),
              ),
            );
            expect(
              await AppleAccount.db.count(
                admin,
                where: (t) => t.authUserId.equals(auth.authUserId),
              ),
              1,
            );
            await valid(auth.token, true);
          } finally {
            revokeFails = false;
            stillValid = false;
          }
        }
        await caller.account.deleteAccount();
        await valid(auth.token, false);
      },
    );

    test(
      'DB rollback after external revoke retains token for idempotent retry',
      () async {
        final auth = await apple('db-rollback');
        await admin.db.unsafeExecute(
          "CREATE FUNCTION reject_social_delete() RETURNS trigger LANGUAGE plpgsql AS 'BEGIN RAISE EXCEPTION ''test deletion failure''; END'",
        );
        await admin.db.unsafeExecute(
          'CREATE TRIGGER reject_social_delete BEFORE DELETE ON serverpod_auth_core_user FOR EACH ROW EXECUTE FUNCTION reject_social_delete()',
        );
        try {
          await expectLater(
            client(auth.token).account.deleteAccount(),
            throwsA(isA<api.ServerpodClientInternalServerError>()),
          );
          expect(revoked, contains('refresh-db-rollback'));
          final account = await AppleAccount.db.findFirstRow(
            admin,
            where: (t) => t.authUserId.equals(auth.authUserId),
          );
          expect(account!.refreshToken, 'refresh-db-rollback');
          await valid(auth.token, true);
        } finally {
          await admin.db.unsafeExecute(
            'DROP TRIGGER reject_social_delete ON serverpod_auth_core_user',
          );
          await admin.db.unsafeExecute('DROP FUNCTION reject_social_delete()');
        }
        final count = revokeCalls;
        await client(auth.token).account.deleteAccount();
        expect(revokeCalls, count + 1);
        await valid(auth.token, false);
      },
    );
  });
}
