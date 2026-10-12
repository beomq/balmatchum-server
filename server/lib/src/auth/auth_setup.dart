import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'kakao_provider.dart';
import 'kakao_token_verifier.dart';

void configureAuth(
  Serverpod pod, {
  String? audience,
  String? issuer,
  String? sessionPepper,
  Future<Map<String, dynamic>> Function()? loadJwks,
  Clock clock = const Clock(),
  Future<void> Function(Session, UuidValue) cleanupSessions =
      removeOlderSessions,
}) {
  audience ??= pod.getPassword('kakaoAudience');
  issuer ??= pod.getPassword('kakaoIssuer');
  sessionPepper ??= pod.getPassword('serverSideSessionKeyHashPepper');
  // Missing deployment settings must not silently generate ephemeral secrets.
  if (sessionPepper == null || sessionPepper.isEmpty) {
    stderr.writeln(
      'WARNING: Authentication disabled: session hash pepper is missing.',
    );
    return;
  }
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      ServerSideSessionsConfig(
        sessionKeyHashPepper: sessionPepper,
        defaultSessionLifetime: null,
        defaultSessionInactivityTimeout: const Duration(days: 90),
      ),
    ],
    identityProviderBuilders: [
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
        clock: clock,
        cleanupSessions: cleanupSessions,
      ),
    ],
  );
}
