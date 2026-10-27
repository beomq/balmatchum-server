import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// A JWKS fetch failed and no unexpired cached keys are available.
class JwksUnavailableException implements Exception {
  const JwksUnavailableException();
}

/// Verifies RS256 ID tokens with pinned issuer and cached trusted JWKS.
class OidcTokenVerifier {
  OidcTokenVerifier({
    required this.issuer,
    required this.audience,
    required this.loadJwks,
    this.clock = const Clock(),
    this.clockSkew = const Duration(seconds: 60),
  });

  static const jwksCacheTtl = Duration(hours: 1);
  static const forcedRefreshCooldown = Duration(minutes: 1);

  final String audience;
  final String issuer;
  final Future<Map<String, dynamic>> Function() loadJwks;
  final Clock clock;
  final Duration clockSkew;
  Map<String, dynamic>? _cachedJwks;
  DateTime? _cacheExpiresAt;
  Future<Map<String, dynamic>>? _inflightJwks;
  DateTime? _nextForcedRefreshAt;

  bool get _hasValidCache =>
      _cachedJwks != null && clock.now().isBefore(_cacheExpiresAt!);

  Future<Map<String, dynamic>> _getJwks() {
    if (_inflightJwks != null) return _inflightJwks!;
    if (_hasValidCache) return Future.value(_cachedJwks!);
    return _refreshJwks();
  }

  Future<Map<String, dynamic>> _refreshJwks() => _inflightJwks ??= _fetchJwks();

  Future<Map<String, dynamic>> _fetchJwks() async {
    try {
      final Map<String, dynamic> jwks;
      try {
        jwks = await Future.sync(loadJwks);
      } catch (_) {
        if (_hasValidCache) return _cachedJwks!;
        throw const JwksUnavailableException();
      }
      if (jwks['keys'] is! List) {
        throw const FormatException('Invalid JWKS');
      }
      _cachedJwks = jwks;
      _cacheExpiresAt = clock.now().add(jwksCacheTtl);
      return jwks;
    } finally {
      _inflightJwks = null;
    }
  }

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
      final joinedRefresh = _inflightJwks != null;
      var jwks = await _getJwks();
      var matches = (jwks['keys'] as List).where(
        (key) => key is Map<String, dynamic> && key['kid'] == header['kid'],
      );
      if (matches.isEmpty && !joinedRefresh) {
        // Another verifier call may already have refreshed this snapshot.
        if (!identical(jwks, _cachedJwks)) {
          jwks = await _getJwks();
        } else if (_inflightJwks != null) {
          jwks = await _inflightJwks!;
        } else if (_nextForcedRefreshAt == null ||
            !clock.now().isBefore(_nextForcedRefreshAt!)) {
          // Reserve before awaiting: failed fetches also consume the cooldown.
          _nextForcedRefreshAt = clock.now().add(forcedRefreshCooldown);
          jwks = await _refreshJwks();
        }
        matches = (jwks['keys'] as List).where(
          (key) => key is Map<String, dynamic> && key['kid'] == header['kid'],
        );
      }
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
      final skew = clockSkew.inMicroseconds / Duration.microsecondsPerSecond;
      final exp = claims['exp'];
      final iat = claims['iat'];
      final nbf = claims['nbf'];
      final sub = claims['sub'];
      final nonce = claims['nonce'];
      if (claims['iss'] != issuer ||
          !validAudience ||
          (claims.containsKey('azp') && claims['azp'] != audience) ||
          exp is! num ||
          !exp.isFinite ||
          exp <= now - skew ||
          iat is! num ||
          !iat.isFinite ||
          iat > now + skew ||
          iat >= exp ||
          (claims.containsKey('nbf') &&
              (nbf is! num || !nbf.isFinite || nbf > now + skew)) ||
          nonce is! String ||
          nonce.isEmpty ||
          sha256.convert(utf8.encode(nonce)).toString() != nonceHash ||
          sub is! String ||
          sub.trim().isEmpty) {
        throw const FormatException('Invalid ID token claims');
      }
      return sub;
    } on JwksUnavailableException {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid ID token or JWKS');
    }
  }
}
