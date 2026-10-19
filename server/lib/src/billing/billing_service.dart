import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'billing_verifier.dart';

/// Only outbound HTTP is replaceable in tests; facts remain verifier-owned.
class BillingService {
  BillingService(
    this.config,
    String identityKey, {
    AppleBillingClient? apple,
    GoogleBillingClient? google,
    this.clock = const Clock(),
  }) : _hmac = Hmac(sha256, base64Decode(identityKey)),
       apple =
           apple ??
           (config.apple == null
               ? null
               : AppleBillingClient(config.apple!, clock: clock)),
       google =
           google ??
           (config.google == null
               ? null
               : GoogleBillingClient(config.google!, clock: clock));

  final BillingConfig config;
  final Hmac _hmac;
  final AppleBillingClient? apple;
  final GoogleBillingClient? google;
  final Clock clock;
  static final instances = Expando<BillingService>();

  static void configure(Serverpod pod) {
    final config = BillingConfig.fromPasswords(pod.getPassword);
    final key = pod.getPassword('billingIdentityHmacKey');
    if (key == null) return;
    try {
      if (base64Decode(key).length < 32) throw const FormatException();
    } catch (_) {
      throw const BillingVerificationException(BillingFailure.configuration);
    }
    if (config.apple == null && config.google == null) return;
    instances[pod] = BillingService(config, key);
  }

  static Future<T> run<T>(
    Session caller,
    Future<T> Function(BillingService, Session) action,
  ) async {
    final service = instances[caller.serverpod];
    if (service == null) throw BillingException(code: 'configurationMissing');
    if (caller.authenticated == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
      );
    }
    // Query logs can contain bound values. Never log purchase-bearing queries,
    // even when the operator enables slow/failed/all-query logging globally.
    final db = await caller.serverpod.createSession(enableLogging: false);
    db.updateAuthenticated(caller.authenticated);
    try {
      return await action(service, db);
    } on BillingVerificationException catch (e) {
      throw BillingException(
        code: switch (e.code) {
          BillingFailure.configuration => 'configurationMissing',
          BillingFailure.invalidPurchase => 'invalidPurchase',
          BillingFailure.unavailable => 'temporarilyUnavailable',
        },
      );
    } on DatabaseQueryException {
      // PostgreSQL constraint errors may embed row contents, including tokens.
      throw BillingException(code: 'temporarilyUnavailable');
    } finally {
      await db.close();
    }
  }

  String _owner(Session s) => s.authenticated!.userIdentifier;

  BillingEnvironment _environment(String store) => switch (store) {
    'apple' when config.apple != null => config.apple!.environment,
    'google' when config.google != null => config.google!.environment,
    'apple' || 'google' => throw BillingException(code: 'configurationMissing'),
    _ => throw BillingException(code: 'invalidPurchase'),
  };

  Map<String, BillingProductKind> _products(String store) {
    _environment(store);
    return store == 'apple' ? config.apple!.products : config.google!.products;
  }

  Future<BillingAccount> _account(Session s, Transaction tx) async {
    final owner = _owner(s);
    await lockProductAccount(s, owner, tx);
    return await BillingAccount.db.findFirstRow(
          s,
          where: (t) => t.owner.equals(owner),
          transaction: tx,
        ) ??
        await BillingAccount.db.insertRow(
          s,
          BillingAccount(owner: owner, binding: const Uuid().v4()),
          transaction: tx,
        );
  }

  Future<PurchaseConfiguration> configuration(Session s, String store) async {
    final products = _products(store);
    return s.db.transaction((tx) async {
      final account = await _account(s, tx);
      return PurchaseConfiguration(
        store: store,
        environment: _environment(store).name,
        accountBinding: account.binding,
        products: [
          for (final p in products.entries)
            PurchaseProduct(productId: p.key, kind: p.value.name),
        ],
      );
    });
  }

  String _identity(BillingFacts facts) => _hmac
      .convert(
        utf8.encode(
          jsonEncode([
            'billing-purchase-v1',
            facts.store.name,
            facts.environment.name,
            facts.purchaseReference,
          ]),
        ),
      )
      .toString();

  Future<EntitlementView> verify(Session s, PurchaseInput input) async {
    await _verify(s, input);
    return _view(s);
  }

  Future<void> _verify(
    Session s,
    PurchaseInput input, {
    ({String binding, int sequence})? reserved,
  }) async {
    if (!_products(input.store).containsKey(input.productId)) {
      throw BillingException(code: 'invalidPurchase');
    }
    // Reserve before the external lookup, not at completion. A later request
    // invalidates earlier requests even if those finish after a revocation.
    final reservation =
        reserved ??
        await s.db.transaction<({String binding, int sequence})>((tx) async {
          final account = await _account(s, tx);
          account.sequence++;
          await BillingAccount.db.updateRow(s, account, transaction: tx);
          return (binding: account.binding, sequence: account.sequence);
        });
    final facts = input.store == 'apple'
        ? await apple!.verify(
            transactionId: input.purchaseReference,
            productId: input.productId,
            expectedAppAccountToken: reservation.binding,
          )
        : await google!.verify(
            purchaseToken: input.purchaseReference,
            productId: input.productId,
            expectedObfuscatedAccountId: reservation.binding,
          );
    final hash = _identity(facts);
    final owner = _owner(s);
    final outcome = await s.db.transaction((tx) async {
      // Unlike _account, allow a missing user only to retain the anonymous hash
      // of a verified lookup that was already in flight when deletion won.
      final user = await AuthUser.db.findFirstRow(
        s,
        where: (t) => t.id.equals(UuidValue.fromString(owner)),
        lockMode: LockMode.forUpdate,
        transaction: tx,
      );
      await lockPurchaseIdentity(s, hash, tx);
      final previous = await StoredPurchase.db.findFirstRow(
        s,
        where: (t) => t.identityHash.equals(hash),
        transaction: tx,
      );
      if (previous != null && previous.owner != owner) {
        return 'purchaseUnavailable';
      }
      if (await PurchaseTombstone.db.findFirstRow(
            s,
            where: (t) => t.identityHash.equals(hash),
            transaction: tx,
          ) !=
          null) {
        return 'purchaseUnavailable';
      }
      if (user == null) {
        await PurchaseTombstone.db.insert(
          s,
          [PurchaseTombstone(identityHash: hash)],
          ignoreConflicts: true,
          transaction: tx,
        );
        return 'accountDeleted';
      }
      final account = await BillingAccount.db.findFirstRow(
        s,
        where: (t) => t.owner.equals(owner),
        transaction: tx,
      );
      if (account == null ||
          account.binding != reservation.binding ||
          facts.ownerBinding != account.binding ||
          account.sequence != reservation.sequence) {
        return 'staleObservation';
      }
      final row = StoredPurchase(
        id: previous?.id,
        owner: owner,
        identityHash: hash,
        store: facts.store.name,
        environment: facts.environment.name,
        productId: facts.productId,
        kind: facts.kind.name,
        purchaseReference: facts.purchaseReference,
        state: facts.state.name,
        sequence: reservation.sequence,
        observedAt: facts.observedAt,
        purchasedAt: facts.purchasedAt,
        expiresAt: facts.expiresAt,
        graceExpiresAt: facts.graceExpiresAt,
        revokedAt: facts.revokedAt,
        acknowledgementPending:
            facts.requiresAcknowledgement &&
            facts.isActiveAt(clock.now().toUtc()),
      );
      if (row.id == null) {
        await StoredPurchase.db.insertRow(s, row, transaction: tx);
      } else {
        await StoredPurchase.db.updateRow(s, row, transaction: tx);
      }
      return 'stored';
    });
    if (outcome != 'stored') throw BillingException(code: outcome);
    // Commit precedes Google acknowledgement. A crash/failure leaves the marker
    // and original token available for a fresh verified retry on the next call.
    if (facts.requiresAcknowledgement &&
        facts.isActiveAt(clock.now().toUtc())) {
      try {
        await google!.acknowledge(
          purchaseToken: facts.purchaseReference,
          productId: facts.productId,
        );
        await s.db.transaction((tx) async {
          final user = await AuthUser.db.findFirstRow(
            s,
            where: (t) => t.id.equals(UuidValue.fromString(owner)),
            lockMode: LockMode.forUpdate,
            transaction: tx,
          );
          if (user == null) return;
          final row = await StoredPurchase.db.findFirstRow(
            s,
            where: (t) => t.owner.equals(owner) & t.identityHash.equals(hash),
            transaction: tx,
          );
          if (row == null || row.sequence != reservation.sequence) return;
          row.acknowledgementPending = false;
          await StoredPurchase.db.updateRow(s, row, transaction: tx);
        });
      } on BillingVerificationException {
        // Entitlement was committed. Never report that persistence failed or
        // clear the marker because a remote acknowledgement outcome is unknown.
      }
    }
  }

  /// One observation sequence covers the entire fresh lookup. Every store call
  /// finishes before the caller opens the reward/quiz consumption transaction.
  Future<BillingBenefit> revalidateBenefit(Session s) async {
    final snapshot = await s.db.transaction((tx) async {
      final account = await _account(s, tx);
      account.sequence++;
      await BillingAccount.db.updateRow(s, account, transaction: tx);
      final rows = await StoredPurchase.db.find(
        s,
        where: (t) => t.owner.equals(_owner(s)),
        transaction: tx,
      );
      return (binding: account.binding, sequence: account.sequence, rows: rows);
    });
    for (final row in snapshot.rows) {
      if (_environment(row.store).name != row.environment) {
        throw BillingException(code: 'configurationMissing');
      }
      await _verify(
        s,
        PurchaseInput(
          store: row.store,
          productId: row.productId,
          purchaseReference: row.purchaseReference,
        ),
        reserved: (binding: snapshot.binding, sequence: snapshot.sequence),
      );
    }
    return BillingBenefit._(
      this,
      _owner(s),
      snapshot.binding,
      snapshot.sequence,
    );
  }

  Future<EntitlementView> entitlement(Session s) async {
    final rows = await s.db.transaction((tx) async {
      await _account(s, tx);
      return StoredPurchase.db.find(
        s,
        where: (t) => t.owner.equals(_owner(s)),
        transaction: tx,
      );
    });
    for (final row in rows) {
      // Fail closed if configuration changed: old environment observations are
      // never reinterpreted as purchases from a newly selected environment.
      if (_environment(row.store).name != row.environment) {
        throw BillingException(code: 'configurationMissing');
      }
      await verify(
        s,
        PurchaseInput(
          store: row.store,
          productId: row.productId,
          purchaseReference: row.purchaseReference,
        ),
      );
    }
    return _view(s);
  }

  Future<EntitlementView> _view(Session s) => s.db.transaction((tx) async {
    await _account(s, tx);
    final rows = await StoredPurchase.db.find(
      s,
      where: (t) => t.owner.equals(_owner(s)),
      orderBy: (t) => t.id,
      transaction: tx,
    );
    final now = clock.now().toUtc();
    final views = [
      for (final row in rows)
        PurchaseView(
          store: row.store,
          productId: row.productId,
          kind: row.kind,
          state: row.state,
          active: _active(row, now),
          observedAt: row.observedAt,
          expiresAt: row.expiresAt,
          graceExpiresAt: row.graceExpiresAt,
          acknowledgementPending: row.acknowledgementPending,
        ),
    ];
    return EntitlementView(
      active: views.any((v) => v.active),
      purchases: views,
    );
  });

  bool _active(StoredPurchase p, DateTime now) {
    if (now.isBefore(p.observedAt) ||
        p.purchasedAt == null ||
        now.isBefore(p.purchasedAt!) ||
        p.revokedAt != null) {
      return false;
    }
    if (p.state == 'grace') {
      return p.graceExpiresAt != null && now.isBefore(p.graceExpiresAt!);
    }
    return p.state == 'active' &&
        (p.kind == 'lifetime' ||
            (p.expiresAt != null && now.isBefore(p.expiresAt!)));
  }
}

/// Server-only proof of a completed fresh lookup, never a client premium flag.
class BillingBenefit {
  BillingBenefit._(this._service, this._owner, this._binding, this._sequence);
  final BillingService _service;
  final String _owner;
  final String _binding;
  final int _sequence;

  /// ProductService already holds AuthUser -> ProductAccount until consumption
  /// commits. A later reservation (even one that failed) invalidates this proof.
  Future<bool> isActive(ProductService s) async {
    final account = await BillingAccount.db.findFirstRow(
      s.session,
      where: (t) => t.owner.equals(s.owner),
      transaction: s.tx,
    );
    if (s.owner != _owner ||
        account == null ||
        account.binding != _binding ||
        account.sequence != _sequence) {
      throw BillingException(code: 'staleObservation');
    }
    final rows = await StoredPurchase.db.find(
      s.session,
      where: (t) => t.owner.equals(s.owner),
      transaction: s.tx,
    );
    if (rows.any((p) => p.sequence != _sequence)) {
      throw BillingException(code: 'staleObservation');
    }
    final now = _service.clock.now().toUtc();
    return rows.any((p) => _service._active(p, now));
  }

  Future<void> requireActive(ProductService s) async {
    if (!await isActive(s)) {
      throw BillingException(code: 'entitlementInactive');
    }
  }
}

Future<void> lockPurchaseIdentity(
  Session s,
  String hash,
  Transaction tx,
) async {
  await s.db.unsafeQuery(
    'SELECT pg_advisory_xact_lock(hashtextextended(@hash, 892173))',
    parameters: QueryParameters.named({'hash': hash}),
    transaction: tx,
  );
}

/// Called under the same AuthUser lock as billing writes. No owner, binding,
/// token, timestamps, product or store survive in the retained tombstone.
Future<void> deleteBillingData(Session s, String owner, Transaction tx) async {
  final db = await s.serverpod.createSession(enableLogging: false);
  try {
    await _deleteBillingData(db, owner, tx);
  } on DatabaseQueryException {
    throw BillingException(code: 'temporarilyUnavailable');
  } finally {
    await db.close();
  }
}

Future<void> _deleteBillingData(Session s, String owner, Transaction tx) async {
  final rows = await StoredPurchase.db.find(
    s,
    where: (t) => t.owner.equals(owner),
    orderBy: (t) => t.identityHash,
    transaction: tx,
  );
  for (final row in rows) {
    await lockPurchaseIdentity(s, row.identityHash, tx);
    await PurchaseTombstone.db.insert(
      s,
      [PurchaseTombstone(identityHash: row.identityHash)],
      ignoreConflicts: true,
      transaction: tx,
    );
  }
  await StoredPurchase.db.deleteWhere(
    s,
    where: (t) => t.owner.equals(owner),
    transaction: tx,
  );
  await BillingAccount.db.deleteWhere(
    s,
    where: (t) => t.owner.equals(owner),
    transaction: tx,
  );
}
