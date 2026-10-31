import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../config_password.dart';
import 'kakao_provider.dart';
import 'kakao_token_verifier.dart';
import 'login_rate_limiter.dart';
import 'social_auth.dart';
import 'naver_client.dart';
import 'naver_provider.dart';

void configureAuth(
  Serverpod pod, {
  String? audience,
  String? issuer,
  String? sessionPepper,
  Future<Map<String, dynamic>> Function()? loadJwks,
  String? Function(String)? providerPassword,
  Clock clock = const Clock(),
  Future<void> Function(Session, UuidValue) cleanupSessions =
      removeOlderSessions,
}) {
  audience ??= pod.configPassword('kakaoAudience');
  issuer ??= pod.configPassword('kakaoIssuer');
  sessionPepper ??= pod.configPassword('serverSideSessionKeyHashPepper');
  // Parse supplied provider settings even when sessions are disabled: partial
  // deployment configuration is an error, never a silently disabled provider.
  final social = SocialAuthSettings.fromPasswords(
    providerPassword ?? pod.configPassword,
    sessionsEnabled: sessionPepper != null && sessionPepper.isNotEmpty,
    cleanupSessions: cleanupSessions,
  );
  socialAuthSettings[pod] = social;
  final naver = NaverConfig.fromPasswords(
    providerPassword ?? pod.configPassword,
  );
  naverSettings[pod] = sessionPepper != null && sessionPepper.isNotEmpty
      ? naver
      : null;
  // Missing deployment settings must not silently generate ephemeral secrets.
  if (sessionPepper == null || sessionPepper.isEmpty) {
    stderr.writeln(
      'WARNING: Authentication disabled: session hash pepper is missing.',
    );
    return;
  }
  // One limiter per pod: Kakao and Naver login starts share the budget.
  final limiter = LoginRateLimiter(clock: clock);
  pod.initializeAuthServices(
    userProfileConfig: providerProfileConfig,
    tokenManagerBuilders: [
      ServerSideSessionsConfig(
        sessionKeyHashPepper: sessionPepper,
        defaultSessionLifetime: null,
        defaultSessionInactivityTimeout: const Duration(days: 90),
      ),
    ],
    identityProviderBuilders: [
      if (social.google != null) social.google!,
      if (social.apple != null) social.apple!,
      if (naver != null)
        NaverProviderBuilder(
          config: naver,
          limiter: limiter,
          clock: clock,
          cleanupSessions: cleanupSessions,
        ),
      KakaoProviderBuilder(
        audience: audience,
        verifier:
            audience == null ||
                audience.isEmpty ||
                issuer != 'https://kauth.kakao.com'
            ? null
            : KakaoTokenVerifier(
                audience: audience,
                clock: clock,
                loadJwks:
                    loadJwks ??
                    () async {
                      final response = await http
                          .get(
                            Uri.parse(
                              'https://kauth.kakao.com/.well-known/jwks.json',
                            ),
                          )
                          .timeout(const Duration(seconds: 10));
                      if (response.statusCode != 200) {
                        throw const FormatException('JWKS unavailable');
                      }
                      return jsonDecode(response.body) as Map<String, dynamic>;
                    },
              ),
        limiter: limiter,
        clock: clock,
        cleanupSessions: cleanupSessions,
      ),
    ],
  );
}
