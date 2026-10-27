import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/future_calls.dart';
import '../generated/protocol.dart';

/// Payment and withdrawal records survive account deletion for five years
/// (Enforcement Decree of the E-Commerce Consumer Protection Act, Article 6).
const paymentRecordRetentionYears = 5;

/// Owner decision: a subscription identity hash outlives its last known expiry
/// by one year; a lifetime purchase hash stays while the service runs.
const subscriptionIdentityRetentionYears = 1;

const billingRetentionPurgeIdentifier = 'billing-retention-purge';

/// Daily at 18:00 UTC (03:00 KST). Cron is computed from the current time, so
/// frequent restarts cannot postpone the purge the way a fresh interval would.
const billingRetentionPurgeCron = '0 18 * * *';

DateTime _plusYears(DateTime time, int years) => DateTime.utc(
  time.year + years,
  time.month,
  time.day,
  time.hour,
  time.minute,
  time.second,
  time.millisecond,
  time.microsecond,
);

DateTime _latest(Iterable<DateTime> times) =>
    times.reduce((a, b) => a.isAfter(b) ? a : b);

/// Null means "keep while the service runs". The expiry is the latest one the
/// store reported; [observedAt] stands in only when the store reported none.
DateTime? identityRetainUntil(
  String kind,
  List<DateTime?> expiries,
  DateTime observedAt,
) => kind == 'lifetime'
    ? null
    : _plusYears(
        expiries.nonNulls.isEmpty ? observedAt : _latest(expiries.nonNulls),
        subscriptionIdentityRetentionYears,
      );

/// The caller holds [lockPurchaseIdentity] for the hash. An existing hash is
/// only ever kept longer: a later store observation may extend it.
Future<void> retainPurchaseIdentity(
  Session s,
  PurchaseTombstone wanted,
  Transaction tx,
) async {
  final existing = await PurchaseTombstone.db.findFirstRow(
    s,
    where: (t) => t.identityHash.equals(wanted.identityHash),
    transaction: tx,
  );
  if (existing == null) {
    await PurchaseTombstone.db.insertRow(s, wanted, transaction: tx);
    return;
  }
  final current = existing.retainUntil;
  final until = wanted.retainUntil;
  if (current == null || (until != null && !until.isAfter(current))) return;
  existing.retainUntil = until;
  await PurchaseTombstone.db.updateRow(s, existing, transaction: tx);
}

/// Deliberately drops owner, binding, identity hash and any Google purchase
/// token, so the record cannot be joined back to the deleted account.
RetainedPaymentRecord paymentRecordOf(StoredPurchase row, DateTime recordedAt) {
  // A renewal may be charged after Google's startTime, but never after the
  // last observation or past the paid-through expiry.
  final expiresAt = row.expiresAt;
  final lastTransaction = _latest([
    row.purchasedAt ?? row.observedAt,
    if (row.revokedAt != null) row.revokedAt!,
    if (row.kind == 'subscription')
      expiresAt != null && expiresAt.isBefore(row.observedAt)
          ? expiresAt
          : row.observedAt,
  ]);
  return RetainedPaymentRecord(
    store: row.store,
    environment: row.environment,
    productId: row.productId,
    kind: row.kind,
    storeTransactionId: row.transactionId,
    // Apple's original transaction ID is a store transaction ID; Google's
    // purchase reference is a token and must never be retained.
    originalTransactionId: switch (row.store) {
      'apple' => row.purchaseReference,
      _ => null,
    },
    state: row.state,
    purchasedAt: row.purchasedAt,
    expiresAt: row.expiresAt,
    revokedAt: row.revokedAt,
    recordedAt: recordedAt,
    purgeAfter: _plusYears(lastTransaction, paymentRecordRetentionYears),
  );
}

/// Idempotent and restart-safe: each batch re-checks expiry when deleting, so
/// a hash extended by a concurrent lookup is kept.
Future<({int records, int identities})> purgeExpiredBillingRetention(
  Session session, {
  Clock clock = const Clock(),
  int batchSize = 500,
}) async {
  final cutoff = clock.now().toUtc();
  final db = await session.serverpod.createSession(enableLogging: false);
  try {
    var records = 0;
    while (true) {
      final ids = {
        for (final row in await RetainedPaymentRecord.db.find(
          db,
          where: (t) => t.purgeAfter < cutoff,
          orderBy: (t) => t.id,
          limit: batchSize,
        ))
          row.id!,
      };
      if (ids.isEmpty) break;
      records += (await RetainedPaymentRecord.db.deleteWhere(
        db,
        where: (t) => t.id.inSet(ids) & (t.purgeAfter < cutoff),
      )).length;
      if (ids.length < batchSize) break;
    }
    var identities = 0;
    while (true) {
      final ids = {
        for (final row in await PurchaseTombstone.db.find(
          db,
          where: (t) => t.retainUntil < cutoff,
          orderBy: (t) => t.id,
          limit: batchSize,
        ))
          row.id!,
      };
      if (ids.isEmpty) break;
      identities += (await PurchaseTombstone.db.deleteWhere(
        db,
        where: (t) => t.id.inSet(ids) & (t.retainUntil < cutoff),
      )).length;
      if (ids.length < batchSize) break;
    }
    return (records: records, identities: identities);
  } finally {
    await db.close();
  }
}

/// Purges once at startup, then replaces any previous daily schedule so
/// repeated startups keep exactly one. Serverpod Cloud Starter disables future
/// calls; there only the startup purge runs (every deploy or restart).
Future<void> startBillingRetention(Serverpod pod) async {
  final session = await pod.createSession(enableLogging: false);
  try {
    await purgeExpiredBillingRetention(session);
  } finally {
    await session.close();
  }
  // Same switch Serverpod checks before creating its future call manager.
  if (!pod.config.futureCall.enabled) return;
  await pod.futureCalls.cancel(billingRetentionPurgeIdentifier);
  await pod.futureCalls
      .callRecurring(identifier: billingRetentionPurgeIdentifier)
      .cron(billingRetentionPurgeCron)
      .billingRetentionPurgeCall
      .purge();
}

class BillingRetentionPurgeCall extends FutureCall {
  Future<void> purge(Session session) async {
    await purgeExpiredBillingRetention(session);
  }
}
