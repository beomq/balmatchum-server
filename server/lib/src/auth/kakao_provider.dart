import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'kakao_token_verifier.dart';

class KakaoProvider implements IdentityProvider {
  KakaoProvider({
    required this.tokenManager,
    required this.authUsers,
    required this.audience,
    required this.verifier,
    this.clock = const Clock(),
  });

  static KakaoProvider get current {
    try {
      return AuthServices.getIdentityProvider<KakaoProvider>();
    } on StateError {
      throw LoginException(code: 'configurationMissing');
    }
  }

  final TokenManager tokenManager;
  final AuthUsers authUsers;
  final String? audience;
  final KakaoTokenVerifier? verifier;
  final Clock clock;

  @override
  String get method => 'kakao';

  void _configured() {
    if (audience == null || audience!.isEmpty || verifier == null) {
      throw LoginException(code: 'configurationMissing');
    }
  }

  Future<LoginChallenge> beginLogin(
    Session session, {
    required String provider,
  }) async {
    _configured();
    if (provider != method) throw LoginException(code: 'unsupportedProvider');
    final random = Random.secure();
    final nonce = base64UrlEncode(
      List.generate(32, (_) => random.nextInt(256)),
    );
    final expiresAt = clock.now().toUtc().add(const Duration(minutes: 5));
    final attempt = await LoginAttempt.db.insertRow(
      session,
      LoginAttempt(
        nonceHash: sha256.convert(utf8.encode(nonce)).toString(),
        expiresAt: expiresAt,
      ),
    );
    return LoginChallenge(
      attemptId: attempt.id!,
      nonce: nonce,
      expiresAt: expiresAt,
    );
  }

  Future<AuthSuccess> login(
    Session session, {
    required UuidValue attemptId,
    required String idToken,
  }) async {
    _configured();
    final attempt = await LoginAttempt.db.findById(session, attemptId);
    if (attempt == null ||
        attempt.consumedAt != null ||
        !attempt.expiresAt.isAfter(clock.now())) {
      throw LoginException(code: 'invalidAttempt');
    }
    final String subject;
    try {
      subject = await verifier!.verify(idToken, nonceHash: attempt.nonceHash);
    } on FormatException {
      throw LoginException(code: 'invalidToken');
    }
    // Only a unique identity conflict is retried. The failed transaction rolls
    // back both its candidate AuthUser and the attempt consumption.
    Future<AuthSuccess> issue() => session.db.transaction((tx) async {
      final consumed = await LoginAttempt.db.updateWhere(
        session,
        columnValues: (t) => [t.consumedAt(clock.now().toUtc())],
        where: (t) =>
            t.id.equals(attemptId) &
            t.consumedAt.equals(null) &
            (t.expiresAt > clock.now()),
        transaction: tx,
      );
      if (consumed.isEmpty) throw LoginException(code: 'invalidAttempt');
      var identity = await ExternalIdentity.db.findFirstRow(
        session,
        where: (t) =>
            t.provider.equals(method) &
            t.issuer.equals('https://kauth.kakao.com') &
            t.audience.equals(audience!) &
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
            issuer: 'https://kauth.kakao.com',
            audience: audience!,
            subjectNamespace: 'oidc',
            subject: subject,
            authUserId: user.id,
          ),
          transaction: tx,
        );
      }
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
    // This is after the login transaction commit. A late older login must
    // never remove a newer session: order by (createdAt, UUID text).
    await removeOlderSessions(session, success.authUserId);
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

/// A late commit may have an older creation time than an already committed
/// login. Use the latest committed session, never completion/response order.
Future<void> removeOlderSessions(Session session, UuidValue authUserId) async {
  final deleted = await session.db.unsafeQuery(
    'DELETE FROM serverpod_auth_core_session AS old USING '
    '(SELECT "createdAt", id FROM serverpod_auth_core_session '
    'WHERE "authUserId" = CAST(@owner AS uuid) ORDER BY "createdAt" DESC, id DESC LIMIT 1) AS latest '
    'WHERE old."authUserId" = CAST(@owner AS uuid) AND '
    '(old."createdAt", old.id) < (latest."createdAt", latest.id) RETURNING old.id',
    parameters: QueryParameters.named({'owner': authUserId.uuid}),
  );
  for (final row in deleted) {
    await session.messages.authenticationRevoked(
      authUserId.uuid,
      RevokedAuthenticationAuthId(authId: row[0].toString()),
    );
  }
}

class KakaoProviderBuilder extends IdentityProviderBuilder<KakaoProvider> {
  const KakaoProviderBuilder({
    required this.audience,
    required this.verifier,
    this.clock = const Clock(),
  });
  final String? audience;
  final KakaoTokenVerifier? verifier;
  final Clock clock;
  @override
  KakaoProvider build({
    required TokenManager tokenManager,
    required AuthUsers authUsers,
    required UserProfiles userProfiles,
  }) => KakaoProvider(
    tokenManager: tokenManager,
    authUsers: authUsers,
    audience: audience,
    verifier: verifier,
    clock: clock,
  );
}
