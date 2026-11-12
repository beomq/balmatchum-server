import 'dart:convert';

import 'package:clock/clock.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'season_grants.dart';
import 'wardrobe_catalog.dart';

const wardrobePurchasePolicyVersion = 'wardrobe-purchase-v1-20261112';

String _sku(String itemId, String colourId) => '$itemId:$colourId';

/// Everything one wardrobe view or decision needs, read in the caller's tx.
class _Owned {
  _Owned({
    required this.items,
    required this.backgrounds,
    required this.equips,
    required this.granted,
    required this.breed,
    required this.subscriber,
    required this.now,
  });

  /// `item:colour` SKUs.
  final Set<String> items;
  final Set<String> backgrounds;
  final List<OutfitEquip> equips;
  final Set<String> granted;
  final String? breed;
  final bool subscriber;
  final DateTime now;

  bool ownsAnyOf(WardrobeSet set) => set.items.any(
    (item) => set.colours.any((c) => items.contains(_sku(item, c))),
  );
}

extension WardrobeService on ProductService {
  WardrobeCatalog get _catalog => WardrobeCatalog.current;

  Future<_Owned> _owned() async {
    final items = await OutfitOwnership.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    final themes = await ThemeOwnership.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    final equips = await OutfitEquip.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      orderBy: (t) => t.slot,
      transaction: tx,
    );
    final grants = await SeasonGrant.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    final dog = await DogProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    return _Owned(
      items: {for (final o in items) _sku(o.outfitId, o.colourId)},
      backgrounds: {defaultBackgroundId, for (final t in themes) t.themeId},
      equips: equips,
      granted: {for (final g in grants) g.setId},
      breed: dog?.breedId,
      subscriber: await subscriberActive(),
      now: clock.now().toUtc(),
    );
  }

  /// A season set is hidden before its release, shown while open, and after
  /// its end shown only to owners or during a limited-time resale.
  bool _visible(WardrobeSet set, _Owned o) {
    final season = set.season;
    if (season == null) return true;
    if (o.now.isBefore(season.releaseAt)) return false;
    if (!o.now.isAfter(season.endsAt)) return true;
    return o.granted.contains(_setIdOf(set)) ||
        o.ownsAnyOf(set) ||
        (season.resale?.contains(o.now) ?? false);
  }

  String _setIdOf(WardrobeSet set) =>
      _catalog.sets.entries.firstWhere((e) => identical(e.value, set)).key;

  bool _resaleOpen(WardrobeSet set, _Owned o) =>
      set.season?.resale?.contains(o.now) ?? false;

  /// Points for [set] in [colourId]: 20% off the parts not owned yet.
  ({int price, int missing}) _setPrice(
    WardrobeSet set,
    String colourId,
    _Owned o,
  ) {
    var sum = 0;
    var missing = 0;
    for (final itemId in set.items) {
      if (!o.items.contains(_sku(itemId, colourId))) {
        sum += itemPrice;
        missing++;
      }
    }
    if (!o.backgrounds.contains(set.background)) {
      sum += _catalog.backgrounds[set.background]!.price;
      missing++;
    }
    return (price: sum * (100 - setDiscountPct) ~/ 100, missing: missing);
  }

  bool _setWearable(WardrobeSet set, String colourId, String? breed) =>
      set.items.every(
        (itemId) =>
            _catalog.items[itemId]!.wearableColours(breed).contains(colourId),
      );

  bool _setPurchasable(WardrobeSet set, String colourId, _Owned o) {
    if (!_visible(set, o)) return false;
    final season = set.season;
    if (season != null && !_resaleOpen(set, o)) return false;
    return _setPrice(set, colourId, o).missing > 0 &&
        _setWearable(set, colourId, o.breed);
  }

  /// The set worn completely: every item in one colour over its background.
  (String, String)? _complete(_Owned o) {
    final worn = {
      for (final e in o.equips) e.slot: _sku(e.outfitId, e.colourId),
    };
    for (final MapEntry(key: setId, value: set) in _catalog.sets.entries) {
      if (account.equippedTheme != set.background) continue;
      for (final colourId in set.colours) {
        final all = set.items.every((itemId) {
          final item = _catalog.items[itemId]!;
          return worn[item.slot] == _sku(itemId, colourId) &&
              item.wearableColours(o.breed).contains(colourId);
        });
        if (all) return (setId, colourId);
      }
    }
    return null;
  }

  Future<WardrobeStore> wardrobe() async {
    final o = await _owned();
    final fixture = productFixturesEnabled(session);
    final visibleSets = {
      for (final MapEntry(:key, :value) in _catalog.sets.entries)
        if (_visible(value, o)) key: value,
    };
    final complete = _complete(o);
    return WardrobeStore(
      colours: [
        for (final MapEntry(:key, :value) in wardrobeColours.entries)
          WardrobeColourView(
            colourId: key,
            name: value.name,
            swatch: value.swatch,
          ),
      ],
      items: [
        for (final MapEntry(key: itemId, value: item) in _catalog.items.entries)
          if (_itemVisible(itemId, item, visibleSets, o))
            WardrobeItemView(
              itemId: itemId,
              slot: item.slot,
              name: item.name,
              price: itemPrice,
              colours: item.colours,
              ownedColours: [
                for (final c in item.colours)
                  if (o.items.contains(_sku(itemId, c))) c,
              ],
              wearableColours: item.wearableColours(o.breed),
              sellable: item.sellable,
              setIds: [
                for (final MapEntry(:key, :value) in visibleSets.entries)
                  if (value.items.contains(itemId)) key,
              ],
            ),
      ],
      backgrounds: [
        for (final MapEntry(key: id, value: bg) in _catalog.backgrounds.entries)
          if (_backgroundVisible(id, visibleSets))
            WardrobeBackgroundView(
              backgroundId: id,
              name: bg.name,
              price: bg.price,
              owned: o.backgrounds.contains(id),
              sellable: !_catalog.seasonBackground(id),
              setId: _catalog.setOfBackground(id),
            ),
      ],
      sets: [
        for (final MapEntry(key: setId, value: set) in visibleSets.entries)
          WardrobeSetView(
            setId: setId,
            name: set.name,
            itemIds: set.items,
            backgroundId: set.background,
            effect: set.effect,
            fullPrice:
                set.items.length * itemPrice +
                _catalog.backgrounds[set.background]!.price,
            discountPct: setDiscountPct,
            colours: [
              for (final colourId in set.colours)
                WardrobeSetColourView(
                  colourId: colourId,
                  price: _setPrice(set, colourId, o).price,
                  missingParts: _setPrice(set, colourId, o).missing,
                  purchasable: _setPurchasable(set, colourId, o),
                  wearable: _setWearable(set, colourId, o.breed),
                ),
            ],
            season: switch (set.season) {
              null => null,
              final season => WardrobeSeasonView(
                releaseAt: season.releaseAt,
                endsAt: season.endsAt,
                open: season.window.contains(o.now),
                granted: o.granted.contains(setId),
                resaleOpen: _resaleOpen(set, o),
                resaleEndsAt: season.resale?.endsAt,
              ),
            },
          ),
      ],
      equipped: [
        for (final e in o.equips)
          WardrobeEquipView(
            slot: e.slot,
            itemId: e.outfitId,
            colourId: e.colourId,
          ),
      ],
      equippedBackground: account.equippedTheme,
      completeSetId: complete?.$1,
      completeColour: complete?.$2,
      breedId: o.breed,
      balance: await balance(fixture: fixture),
      subscriber: o.subscriber,
      fixtureLabel: fixture ? productFixtureLabel : null,
    );
  }

  bool _itemVisible(
    String itemId,
    WardrobeItem item,
    Map<String, WardrobeSet> visibleSets,
    _Owned o,
  ) =>
      item.sellable ||
      visibleSets.values.any((set) => set.items.contains(itemId)) ||
      item.colours.any((c) => o.items.contains(_sku(itemId, c)));

  bool _backgroundVisible(String id, Map<String, WardrobeSet> visibleSets) {
    final setId = _catalog.setOfBackground(id);
    return setId == null ||
        _catalog.sets[setId]!.season == null ||
        visibleSets.containsKey(setId);
  }

  Future<WardrobeStore> _write(
    String requestId,
    List<Object?> payload,
    Future<void> Function(_Owned) action,
  ) async {
    final previous = await replay(requestId, payload);
    if (previous != null) {
      return WardrobeStore.fromJson(
        jsonDecode(previous) as Map<String, dynamic>,
      );
    }
    await action(await _owned());
    final result = await wardrobe();
    await remember(requestId, payload, result.toJson());
    return result;
  }

  WardrobeItem _item(String itemId, String colourId) {
    final item = _catalog.items[itemId];
    if (item == null || !item.colours.contains(colourId)) {
      throw ProductException(code: 'unknownOutfit');
    }
    return item;
  }

  WardrobeSet _set(String setId, String colourId, _Owned o) {
    final set = _catalog.sets[setId];
    if (set == null || !set.colours.contains(colourId) || !_visible(set, o)) {
      throw ProductException(code: 'unknownSet');
    }
    return set;
  }

  Future<void> _spend(String entryKey, int amount) async {
    final fixture = productFixturesEnabled(session);
    if (await balance(fixture: fixture) < amount) {
      throw ProductException(code: 'insufficientPoints');
    }
    await appendPointEntry(
      PointEntry(
        authUserId: authUserId,
        entryKey: entryKey,
        kind: 'purchase',
        amount: -amount,
        policyVersion: fixture
            ? productFixtureLabel
            : wardrobePurchasePolicyVersion,
        createdAt: clock.now().toUtc(),
      ),
    );
  }

  Future<void> _own(String itemId, String colourId) =>
      OutfitOwnership.db.insertRow(
        session,
        OutfitOwnership(
          authUserId: authUserId,
          outfitId: itemId,
          colourId: colourId,
          purchasedAt: clock.now().toUtc(),
        ),
        transaction: tx,
      );

  Future<void> _ownBackground(String backgroundId) =>
      ThemeOwnership.db.insertRow(
        session,
        ThemeOwnership(
          authUserId: authUserId,
          themeId: backgroundId,
          purchasedAt: clock.now().toUtc(),
        ),
        transaction: tx,
      );

  Future<WardrobeStore> purchaseItem(
    String itemId,
    String colourId,
    String requestId,
  ) => _write(requestId, ['purchaseItem', itemId, colourId], (o) async {
    final item = _item(itemId, colourId);
    if (!item.sellable) throw ProductException(code: 'setOnly');
    if (!item.wearableColours(o.breed).contains(colourId)) {
      throw ProductException(code: 'outfitIncompatible');
    }
    if (o.items.contains(_sku(itemId, colourId))) return;
    await _spend('outfit:$itemId:$colourId', itemPrice);
    await _own(itemId, colourId);
  });

  Future<WardrobeStore> purchaseBackground(
    String backgroundId,
    String requestId,
  ) => _write(requestId, ['purchaseBackground', backgroundId], (o) async {
    final bg = _catalog.backgrounds[backgroundId];
    if (bg == null) throw ProductException(code: 'unknownTheme');
    if (_catalog.seasonBackground(backgroundId)) {
      throw ProductException(code: 'setOnly');
    }
    if (o.backgrounds.contains(backgroundId)) return;
    await _spend('theme:$backgroundId', bg.price);
    await _ownBackground(backgroundId);
  });

  Future<WardrobeStore> purchaseSet(
    String setId,
    String colourId,
    String requestId,
  ) => _write(requestId, ['purchaseSet', setId, colourId], (o) async {
    final set = _set(setId, colourId, o);
    final season = set.season;
    if (season != null && season.window.contains(o.now)) {
      // During the window a season set is a subscriber gift, never sold.
      if (!o.subscriber) throw ProductException(code: 'subscriptionRequired');
      await grantSeasonSet(setId, 'subscribe');
      return;
    }
    if (!_setWearable(set, colourId, o.breed)) {
      throw ProductException(code: 'outfitIncompatible');
    }
    if (!_setPurchasable(set, colourId, o)) {
      throw ProductException(code: 'setNotPurchasable');
    }
    await _spend('set:$setId:$colourId', _setPrice(set, colourId, o).price);
    for (final itemId in set.items) {
      if (!o.items.contains(_sku(itemId, colourId))) {
        await _own(itemId, colourId);
      }
    }
    if (!o.backgrounds.contains(set.background)) {
      await _ownBackground(set.background);
    }
  });

  Future<void> _wear(String itemId, String colourId, _Owned o) async {
    final item = _item(itemId, colourId);
    if (!o.items.contains(_sku(itemId, colourId))) {
      throw ProductException(code: 'outfitNotOwned');
    }
    if (!item.wearableColours(o.breed).contains(colourId)) {
      throw ProductException(code: 'outfitIncompatible');
    }
    await setSlot(item.slot, itemId, colourId);
  }

  /// Puts one item in [slot], replacing whatever was there.
  Future<void> setSlot(String slot, String itemId, String colourId) async {
    final existing = await OutfitEquip.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId) & t.slot.equals(slot),
      transaction: tx,
    );
    if (existing == null) {
      await OutfitEquip.db.insertRow(
        session,
        OutfitEquip(
          authUserId: authUserId,
          slot: slot,
          outfitId: itemId,
          colourId: colourId,
        ),
        transaction: tx,
      );
    } else {
      existing
        ..outfitId = itemId
        ..colourId = colourId;
      await OutfitEquip.db.updateRow(session, existing, transaction: tx);
    }
  }

  Future<void> clearSlot(String slot) => OutfitEquip.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserId) & t.slot.equals(slot),
    transaction: tx,
  );

  Future<void> _wearBackground(String backgroundId, _Owned o) async {
    if (!_catalog.backgrounds.containsKey(backgroundId)) {
      throw ProductException(code: 'unknownTheme');
    }
    if (!o.backgrounds.contains(backgroundId)) {
      throw ProductException(code: 'themeNotOwned');
    }
    account.equippedTheme = backgroundId;
    await ProductAccount.db.updateRow(session, account, transaction: tx);
  }

  Future<WardrobeStore> equipItem(
    String itemId,
    String colourId,
    String requestId,
  ) => _write(
    requestId,
    ['equipItem', itemId, colourId],
    (o) => _wear(itemId, colourId, o),
  );

  Future<WardrobeStore> unequipSlot(String slot, String requestId) =>
      _write(requestId, ['unequipSlot', slot], (_) => clearSlot(slot));

  Future<WardrobeStore> equipBackground(
    String backgroundId,
    String requestId,
  ) => _write(
    requestId,
    ['equipBackground', backgroundId],
    (o) => _wearBackground(backgroundId, o),
  );

  /// Wears every item of the set in [colourId] and its background at once.
  Future<WardrobeStore> equipSet(
    String setId,
    String colourId,
    String requestId,
  ) => _write(requestId, ['equipSet', setId, colourId], (o) async {
    final set = _set(setId, colourId, o);
    for (final itemId in set.items) {
      if (!o.items.contains(_sku(itemId, colourId))) {
        throw ProductException(code: 'outfitNotOwned');
      }
    }
    for (final itemId in set.items) {
      await _wear(itemId, colourId, o);
    }
    await _wearBackground(set.background, o);
  });

  /// Takes off the set's items that are worn; the background stays.
  Future<WardrobeStore> unequipSet(String setId, String requestId) =>
      _write(requestId, ['unequipSet', setId], (o) async {
        final set = _catalog.sets[setId];
        if (set == null) throw ProductException(code: 'unknownSet');
        for (final e in o.equips) {
          if (set.items.contains(e.outfitId)) await clearSlot(e.slot);
        }
      });
}
