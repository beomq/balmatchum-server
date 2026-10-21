import 'dart:convert';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';

const naverIssuer = 'https://nid.naver.com';

class NaverConfig {
  NaverConfig._(this.clientId, this.clientSecret, this.redirectUri);

  final String clientId;
  final String clientSecret;
  final String redirectUri;

  static NaverConfig? fromPasswords(String? Function(String) password) {
    final id = password('naverClientId');
    final secret = password('naverClientSecret');
    final redirect = password('naverRedirectUri');
    if (id == null && secret == null && redirect == null) return null;
    final uri = redirect == null ? null : Uri.tryParse(redirect);
    if (id == null ||
        id.trim().isEmpty ||
        secret == null ||
        secret.trim().isEmpty ||
        uri == null ||
        (uri.scheme != 'https' &&
            !const {
              'com.beomq.balmatchum.dev://naver/callback',
              'com.beomq.balmatchum://naver/callback',
            }.contains(redirect)) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        uri.hasQuery) {
      throw StateError('Invalid Naver authentication configuration.');
    }
    return NaverConfig._(id, secret, redirect!);
  }
}

/// Only fixed official endpoints; neither redirect responses nor token header
/// URLs are followed. Transport errors and provider bodies never escape.
class NaverClient {
  NaverClient(this.config);
  final NaverConfig config;

  Future<http.Response> _request(
    String path, {
    Map<String, String>? fields,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request(
        fields == null ? 'GET' : 'POST',
        Uri.parse('$naverIssuer$path'),
      )..followRedirects = false;
      if (fields != null) request.bodyFields = fields;
      return await (() async => http.Response.fromStream(
        await client.send(request),
      ))().timeout(const Duration(seconds: 10));
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> loadJwks() async {
    final response = await _request('/oauth2/jwks');
    if (response.statusCode != 200) {
      throw const FormatException('JWKS unavailable');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<({String idToken, String refreshToken})> exchange({
    required String code,
    required String codeVerifier,
  }) async {
    try {
      final response = await _request(
        '/oauth2/token',
        fields: {
          'grant_type': 'authorization_code',
          'client_id': config.clientId,
          'client_secret': config.clientSecret,
          'redirect_uri': config.redirectUri,
          'code': code,
          'code_verifier': codeVerifier,
        },
      );
      if (response.statusCode >= 500 || response.statusCode == 429) {
        throw LoginException(code: 'temporarilyUnavailable');
      }
      if (response.statusCode != 200) {
        throw LoginException(code: 'invalidToken');
      }
      final value = jsonDecode(response.body);
      if (value is! Map<String, dynamic> ||
          value.containsKey('error') ||
          value['id_token'] is! String ||
          (value['id_token'] as String).isEmpty ||
          value['refresh_token'] is! String ||
          (value['refresh_token'] as String).isEmpty) {
        throw LoginException(code: 'invalidToken');
      }
      return (
        idToken: value['id_token'] as String,
        refreshToken: value['refresh_token'] as String,
      );
    } on LoginException {
      rethrow;
    } on FormatException {
      throw LoginException(code: 'invalidToken');
    } catch (_) {
      throw LoginException(code: 'temporarilyUnavailable');
    }
  }

  Future<void> revoke(String refreshToken) async {
    try {
      // The OIDC discovery endpoint is /oauth2/revoke, not the legacy
      // /oauth2.0/revoke documented for OAuth-only applications.
      final response = await _request(
        '/oauth2/revoke',
        fields: {
          'client_id': config.clientId,
          'client_secret': config.clientSecret,
          'token': refreshToken,
          'token_type_hint': 'refresh_token',
        },
      );
      // RFC 7009: already revoked/unknown tokens also return 200.
      if (response.statusCode != 200) {
        throw const FormatException('Revocation failed');
      }
    } catch (_) {
      throw LoginException(code: 'naverRevocationFailed');
    }
  }
}
