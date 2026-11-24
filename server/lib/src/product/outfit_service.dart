import 'dart:convert';

import 'package:clock/clock.dart';

import '../generated/protocol.dart';
import '../wardrobe/wardrobe_catalog.dart';
import '../wardrobe/wardrobe_service.dart';
import 'product_service.dart';

/// Legacy single-outfit API kept for app builds from before the wardrobe.
/// It sees only the vest, stored as wardrobe item vest/classic.
const vestOutfitPrice = 3;
const _outfits = {
  legacyVestOutfitId: ('조끼', vestOutfitPrice, ['shih-tzu', 'dachshund']),
};

bool _isVest(String outfitId, String colourId) =>
    outfitId == vestItemId && colourId == vestColourId;

extension OutfitService on ProductService {
  Future<OutfitStore> outfits() async {
    final owned = await OutfitOwnership.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    final dog = await DogProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    final torso = await OutfitEquip.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId) & t.slot.equals('torso'),
      transaction: tx,
    );
    final fixture = productFixturesEnabled(session);
    return OutfitStore(
      items: [
        for (final MapEntry(key: id, value: (name, price, breeds))
            in _outfits.entries)
          OutfitItem(
            outfitId: id,
            name: name,
            price: price,
            compatibleBreeds: breeds,
            compatible: breeds.contains(dog?.breedId),
            owned: owned.any((o) => _isVest(o.outfitId, o.colourId)),
          ),
      ],
      equippedOutfit: torso != null && _isVest(torso.outfitId, torso.colourId)
          ? legacyVestOutfitId
          : null,
      breedId: dog?.breedId,
      balance: await balance(fixture: fixture),
      fixtureLabel: fixture ? productFixtureLabel : null,
    );
  }

  Future<OutfitStore?> _replayOutfit(String requestId, Object payload) async {
    final previous = await replay(requestId, payload);
    return previous == null
        ? null
        : OutfitStore.fromJson(jsonDecode(previous) as Map<String, dynamic>);
  }

  OutfitItem _outfit(OutfitStore store, String outfitId) {
    final matches = store.items.where((item) => item.outfitId == outfitId);
    if (matches.isEmpty) throw ProductException(code: 'unknownOutfit');
    return matches.single;
  }

  Future<OutfitStore> purchaseOutfit(String outfitId, String requestId) async {
    final payload = ['purchaseOutfit', outfitId];
    final previous = await _replayOutfit(requestId, payload);
    if (previous != null) return previous;
    final store = await outfits();
    final item = _outfit(store, outfitId);
    if (!item.compatible) throw ProductException(code: 'outfitIncompatible');
    if (!item.owned) {
      if (store.balance < item.price) {
        throw ProductException(code: 'insufficientPoints');
      }
      await appendPointEntry(
        PointEntry(
          authUserId: authUserId,
          entryKey: 'outfit:$outfitId',
          kind: 'purchase',
          amount: -item.price,
          policyVersion: productFixturesEnabled(session)
              ? productFixtureLabel
              : outfitPurchasePolicyVersion,
          createdAt: clock.now().toUtc(),
        ),
      );
      await OutfitOwnership.db.insertRow(
        session,
        OutfitOwnership(
          authUserId: authUserId,
          outfitId: vestItemId,
          colourId: vestColourId,
          purchasedAt: clock.now().toUtc(),
        ),
        transaction: tx,
      );
    }
    final result = await outfits();
    await remember(requestId, payload, result.toJson());
    return result;
  }

  Future<OutfitStore> equipOutfit(String outfitId, String requestId) async {
    final payload = ['equipOutfit', outfitId];
    final previous = await _replayOutfit(requestId, payload);
    if (previous != null) return previous;
    final item = _outfit(await outfits(), outfitId);
    if (!item.owned) throw ProductException(code: 'outfitNotOwned');
    if (!item.compatible) throw ProductException(code: 'outfitIncompatible');
    return _saveEquipped(outfitId, requestId, payload);
  }

  Future<OutfitStore> unequipOutfit(String requestId) async {
    final payload = ['unequipOutfit'];
    final previous = await _replayOutfit(requestId, payload);
    if (previous != null) return previous;
    return _saveEquipped(null, requestId, payload);
  }

  Future<OutfitStore> _saveEquipped(
    String? outfitId,
    String requestId,
    Object payload,
  ) async {
    if (outfitId != null) {
      await setSlot('torso', vestItemId, vestColourId);
    } else {
      await OutfitEquip.db.deleteWhere(
        session,
        where: (t) =>
            t.authUserId.equals(authUserId) &
            t.slot.equals('torso') &
            t.outfitId.equals(vestItemId),
        transaction: tx,
      );
    }
    final result = await outfits();
    await remember(requestId, payload, result.toJson());
    return result;
  }
}
