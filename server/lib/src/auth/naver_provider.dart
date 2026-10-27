import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'kakao_provider.dart';
import 'naver_client.dart';
import 'oidc_token_verifier.dart';

/// Pod-local availability avoids stale process-global auth registries.
final naverSettings = Expando<NaverConfig>();

class NaverProvider implements IdentityProvider {
  NaverProvider({
    required this.tokenManager,
    required this.authUsers,
    required this.client,
    required this.verifier,
    required this.clock,
    required this.cleanupSessions,
  });

  static NaverProvider require(Session session) {
    if (naverSettings[session.serverpod] == null) {
      throw LoginException(code: 'configurationMissing');
    }
    return AuthServices.getIdentityProvider<NaverProvider>();
  }

  final TokenManager tokenManager;
  final AuthUsers authUsers;
  final NaverClient client;
  final OidcTokenVerifier verifier;
  final Clock clock;
  final Future<void> Function(Session, UuidValue) cleanupSessions;

  @override
  String get method => 'naver';

  Future<NaverLoginChallenge> beginLogin(
    Session session, {
    required String codeChallenge,
  }) async {
    // S256 is exactly 32 bytes encoded as canonical, unpadded base64url.
    if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(codeChallenge)) {
      throw LoginException(code: 'invalidAttempt');
    }
    try {
      base64Url.decode('$codeChallenge=');
    } on FormatException {
      // Dart also rejects nonzero padding bits; do not log parser input.
      throw LoginException(code: 'invalidAttempt');
    }
    final random = Random.secure();
    String secret() => base64UrlEncode(
      List.generate(32, (_) => random.nextInt(256)),
    ).replaceAll('=', '');
    final state = secret();
    final nonce = secret();
    final config = client.config;
    final expiresAt = clock.now().toUtc().add(const Duration(minutes: 5));
    final attempt = await NaverLoginAttempt.db.insertRow(
      session,
      NaverLoginAttempt(
        stateHash: _digest(state),
        nonceHash: _digest(nonce),
        codeChallenge: codeChallenge,
        clientId: config.clientId,
        redirectUri: config.redirectUri,
        expiresAt: expiresAt,
      ),
    );
    final authorization = Uri.parse('$naverIssuer/oauth2/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': config.clientId,
        'redirect_uri': config.redirectUri,
        'scope': 'openid',
        'state': state,
        'nonce': nonce,
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );
    return NaverLoginChallenge(
      attemptId: attempt.id!,
      authorizationUrl: authorization.toString(),
      state: state,
      redirectUri: config.redirectUri,
      expiresAt: expiresAt,
    );
  }

  Future<AuthSuccess> completeLogin(
    Session session, {
    required UuidValue attemptId,
    required String code,
    required String state,
    required String codeVerifier,
  }) async {
    // SQL logs include bound values, including refresh tokens on failed or slow
    // inserts. Use the existing billing credential-storage boundary.
    final db = await session.serverpod.createSession(enableLogging: false);
    final AuthSuccess success;
    try {
      success = await _completeLogin(
        db,
        attemptId: attemptId,
        code: code,
        state: state,
        codeVerifier: codeVerifier,
      );
    } on DatabaseQueryException {
      // PostgreSQL errors can contain complete failing rows. Never propagate.
      throw LoginException(code: 'temporarilyUnavailable');
    } finally {
      await db.close();
    }
    try {
      await cleanupSessions(session, success.authUserId);
    } catch (_) {
      session.log(
        'Post-commit session cleanup failed; retry on next login.',
        level: LogLevel.warning,
      );
    }
    return success;
  }

  Future<AuthSuccess> _completeLogin(
    Session session, {
    required UuidValue attemptId,
    required String code,
    required String state,
    required String codeVerifier,
  }) async {
    if (code.isEmpty ||
        code.length > 4096 ||
        !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(state) ||
        !RegExp(r'^[A-Za-z0-9._~-]{43,128}$').hasMatch(codeVerifier)) {
      throw LoginException(code: 'invalidAttempt');
    }
    final challenge = base64UrlEncode(
      sha256.convert(ascii.encode(codeVerifier)).bytes,
    ).replaceAll('=', '');
    // Commit consumption BEFORE external exchange. Neither a failed exchange
    // nor a later DB rollback can replay an authorization code.
    final consumed = await NaverLoginAttempt.db.updateWhere(
      session,
      columnValues: (t) => [t.consumedAt(clock.now().toUtc())],
      where: (t) =>
          t.id.equals(attemptId) &
          t.stateHash.equals(_digest(state)) &
          t.codeChallenge.equals(challenge) &
          t.clientId.equals(client.config.clientId) &
          t.redirectUri.equals(client.config.redirectUri) &
          t.consumedAt.equals(null) &
          (t.expiresAt > clock.now()),
    );
    if (consumed.isEmpty) throw LoginException(code: 'invalidAttempt');
    final tokens = await client.exchange(
      code: code,
      codeVerifier: codeVerifier,
    );
    final String subject;
    try {
      subject = await verifier.verify(
        tokens.idToken,
        nonceHash: consumed.single.nonceHash,
      );
    } on JwksUnavailableException {
      throw LoginException(code: 'temporarilyUnavailable');
    } on FormatException {
      throw LoginException(code: 'invalidToken');
    }
    Future<AuthSuccess> issue() => session.db.transaction((tx) async {
      var identity = await ExternalIdentity.db.findFirstRow(
        session,
        where: (t) =>
            t.provider.equals(method) &
            t.issuer.equals(naverIssuer) &
            t.audience.equals(client.config.clientId) &
            t.subjectNamespace.equals('oidc') &
            t.subject.equals(subject),
        transaction: tx,
      );
      if (identity == null) {
        final user = await authUsers.create(session, transaction: tx);
        identity = await ExternalIdentity.db.insertRow(
          session,
          ExternalIdentity(
            provider: method,
            issuer: naverIssuer,
            audience: client.config.clientId,
            subjectNamespace: 'oidc',
            subject: subject,
            authUserId: user.id,
          ),
          transaction: tx,
        );
      }
      // Serialize token persistence/issuance with account deletion. An identity
      // read before deletion must not recreate credentials after its cascade.
      final user = await AuthUser.db.findFirstRow(
        session,
        where: (t) => t.id.equals(identity!.authUserId),
        lockMode: LockMode.forUpdate,
        transaction: tx,
      );
      if (user == null) throw LoginException(code: 'invalidAttempt');
      // Revocation unlinks the app (Naver guide 4.3), so do not revoke the
      // previous token during login. Replace it under the deletion owner lock.
      await NaverGrant.db.deleteWhere(
        session,
        where: (t) => t.authUserId.equals(identity!.authUserId),
        transaction: tx,
      );
      await NaverGrant.db.insertRow(
        session,
        NaverGrant(
          authUserId: identity.authUserId,
          clientId: client.config.clientId,
          refreshToken: tokens.refreshToken,
        ),
        transaction: tx,
      );
      return withClock(
        clock,
        () => tokenManager.issueToken(
          session,
          authUserId: identity!.authUserId,
          method: method,
          transaction: tx,
        ),
      );
    });
    AuthSuccess success;
    try {
      success = await issue();
    } on DatabaseQueryException catch (error) {
      if (error.code != '23505' ||
          error.constraintName != 'external_identity_provider_subject') {
        rethrow;
      }
      success = await issue();
    }
    return success;
  }

  @override
  Future<void> mergeAuthUsers(
    Session session, {
    required UuidValue userToKeepId,
    required UuidValue userToRemoveId,
    required Transaction transaction,
  }) async {
    throw UnsupportedError('Account linking is not supported.');
  }
}

String _digest(String value) => sha256.convert(utf8.encode(value)).toString();

class NaverProviderBuilder extends IdentityProviderBuilder<NaverProvider> {
  const NaverProviderBuilder({
    required this.config,
    this.clock = const Clock(),
    this.cleanupSessions = removeOlderSessions,
  });
  final NaverConfig config;
  final Clock clock;
  final Future<void> Function(Session, UuidValue) cleanupSessions;

  @override
  NaverProvider build({
    required TokenManager tokenManager,
    required AuthUsers authUsers,
    required UserProfiles userProfiles,
  }) {
    final client = NaverClient(config);
    return NaverProvider(
      tokenManager: tokenManager,
      authUsers: authUsers,
      client: client,
      verifier: OidcTokenVerifier(
        issuer: naverIssuer,
        audience: config.clientId,
        loadJwks: client.loadJwks,
        clock: clock,
      ),
      clock: clock,
      cleanupSessions: cleanupSessions,
    );
  }
}
