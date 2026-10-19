import 'dart:convert';
import 'package:balmatchum_server/src/billing/billing_verifier.dart';
import 'package:clock/clock.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import '../../test_utils/ad_test_keys.dart';
import '../../test_utils/kakao_test_keys.dart';

final now = DateTime.utc(2026, 10, 19, 12);
final purchaseDate = now.subtract(const Duration(days: 1));
final expiry = now.add(const Duration(days: 1));
const owner = '12345678-1234-1234-1234-123456789abc';
const googleOwner = 'server-owned-account-binding';
const lookupToken = 'opaque/token+with?reserved#chars';
const products = '{"monthly":"subscription","lifetime":"lifetime"}';

Map<String, String> passwords() => {
  'billingAppleBundleId': 'test.app',
  'billingAppleIssuerId': 'issuer',
  'billingAppleKeyId': 'apple-key',
  'billingApplePrivateKey': adPrivatePem,
  'billingAppleEnvironment': 'sandbox',
  'billingAppleProducts': products,
  'billingGooglePackageName': 'test.app',
  'billingGoogleClientEmail': 'billing@test.iam.gserviceaccount.com',
  'billingGoogleKeyId': 'google-key',
  'billingGooglePrivateKey': rsaPem,
  'billingGoogleEnvironment': 'sandbox',
  'billingGoogleProducts': products,
};
BillingConfig config([Map<String, String>? values]) {
  final p = values ?? passwords();
  return BillingConfig.fromPasswords((key) => p[key]);
}

String jws(Map<String, dynamic> body) => JWT(body).sign(
  ECPrivateKey(adPrivatePem),
  algorithm: JWTAlgorithm.ES256,
  noIssueAt: true,
);
Map<String, dynamic> transaction({bool lifetime = false}) => {
  'transactionId': '123',
  'originalTransactionId': '100',
  'bundleId': 'test.app',
  'environment': 'Sandbox',
  'appAccountToken': owner,
  'productId': lifetime ? 'lifetime' : 'monthly',
  'type': lifetime ? 'Non-Consumable' : 'Auto-Renewable Subscription',
  'inAppOwnershipType': 'PURCHASED',
  'purchaseDate': purchaseDate.millisecondsSinceEpoch,
  if (!lifetime) 'expiresDate': expiry.millisecondsSinceEpoch,
};
Map<String, dynamic> renewal() => {
  'environment': 'Sandbox',
  'originalTransactionId': '100',
  'productId': 'monthly',
  'appAccountToken': owner,
  'isInBillingRetryPeriod': false,
};
Map<String, dynamic> subscription({String state = 'ACTIVE'}) => {
  'kind': 'androidpublisher#subscriptionPurchaseV2',
  'subscriptionState': 'SUBSCRIPTION_STATE_$state',
  'testPurchase': <String, dynamic>{},
  'externalAccountIdentifiers': {'obfuscatedExternalAccountId': googleOwner},
  'startTime': purchaseDate.toIso8601String(),
  'lineItems': [
    <String, dynamic>{
      'productId': 'monthly',
      'expiryTime': expiry.toIso8601String(),
      'latestSuccessfulOrderId': 'order-1',
    },
  ],
};
Map<String, dynamic> lifetimePurchase({String state = 'PURCHASED'}) => {
  'kind': 'androidpublisher#productPurchaseV2',
  'purchaseStateContext': {'purchaseState': state},
  'testPurchaseContext': {'fopType': 'TEST'},
  'obfuscatedExternalAccountId': googleOwner,
  'purchaseCompletionTime': purchaseDate.toIso8601String(),
  'orderId': 'order-2',
  'productLineItem': [
    {
      'productId': 'lifetime',
      'productOfferDetails': {
        'quantity': 1,
        'refundableQuantity': 1,
        'consumptionState': 'CONSUMPTION_STATE_YET_TO_BE_CONSUMED',
      },
    },
  ],
};

final invalid = throwsA(
  isA<BillingVerificationException>().having(
    (e) => e.code,
    'code',
    BillingFailure.invalidPurchase,
  ),
);
final unavailable = throwsA(
  isA<BillingVerificationException>().having(
    (e) => e.code,
    'code',
    BillingFailure.unavailable,
  ),
);
final misconfigured = throwsA(
  isA<BillingVerificationException>().having(
    (e) => e.code,
    'code',
    BillingFailure.configuration,
  ),
);

/// Real request construction and response parsers; only the wire is replaced.
class Wire {
  final requests = <http.Request>[];
  final responses = <http.Response>[];
  http.Client client() => MockClient((request) async {
    expect(request.followRedirects, isFalse);
    expect(request.maxRedirects, 0);
    expect(request.url.scheme, 'https');
    expect(request.url.port, 443);
    requests.add(request);
    if (responses.isEmpty) throw StateError('Unexpected extra request');
    return responses.removeAt(0);
  });
  void json(Object value) =>
      responses.add(http.Response(jsonEncode(value), 200));
  void apple(
    Map<String, dynamic> tx, {
    int status = 1,
    Map<String, dynamic>? renew,
    Map<String, dynamic>? latest,
  }) {
    json({'signedTransactionInfo': jws(tx)});
    if (tx['type'] == 'Auto-Renewable Subscription') {
      json({
        'bundleId': 'test.app',
        'environment': 'Sandbox',
        'data': [
          {
            'lastTransactions': [
              {
                'originalTransactionId': '100',
                'status': status,
                'signedTransactionInfo': jws(latest ?? tx),
                'signedRenewalInfo': jws(renew ?? renewal()),
              },
            ],
          },
        ],
      });
    }
  }

  void google(Object purchase) {
    json({
      'access_token': 'server-access-token',
      'token_type': 'Bearer',
      'expires_in': 3600,
    });
    json(purchase);
  }

  Future<BillingFacts> verifyApple({
    String product = 'monthly',
    String binding = owner,
    String lookup = '123',
    BillingConfig? settings,
    DateTime? instant,
  }) =>
      AppleBillingClient(
        (settings ?? config()).apple!,
        clock: Clock.fixed(instant ?? now),
        clientFactory: client,
      ).verify(
        transactionId: lookup,
        productId: product,
        expectedAppAccountToken: binding,
      );
  Future<BillingFacts> verifyGoogle({
    String product = 'monthly',
    String binding = googleOwner,
    BillingConfig? settings,
    DateTime? instant,
  }) =>
      GoogleBillingClient(
        (settings ?? config()).google!,
        clock: Clock.fixed(instant ?? now),
        clientFactory: client,
      ).verify(
        purchaseToken: lookupToken,
        productId: product,
        expectedObfuscatedAccountId: binding,
      );
}

void checkJwt(String token, {required bool apple}) {
  final jwt = JWT.verify(
    token,
    apple ? ECPublicKey(adPublicPem) : KakaoTestKeys.publicKey,
    checkExpiresIn: false,
    checkNotBefore: false,
  );
  expect(jwt.header!['alg'], apple ? 'ES256' : 'RS256');
  expect(jwt.header!['kid'], apple ? 'apple-key' : 'google-key');
  expect(jwt.payload['iat'], now.millisecondsSinceEpoch ~/ 1000);
  expect(
    jwt.payload['exp'],
    now.add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/ 1000,
  );
  expect(
    jwt.payload['iss'],
    apple ? 'issuer' : 'billing@test.iam.gserviceaccount.com',
  );
  expect(
    jwt.payload['aud'],
    apple ? 'appstoreconnect-v1' : 'https://oauth2.googleapis.com/token',
  );
  if (apple) {
    expect(jwt.payload['bid'], 'test.app');
    expect(
      () => JWT.verify(
        token,
        ECPublicKey(wrongAdPublicPem),
        checkExpiresIn: false,
      ),
      throwsA(isA<JWTException>()),
    );
  } else {
    expect(
      jwt.payload['scope'],
      'https://www.googleapis.com/auth/androidpublisher',
    );
    expect(jwt.payload.containsKey('sub'), isFalse);
    final parts = token.split('.');
    parts[1] = base64Url
        .encode(
          utf8.encode(jsonEncode({...jwt.payload as Map, 'iss': 'wrong'})),
        )
        .replaceAll('=', '');
    expect(
      () => JWT.verify(
        parts.join('.'),
        KakaoTestKeys.publicKey,
        checkExpiresIn: false,
      ),
      throwsA(isA<JWTException>()),
    );
  }
}

// Public disposable RSA fixture, copied from the existing authentication tests.
const rsaPem = '''
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC5eEV8Ht5QUVyD
1sYmOolNCJyHaMOwACf/tCQNQGhsra05/7tYUvNn2YCD2IiK4PR9Clh9htVvQ+Ai
zviNh6Woh/4GTafZBwU7IKpaCfoAl3xBVKjEGj3oXCf4ol2zL6LnqqljrUxoJlNh
YjmHlC/Px+1sjqP5qn9mA4wh8Beig4z2In/5vCKdhEVIjX3063KEhmoX/8WXu3uX
oNy47GP88FRz7YMOoWmCPmI/0qnQ+xoqn2DeNNKPiqPIETFhH3BiOf4PUV/gzR6l
7EFTm/pVpWdcyTUU46pFCa+6aIXdGXVdJKlYnr7ffJCDJoCc5OaUqww1y//mL5pE
su6a/0DjAgMBAAECggEAGxGnqobi0XwecYt+HgQ7F8gi+ExdCynqrJJBFMIKu5nZ
h3aAhFKO/eArtpJ60zIj3MAOzDtKmVOhudLVSeq7Tc6TT54z2iQBKnEJC90a5M03
MF3Hx99Am9Ifb1VbMZTJROCOmmKnnSfC0ZrBZL1HAR9f0pE682xj7aKk6Csfd/NV
jPQLFSr0+fONbaIrPowNn4fSuHXkSdFz9As59yvji773tJMnNsdA70TAmHuxnEmi
vSmeXU8B9w6YJPgpKG8Wuv9BjCLdvRH3l8VvtgOuWoU1H/wVYvgw/kpIiwgb33bl
FHkWgIxaksaByVLQP0TsIQtxuGyhJSWt5UJr9AivaQKBgQDjUzDxxSd+dd+khOvo
BkkIVI+36qUWhDtM8oe34hLwf9kqfOPOjjZy7ukuesLp2rLsJGnWJMx7nJJ1fPJ9
y8LDchs9x/VWFmxNtHdqDgiffydTN6M6qGQTipRjRvSi9wYvYcRw7FlOMUp/o5rJ
NP/PQGB28y1O/taUdYGDZAWL/QKBgQDQ3XzjoZcgXsNljoPTvQhGY0/ysrsYbZG+
5BHWRopez0UNclFbzoe3Neg/pZQ6+JO8Cm2nBBi8RtxCpVxc56fMYjdpxCZuzO29
K+HJBWlFhzOoJW/q+rwhaGRBGDIn6Is3VQE8GXCUs6BmXN3eDRsk7SdCsjDO/iD6
KyWAxkfmXwKBgD+KzoCWOn7n1fa3zPVTZHC2qmGfbjwIBEdy96rXv7GIGxz8QfVH
3UJtM7LxT7BsmFzXpNnd+WaIEoxSu7mcDjnxmFnBnftNU0K5MjPr7k8fDM//GlpY
HXk04FuLxvASmqD99BoYhrILpyZchfS+Is880HoPaVfOdg6TdftTJxXFAoGAELCy
Sypdfju0V4g05pWjdKR4/gbkRoZy8BMfjcTjR8I+XV22PKTbWXuYTIW5u6CjhZI7
wu3j4B+1eCnooI/ua7mpfe0ruQztLoG0MDEbgW/VY+lh8SAKKo1B/aWmVGQTw98q
ExhhU7Cq76MaI6VeduvwiDbfCZtrHTKXc5vkoPcCgYB4yTIzTIe967szS0cblDMO
yOY+kHS2jzNqJ2d4mi9xzbncypPmj734KY+eoOmQVAOd2RRi7pX/6rwuyEUYtvwr
ljIV9zB2nuk3u4YZxwSof7V+y3aDNbnoZ8vnVc3hVx0TN2V/kU3JQtYjds6SvrTf
1lnwM51nOK4hEn9/x2zqsA==
-----END PRIVATE KEY-----
''';
