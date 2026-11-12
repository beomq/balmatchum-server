import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../billing/billing_service.dart';
import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'wardrobe_catalog.dart';

/// Season sets handed to paid subscribers.
///
/// A subscriber active while a set's window is open receives every item of the
/// set in every colour plus the set background, once ([SeasonGrant] is unique
/// per user and set). Grants are never taken back: unsubscribing keeps them,
/// and equipping never checks the subscription. Someone who subscribes after
/// the window has closed does not receive that set.
extension SeasonGrants on ProductService {
  /// An active paid subscription by the server's stored purchase observation.
  Future<bool> subscriberActive() async {
    final rows = await StoredPurchase.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    final now = clock.now().toUtc();
    return rows.any((row) => activeSubscription(row, now));
  }

  /// Grants every open season set this user has not received yet, if the
  /// user is an active subscriber. Returns the newly granted set ids.
  Future<List<String>> grantOpenSeasonSets(String reason) async {
    if (!await subscriberActive()) return const [];
    final now = clock.now().toUtc();
    final granted = <String>[];
    for (final MapEntry(key: setId, value: set)
        in WardrobeCatalog.current.sets.entries) {
      final season = set.season;
      if (season == null || !season.window.contains(now)) continue;
      if (await grantSeasonSet(setId, reason)) granted.add(setId);
    }
    return granted;
  }

  /// Gives [setId] in all colours with its background. False when this user
  /// already received it. Writes no point ledger rows.
  Future<bool> grantSeasonSet(String setId, String reason) async {
    final set = WardrobeCatalog.current.sets[setId]!;
    final now = clock.now().toUtc();
    final inserted = await SeasonGrant.db.insert(
      session,
      [
        SeasonGrant(
          authUserId: authUserId,
          setId: setId,
          grantedAt: now,
          reason: reason,
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    if (inserted.isEmpty) return false;
    await OutfitOwnership.db.insert(
      session,
      [
        for (final itemId in set.items)
          for (final colourId in set.colours)
            OutfitOwnership(
              authUserId: authUserId,
              outfitId: itemId,
              colourId: colourId,
              source: 'subscription',
              purchasedAt: now,
            ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    await ThemeOwnership.db.insert(
      session,
      [
        ThemeOwnership(
          authUserId: authUserId,
          themeId: set.background,
          source: 'subscription',
          purchasedAt: now,
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    return true;
  }
}

/// Season sets are a gift for paid subscribers only. A lifetime purchase is a
/// different product (DESIGN.md 6 names subscribers; BILLING_API.md keeps
/// `subscription` and `lifetime` apart), so it does not count here.
bool activeSubscription(StoredPurchase row, DateTime now) =>
    row.kind == 'subscription' && storedPurchaseActive(row, now);

/// Maintenance job: once a season window opens, hand the set to everyone whose
/// subscription is active by the stored observation. Idempotent and resumable:
/// a run cut short simply continues on the next tick.
Future<void> grantReleasedSeasonSets(Session session) async {
  final now = clock.now().toUtc();
  final open = WardrobeCatalog.current.sets.values.any(
    (set) => set.season?.window.contains(now) ?? false,
  );
  if (!open) return;
  final rows = await StoredPurchase.db.find(
    session,
    where: (t) => t.revokedAt.equals(null),
  );
  final users = {
    for (final row in rows)
      if (activeSubscription(row, now)) row.authUserId.toString(),
  };
  for (final owner in users) {
    try {
      await session.db.transaction((tx) async {
        final account = await lockProductAccount(session, owner, tx);
        await withClock(
          Clock.fixed(now),
          () => ProductService(
            session,
            owner,
            tx,
            account,
          ).grantOpenSeasonSets('release'),
        );
      });
    } on NotAuthorizedException {
      // The account was deleted after the purchase rows were read.
    }
  }
}
