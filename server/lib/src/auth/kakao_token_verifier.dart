import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Verifies Kakao ID tokens without owning JWKS fetching or nonce consumption.
class KakaoTokenVerifier {
  KakaoTokenVerifier({
    required this.audience,
    required this.loadJwks,
    this.clock = const Clock(),
  });

  final String audience;
  final Future<Map<String, dynamic>> Function() loadJwks;
  final Clock clock;

  Future<String> verify(String idToken, {required String nonceHash}) async {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3 || parts.any((part) => part.isEmpty)) {
        throw const FormatException('Invalid ID token structure');
      }
      final header = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts.first))),
      );
      if (header is! Map<String, dynamic> ||
          header['alg'] != 'RS256' ||
          header['kid'] is! String ||
          (header['kid'] as String).trim().isEmpty ||
          header.containsKey('crit')) {
        throw const FormatException('Invalid ID token header');
      }
      final jwks = await loadJwks();
      final keys = jwks['keys'];
      if (keys is! List) {
        throw const FormatException('Invalid JWKS');
      }
      final matches = keys.where(
        (key) => key is Map<String, dynamic> && key['kid'] == header['kid'],
      );
      if (matches.length != 1) {
        throw const FormatException('Unknown or ambiguous signing key');
      }
      final jwk = matches.single as Map<String, dynamic>;
      if (jwk['kty'] != 'RSA' ||
          (jwk.containsKey('use') && jwk['use'] != 'sig') ||
          (jwk.containsKey('alg') && jwk['alg'] != 'RS256') ||
          (jwk.containsKey('key_ops') &&
              (jwk['key_ops'] is! List ||
                  !(jwk['key_ops'] as List).contains('verify')))) {
        throw const FormatException('Invalid RSA signing key');
      }
      // Only public RSA parameters are accepted by the signature verifier.
      final key = JWTKey.fromJWK({
        'kty': 'RSA',
        'n': jwk['n'],
        'e': jwk['e'],
      });
      final jwt = JWT.verify(
        idToken,
        key,
        checkHeaderType: false,
        checkExpiresIn: false,
        checkNotBefore: false,
      );
      final claims = jwt.payload;
      if (claims is! Map<String, dynamic>) {
        throw const FormatException('Invalid ID token claims');
      }
      final aud = claims['aud'];
      final validAudience =
          audience.isNotEmpty &&
          (aud == audience ||
              (aud is List &&
                  aud.isNotEmpty &&
                  aud.every((value) => value is String && value.isNotEmpty) &&
                  aud.contains(audience) &&
                  (aud.length == 1 || claims['azp'] == audience)));
      final now = clock.now().millisecondsSinceEpoch / 1000;
      final exp = claims['exp'];
      final iat = claims['iat'];
      final nbf = claims['nbf'];
      final sub = claims['sub'];
      final nonce = claims['nonce'];
      if (claims['iss'] != 'https://kauth.kakao.com' ||
          !validAudience ||
          (claims.containsKey('azp') && claims['azp'] != audience) ||
          exp is! num ||
          !exp.isFinite ||
          exp <= now ||
          iat is! num ||
          !iat.isFinite ||
          iat > now ||
          iat >= exp ||
          (claims.containsKey('nbf') &&
              (nbf is! num || !nbf.isFinite || nbf > now)) ||
          nonce is! String ||
          nonce.isEmpty ||
          sha256.convert(utf8.encode(nonce)).toString() != nonceHash ||
          sub is! String ||
          sub.trim().isEmpty) {
        throw const FormatException('Invalid ID token claims');
      }
      return sub;
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid ID token or JWKS');
    }
  }
}
