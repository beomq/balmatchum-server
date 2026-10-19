part of 'billing_verifier.dart';

final class GoogleBillingClient {
  GoogleBillingClient(
    this.config, {
    this.clock = const Clock(),
    http.Client Function()? clientFactory,
  }) : _http = _BillingHttp(clientFactory);
  final GoogleBillingConfig config;
  final Clock clock;
  final _BillingHttp _http;

  Future<BillingFacts> verify({
    required String purchaseToken,
    required String productId,
    required String expectedObfuscatedAccountId,
  }) => _safeVerify(() async {
    _lookup(purchaseToken, expectedObfuscatedAccountId);
    if (expectedObfuscatedAccountId.length > 64) {
      _invalid();
    }
    final kind = config.products[productId];
    if (kind == null) {
      _invalid();
    }
    final token = await _accessToken();
    final endpoint = kind == BillingProductKind.subscription
        ? 'subscriptionsv2'
        : 'productsv2';
    final uri = Uri(
      scheme: 'https',
      host: 'androidpublisher.googleapis.com',
      pathSegments: [
        'androidpublisher',
        'v3',
        'applications',
        config.packageName,
        'purchases',
        endpoint,
        'tokens',
        purchaseToken,
      ],
    );
    final result = await _http.send(
      http.Request('GET', uri)..headers['authorization'] = 'Bearer $token',
    );
    final observed = clock.now().toUtc();
    final subscription = kind == BillingProductKind.subscription;
    if (result['kind'] !=
        (subscription
            ? 'androidpublisher#subscriptionPurchaseV2'
            : 'androidpublisher#productPurchaseV2')) {
      _invalid();
    }
    // Publisher binds the app through the authenticated packageName path; the
    // official resource has no packageName field. Never accept one from a client.
    if (result.containsKey('packageName') &&
        result['packageName'] != config.packageName) {
      _invalid();
    }
    final testField = subscription ? 'testPurchase' : 'testPurchaseContext';
    final isTest = result.containsKey(testField);
    if (isTest) {
      final context = _object(result[testField]);
      if (!subscription && context['fopType'] != 'TEST') {
        _invalid();
      }
    }
    if (isTest != (config.environment == BillingEnvironment.sandbox)) {
      _invalid();
    }
    final owner = subscription
        ? _object(
            result['externalAccountIdentifiers'],
          )['obfuscatedExternalAccountId']
        : result['obfuscatedExternalAccountId'];
    if (_string(owner) != expectedObfuscatedAccountId) {
      _invalid();
    }
    final lines = result[subscription ? 'lineItems' : 'productLineItem'];
    if (lines is! List) {
      _invalid();
    }
    final matching = lines
        .map(_object)
        .where((v) => v['productId'] == productId)
        .toList();
    if (matching.length != 1) {
      _invalid();
    }
    final item = matching.single;
    DateTime? purchased;
    DateTime? expires;
    DateTime? grace;
    String? order;
    BillingState state;
    if (subscription) {
      final raw = result['subscriptionState'];
      state = switch (raw) {
        'SUBSCRIPTION_STATE_ACTIVE' ||
        'SUBSCRIPTION_STATE_CANCELED' => BillingState.active,
        'SUBSCRIPTION_STATE_IN_GRACE_PERIOD' => BillingState.grace,
        'SUBSCRIPTION_STATE_PENDING' ||
        'SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED' => BillingState.pending,
        'SUBSCRIPTION_STATE_ON_HOLD' => BillingState.onHold,
        'SUBSCRIPTION_STATE_PAUSED' => BillingState.paused,
        'SUBSCRIPTION_STATE_EXPIRED' => BillingState.expired,
        _ => _invalid(),
      };
      if (result.containsKey('startTime')) {
        purchased = _timestamp(result['startTime']);
      }
      if (item.containsKey('expiryTime')) {
        expires = _timestamp(item['expiryTime']);
      }
      if (item.containsKey('latestSuccessfulOrderId')) {
        order = _string(item['latestSuccessfulOrderId']);
      }
      if (state == BillingState.active || state == BillingState.grace) {
        // A deferred replacement line may name the product before it is owned.
        if (purchased == null || expires == null || order == null) {
          _invalid();
        }
        if (!observed.isBefore(expires)) state = BillingState.expired;
      }
      // Play extends the line item's expiryTime while in grace. Do not add a
      // locally configured duration or use autoRenewEnabled as entitlement proof.
      if (raw == 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD') grace = expires;
    } else {
      final raw = _object(result['purchaseStateContext'])['purchaseState'];
      state = switch (raw) {
        'PURCHASED' => BillingState.active,
        'PENDING' => BillingState.pending,
        'CANCELLED' => BillingState.revoked,
        _ => _invalid(),
      };
      if (result.containsKey('purchaseCompletionTime')) {
        purchased = _timestamp(result['purchaseCompletionTime']);
      }
      if (result.containsKey('orderId')) order = _string(result['orderId']);
      if (state == BillingState.active) {
        final offer = _object(item['productOfferDetails']);
        if (purchased == null ||
            offer.containsKey('rentOfferDetails') ||
            offer.containsKey('preorderOfferDetails') ||
            offer['quantity'] != 1 ||
            offer['refundableQuantity'] is! int ||
            !const [0, 1].contains(offer['refundableQuantity'])) {
          _invalid();
        }
        if (offer['refundableQuantity'] == 0) state = BillingState.revoked;
        if (offer['consumptionState'] !=
            'CONSUMPTION_STATE_YET_TO_BE_CONSUMED') {
          _invalid();
        }
      }
    }
    if ((purchased != null && purchased.isAfter(observed)) ||
        (purchased != null && expires != null && expires.isBefore(purchased))) {
      _invalid();
    }
    return BillingFacts._(
      store: BillingStore.google,
      environment: config.environment,
      productId: productId,
      kind: kind,
      ownerBinding: expectedObfuscatedAccountId,
      purchaseReference: purchaseToken,
      transactionId: order,
      state: state,
      observedAt: observed,
      purchasedAt: purchased,
      expiresAt: expires,
      graceExpiresAt: grace,
      revokedAt: null,
      requiresAcknowledgement: switch (result['acknowledgementState']) {
        'ACKNOWLEDGEMENT_STATE_PENDING' => true,
        'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED' => false,
        _ => _invalid(),
      },
    );
  });

  /// Call only after verified persistence. Never consumes a lifetime purchase.
  Future<void> acknowledge({
    required String purchaseToken,
    required String productId,
  }) async {
    _lookup(purchaseToken, productId);
    final kind = config.products[productId];
    if (kind == null) _invalid();
    final access = await _accessToken();
    final uri = Uri(
      scheme: 'https',
      host: 'androidpublisher.googleapis.com',
      pathSegments: [
        'androidpublisher',
        'v3',
        'applications',
        config.packageName,
        'purchases',
        kind == BillingProductKind.subscription ? 'subscriptions' : 'products',
        productId,
        'tokens',
        '$purchaseToken:acknowledge',
      ],
    );
    await _http.send(
      http.Request('POST', uri)
        ..headers['authorization'] = 'Bearer $access'
        ..headers['content-type'] = 'application/json'
        ..body = '{}',
      allowEmpty: true,
    );
  }

  Future<String> _accessToken() async {
    final now = clock.now().toUtc();
    final assertion = JWT(
      {
        'iss': config.clientEmail,
        'scope': 'https://www.googleapis.com/auth/androidpublisher',
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp':
            now.add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/ 1000,
      },
      header: {'kid': config.keyId},
    ).sign(config._key, algorithm: JWTAlgorithm.RS256, noIssueAt: true);
    final oauth = await _http.send(
      http.Request('POST', Uri.https('oauth2.googleapis.com', '/token'))
        ..bodyFields = {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': assertion,
        },
    );
    final token = _string(oauth['access_token']);
    final lifetime = oauth['expires_in'];
    if (oauth['token_type'] != 'Bearer' ||
        lifetime is! int ||
        lifetime <= 0 ||
        !RegExp(r'^[A-Za-z0-9._~+/-]+=*$').hasMatch(token)) {
      _invalid();
    }
    return token;
  }
}
