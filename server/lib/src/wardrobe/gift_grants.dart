import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../billing/billing_service.dart';
import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'wardrobe_catalog.dart';

/// Monthly gifts for paying members (owner decisions 2026-11-12).
///
/// Every KST calendar month may have one gift: a set (every item in every
/// colour plus its background) or a single item (every colour). A member
/// active during that month receives it once ([GiftGrant] is unique per user
/// and month). Gifts are never taken back: cancelling keeps them and wearing
/// never checks membership. Someone who becomes a member later does not
/// receive past months. A month without a gift gives nothing.
extension GiftGrants on ProductService {
  /// An active subscription or lifetime purchase by the server's stored
  /// purchase observation.
  Future<bool> subscriberActive() async {
    final rows = await StoredPurchase.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    final now = clock.now().toUtc();
    return rows.any((row) => activeSubscription(row, now));
  }

  /// Gives this month's gift if the user is a member and has not received
  /// it. Returns the month granted, else null.
  Future<String?> grantCurrentGift(String reason) async {
    if (!await subscriberActive()) return null;
    final month = kstMonth(clock.now());
    if (!WardrobeCatalog.current.gifts.containsKey(month)) return null;
    return await grantGift(month, reason) ? month : null;
  }

  /// Gives [month]'s gift. False when this user already received it.
  /// Writes no point ledger rows.
  Future<bool> grantGift(String month, String reason) async {
    final catalog = WardrobeCatalog.current;
    final gift = catalog.gifts[month]!;
    final now = clock.now().toUtc();
    final inserted = await GiftGrant.db.insert(
      session,
      [
        GiftGrant(
          authUserId: authUserId,
          month: month,
          setId: gift.setId,
          itemId: gift.itemId,
          grantedAt: now,
          reason: reason,
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    if (inserted.isEmpty) return false;
    final set = gift.setId == null ? null : catalog.sets[gift.setId]!;
    final items = set?.items ?? [gift.itemId!];
    await OutfitOwnership.db.insert(
      session,
      [
        for (final itemId in items)
          for (final colourId in set?.colours ?? catalog.items[itemId]!.colours)
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
    if (set != null) {
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
    }
    return true;
  }
}

/// Gift eligibility: an active subscription or lifetime purchase (owner
/// decision 2026-11-12). A lifetime purchase never expires, so its holder
/// keeps receiving the gifts; a revoked one receives nothing.
bool activeSubscription(StoredPurchase row, DateTime now) =>
    const {'subscription', 'lifetime'}.contains(row.kind) &&
    storedPurchaseActive(row, now);

/// Maintenance job: from the 1st of a month with a gift, hand it to every
/// member by the stored observation. Idempotent and resumable: a run cut
/// short continues on the next tick.
Future<void> grantMonthlyGifts(Session session) async {
  final now = clock.now().toUtc();
  if (!WardrobeCatalog.current.gifts.containsKey(kstMonth(now))) return;
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
          ).grantCurrentGift('release'),
        );
      });
    } on NotAuthorizedException {
      // The account was deleted after the purchase rows were read.
    }
  }
}
