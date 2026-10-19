import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/billing/billing_service.dart';
import 'package:balmatchum_server/src/billing/billing_verifier.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../unit/billing/billing_fixture.dart' as fixture;

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
  final acknowledgements = <String>[];
  var ackFails = false;
  String? heldLookup;
  Completer<void>? lookupEntered;
  Completer<void>? releaseLookup;
  Completer<void>? ackEntered;
  Completer<void>? releaseAck;
  var queryCount = 0;

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
    // Snapshot before releasing the second request, so the first really carries
    // stale active data rather than merely returning the later fixture value.
    final value = responses[segment];
    final body = jsonEncode(value);
    if (heldLookup == segment && !lookupEntered!.isCompleted) {
      lookupEntered!.complete();
      await releaseLookup!.future.timeout(bound);
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
      clock: Clock.fixed(fixture.now),
      apple: AppleBillingClient(
        settings.apple!,
        clock: Clock.fixed(fixture.now),
        clientFactory: () => MockClient(external),
      ),
      google: GoogleBillingClient(
        settings.google!,
        clock: Clock.fixed(fixture.now),
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
    await pod.start(runInGuardedZone: false);
    admin = await pod.createSession(enableLogging: false);
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
      expect(columns.map((r) => r[0]), ['id', 'identityHash']);
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
}
