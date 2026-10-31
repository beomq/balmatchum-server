part of 'billing_verifier.dart';

final class AppleBillingClient {
  AppleBillingClient(
    this.config, {
    this.clock = const Clock(),
    http.Client Function()? clientFactory,
  }) : _http = _BillingHttp(clientFactory);
  final AppleBillingConfig config;
  final Clock clock;
  final _BillingHttp _http;

  Future<BillingFacts> verify({
    required String transactionId,
    required String productId,
    required String expectedAppAccountToken,
  }) => _safeVerify(() async {
    _lookup(transactionId, expectedAppAccountToken);
    if (!RegExp(r'^[0-9]{1,64}$').hasMatch(transactionId) ||
        !RegExp(
          r'^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
        ).hasMatch(expectedAppAccountToken)) {
      _invalid();
    }
    final kind = config.products[productId];
    if (kind == null) {
      _invalid();
    }
    final now = clock.now().toUtc();
    final jwt = JWT(
      {
        'iss': config.issuerId,
        'aud': 'appstoreconnect-v1',
        'bid': config.bundleId,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp':
            now.add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/ 1000,
      },
      header: {'kid': config.keyId},
    ).sign(config._key, algorithm: JWTAlgorithm.ES256, noIssueAt: true);
    final host = config.environment == BillingEnvironment.production
        ? 'api.storekit.apple.com'
        : 'api.storekit-sandbox.apple.com';
    // Both calls look up this purchase; the JWT is signed locally.
    Future<Map<String, dynamic>> get(String path) => _http.send(
      http.Request('GET', Uri.https(host, path))
        ..headers['authorization'] = 'Bearer $jwt',
      purchaseLookup: true,
    );
    final response = await get('/inApps/v1/transactions/$transactionId');
    var transaction = _decodeTrustedApple(response['signedTransactionInfo']);
    _validateTransaction(transaction, productId, kind, expectedAppAccountToken);
    if (transaction['transactionId'] != transactionId) {
      _invalid();
    }
    final original = _string(transaction['originalTransactionId']);
    int? status;
    DateTime? grace;
    if (kind == BillingProductKind.subscription) {
      final subscriptions = await get('/inApps/v1/subscriptions/$original');
      if (subscriptions['bundleId'] != config.bundleId ||
          subscriptions['environment'] != _environment) {
        _invalid();
      }
      final groups = subscriptions['data'];
      if (groups is! List) {
        _invalid();
      }
      Map<String, dynamic>? selected;
      for (final group in groups) {
        final entries = _object(group)['lastTransactions'];
        if (entries is! List) {
          _invalid();
        }
        for (final item in entries) {
          final entry = _object(item);
          if (entry['originalTransactionId'] == original) {
            if (selected != null) {
              _invalid();
            }
            selected = entry;
          }
        }
      }
      if (selected == null) {
        _invalid();
      }
      transaction = _decodeTrustedApple(selected['signedTransactionInfo']);
      _validateTransaction(
        transaction,
        productId,
        kind,
        expectedAppAccountToken,
      );
      if (transaction['originalTransactionId'] != original) {
        _invalid();
      }
      final rawStatus = selected['status'];
      if (rawStatus is! int || rawStatus < 1 || rawStatus > 5) {
        _invalid();
      }
      status = rawStatus;
      final renewal = _decodeTrustedApple(selected['signedRenewalInfo']);
      if (renewal['environment'] != _environment ||
          renewal['originalTransactionId'] != original ||
          renewal['productId'] != productId ||
          (renewal.containsKey('appAccountToken') &&
              _string(renewal['appAccountToken']).toLowerCase() !=
                  expectedAppAccountToken.toLowerCase())) {
        _invalid();
      }
      grace = _optionalMillis(renewal, 'gracePeriodExpiresDate');
      if (status == 4 && grace == null) {
        _invalid();
      }
    }
    final observed = clock.now().toUtc();
    final purchased = _millis(transaction['purchaseDate']);
    final expires = _optionalMillis(transaction, 'expiresDate');
    final revoked = _optionalMillis(transaction, 'revocationDate');
    if (purchased.isAfter(observed) ||
        (expires != null && expires.isBefore(purchased))) {
      _invalid();
    }
    if (transaction.containsKey('isUpgraded') &&
        transaction['isUpgraded'] is! bool) {
      _invalid();
    }
    final state =
        revoked != null ||
            status == 5 ||
            transaction.containsKey('revocationReason') ||
            transaction.containsKey('revocationType') ||
            transaction.containsKey('revocationPercentage')
        ? BillingState.revoked
        : transaction['isUpgraded'] == true
        ? BillingState.expired
        : kind == BillingProductKind.lifetime
        ? BillingState.active
        : status == 4
        ? (observed.isBefore(grace!)
              ? BillingState.grace
              : BillingState.expired)
        : status == 3
        ? BillingState.billingRetry
        : status == 2 || !observed.isBefore(expires!)
        ? BillingState.expired
        : BillingState.active;
    return BillingFacts._(
      store: BillingStore.apple,
      environment: config.environment,
      productId: productId,
      kind: kind,
      ownerBinding: expectedAppAccountToken.toLowerCase(),
      purchaseReference: original,
      transactionId: _string(transaction['transactionId']),
      state: state,
      observedAt: observed,
      purchasedAt: purchased,
      expiresAt: expires,
      graceExpiresAt: grace,
      revokedAt: revoked,
    );
  });

  String get _environment => config.environment == BillingEnvironment.production
      ? 'Production'
      : 'Sandbox';
  void _validateTransaction(
    Map<String, dynamic> value,
    String product,
    BillingProductKind kind,
    String owner,
  ) {
    if (value['bundleId'] != config.bundleId ||
        value['environment'] != _environment ||
        value['productId'] != product ||
        value['inAppOwnershipType'] != 'PURCHASED' ||
        _string(value['appAccountToken']).toLowerCase() !=
            owner.toLowerCase() ||
        value['type'] !=
            (kind == BillingProductKind.subscription
                ? 'Auto-Renewable Subscription'
                : 'Non-Consumable')) {
      _invalid();
    }
    _string(value['transactionId']);
    _string(value['originalTransactionId']);
    if (kind == BillingProductKind.subscription) _millis(value['expiresDate']);
  }
}

/// Private decoder: called ONLY on the body returned by the fixed-host HTTPS API.
/// This deliberately does not verify an x5c chain and MUST NOT accept client or
/// notification JWS. Its trust is TLS plus server authentication, not base64.
Map<String, dynamic> _decodeTrustedApple(Object? value) {
  final parts = _string(value).split('.');
  if (parts.length != 3 ||
      parts.any((s) => s.isEmpty || !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(s))) {
    _invalid();
  }
  final header = _object(
    jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[0])))),
  );
  if (header['alg'] != 'ES256' ||
      base64Url.decode(base64Url.normalize(parts[2])).length != 64) {
    _invalid();
  }
  return _object(
    jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))),
  );
}
