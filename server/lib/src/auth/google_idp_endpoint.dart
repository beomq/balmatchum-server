import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'social_auth.dart';

class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  Future<bool> isConfigured(Session session) async {
    final settings = socialAuthSettings[session.serverpod];
    return settings?.sessionsEnabled == true && settings?.google != null;
  }

  @override
  Future<AuthSuccess> login(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) => finishSocialLogin(
    session,
    requireSocialAuth(session, apple: false),
    () => super.login(session, idToken: idToken, accessToken: accessToken),
  );

  @override
  Future<AuthSuccess> loginWithCode(
    Session session, {
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => finishSocialLogin(
    session,
    requireSocialAuth(session, apple: false),
    () => super.loginWithCode(
      session,
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
    ),
  );

  @override
  Future<bool> hasAccount(Session session) {
    requireSocialAuth(session, apple: false);
    return super.hasAccount(session);
  }
}
