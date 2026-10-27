import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/ads/ad_config.dart';
import 'package:balmatchum_server/src/ads/ad_service.dart';
import 'package:balmatchum_server/src/ads/ad_verifier.dart';
import 'package:balmatchum_server/src/billing/billing_retention.dart';
import 'package:balmatchum_server/src/billing/billing_service.dart';
import 'package:balmatchum_server/src/billing/billing_verifier.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/quiz/quiz_bank.dart';
import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/protocol.dart' show FutureCallEntry;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../unit/billing/billing_fixture.dart' as fixture;
import '../test_utils/ad_test_keys.dart';
import '../test_utils/quiz_fixture.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

const bound = Duration(seconds: 10);
final identityKey = base64Encode(List.filled(32, 42));

void main() {
  late generated.Serverpod pod;
  late Session admin;
  late Directory directory;
  final callers = <api.Client>[];
  final responses = <String, Map<String, dynamic>>{};
  final lookupStatus = <String, int>{};
  final acknowledgements = <String>[];
  var ackFails = false;
  String? heldLookup;
  Completer<void>? lookupEntered;
  Completer<void>? releaseLookup;
  Completer<void>? ackEntered;
  Completer<void>? releaseAck;
  var queryCount = 0;
  var freshSequence = 98000;
  var now = fixture.now;
  var storeUnavailable = false;
  var adSequence = 0;
  late AdService ads;

  Matcher failure(String code) =>
      throwsA(isA<api.BillingException>().having((e) => e.code, 'code', code));

  api.Client client([String? token]) {
    final c = api.Client('http://localhost:${pod.server.port}/');
    if (token != null) c.authKeyProvider = _Token(token);
    callers.add(c);
    return c;
  }

  Future<({api.Client client, String owner, String binding})> user() async {
    final u = await AuthServices.instance.authUsers.create(admin);
    final token = await AuthServices.instance.tokenManager.issueToken(
      admin,
      authUserId: u.id,
      method: 'billing-test',
    );
    final c = client(token.token);
    final config = await c.billing.getPurchaseConfiguration('google');
    return (client: c, owner: u.id.uuid, binding: config.accountBinding);
  }

  api.PurchaseInput input(
    String token, {
    String product = 'lifetime',
    String store = 'google',
  }) => api.PurchaseInput(
    store: store,
    productId: product,
    purchaseReference: token,
  );

  void purchase(
    String token,
    String binding, {
    String state = 'PURCHASED',
    bool pendingAck = false,
  }) {
    responses[token] = fixture.lifetimePurchase(state: state)
      ..['obfuscatedExternalAccountId'] = binding
      ..['acknowledgementState'] = pendingAck
          ? 'ACKNOWLEDGEMENT_STATE_PENDING'
          : 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED';
  }

  String hash(String store, String reference) =>
      Hmac(sha256, base64Decode(identityKey))
          .convert(
            utf8.encode(
              jsonEncode(['billing-purchase-v1', store, 'sandbox', reference]),
            ),
          )
          .toString();

  Future<http.Response> external(http.Request request) async {
    expect(request.followRedirects, false);
    expect(request.url.scheme, 'https');
    if (request.url.host == 'oauth2.googleapis.com') {
      return http.Response(
        jsonEncode({
          'access_token': 'test-access',
          'token_type': 'Bearer',
          'expires_in': 3600,
        }),
        200,
      );
    }
    final segment = request.url.pathSegments.last;
    if (segment.endsWith(':acknowledge')) {
      final token = segment.substring(
        0,
        segment.length - ':acknowledge'.length,
      );
      expect(request.method, 'POST');
      expect(request.body, '{}');
      expect(request.url.pathSegments[5], anyOf('products', 'subscriptions'));
      acknowledgements.add(token);
      // A separate connection observes committed persistence before HTTP ack.
      final row = await StoredPurchase.db.findFirstRow(
        admin,
        where: (t) => t.identityHash.equals(hash('google', token)),
      );
      expect(row, isNotNull);
      expect(row!.acknowledgementPending, true);
      // No DB owner lock remains held during an external request.
      await admin.db.transaction(
        (tx) => admin.db.unsafeQuery(
          'SELECT id FROM serverpod_auth_core_user WHERE id = CAST(@owner AS uuid) FOR UPDATE NOWAIT',
          parameters: QueryParameters.named({'owner': row.owner}),
          transaction: tx,
        ),
      );
      final entered = ackEntered;
      if (entered != null && !entered.isCompleted) {
        entered.complete();
        await releaseAck!.future.timeout(bound);
      }
      if (ackFails) return http.Response('private-upstream-error', 503);
      responses[token]!['acknowledgementState'] =
          'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED';
      return http.Response('', 200);
    }
    expect(request.method, 'GET');
    queryCount++;
    final persisted = await StoredPurchase.db.findFirstRow(
      admin,
      where: (t) => t.identityHash.equals(hash('google', segment)),
    );
    if (persisted != null) {
      // The real HTTP verifier must never execute inside the owner transaction.
      await admin.db.transaction(
        (tx) => admin.db.unsafeQuery(
          'SELECT id FROM serverpod_auth_core_user WHERE id = CAST(@owner AS uuid) FOR UPDATE NOWAIT',
          parameters: QueryParameters.named({'owner': persisted.owner}),
          transaction: tx,
        ),
      );
    }
    // Snapshot before releasing the second request, so the first really carries
    // stale active data rather than merely returning the later fixture value.
    final value = responses[segment];
    final body = jsonEncode(value);
    if (heldLookup == segment && !lookupEntered!.isCompleted) {
      lookupEntered!.complete();
      await releaseLookup!.future.timeout(bound);
    }
    if (storeUnavailable) return http.Response('unavailable', 503);
    if (lookupStatus[segment] case final int status) {
      return http.Response('private-store-error', status);
    }
    if (value == null) return http.Response('private-token-not-found', 404);
    if (request.url.host == 'api.storekit-sandbox.apple.com') {
      return http.Response(
        jsonEncode({
          'signedTransactionInfo': fixture.jws(
            jsonDecode(body) as Map<String, dynamic>,
          ),
        }),
        200,
      );
    }
    return http.Response(body, 200);
  }

  BillingService service() {
    final settings = fixture.config();
    return BillingService(
      settings,
      identityKey,
      clock: Clock(() => now),
      apple: AppleBillingClient(
        settings.apple!,
        clock: Clock(() => now),
        clientFactory: () => MockClient(external),
      ),
      google: GoogleBillingClient(
        settings.google!,
        clock: Clock(() => now),
        clientFactory: () => MockClient(external),
      ),
    );
  }

  Future<void> noOwner(String owner) async {
    expect(
      await StoredPurchase.db.count(admin, where: (t) => t.owner.equals(owner)),
      0,
    );
    expect(
      await BillingAccount.db.count(admin, where: (t) => t.owner.equals(owner)),
      0,
    );
    expect(
      await AuthUser.db.findById(admin, UuidValue.fromString(owner)),
      isNull,
    );
  }

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('billing-http-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        database: PostgresDatabaseConfig.embedded(
          dataPath: '${directory.path}/pgdata',
          name: 'billing_test',
          maxConnectionCount: 10,
        ),
      ),
    );
    configureAuth(pod, sessionPepper: 'public-billing-test-only');
    BillingService.instances[pod] = service();
    await withClock(Clock(() => now), () => pod.start(runInGuardedZone: false));
    admin = await pod.createSession(enableLogging: false);
    ads = AdService(
      AdConfig({
        'dailyReward': const AdPlacement(
          (
            ios: 'ca-app-pub-0000000000000001/1000000001',
            android: 'ca-app-pub-0000000000000001/1000000002',
          ),
          'points',
          '1',
        ),
        'extraQuiz': const AdPlacement(
          (
            ios: 'ca-app-pub-0000000000000001/2000000001',
            android: 'ca-app-pub-0000000000000001/2000000002',
          ),
          'points',
          '1',
        ),
      }),
      AdVerifier(loadKeys: () async => adKeys(), clock: Clock(() => now)),
      clock: Clock(() => now),
    );
    AdService.instances[pod] = ads;
  });
  setUp(() async {
    now = fixture.now;
    storeUnavailable = false;
    await configureQuizBank(pod, bank: fixtureBank());
  });
  tearDown(() {
    if (releaseLookup != null && !releaseLookup!.isCompleted) {
      releaseLookup!.complete();
    }
    if (releaseAck != null && !releaseAck!.isCompleted) releaseAck!.complete();
    heldLookup = null;
    lookupEntered = releaseLookup = ackEntered = releaseAck = null;
    ackFails = false;
  });
  tearDownAll(() async {
    for (final c in callers) {
      c.close();
    }
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  });

  Matcher productFailure(String code) => throwsA(
    isA<api.ProductException>().having((e) => e.code, 'code', code),
  );

  for (final store in ['google', 'apple']) {
    for (final benefit in [false, true]) {
      for (final status in [410, 503]) {
        for (final hasActive in [false, true]) {
          test(
            'fresh $store benefit=$benefit status=$status active=$hasActive',
            () async {
              // Given: cached active rows must not substitute for fresh proof.
              final a = await user();
              final bad = '${++freshSequence}';
              final good = '${++freshSequence}';
              for (final reference in [bad, if (hasActive) good]) {
                if (store == 'apple') {
                  responses[reference] = fixture.transaction(lifetime: true)
                    ..['transactionId'] = reference
                    ..['originalTransactionId'] = reference
                    ..['appAccountToken'] = a.binding;
                } else {
                  purchase(reference, a.binding);
                  responses[reference]!['orderId'] = 'order-$reference';
                }
                await a.client.billing.verifyPurchase(
                  input(reference, store: store),
                );
              }
              lookupStatus[bad] = status;
              Future<bool> check() async => benefit
                  ? (await a.client.quiz.getTodayWithPremium()).paidEntitlement
                  : (await a.client.billing.getEntitlement()).active;

              // When / Then: the real endpoint must classify each store result.
              try {
                if (status == 503 && !hasActive) {
                  await expectLater(check(), failure('temporarilyUnavailable'));
                } else {
                  expect(await check(), hasActive);
                  final rows = await StoredPurchase.db.find(
                    admin,
                    where: (t) => t.owner.equals(a.owner),
                  );
                  expect(rows, hasLength(hasActive ? 2 : 1));
                  if (status == 410) {
                    // A reference the store no longer knows is not a refund.
                    expect(
                      rows.firstWhere((r) => r.purchaseReference == bad).state,
                      'expired',
                    );
                    final before = queryCount;
                    expect(await check(), hasActive);
                    expect(queryCount - before, hasActive ? 2 : 1);
                    await a.client.account.deleteAccount();
                    final record = (await RetainedPaymentRecord.db.find(
                      admin,
                      where: (t) => t.storeTransactionId.equals(
                        store == 'apple' ? bad : 'order-$bad',
                      ),
                    )).single;
                    expect(record.state, 'expired');
                  } else {
                    final view = await a.client.billing.getEntitlement();
                    expect(view.purchases.where((p) => p.active), hasLength(1));
                  }
                }
              } finally {
                lookupStatus.remove(bad);
              }
            },
          );
        }
      }
    }
  }

  Future<String> storedState(String owner, String reference) async =>
      (await StoredPurchase.db.findFirstRow(
        admin,
        where: (t) =>
            t.owner.equals(owner) & t.purchaseReference.equals(reference),
      ))!.state;

  test(
    'response anomaly keeps the stored state and a later valid answer restores access',
    () async {
      // Given: the only verified purchase now gets a response failing validation.
      final a = await user();
      const token = 'anomaly-only';
      purchase(token, a.binding);
      await a.client.billing.verifyPurchase(input(token));
      purchase(token, a.binding, state: 'UNEXPECTED_STATE');
      await expectLater(
        a.client.billing.getEntitlement(),
        failure('invalidPurchase'),
      );
      expect(await storedState(a.owner, token), 'active');

      // When: the store answers validly again.
      purchase(token, a.binding);

      // Then: server revalidation alone restores access.
      expect((await a.client.billing.getEntitlement()).active, true);
    },
  );

  test(
    'response anomaly on one row neither changes it nor blocks another active row',
    () async {
      // Given: two verified purchases, one of which now answers anomalously.
      final a = await user();
      for (final token in ['anomaly-row', 'anomaly-good']) {
        purchase(token, a.binding);
        await a.client.billing.verifyPurchase(input(token));
      }
      purchase('anomaly-row', a.binding, state: 'UNEXPECTED_STATE');

      // When
      final view = await a.client.billing.getEntitlement();

      // Then: only the freshly verified row grants; the anomalous row is untouched.
      expect(view.active, true);
      expect(view.purchases.where((p) => p.active), hasLength(1));
      expect(await storedState(a.owner, 'anomaly-row'), 'active');
    },
  );

  Future<api.DailyRecord> steps(
    api.Client c,
    int total, {
    String? date,
    int revision = 1,
  }) async {
    final day = date ?? localDate(now);
    var generation = (await c.product.getWallet()).streamGeneration;
    if (generation == 0) {
      generation = await c.product.registerStepStream('stream', 0);
    }
    return c.product.submitSteps(
      api.DailyStepInput(
        date: day,
        streamGeneration: generation,
        revision: revision,
        windowStart: dayStart(day),
        windowEnd: dayStart(day).add(const Duration(days: 1)),
        observedAt: now,
        availability: 'confirmed',
        total: total,
      ),
    );
  }

  Future<api.AdIntent> verifiedAd(
    api.Client c,
    String purpose,
    String date,
    int revision,
  ) async {
    final intent = await c.ads.createIntent(
      purpose,
      date,
      revision,
      api.AdPlatform.android,
    );
    await ads.callback(
      admin,
      signAd(
        'ad_network=123&ad_unit=${intent.adUnit}&custom_data=${intent.customData}'
        '&reward_amount=1&reward_item=points'
        '&timestamp=${now.millisecondsSinceEpoch}&transaction_id=${(++adSequence).toRadixString(16)}'
        '&user_id=${intent.userId}',
      ),
    );
    return intent;
  }

  Future<api.QuizToday> answeredFree(api.Client c) async {
    final q = (await c.quiz.getToday()).free!;
    await c.quiz.answer(
      q.assignmentId,
      q.questionId,
      q.version,
      1,
      'free-answer',
    );
    return c.quiz.getToday();
  }

  test(
    'all stored purchases are refreshed under one benefit sequence',
    () async {
      final a = await user();
      for (final token in ['multi-active', 'multi-refunded']) {
        purchase(token, a.binding);
        await a.client.billing.verifyPurchase(input(token));
      }
      purchase('multi-refunded', a.binding, state: 'CANCELLED');
      final d = await steps(a.client, 100);
      final before = queryCount;
      expect(
        (await a.client.product.claimDayWithPremium(
          d.date,
          'multi',
          d.revision,
        )).amount,
        2,
      );
      expect(queryCount, before + 2);
      final rows = await StoredPurchase.db.find(
        admin,
        where: (t) => t.owner.equals(a.owner),
      );
      expect(rows.map((r) => r.sequence).toSet(), hasLength(1));
      expect(rows.map((r) => r.state), contains('revoked'));
      final more = await steps(a.client, 200, revision: 2);
      responses.remove('multi-refunded');
      expect(
        (await a.client.product.claimDayWithPremium(
          more.date,
          'partial-failure',
          more.revision,
        )).amount,
        2,
      );
      expect((await a.client.product.getWallet()).balance, 4);
    },
  );

  test(
    'store subscription grace permits benefits only before exclusive end',
    () async {
      final a = await user();
      responses['benefit-store-grace'] =
          fixture.subscription(state: 'IN_GRACE_PERIOD')
            ..['externalAccountIdentifiers'] = {
              'obfuscatedExternalAccountId': a.binding,
            };
      await a.client.billing.verifyPurchase(
        input('benefit-store-grace', product: 'monthly'),
      );
      final d = await steps(a.client, 100);
      expect(
        (await a.client.product.claimDayWithPremium(
          d.date,
          'in-grace',
          d.revision,
        )).amount,
        2,
      );
      final more = await steps(a.client, 200, revision: 2);
      now = fixture.expiry;
      await expectLater(
        a.client.product.claimDayWithPremium(
          more.date,
          'end-grace',
          more.revision,
        ),
        failure('entitlementInactive'),
      );
      expect((await a.client.product.getWallet()).balance, 2);
    },
  );

  test(
    'failed premium transaction rolls back slices ledger and request then retries',
    () async {
      final a = await user();
      purchase('benefit-rollback', a.binding);
      await a.client.billing.verifyPurchase(input('benefit-rollback'));
      final d = await steps(a.client, 100);
      await admin.db.unsafeExecute(
        "CREATE FUNCTION reject_paid_request() RETURNS trigger LANGUAGE plpgsql AS 'BEGIN RAISE EXCEPTION ''test failure''; END'",
      );
      await admin.db.unsafeExecute(
        'CREATE TRIGGER reject_paid_request BEFORE INSERT ON product_request FOR EACH ROW EXECUTE FUNCTION reject_paid_request()',
      );
      try {
        await expectLater(
          a.client.product.claimDayWithPremium(
            d.date,
            'retry-rollback',
            d.revision,
          ),
          failure('temporarilyUnavailable'),
        );
        expect((await a.client.product.getWallet()).balance, 0);
        expect((await a.client.product.getDay(d.date)).revision, d.revision);
        expect((await a.client.product.getDay(d.date)).adClaimablePoints, 2);
      } finally {
        await admin.db.unsafeExecute(
          'DROP TRIGGER reject_paid_request ON product_request',
        );
        await admin.db.unsafeExecute('DROP FUNCTION reject_paid_request()');
      }
      expect(
        (await a.client.product.claimDayWithPremium(
          d.date,
          'retry-rollback',
          d.revision,
        )).amount,
        2,
      );
    },
  );

  test(
    'premium APIs require authentication and honestly distinguish unchecked eligibility',
    () async {
      final anon = client();
      for (final call in <Future<Object> Function()>[
        () => anon.product.claimDayWithPremium('2026-10-19', 'x', 1),
        () => anon.quiz.unlockExtraWithPremium('2026-10-19', 1, 'x'),
        () => anon.quiz.getTodayWithPremium(),
      ]) {
        await expectLater(
          call(),
          throwsA(isA<api.ServerpodClientUnauthorized>()),
        );
      }
      final a = await user();
      final ordinary = await a.client.quiz.getToday();
      expect(ordinary.premiumStatus, 'notChecked');
      final inactive = await a.client.quiz.getTodayWithPremium();
      expect(inactive.paidEntitlement, false);
      expect(inactive.premiumStatus, 'inactive');
      final d = await steps(a.client, 100);
      await expectLater(
        a.client.product.claimDayWithPremium(d.date, 'no-paid', d.revision),
        failure('entitlementInactive'),
      );
      expect(
        (await a.client.product.claimDay(d.date, 'free-ok', d.revision)).amount,
        1,
      );
    },
  );

  test(
    'premium total 2x shares slices with free and ad, cap and no topup',
    () async {
      final a = await user();
      purchase('benefit-slices', a.binding);
      await a.client.billing.verifyPurchase(input('benefit-slices'));
      var d = await steps(a.client, 7000);
      expect(
        (await a.client.product.claimDay(d.date, 'free70', d.revision)).amount,
        70,
      );
      d = await a.client.product.getDay(d.date);
      await expectLater(
        a.client.product.claimDayWithPremium(d.date, 'no-topup', d.revision),
        productFailure('nothingToClaim'),
      );
      d = await steps(a.client, 9000, revision: 2);
      final before = queryCount;
      final paid = await a.client.product.claimDayWithPremium(
        d.date,
        'paid20',
        d.revision,
      );
      expect(queryCount, before + 1);
      expect(paid.amount, 40);
      expect(paid.basePoints, 20);
      expect(paid.multiplier, 2);
      expect(paid.slices!.single.fromUnits, 70);
      expect(paid.slices!.single.throughUnits, 90);
      d = await steps(a.client, 50000, revision: 3);
      final intent = await verifiedAd(
        a.client,
        'dailyReward',
        d.date,
        d.revision,
      );
      expect(
        (await a.client.product.claimDayWithAd(
          d.date,
          'ad10',
          d.revision,
          intent.id,
        )).amount,
        20,
      );
      d = await a.client.product.getDay(d.date);
      await expectLater(
        a.client.product.claimDayWithPremium(d.date, 'no-ad-topup', d.revision),
        productFailure('nothingToClaim'),
      );
      expect((await a.client.product.getWallet()).balance, 130);
      final b = await user();
      purchase('benefit-cap', b.binding);
      await b.client.billing.verifyPurchase(input('benefit-cap'));
      final cap = await steps(b.client, 99999);
      expect(
        (await b.client.product.claimDayWithPremium(
          cap.date,
          'cap',
          cap.revision,
        )).amount,
        200,
      );
    },
  );

  test(
    'premium consumes expired unclaimed slices without extending old grace',
    () async {
      final a = await user();
      purchase('benefit-grace', a.binding);
      await a.client.billing.verifyPurchase(input('benefit-grace'));
      final oldDate = localDate(now.subtract(const Duration(days: 20)));
      await steps(a.client, 7000, date: oldDate);
      now = now.add(const Duration(hours: 72));
      var d = await steps(a.client, 9000, date: oldDate, revision: 2);
      expect(d.claimablePoints, 20);
      expect(d.adClaimablePoints, 180);
      expect(
        (await a.client.product.claimDay(
          d.date,
          'new-free',
          d.revision,
        )).amount,
        20,
      );
      d = await a.client.product.getDay(d.date);
      expect(d.rewardStatus, 'adRequired');
      final grant = await a.client.product.claimDayWithPremium(
        d.date,
        'old-paid',
        d.revision,
      );
      expect(grant.amount, 140);
      expect(grant.slices!.single.fromUnits, 0);
      expect(grant.slices!.single.throughUnits, 70);
    },
  );

  test(
    'premium replay after revocation deletion and outage does not revalidate or topup',
    () async {
      final a = await user();
      purchase('benefit-replay', a.binding);
      await a.client.billing.verifyPurchase(input('benefit-replay'));
      final d = await steps(a.client, 100);
      final grant = await a.client.product.claimDayWithPremium(
        d.date,
        'replay-paid',
        d.revision,
      );
      purchase('benefit-replay', a.binding, state: 'CANCELLED');
      await a.client.billing.getEntitlement();
      await a.client.product.deleteDay(d.date, 'delete-paid-day');
      storeUnavailable = true;
      final before = queryCount;
      final replay = await a.client.product.claimDayWithPremium(
        d.date,
        'replay-paid',
        d.revision,
      );
      expect(replay.ledgerId, grant.ledgerId);
      expect(queryCount, before);
      await expectLater(
        a.client.product.claimDayWithPremium(
          d.date,
          'replay-paid',
          d.revision + 1,
        ),
        productFailure('idempotencyConflict'),
      );
      expect((await a.client.product.getWallet()).balance, 2);
    },
  );

  test(
    'revoked unavailable and expired purchases cannot consume either premium benefit',
    () async {
      for (final state in ['revoked', 'unavailable', 'expired']) {
        final a = await user();
        final token = 'benefit-$state';
        if (state == 'expired') {
          responses[token] = fixture.subscription()
            ..['externalAccountIdentifiers'] = {
              'obfuscatedExternalAccountId': a.binding,
            };
          await a.client.billing.verifyPurchase(
            input(token, product: 'monthly'),
          );
          now = fixture.expiry;
        } else {
          purchase(token, a.binding);
          await a.client.billing.verifyPurchase(input(token));
          if (state == 'revoked') {
            purchase(token, a.binding, state: 'CANCELLED');
          }
        }
        final d = await steps(a.client, 100);
        final q = await answeredFree(a.client);
        storeUnavailable = state == 'unavailable';
        final code = storeUnavailable
            ? 'temporarilyUnavailable'
            : 'entitlementInactive';
        await expectLater(
          a.client.product.claimDayWithPremium(
            d.date,
            'blocked-step',
            d.revision,
          ),
          failure(code),
        );
        await expectLater(
          a.client.quiz.unlockExtraWithPremium(
            q.date,
            q.extraRevision!,
            'blocked-quiz',
          ),
          failure(code),
        );
        expect((await a.client.product.getWallet()).balance, 0);
        expect((await a.client.quiz.getToday()).extra, isNull);
        storeUnavailable = false;
        now = fixture.now;
      }
    },
  );

  test(
    'premium quiz requires free answer, shares one extra quota and pays only 2P once',
    () async {
      final a = await user();
      purchase('benefit-quiz', a.binding);
      await a.client.billing.verifyPurchase(input('benefit-quiz'));
      var t = await a.client.quiz.getTodayWithPremium();
      expect(t.paidEntitlement, true);
      expect(t.premiumStatus, 'active');
      expect(t.extraStatus, 'freeRequired');
      await expectLater(
        a.client.quiz.unlockExtraWithPremium(
          t.date,
          t.free!.assignmentId,
          'before-free',
        ),
        productFailure('freeRequired'),
      );
      await answeredFree(a.client);
      t = await a.client.quiz.getTodayWithPremium();
      expect(t.extraStatus, 'premiumAvailable');
      final intent = await verifiedAd(
        a.client,
        'extraQuiz',
        t.date,
        t.extraRevision!,
      );
      final q = await a.client.quiz.unlockExtraWithPremium(
        t.date,
        t.extraRevision!,
        'premium-extra',
      );
      expect(q.slot, 'extra');
      expect(q.correctIndex, isNull);
      final answer = await a.client.quiz.answer(
        q.assignmentId,
        q.questionId,
        q.version,
        1,
        'extra-answer',
      );
      expect(answer.awardedPoints, 2);
      expect(
        (await a.client.quiz.answer(
          q.assignmentId,
          q.questionId,
          q.version,
          1,
          'extra-answer-again',
        )).awardedPoints,
        2,
      );
      expect((await a.client.quiz.review(q.assignmentId)).awardedPoints, 2);
      await expectLater(
        a.client.quiz.unlockExtra(
          t.date,
          t.extraRevision!,
          intent.id,
          'ad-overlap',
        ),
        productFailure('dailyLimitReached'),
      );
      await expectLater(
        a.client.quiz.unlockExtraWithPremium(
          t.date,
          t.extraRevision!,
          'second-premium',
        ),
        productFailure('dailyLimitReached'),
      );
      expect((await a.client.ads.getIntent(intent.id)).status, 'verified');
      final entries = await PointEntry.db.find(
        admin,
        where: (e) => e.owner.equals(a.owner),
      );
      expect(entries, hasLength(2));
      expect(entries.fold<int>(0, (n, e) => n + e.amount), 4);
      purchase('benefit-quiz', a.binding, state: 'CANCELLED');
      storeUnavailable = true;
      final before = queryCount;
      expect(
        (await a.client.quiz.unlockExtraWithPremium(
          t.date,
          t.extraRevision!,
          'premium-extra',
        )).assignmentId,
        q.assignmentId,
      );
      expect(queryCount, before);
    },
  );

  test(
    'premium quiz cannot bypass ad-used quota or unavailable exhausted content',
    () async {
      final a = await user();
      purchase('quiz-ad-first', a.binding);
      await a.client.billing.verifyPurchase(input('quiz-ad-first'));
      final t = await answeredFree(a.client);
      final ad = await verifiedAd(
        a.client,
        'extraQuiz',
        t.date,
        t.extraRevision!,
      );
      await a.client.quiz.unlockExtra(
        t.date,
        t.extraRevision!,
        ad.id,
        'ad-first',
      );
      await expectLater(
        a.client.quiz.unlockExtraWithPremium(
          t.date,
          t.extraRevision!,
          'paid-after-ad',
        ),
        productFailure('dailyLimitReached'),
      );
      final b = await user();
      purchase('quiz-content', b.binding);
      await b.client.billing.verifyPurchase(input('quiz-content'));
      await configureQuizBank(pod, bank: fixtureBank(1));
      final free = (await b.client.quiz.getToday()).free!;
      await b.client.quiz.answer(
        free.assignmentId,
        free.questionId,
        free.version,
        0,
        'free-one',
      );
      expect(
        (await b.client.quiz.getTodayWithPremium()).extraStatus,
        'exhausted',
      );
      await expectLater(
        b.client.quiz.unlockExtraWithPremium(
          free.date,
          free.assignmentId,
          'exhausted',
        ),
        productFailure('exhausted'),
      );
      QuizBank.instances[pod] = null;
      await expectLater(
        b.client.quiz.unlockExtraWithPremium(
          free.date,
          free.assignmentId,
          'missing',
        ),
        productFailure('contentUnavailable'),
      );
    },
  );

  test(
    'later refund or failed observation invalidates premium while HTTP is in flight',
    () async {
      for (final laterFails in [false, true]) {
        final a = await user();
        final token = 'race-later-$laterFails';
        purchase(token, a.binding);
        await a.client.billing.verifyPurchase(input(token));
        final d = await steps(a.client, 100);
        heldLookup = token;
        lookupEntered = Completer<void>();
        releaseLookup = Completer<void>();
        final pending = expectLater(
          a.client.product.claimDayWithPremium(
            d.date,
            'stale-paid',
            d.revision,
          ),
          failure('staleObservation'),
        );
        await lookupEntered!.future.timeout(bound);
        if (laterFails) {
          storeUnavailable = true;
          await expectLater(
            a.client.billing.getEntitlement(),
            failure('temporarilyUnavailable'),
          );
          storeUnavailable = false;
        } else {
          purchase(token, a.binding, state: 'CANCELLED');
          expect((await a.client.billing.getEntitlement()).active, false);
        }
        releaseLookup!.complete();
        await pending.timeout(bound);
        expect((await a.client.product.getWallet()).balance, 0);
        heldLookup = null;
      }
    },
  );

  test(
    'consumption rechecks expiry and sequence after verified persistence and acknowledgement',
    () async {
      for (final expire in [true, false]) {
        final a = await user();
        final token = 'after-verify-$expire';
        responses[token] = fixture.subscription()
          ..['externalAccountIdentifiers'] = {
            'obfuscatedExternalAccountId': a.binding,
          };
        await a.client.billing.verifyPurchase(input(token, product: 'monthly'));
        final d = await steps(a.client, 100);
        responses[token]!['acknowledgementState'] =
            'ACKNOWLEDGEMENT_STATE_PENDING';
        ackEntered = Completer<void>();
        releaseAck = Completer<void>();
        final pending = expectLater(
          a.client.product.claimDayWithPremium(
            d.date,
            'consumption-check',
            d.revision,
          ),
          failure(expire ? 'entitlementInactive' : 'staleObservation'),
        );
        await ackEntered!.future.timeout(bound);
        if (expire) {
          now = fixture.expiry;
        } else {
          responses[token]!['acknowledgementState'] =
              'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED';
          responses[token]!['subscriptionState'] = 'SUBSCRIPTION_STATE_EXPIRED';
          expect((await a.client.billing.getEntitlement()).active, false);
        }
        releaseAck!.complete();
        await pending.timeout(bound);
        expect((await a.client.product.getWallet()).balance, 0);
        now = fixture.now;
        ackEntered = releaseAck = null;
      }
    },
  );

  test(
    'concurrent duplicate premium claims have one ledger and retry replays winner',
    () async {
      final a = await user();
      purchase('duplicate-premium', a.binding);
      await a.client.billing.verifyPurchase(input('duplicate-premium'));
      final d = await steps(a.client, 100);
      heldLookup = 'duplicate-premium';
      lookupEntered = Completer<void>();
      releaseLookup = Completer<void>();
      final older = expectLater(
        a.client.product.claimDayWithPremium(d.date, 'same-paid', d.revision),
        failure('staleObservation'),
      );
      await lookupEntered!.future.timeout(bound);
      final winner = await a.client.product.claimDayWithPremium(
        d.date,
        'same-paid',
        d.revision,
      );
      releaseLookup!.complete();
      await older.timeout(bound);
      expect(
        (await a.client.product.claimDayWithPremium(
          d.date,
          'same-paid',
          d.revision,
        )).ledgerId,
        winner.ledgerId,
      );
      expect(
        await PointEntry.db.count(admin, where: (t) => t.owner.equals(a.owner)),
        1,
      );
    },
  );

  test(
    'free or verified ad wins pending premium without topup or consuming more evidence',
    () async {
      for (final withAd in [false, true]) {
        final a = await user();
        final token = 'overlap-$withAd';
        purchase(token, a.binding);
        await a.client.billing.verifyPurchase(input(token));
        final d = await steps(a.client, 100);
        final ad = withAd
            ? await verifiedAd(a.client, 'dailyReward', d.date, d.revision)
            : null;
        heldLookup = token;
        lookupEntered = Completer<void>();
        releaseLookup = Completer<void>();
        final pending = expectLater(
          a.client.product.claimDayWithPremium(
            d.date,
            'pending-paid',
            d.revision,
          ),
          productFailure('staleProjection'),
        );
        await lookupEntered!.future.timeout(bound);
        if (ad == null) {
          await a.client.product.claimDay(d.date, 'winning-free', d.revision);
        } else {
          await a.client.product.claimDayWithAd(
            d.date,
            'winning-ad',
            d.revision,
            ad.id,
          );
        }
        releaseLookup!.complete();
        await pending.timeout(bound);
        expect((await a.client.product.getWallet()).balance, withAd ? 2 : 1);
        expect(
          await PointEntry.db.count(
            admin,
            where: (t) => t.owner.equals(a.owner),
          ),
          1,
        );
        heldLookup = null;
      }
    },
  );

  test(
    'premium quiz concurrent duplicate and ad race share the same extra slot',
    () async {
      for (final adWins in [false, true]) {
        final a = await user();
        final token = 'quiz-overlap-$adWins';
        purchase(token, a.binding);
        await a.client.billing.verifyPurchase(input(token));
        final t = await answeredFree(a.client);
        final ad = adWins
            ? await verifiedAd(a.client, 'extraQuiz', t.date, t.extraRevision!)
            : null;
        heldLookup = token;
        lookupEntered = Completer<void>();
        releaseLookup = Completer<void>();
        final pending = expectLater(
          a.client.quiz.unlockExtraWithPremium(
            t.date,
            t.extraRevision!,
            'same-extra',
          ),
          adWins
              ? productFailure('dailyLimitReached')
              : failure('staleObservation'),
        );
        await lookupEntered!.future.timeout(bound);
        final winner = ad != null
            ? await a.client.quiz.unlockExtra(
                t.date,
                t.extraRevision!,
                ad.id,
                'ad-extra-wins',
              )
            : await a.client.quiz.unlockExtraWithPremium(
                t.date,
                t.extraRevision!,
                'same-extra',
              );
        releaseLookup!.complete();
        await pending.timeout(bound);
        expect(
          (await a.client.quiz.getToday()).extra!.assignmentId,
          winner.assignmentId,
        );
        expect(
          await QuizAssignment.db.count(
            admin,
            where: (r) => r.owner.equals(a.owner) & r.slot.equals('extra'),
          ),
          1,
        );
        heldLookup = null;
      }
    },
  );

  test(
    'account deletion during either premium lookup prevents resurrection',
    () async {
      for (final quiz in [false, true]) {
        final a = await user();
        final token = 'benefit-delete-$quiz';
        purchase(token, a.binding);
        await a.client.billing.verifyPurchase(input(token));
        final d = await steps(a.client, 100);
        final t = await answeredFree(a.client);
        heldLookup = token;
        lookupEntered = Completer<void>();
        releaseLookup = Completer<void>();
        final pending = expectLater(
          quiz
              ? a.client.quiz.unlockExtraWithPremium(
                  t.date,
                  t.extraRevision!,
                  'deleted-extra',
                )
              : a.client.product.claimDayWithPremium(
                  d.date,
                  'deleted-step',
                  d.revision,
                ),
          failure('purchaseUnavailable'),
        );
        await lookupEntered!.future.timeout(bound);
        await a.client.account.deleteAccount();
        releaseLookup!.complete();
        await pending.timeout(bound);
        await noOwner(a.owner);
        expect(
          await ProductAccount.db.count(
            admin,
            where: (r) => r.owner.equals(a.owner),
          ),
          0,
        );
        expect(
          await PointEntry.db.count(
            admin,
            where: (r) => r.owner.equals(a.owner),
          ),
          0,
        );
        expect(
          await QuizAssignment.db.count(
            admin,
            where: (r) => r.owner.equals(a.owner),
          ),
          0,
        );
        heldLookup = null;
      }
    },
  );

  test(
    'authentication, absent configuration and stable opaque UUID binding',
    () async {
      await expectLater(
        client().billing.getEntitlement(),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
      final a = await user();
      final b = await user();
      expect(
        a.binding,
        matches(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
        ),
      );
      expect(a.binding, isNot(a.owner));
      expect(a.binding, isNot(b.binding));
      final configs = await Future.wait(
        List.generate(
          4,
          (_) => a.client.billing.getPurchaseConfiguration('apple'),
        ),
      );
      expect(configs.map((c) => c.accountBinding), everyElement(a.binding));
      expect(configs.first.environment, 'sandbox');
      expect(configs.first.products.map((p) => p.productId), [
        'monthly',
        'lifetime',
      ]);
      final original = BillingService.instances[pod];
      BillingService.instances[pod] = null;
      try {
        await expectLater(
          a.client.billing.getEntitlement(),
          failure('configurationMissing'),
        );
        await expectLater(
          a.client.billing.verifyPurchase(input('absent')),
          failure('configurationMissing'),
        );
      } finally {
        BillingService.instances[pod] = original;
      }
    },
  );

  test('verified ownership replay restore isolation and wrong binding', () async {
    final a = await user();
    final b = await user();
    const token = 'replay/secret+token?x#canary';
    purchase(token, a.binding);
    final first = await a.client.billing.verifyPurchase(input(token));
    expect(first.active, true);
    expect(jsonEncode(first.toJson()), isNot(contains(token)));
    expect((await a.client.billing.restorePurchase(input(token))).active, true);
    expect(
      await StoredPurchase.db.count(
        admin,
        where: (t) => t.owner.equals(a.owner),
      ),
      1,
    );
    expect((await b.client.billing.getEntitlement()).active, false);
    await expectLater(
      b.client.billing.verifyPurchase(input(token)),
      failure('invalidPurchase'),
    );
    // Even a later upstream binding change cannot steal an already owned identity.
    purchase(token, b.binding);
    await expectLater(
      b.client.billing.restorePurchase(input(token)),
      failure('purchaseUnavailable'),
    );
    expect(
      await StoredPurchase.db.count(
        admin,
        where: (t) => t.owner.equals(b.owner),
      ),
      0,
    );
    purchase(token, a.binding);
    final before = queryCount;
    expect((await a.client.billing.getEntitlement()).active, true);
    expect(queryCount, before + 1);
  });

  test(
    'concurrent crossowner completion cannot claim same store identity twice',
    () async {
      final a = await user();
      final b = await user();
      const token = 'crossowner-racing';
      purchase(token, a.binding);
      heldLookup = token;
      lookupEntered = Completer<void>();
      releaseLookup = Completer<void>();
      final older = expectLater(
        a.client.billing.verifyPurchase(input(token)),
        failure('purchaseUnavailable'),
      );
      await lookupEntered!.future.timeout(bound);
      purchase(token, b.binding);
      expect(
        (await b.client.billing.verifyPurchase(input(token))).active,
        true,
      );
      releaseLookup!.complete();
      await older.timeout(bound);
      final rows = await StoredPurchase.db.find(
        admin,
        where: (t) => t.identityHash.equals(hash('google', token)),
      );
      expect(rows, hasLength(1));
      expect(rows.single.owner, b.owner);
    },
  );

  test(
    'Apple canonical original identity deduplicates transaction aliases',
    () async {
      final a = await user();
      for (final id in ['711', '712', '700']) {
        responses[id] = fixture.transaction(lifetime: true)
          ..['transactionId'] = id
          ..['originalTransactionId'] = '700'
          ..['appAccountToken'] = a.binding;
      }
      expect(
        (await a.client.billing.verifyPurchase(
          input('711', store: 'apple'),
        )).active,
        true,
      );
      expect(
        (await a.client.billing.restorePurchase(
          input('712', store: 'apple'),
        )).active,
        true,
      );
      final row = (await StoredPurchase.db.find(
        admin,
        where: (t) => t.owner.equals(a.owner),
      )).single;
      expect(row.purchaseReference, '700');
      expect(row.identityHash, hash('apple', '700'));
      expect((await a.client.billing.getEntitlement()).active, true);
      responses['700']!['revocationDate'] = fixture.now.millisecondsSinceEpoch;
      expect((await a.client.billing.getEntitlement()).active, false);
    },
  );

  for (final state in [
    'PENDING',
    'EXPIRED',
    'ON_HOLD',
    'PAUSED',
    'IN_GRACE_PERIOD',
  ]) {
    test(
      'subscription $state follows verified state and exclusive expiry',
      () async {
        final a = await user();
        final token = 'sub-$state';
        responses[token] = fixture.subscription(state: state)
          ..['externalAccountIdentifiers'] = {
            'obfuscatedExternalAccountId': a.binding,
          };
        final view = await a.client.billing.verifyPurchase(
          input(token, product: 'monthly'),
        );
        expect(view.active, state == 'IN_GRACE_PERIOD');
        expect(view.purchases.single.state, switch (state) {
          'PENDING' => 'pending',
          'EXPIRED' => 'expired',
          'ON_HOLD' => 'onHold',
          'PAUSED' => 'paused',
          _ => 'grace',
        });
        final settings = fixture.config();
        BillingService.instances[pod] = BillingService(
          settings,
          identityKey,
          clock: Clock.fixed(fixture.expiry),
          google: GoogleBillingClient(
            settings.google!,
            clock: Clock.fixed(fixture.expiry),
            clientFactory: () => MockClient(external),
          ),
        );
        try {
          expect((await a.client.billing.getEntitlement()).active, false);
        } finally {
          BillingService.instances[pod] = service();
        }
      },
    );
  }

  test(
    'lifetime pending and revoked never grant and never acknowledge',
    () async {
      for (final state in ['PENDING', 'CANCELLED']) {
        final a = await user();
        final token = 'inactive-$state';
        purchase(token, a.binding, state: state, pendingAck: true);
        final view = await a.client.billing.verifyPurchase(input(token));
        expect(view.active, false);
        expect(view.purchases.single.acknowledgementPending, false);
        expect(acknowledgements, isNot(contains(token)));
      }
    },
  );

  test(
    'older active lookup cannot overwrite newer revoked observation',
    () async {
      final a = await user();
      const token = 'out-of-order';
      purchase(token, a.binding);
      heldLookup = token;
      lookupEntered = Completer<void>();
      releaseLookup = Completer<void>();
      final older = expectLater(
        a.client.billing.verifyPurchase(input(token)),
        failure('staleObservation'),
      );
      await lookupEntered!.future.timeout(bound);
      purchase(token, a.binding, state: 'CANCELLED');
      expect(
        (await a.client.billing.restorePurchase(input(token))).active,
        false,
      );
      releaseLookup!.complete();
      await older.timeout(bound);
      final row = (await StoredPurchase.db.find(
        admin,
        where: (t) => t.owner.equals(a.owner),
      )).single;
      expect(row.state, 'revoked');
      expect(row.sequence, 2);
    },
  );

  test(
    'deletion during first lookup retains only verified identity hash',
    () async {
      final a = await user();
      const token = 'deletion-inflight-secret';
      purchase(token, a.binding);
      heldLookup = token;
      lookupEntered = Completer<void>();
      releaseLookup = Completer<void>();
      final pending = expectLater(
        a.client.billing.verifyPurchase(input(token)),
        failure('accountDeleted'),
      );
      await lookupEntered!.future.timeout(bound);
      await a.client.account.deleteAccount();
      releaseLookup!.complete();
      await pending.timeout(bound);
      await noOwner(a.owner);
      final tomb = await PurchaseTombstone.db.findFirstRow(
        admin,
        where: (t) => t.identityHash.equals(hash('google', token)),
      );
      expect(tomb, isNotNull);
      final b = await user();
      purchase(token, b.binding);
      await expectLater(
        b.client.billing.verifyPurchase(input(token)),
        failure('purchaseUnavailable'),
      );
    },
  );

  test(
    'persisted deletion erases token binding and owner; rejoin cannot reassign',
    () async {
      final a = await user();
      const token = 'deleted-purchase-secret';
      purchase(token, a.binding);
      await a.client.billing.verifyPurchase(input(token));
      await a.client.account.deleteAccount();
      await noOwner(a.owner);
      final columns = await admin.db.unsafeQuery(
        "SELECT column_name FROM information_schema.columns WHERE table_name = 'billing_purchase_tombstone' ORDER BY ordinal_position",
      );
      expect(columns.map((r) => r[0]), ['id', 'identityHash', 'retainUntil']);
      final retained = await admin.db.unsafeQuery(
        'SELECT row_to_json(t)::text FROM billing_purchase_tombstone t',
      );
      final text = retained.toString();
      for (final secret in [token, a.owner, a.binding]) {
        expect(text, isNot(contains(secret)));
      }
      expect(text, contains(hash('google', token)));
      final rejoined = await user();
      await expectLater(
        rejoined.client.billing.restorePurchase(input(token)),
        failure('invalidPurchase'),
      );
      purchase(token, rejoined.binding);
      await expectLater(
        rejoined.client.billing.restorePurchase(input(token)),
        failure('purchaseUnavailable'),
      );
      expect((await rejoined.client.billing.getEntitlement()).active, false);
      await expectLater(
        a.client.billing.getEntitlement(),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
    },
  );

  test(
    'ack failure survives restart and entitlement retries after fresh lookup',
    () async {
      final a = await user();
      const token = 'ack-retry';
      purchase(token, a.binding, pendingAck: true);
      ackFails = true;
      final first = await a.client.billing.verifyPurchase(input(token));
      expect(first.active, true);
      expect(first.purchases.single.acknowledgementPending, true);
      BillingService.instances[pod] = service();
      ackFails = false;
      final retried = await a.client.billing.getEntitlement();
      expect(retried.active, true);
      expect(retried.purchases.single.acknowledgementPending, false);
      expect(acknowledgements.where((t) => t == token), hasLength(2));
      await a.client.billing.getEntitlement();
      expect(acknowledgements.where((t) => t == token), hasLength(2));
    },
  );

  test(
    'ack completion after deletion cannot resurrect persisted purchase',
    () async {
      final a = await user();
      const token = 'ack-delete';
      purchase(token, a.binding, pendingAck: true);
      ackEntered = Completer<void>();
      releaseAck = Completer<void>();
      final pending = expectLater(
        a.client.billing.verifyPurchase(input(token)),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
      await ackEntered!.future.timeout(bound);
      await a.client.account.deleteAccount();
      releaseAck!.complete();
      await pending.timeout(bound);
      await noOwner(a.owner);
      expect(
        await PurchaseTombstone.db.count(
          admin,
          where: (t) => t.identityHash.equals(hash('google', token)),
        ),
        1,
      );
    },
  );

  test(
    'account deletion rollback retains binding purchase and retry marker atomically',
    () async {
      final a = await user();
      const token = 'rollback-delete';
      purchase(token, a.binding, pendingAck: true);
      ackFails = true;
      await a.client.billing.verifyPurchase(input(token));
      await admin.db.unsafeExecute(
        "CREATE FUNCTION reject_billing_delete() RETURNS trigger LANGUAGE plpgsql AS 'BEGIN RAISE EXCEPTION ''test failure''; END'",
      );
      await admin.db.unsafeExecute(
        'CREATE TRIGGER reject_billing_delete BEFORE DELETE ON serverpod_auth_core_user FOR EACH ROW EXECUTE FUNCTION reject_billing_delete()',
      );
      try {
        await expectLater(
          a.client.account.deleteAccount(),
          throwsA(isA<api.ServerpodClientInternalServerError>()),
        );
        expect(
          await PurchaseTombstone.db.count(
            admin,
            where: (t) => t.identityHash.equals(hash('google', token)),
          ),
          0,
        );
        expect(
          (await a.client.billing.getPurchaseConfiguration(
            'google',
          )).accountBinding,
          a.binding,
        );
        expect(
          (await StoredPurchase.db.find(
            admin,
            where: (t) => t.owner.equals(a.owner),
          )).single.acknowledgementPending,
          true,
        );
      } finally {
        await admin.db.unsafeExecute(
          'DROP TRIGGER reject_billing_delete ON serverpod_auth_core_user',
        );
        await admin.db.unsafeExecute('DROP FUNCTION reject_billing_delete()');
      }
      await a.client.account.deleteAccount();
      await noOwner(a.owner);
    },
  );

  Future<String> retainedJson(int id) async =>
      (await admin.db.unsafeQuery(
            'SELECT row_to_json(t)::text FROM billing_payment_record t WHERE id = @id',
            parameters: QueryParameters.named({'id': id}),
          )).single[0]!
          as String;

  test(
    'deletion keeps minimal payment records without user linkage and removes originals',
    () async {
      final a = await user();
      const google = 'retained-lifetime-secret';
      purchase(google, a.binding);
      responses[google]!['orderId'] = 'order-retained-lifetime';
      await a.client.billing.verifyPurchase(input(google));
      responses['9701'] = fixture.transaction(lifetime: true)
        ..['transactionId'] = '9701'
        ..['originalTransactionId'] = '9700'
        ..['appAccountToken'] = a.binding
        ..['revocationDate'] = fixture.now.millisecondsSinceEpoch;
      await a.client.billing.verifyPurchase(input('9701', store: 'apple'));
      await a.client.account.deleteAccount();
      await noOwner(a.owner);
      final columns = await admin.db.unsafeQuery(
        "SELECT column_name FROM information_schema.columns WHERE table_name = 'billing_payment_record' ORDER BY ordinal_position",
      );
      expect(columns.map((r) => r[0]), [
        'id',
        'store',
        'environment',
        'productId',
        'kind',
        'storeTransactionId',
        'originalTransactionId',
        'state',
        'purchasedAt',
        'expiresAt',
        'revokedAt',
        'recordedAt',
        'purgeAfter',
      ]);
      final lifetime = (await RetainedPaymentRecord.db.find(
        admin,
        where: (t) => t.storeTransactionId.equals('order-retained-lifetime'),
      )).single;
      expect(lifetime.store, 'google');
      expect(lifetime.environment, 'sandbox');
      expect(lifetime.productId, 'lifetime');
      expect(lifetime.kind, 'lifetime');
      expect(lifetime.originalTransactionId, isNull);
      expect(lifetime.state, 'active');
      expect(lifetime.purchasedAt, fixture.purchaseDate);
      expect(lifetime.revokedAt, isNull);
      expect(lifetime.purgeAfter, DateTime.utc(2031, 10, 18, 12));
      final refunded = (await RetainedPaymentRecord.db.find(
        admin,
        where: (t) => t.originalTransactionId.equals('9700'),
      )).single;
      expect(refunded.store, 'apple');
      expect(refunded.storeTransactionId, '9701');
      expect(refunded.state, 'revoked');
      expect(refunded.revokedAt, fixture.now);
      expect(refunded.purgeAfter, DateTime.utc(2031, 10, 19, 12));
      final retained =
          await retainedJson(lifetime.id!) + await retainedJson(refunded.id!);
      for (final secret in [
        google,
        a.owner,
        a.binding,
        hash('google', google),
        hash('apple', '9700'),
      ]) {
        expect(retained, isNot(contains(secret)));
      }
      final tomb = await PurchaseTombstone.db.findFirstRow(
        admin,
        where: (t) => t.identityHash.equals(hash('google', google)),
      );
      expect(tomb!.retainUntil, isNull);
    },
  );

  test(
    'subscription identity hash expires one year after latest observed expiry',
    () async {
      final a = await user();
      const token = 'retained-subscription-secret';
      responses[token] = fixture.subscription()
        ..['externalAccountIdentifiers'] = {
          'obfuscatedExternalAccountId': a.binding,
        };
      ((responses[token]!['lineItems'] as List).single
              as Map<String, dynamic>)['latestSuccessfulOrderId'] =
          'order-retained-subscription';
      await a.client.billing.verifyPurchase(input(token, product: 'monthly'));
      await a.client.account.deleteAccount();
      final record = (await RetainedPaymentRecord.db.find(
        admin,
        where: (t) =>
            t.storeTransactionId.equals('order-retained-subscription'),
      )).single;
      expect(record.kind, 'subscription');
      expect(record.expiresAt, fixture.expiry);
      expect(record.purgeAfter, DateTime.utc(2031, 10, 19, 12));
      Future<DateTime?> retainUntil() async =>
          (await PurchaseTombstone.db.findFirstRow(
            admin,
            where: (t) => t.identityHash.equals(hash('google', token)),
          ))!.retainUntil;
      expect(await retainUntil(), DateTime.utc(2027, 10, 20, 12));
      // The store subscription survives deletion; a later renewal observation
      // keeps the rejection, only extending how long the hash is kept.
      final b = await user();
      final renewed = fixture.expiry.add(const Duration(days: 30));
      responses[token]!['externalAccountIdentifiers'] = {
        'obfuscatedExternalAccountId': b.binding,
      };
      ((responses[token]!['lineItems'] as List).single
          as Map<String, dynamic>)['expiryTime'] = renewed
          .toIso8601String();
      await expectLater(
        b.client.billing.verifyPurchase(input(token, product: 'monthly')),
        failure('purchaseUnavailable'),
      );
      expect(await retainUntil(), DateTime.utc(2027, 11, 19, 12));
    },
  );

  test(
    'retention purge deletes only expired records and identity hashes',
    () async {
      final instant = fixture.now;
      RetainedPaymentRecord record(String product, DateTime purgeAfter) =>
          RetainedPaymentRecord(
            store: 'google',
            environment: 'sandbox',
            productId: product,
            kind: 'lifetime',
            state: 'active',
            recordedAt: instant,
            purgeAfter: purgeAfter,
          );
      final past = instant.subtract(const Duration(seconds: 1));
      final future = instant.add(const Duration(seconds: 1));
      await RetainedPaymentRecord.db.insert(admin, [
        for (var i = 0; i < 3; i++) record('purge-expired-$i', past),
        record('purge-boundary', instant),
        record('purge-kept', future),
      ]);
      await PurchaseTombstone.db.insert(admin, [
        for (var i = 0; i < 3; i++)
          PurchaseTombstone(identityHash: 'purge-old-$i', retainUntil: past),
        PurchaseTombstone(identityHash: 'purge-future', retainUntil: future),
        PurchaseTombstone(identityHash: 'purge-lifetime'),
      ]);
      final first = await purgeExpiredBillingRetention(
        admin,
        clock: Clock.fixed(instant),
        batchSize: 2,
      );
      expect(first.records, greaterThanOrEqualTo(3));
      expect(first.identities, greaterThanOrEqualTo(3));
      final products = (await RetainedPaymentRecord.db.find(
        admin,
        where: (t) => t.productId.like('purge-%'),
      )).map((r) => r.productId);
      expect(products, unorderedEquals(['purge-boundary', 'purge-kept']));
      final hashes = (await PurchaseTombstone.db.find(
        admin,
        where: (t) => t.identityHash.like('purge-%'),
      )).map((r) => r.identityHash);
      expect(hashes, unorderedEquals(['purge-future', 'purge-lifetime']));
      final again = await purgeExpiredBillingRetention(
        admin,
        clock: Clock.fixed(instant),
      );
      expect(again, (records: 0, identities: 0));
    },
  );

  test(
    'startup purges once and keeps one daily cron call across restarts',
    () async {
      final stale = await RetainedPaymentRecord.db.insertRow(
        admin,
        RetainedPaymentRecord(
          store: 'google',
          environment: 'sandbox',
          productId: 'startup-expired',
          kind: 'lifetime',
          state: 'active',
          recordedAt: DateTime.utc(2000),
          purgeAfter: DateTime.utc(2001),
        ),
      );
      await startBillingRetention(pod);
      expect(await RetainedPaymentRecord.db.findById(admin, stale.id!), isNull);
      await startBillingRetention(pod);
      final entries = await FutureCallEntry.db.find(
        admin,
        where: (t) => t.identifier.equals(billingRetentionPurgeIdentifier),
      );
      expect(entries, hasLength(1));
      expect(
        entries.single.scheduling,
        isA<CronFutureCallScheduling>().having(
          (s) => s.cron,
          'cron',
          billingRetentionPurgeCron,
        ),
      );
      await FutureCallEntry.db.deleteWhere(
        admin,
        where: (t) => t.identifier.equals(billingRetentionPurgeIdentifier),
      );
    },
  );
}
