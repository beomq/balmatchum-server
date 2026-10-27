import 'oidc_token_verifier.dart';

export 'oidc_token_verifier.dart' show JwksUnavailableException;

/// Kakao keeps its fixed issuer while sharing the audited RS256 verifier.
class KakaoTokenVerifier extends OidcTokenVerifier {
  KakaoTokenVerifier({
    required super.audience,
    required super.loadJwks,
    super.clock,
    super.clockSkew,
  }) : super(issuer: 'https://kauth.kakao.com');

  static const jwksCacheTtl = OidcTokenVerifier.jwksCacheTtl;
  static const forcedRefreshCooldown = OidcTokenVerifier.forcedRefreshCooldown;
}
