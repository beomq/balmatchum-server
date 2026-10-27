part of 'billing_verifier.dart';

/// Production owns a fresh IO client per request, allowing timeout cancellation.
/// Injected factories are a trusted test seam, never sourced from request input.
final class _BillingHttp {
  _BillingHttp(http.Client Function()? clientFactory)
    : _clientFactory =
          clientFactory ??
          (() => IOClient(
            HttpClient()
              ..connectionTimeout = const Duration(seconds: 10)
              ..findProxy = (_) => 'DIRECT',
          ));
  final http.Client Function() _clientFactory;
  static const timeout = Duration(seconds: 10);
  static const maxBytes = 1024 * 1024;

  /// Only a [purchaseLookup] 404/410 means the store no longer knows the
  /// purchase; the same status from a token or acknowledgement call is a
  /// transient failure that says nothing about any purchase.
  Future<Map<String, dynamic>> send(
    http.Request request, {
    bool allowEmpty = false,
    bool purchaseLookup = false,
  }) async {
    if (request.url.scheme != 'https' ||
        request.url.port != 443 ||
        request.url.userInfo.isNotEmpty ||
        !const {
          'api.storekit.apple.com',
          'api.storekit-sandbox.apple.com',
          'androidpublisher.googleapis.com',
          'oauth2.googleapis.com',
        }.contains(request.url.host)) {
      _invalid();
    }
    request.followRedirects = false;
    request.maxRedirects = 0;
    request.headers['accept'] = 'application/json';
    final client = _clientFactory();
    try {
      return await (() async {
        final response = await client.send(request);
        if (response.statusCode != 200 &&
            !(allowEmpty && response.statusCode == 204)) {
          throw purchaseLookup &&
                  (response.statusCode == 404 || response.statusCode == 410)
              ? const BillingPurchaseGone()
              : const BillingVerificationException(BillingFailure.unavailable);
        }
        if ((response.contentLength ?? 0) > maxBytes) {
          _invalid();
        }
        final bytes = <int>[];
        await for (final chunk in response.stream) {
          if (bytes.length + chunk.length > maxBytes) {
            _invalid();
          }
          bytes.addAll(chunk);
        }
        if (allowEmpty && bytes.isEmpty) return <String, dynamic>{};
        return _object(jsonDecode(utf8.decode(bytes)));
      })().timeout(timeout);
    } on BillingVerificationException {
      rethrow;
    } on FormatException {
      _invalid();
    } catch (_) {
      throw const BillingVerificationException(BillingFailure.unavailable);
    } finally {
      client.close();
    }
  }
}

Future<BillingFacts> _safeVerify(Future<BillingFacts> Function() work) async {
  try {
    return await work();
  } on BillingVerificationException {
    rethrow;
  } catch (_) {
    // Neither decoder nor transport exception text may reach logs or endpoints.
    _invalid();
  }
}
