import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/apple.dart';

import 'social_auth.dart';

class AppleIdpEndpoint extends AppleIdpBaseEndpoint {
  Future<bool> isConfigured(Session session) async {
    final settings = socialAuthSettings[session.serverpod];
    return settings?.sessionsEnabled == true && settings?.apple != null;
  }

  @override
  Future<AuthSuccess> login(
    Session session, {
    required String identityToken,
    required String authorizationCode,
    required bool isNativeApplePlatformSignIn,
    String? firstName,
    String? lastName,
  }) => finishSocialLogin(
    session,
    requireSocialAuth(session, apple: true),
    () => super.login(
      session,
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      isNativeApplePlatformSignIn: isNativeApplePlatformSignIn,
      // The SDK copies these into AppleAccount; the app never uses names.
      firstName: null,
      lastName: null,
    ),
  );

  @override
  Future<bool> hasAccount(Session session) {
    requireSocialAuth(session, apple: true);
    return super.hasAccount(session);
  }
}
