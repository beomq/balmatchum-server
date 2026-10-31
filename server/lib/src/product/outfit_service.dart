import 'dart:convert';

import 'package:clock/clock.dart';

import '../generated/protocol.dart';
import 'product_service.dart';

const vestOutfitPrice = 3;
const _outfits = {
  'vest-low-v': ('조끼', vestOutfitPrice, ['shih-tzu', 'dachshund']),
};

extension OutfitService on ProductService {
  Future<OutfitStore> outfits() async {
    final owned = await OutfitOwnership.db.find(
      session,
      where: (t) => t.owner.equals(owner),
      transaction: tx,
    );
    final dog = await DogProfile.db.findFirstRow(
      session,
      where: (t) => t.owner.equals(owner),
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
            owned: owned.any((o) => o.outfitId == id),
          ),
      ],
      equippedOutfit: account.equippedOutfit,
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
          owner: owner,
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
          owner: owner,
          outfitId: outfitId,
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
    account.equippedOutfit = outfitId;
    await ProductAccount.db.updateRow(session, account, transaction: tx);
    final result = await outfits();
    await remember(requestId, payload, result.toJson());
    return result;
  }
}
