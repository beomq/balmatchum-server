import 'dart:async';
import 'package:balmatchum_server/src/billing/billing_verifier.dart';
import 'package:clock/clock.dart' show Clock;
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'billing_fixture.dart';

void main() {
  test(
    'Google acknowledgement strictly parses state and never consumes',
    () async {
      for (final product in ['monthly', 'lifetime']) {
        final pending = product == 'monthly'
            ? subscription()
            : lifetimePurchase();
        pending['acknowledgementState'] = 'ACKNOWLEDGEMENT_STATE_PENDING';
        final verified = Wire()..google(pending);
        expect(
          (await verified.verifyGoogle(
            product: product,
          )).requiresAcknowledgement,
          true,
        );
        for (final state in [
          null,
          'ACKNOWLEDGEMENT_STATE_UNSPECIFIED',
          'other',
        ]) {
          pending['acknowledgementState'] = state;
          await expectLater(
            (Wire()..google(pending)).verifyGoogle(product: product),
            invalid,
          );
        }
        for (final status in [200, 204, 503]) {
          final wire = Wire()
            ..json({
              'access_token': 'server-access-token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            })
            ..responses.add(http.Response('', status));
          final result = GoogleBillingClient(
            config().google!,
            clock: Clock.fixed(now),
            clientFactory: wire.client,
          ).acknowledge(purchaseToken: lookupToken, productId: product);
          if (status == 503) {
            await expectLater(result, unavailable);
          } else {
            await result;
          }
          final request = wire.requests.last;
          expect(request.url.pathSegments, [
            'androidpublisher',
            'v3',
            'applications',
            'test.app',
            'purchases',
            product == 'monthly' ? 'subscriptions' : 'products',
            product,
            'tokens',
            '$lookupToken:acknowledge',
          ]);
          expect(request.method, 'POST');
          expect(request.body, '{}');
          expect(request.url.hasQuery, false);
          expect(request.url.hasFragment, false);
          expect(request.url.toString(), isNot(contains(':consume')));
        }
      }
    },
  );

  test('absent and each partial group fail closed without leaking values', () {
    expect(config({}).apple, isNull);
    expect(config({}).google, isNull);
    for (final key in passwords().keys) {
      expect(() => config(passwords()..remove(key)), misconfigured);
      expect(() => config({key: 'secret-canary'}), misconfigured);
    }
    for (final field in [
      'billingApplePrivateKey',
      'billingGooglePrivateKey',
      'billingAppleProducts',
      'billingGoogleProducts',
      'billingAppleEnvironment',
      'billingGoogleEnvironment',
      'billingGooglePackageName',
      'billingGoogleClientEmail',
    ]) {
      expect(
        () => config(passwords()..[field] = 'secret-canary'),
        misconfigured,
      );
    }
    try {
      config({'billingApplePrivateKey': 'secret-canary'});
    } catch (e) {
      expect(e.toString(), isNot(contains('secret-canary')));
    }
    expect(
      () => config().apple!.products['other'] = BillingProductKind.lifetime,
      throwsUnsupportedError,
    );
  });

  test(
    'Apple HTTP paths, ES256 claims/signature and active expiry boundary',
    () async {
      final wire = Wire()..apple(transaction());
      final facts = await wire.verifyApple();
      expect(facts.state, BillingState.active);
      expect(facts.purchaseReference, '100');
      expect(facts.transactionId, '123');
      expect(facts.isActiveAt(now), isTrue);
      expect(
        facts.isActiveAt(expiry.subtract(const Duration(microseconds: 1))),
        isTrue,
      );
      expect(facts.isActiveAt(expiry), isFalse);
      expect(
        facts.isActiveAt(now.subtract(const Duration(microseconds: 1))),
        isFalse,
      );
      expect(wire.requests.map((r) => r.url.toString()), [
        'https://api.storekit-sandbox.apple.com/inApps/v1/transactions/123',
        'https://api.storekit-sandbox.apple.com/inApps/v1/subscriptions/100',
      ]);
      for (final request in wire.requests) {
        checkJwt(request.headers['authorization']!.substring(7), apple: true);
        expect(request.method, 'GET');
      }
    },
  );

  for (final field in [
    'bundleId',
    'environment',
    'productId',
    'appAccountToken',
    'type',
    'inAppOwnershipType',
    'transactionId',
  ]) {
    test('Apple rejects mismatched $field in trusted transaction', () async {
      final tx = transaction()..[field] = 'wrong';
      final wire = Wire()..apple(tx);
      await expectLater(wire.verifyApple(), invalid);
    });
  }
  test(
    'Apple does not accept a client JWS as lookup or missing owner',
    () async {
      final wire = Wire();
      await expectLater(wire.verifyApple(lookup: jws(transaction())), invalid);
      await expectLater(wire.verifyApple(binding: ''), invalid);
      await expectLater(wire.verifyApple(product: 'unknown'), invalid);
      expect(wire.requests, isEmpty);
      final unbound = Wire()..apple(transaction()..remove('appAccountToken'));
      await expectLater(unbound.verifyApple(), invalid);
    },
  );
  test(
    'Apple latest transaction binding and renewal chain are checked',
    () async {
      for (final field in [
        'bundleId',
        'environment',
        'productId',
        'appAccountToken',
        'originalTransactionId',
      ]) {
        final wire = Wire()
          ..apple(transaction(), latest: transaction()..[field] = 'wrong');
        await expectLater(wire.verifyApple(), invalid);
      }
      for (final field in [
        'environment',
        'originalTransactionId',
        'productId',
        'appAccountToken',
      ]) {
        final wire = Wire()
          ..apple(transaction(), renew: renewal()..[field] = 'wrong');
        await expectLater(wire.verifyApple(), invalid);
      }
    },
  );
  test('Apple uses actual grace deadline, never billing retry alone', () async {
    final tx = transaction()..['expiresDate'] = now.millisecondsSinceEpoch;
    final renew = renewal()
      ..['isInBillingRetryPeriod'] = true
      ..['gracePeriodExpiresDate'] = expiry.millisecondsSinceEpoch;
    final graceWire = Wire()..apple(tx, status: 4, renew: renew);
    final grace = await graceWire.verifyApple();
    expect(grace.isActiveAt(now), isTrue);
    expect(grace.graceExpiresAt, expiry);
    expect(grace.isActiveAt(expiry), isFalse);
    final retryWire = Wire()..apple(tx, status: 3, renew: renew);
    expect((await retryWire.verifyApple()).isActiveAt(now), isFalse);
    final missing = Wire()..apple(tx, status: 4);
    await expectLater(missing.verifyApple(), invalid);
    final boundary = Wire()..apple(tx, status: 4, renew: renew);
    expect(
      (await boundary.verifyApple(instant: expiry)).state,
      BillingState.expired,
    );
  });
  test(
    'Apple lifetime refund and subscription revocation override dates',
    () async {
      for (final lifetime in [true, false]) {
        for (final field in [
          'revocationDate',
          'revocationReason',
          'revocationType',
        ]) {
          final tx = transaction(lifetime: lifetime)
            ..[field] = switch (field) {
              'revocationDate' => now.millisecondsSinceEpoch,
              'revocationReason' => 1,
              _ => 'REFUND',
            };
          final wire = Wire()..apple(tx);
          final facts = await wire.verifyApple(
            product: lifetime ? 'lifetime' : 'monthly',
          );
          expect(facts.state, BillingState.revoked);
          expect(facts.isActiveAt(now), isFalse);
        }
      }
      final wire = Wire()..apple(transaction(lifetime: true));
      expect(
        (await wire.verifyApple(product: 'lifetime')).isActiveAt(expiry),
        isTrue,
      );
    },
  );
  test('Apple malformed data and unknown status fail closed', () async {
    for (final value in ['not-jws', 'e30.e30.AA', null, 1]) {
      final wire = Wire()..json({'signedTransactionInfo': value});
      await expectLater(wire.verifyApple(), invalid);
    }
    for (final patch in [
      <String, dynamic>{'expiresDate': 'tomorrow'},
      {'purchaseDate': expiry.millisecondsSinceEpoch},
      {'isUpgraded': 'true'},
    ]) {
      final wire = Wire()..apple(transaction()..addAll(patch));
      await expectLater(wire.verifyApple(), invalid);
    }
    final unknown = Wire()..apple(transaction(), status: 6);
    await expectLater(unknown.verifyApple(), invalid);
  });

  test('Google OAuth RS256 and token encoded as one path segment', () async {
    final wire = Wire()..google(subscription());
    final facts = await wire.verifyGoogle();
    expect(facts.isActiveAt(now), isTrue);
    expect(facts.isActiveAt(expiry), isFalse);
    expect(facts.purchaseReference, lookupToken);
    final oauth = wire.requests.first;
    expect(oauth.url.toString(), 'https://oauth2.googleapis.com/token');
    expect(oauth.method, 'POST');
    expect(
      oauth.bodyFields['grant_type'],
      'urn:ietf:params:oauth:grant-type:jwt-bearer',
    );
    checkJwt(oauth.bodyFields['assertion']!, apple: false);
    final lookup = wire.requests.last;
    expect(lookup.headers['authorization'], 'Bearer server-access-token');
    expect(lookup.url.host, 'androidpublisher.googleapis.com');
    expect(lookup.url.pathSegments, [
      'androidpublisher',
      'v3',
      'applications',
      'test.app',
      'purchases',
      'subscriptionsv2',
      'tokens',
      lookupToken,
    ]);
    expect(lookup.url.hasQuery, isFalse);
    expect(lookup.url.hasFragment, isFalse);
  });
  for (final state in [
    'PENDING',
    'PENDING_PURCHASE_CANCELED',
    'ON_HOLD',
    'PAUSED',
    'EXPIRED',
  ]) {
    test('Google $state inactive even with a future expiry', () async {
      final result = subscription(state: state);
      if (state.startsWith('PENDING')) result.remove('startTime');
      final wire = Wire()..google(result);
      expect((await wire.verifyGoogle()).isActiveAt(now), isFalse);
    });
  }
  for (final state in ['ACTIVE', 'CANCELED', 'IN_GRACE_PERIOD']) {
    test('Google $state grants only until actual exclusive expiry', () async {
      final wire = Wire()..google(subscription(state: state));
      final facts = await wire.verifyGoogle();
      expect(facts.isActiveAt(now), isTrue);
      expect(facts.isActiveAt(expiry), isFalse);
      final boundary = Wire()..google(subscription(state: state));
      expect(
        (await boundary.verifyGoogle(instant: expiry)).state,
        BillingState.expired,
      );
    });
  }
  test(
    'Google wrong app product environment owner and deferred line rejected',
    () async {
      final patches = [
        <String, dynamic>{'packageName': 'other.app'},
        {'testPurchase': null},
        {
          'externalAccountIdentifiers': {
            'obfuscatedExternalAccountId': 'other',
          },
        },
        {'externalAccountIdentifiers': <String, dynamic>{}},
        {
          'lineItems': [
            {'productId': 'other'},
          ],
        },
        {
          'lineItems': [
            {'productId': 'monthly', 'expiryTime': expiry.toIso8601String()},
          ],
        },
        {'subscriptionState': 'SUBSCRIPTION_STATE_UNSPECIFIED'},
      ];
      for (final patch in patches) {
        final wire = Wire()..google(subscription()..addAll(patch));
        await expectLater(wire.verifyGoogle(), invalid);
      }
      final production = Wire()..google(subscription()..remove('testPurchase'));
      await expectLater(production.verifyGoogle(), invalid);
    },
  );
  test('Google malformed or missing times cannot become active', () async {
    for (final time in [
      null,
      42,
      '2026-10-20',
      '2026-02-30T12:00:00Z',
      'tomorrow',
    ]) {
      final value = subscription();
      (value['lineItems'] as List).first['expiryTime'] = time;
      final wire = Wire()..google(value);
      await expectLater(wire.verifyGoogle(), invalid);
    }
  });
  test('Google lifetime refunds and pending never grant ownership', () async {
    for (final state in ['PENDING', 'CANCELLED']) {
      final wire = Wire()
        ..google(
          lifetimePurchase(state: state)..remove('purchaseCompletionTime'),
        );
      expect(
        (await wire.verifyGoogle(product: 'lifetime')).isActiveAt(now),
        isFalse,
      );
    }
    final refund = lifetimePurchase();
    (refund['productLineItem'] as List)
            .first['productOfferDetails']['refundableQuantity'] =
        0;
    final wire = Wire()..google(refund);
    expect(
      (await wire.verifyGoogle(product: 'lifetime')).state,
      BillingState.revoked,
    );
    final purchased = Wire()..google(lifetimePurchase());
    expect(
      (await purchased.verifyGoogle(product: 'lifetime')).isActiveAt(expiry),
      isTrue,
    );
    expect(purchased.requests.last.url.pathSegments[5], 'productsv2');
  });
  test(
    'Google rejects rental, unbound, wrong product and malformed test purchase',
    () async {
      for (final field in ['rentOfferDetails', 'preorderOfferDetails']) {
        final value = lifetimePurchase();
        (value['productLineItem'] as List).first['productOfferDetails'][field] =
            <String, dynamic>{};
        final wire = Wire()..google(value);
        await expectLater(wire.verifyGoogle(product: 'lifetime'), invalid);
      }
      for (final patch in [
        <String, dynamic>{'obfuscatedExternalAccountId': null},
        {
          'testPurchaseContext': {'fopType': 'unknown'},
        },
        {'productLineItem': []},
      ]) {
        final wire = Wire()..google(lifetimePurchase()..addAll(patch));
        await expectLater(wire.verifyGoogle(product: 'lifetime'), invalid);
      }
    },
  );

  test(
    'HTTP redirects fail without a second request or exposed credentials',
    () async {
      for (final status in [301, 302, 303, 307, 308, 401, 403, 429, 500]) {
        final wire = Wire()
          ..responses.add(
            http.Response(
              'secret-canary',
              status,
              headers: {'location': 'https://attacker.test/steal'},
            ),
          );
        await expectLater(wire.verifyApple(product: 'lifetime'), unavailable);
        expect(wire.requests, hasLength(1));
      }
      for (final status in [404, 410]) {
        final wire = Wire()
          ..responses.add(http.Response('secret-canary', status));
        await expectLater(wire.verifyApple(), invalid);
      }
    },
  );
  test(
    'HTTP invalid JSON and body limit reject without parsing fabricated facts',
    () async {
      for (final body in ['{secret-canary', '[]', 'x' * (1024 * 1024 + 1)]) {
        final wire = Wire()..responses.add(http.Response(body, 200));
        await expectLater(wire.verifyApple(), invalid);
      }
    },
  );
  test('HTTP streaming limit cancels stream and closes client', () async {
    final canceled = Completer<void>();
    final stream = StreamController<List<int>>(
      onCancel: () {
        canceled.complete();
      },
    );
    final client = StreamClient(stream.stream);
    final pending =
        AppleBillingClient(
          config().apple!,
          clock: Clock.fixed(now),
          clientFactory: () => client,
        ).verify(
          transactionId: '123',
          productId: 'lifetime',
          expectedAppAccountToken: owner,
        );
    final assertion = expectLater(pending, invalid);
    stream.add(List.filled(1024 * 1024 + 1, 32));
    await assertion;
    await canceled.future.timeout(const Duration(seconds: 2));
    expect(client.closed, isTrue);
    await stream.close();
  });
  test('HTTP exceptions are scrubbed and client is closed', () async {
    final client = StreamClient(Stream.error(StateError('secret-canary')));
    final verifier = AppleBillingClient(
      config().apple!,
      clientFactory: () => client,
    );
    try {
      await verifier.verify(
        transactionId: '123',
        productId: 'lifetime',
        expectedAppAccountToken: owner,
      );
      fail('Expected failure');
    } on BillingVerificationException catch (e) {
      expect(e.code, BillingFailure.unavailable);
      expect(e.toString(), isNot(contains('secret-canary')));
    }
    expect(client.closed, isTrue);
  });
  test('Google invalid OAuth never reaches Publisher', () async {
    for (final response in [
      <String, dynamic>{},
      {
        'access_token': 'secret\nheader',
        'token_type': 'Bearer',
        'expires_in': 3600,
      },
      {'access_token': 'valid', 'token_type': 'Bearer', 'expires_in': 0},
    ]) {
      final wire = Wire()..json(response);
      await expectLater(wire.verifyGoogle(), invalid);
      expect(wire.requests, hasLength(1));
    }
  });
  test('production configuration selects only production evidence', () async {
    final settings = config(
      passwords()
        ..['billingAppleEnvironment'] = 'production'
        ..['billingGoogleEnvironment'] = 'production',
    );
    final apple = Wire()
      ..apple(transaction(lifetime: true)..['environment'] = 'Production');
    expect(
      (await apple.verifyApple(
        product: 'lifetime',
        settings: settings,
      )).isActiveAt(now),
      isTrue,
    );
    expect(apple.requests.single.url.host, 'api.storekit.apple.com');
    final google = Wire()..google(subscription()..remove('testPurchase'));
    expect(
      (await google.verifyGoogle(settings: settings)).isActiveAt(now),
      isTrue,
    );
    final wrong = Wire()..google(subscription());
    await expectLater(wrong.verifyGoogle(settings: settings), invalid);
  });
  test(
    'Google redirects at OAuth or Publisher never follow location',
    () async {
      for (final atPublisher in [false, true]) {
        final wire = Wire();
        if (atPublisher) {
          wire.json({
            'access_token': 'server-access-token',
            'token_type': 'Bearer',
            'expires_in': 3600,
          });
        }
        wire.responses.add(
          http.Response(
            '',
            302,
            headers: {'location': 'https://attacker.test'},
          ),
        );
        await expectLater(wire.verifyGoogle(), unavailable);
        expect(wire.requests, hasLength(atPublisher ? 2 : 1));
      }
    },
  );
  test(
    'whole HTTP deadline closes client without wall-clock waiting',
    () async {
      final sent = Completer<void>();
      final response = Completer<http.StreamedResponse>();
      final client = PendingClient(sent, response);
      late ManualTimer deadline;
      final pending = runZoned(
        () => AppleBillingClient(config().apple!, clientFactory: () => client)
            .verify(
              transactionId: '123',
              productId: 'lifetime',
              expectedAppAccountToken: owner,
            ),
        zoneSpecification: ZoneSpecification(
          createTimer: (self, parent, zone, duration, callback) {
            expect(duration, const Duration(seconds: 10));
            return deadline = ManualTimer(zone.bindCallback(callback));
          },
        ),
      );
      final assertion = expectLater(pending, unavailable);
      await sent.future.timeout(const Duration(seconds: 2));
      deadline.fire();
      await assertion;
      expect(client.closed, isTrue);
      response.complete(http.StreamedResponse(const Stream.empty(), 500));
    },
  );
}

class ManualTimer implements Timer {
  ManualTimer(this.callback);
  final void Function() callback;
  bool active = true;
  int ticks = 0;
  void fire() {
    if (!active) return;
    active = false;
    ticks++;
    callback();
  }

  @override
  void cancel() {
    active = false;
  }

  @override
  bool get isActive => active;
  @override
  int get tick => ticks;
}

class PendingClient extends http.BaseClient {
  PendingClient(this.sent, this.response);
  final Completer<void> sent;
  final Completer<http.StreamedResponse> response;
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    sent.complete();
    return response.future;
  }

  @override
  void close() {
    closed = true;
  }
}

class StreamClient extends http.BaseClient {
  StreamClient(this.stream);
  final Stream<List<int>> stream;
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(stream, 200);
  @override
  void close() {
    closed = true;
  }
}
