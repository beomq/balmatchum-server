import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/wardrobe/season_grants.dart';
import 'package:balmatchum_server/src/wardrobe/wardrobe_catalog.dart';
import 'package:balmatchum_server/src/wardrobe/wardrobe_service.dart';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

final createdAt = DateTime.utc(2026, 10, 27);

/// Before any season window: only the winter set is on sale.
final november = kst(2026, 11, 20, 12);
final holidayOpen = kst(2026, 12, 5, 12);
final holidayRelease = kst(2026, 12, 1, 0, 0, 1);
final afterHoliday = kst(2027, 1, 20, 12);

Matcher productError(String code) =>
    throwsA(isA<ProductException>().having((e) => e.code, 'code', code));

Future<T> at<T>(DateTime instant, Future<T> Function() body) =>
    withClock(Clock.fixed(instant), body);

WardrobeSetView setOf(WardrobeStore store, String setId) =>
    store.sets.singleWhere((s) => s.setId == setId);

WardrobeSetColourView colourOf(
  WardrobeStore store,
  String setId,
  String colourId,
) => setOf(store, setId).colours.singleWhere((c) => c.colourId == colourId);

WardrobeItemView itemOf(WardrobeStore store, String itemId) =>
    store.items.singleWhere((i) => i.itemId == itemId);

void main() {
  withServerpod('Wardrobe items, sets and season sets', (builder, endpoints) {
    late TestSessionBuilder owner;
    late Session session;
    late String userId;
    var requests = 0;
    String request() => 'req-${requests++}';

    Future<void> as(String? breed) async {
      final id = const Uuid().v4();
      owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(id, {}),
      );
      session = owner.build();
      userId = id;
      await AuthUser.db.insertRow(
        session,
        AuthUser(id: UuidValue.fromString(id), scopeNames: {}),
      );
      if (breed != null) {
        await DogProfile.db.insertRow(
          session,
          DogProfile(
            authUserId: authUserIdOf(id),
            breedId: breed,
            name: 'Dog',
            sex: 'female',
            dailyGoal: 5000,
            firstMetAt: createdAt,
          ),
        );
      }
    }

    Future<void> fund(int amount) => session.db.transaction((tx) async {
      final account = await lockProductAccount(session, userId, tx);
      await ProductService(session, userId, tx, account).appendPointEntry(
        PointEntry(
          authUserId: authUserIdOf(userId),
          entryKey: 'fund:${request()}',
          kind: 'test-credit',
          amount: amount,
          policyVersion: stepPolicyVersion,
          createdAt: createdAt,
        ),
      );
    });

    Future<List<PointEntry>> debits() => PointEntry.db.find(
      session,
      where: (t) =>
          t.authUserId.equals(authUserIdOf(userId)) & t.kind.equals('purchase'),
      orderBy: (t) => t.id,
    );

    /// A stored subscription observed active from [from] until [until].
    Future<StoredPurchase> subscribe(DateTime from, DateTime until) =>
        StoredPurchase.db.insertRow(
          session,
          StoredPurchase(
            authUserId: authUserIdOf(userId),
            identityHash: 'hash-$userId',
            store: 'apple',
            environment: 'sandbox',
            productId: 'premium-monthly',
            kind: 'subscription',
            purchaseReference: 'ref-$userId',
            state: 'active',
            sequence: 1,
            observedAt: from,
            purchasedAt: from,
            expiresAt: until,
            acknowledgementPending: false,
          ),
        );

    Future<WardrobeStore> wardrobe(DateTime when) =>
        at(when, () => endpoints.wardrobe.getWardrobe(owner));

    tearDown(() => WardrobeCatalog.current = WardrobeCatalog.standard);

    test('wardrobe methods require authentication', () async {
      await expectLater(
        endpoints.wardrobe.getWardrobe(builder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
      await expectLater(
        endpoints.wardrobe.purchaseSet(builder, 'winter', 'tomato', 'r'),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test(
      'before the holiday window only the winter set shows, at 440P',
      () async {
        await as('maltese');

        final store = await wardrobe(november);

        expect(store.sets.map((s) => s.setId), ['winter']);
        final winter = setOf(store, 'winter');
        expect(winter.fullPrice, 550);
        expect(winter.discountPct, 20);
        expect(winter.effect, 'snow');
        for (final colour in winter.colours) {
          expect(colour.price, 440, reason: colour.colourId);
          expect(colour.missingParts, 4);
          expect(colour.purchasable, isTrue);
          expect(colour.wearable, isTrue);
        }
        expect(
          store.items.map((i) => i.itemId),
          unorderedEquals(['padding', 'beanie', 'booties', 'vest']),
        );
        expect(itemOf(store, 'padding').price, itemPrice);
        expect(itemOf(store, 'padding').wearableColours, [
          'tomato',
          'pine',
          'plum',
          'navy',
        ]);
        expect(
          store.backgrounds.map((b) => b.backgroundId),
          isNot(contains('holiday-night')),
        );
        expect(
          store.backgrounds
              .singleWhere((b) => b.backgroundId == 'winter-dusk')
              .price,
          backgroundPrice,
        );
        expect(store.subscriber, isFalse);
      },
    );

    test(
      'a breed without layered art wears only the baked tomato padding',
      () async {
        await as('beagle');
        await fund(1000);

        final store = await wardrobe(november);
        expect(itemOf(store, 'padding').wearableColours, ['tomato']);
        expect(itemOf(store, 'beanie').wearableColours, isEmpty);
        expect(
          setOf(store, 'winter').colours.map((c) => c.purchasable),
          everyElement(isFalse),
        );

        await expectLater(
          at(
            november,
            () => endpoints.wardrobe.purchaseItem(
              owner,
              'beanie',
              'tomato',
              request(),
            ),
          ),
          productError('outfitIncompatible'),
        );
        await expectLater(
          at(
            november,
            () => endpoints.wardrobe.purchaseItem(
              owner,
              'padding',
              'pine',
              request(),
            ),
          ),
          productError('outfitIncompatible'),
        );
        final bought = await at(
          november,
          () => endpoints.wardrobe.purchaseItem(
            owner,
            'padding',
            'tomato',
            request(),
          ),
        );
        final worn = await at(
          november,
          () => endpoints.wardrobe.equipItem(
            owner,
            'padding',
            'tomato',
            request(),
          ),
        );
        expect(bought.balance, 850);
        expect(worn.equipped.single.itemId, 'padding');
        expect(worn.completeSetId, isNull);
      },
    );

    test(
      'each colour is its own 150P purchase and replays never charge twice',
      () async {
        await as('dachshund');
        await fund(400);

        final id = request();
        final first = await at(
          november,
          () => endpoints.wardrobe.purchaseItem(owner, 'padding', 'tomato', id),
        );
        final replayed = await at(
          november,
          () => endpoints.wardrobe.purchaseItem(owner, 'padding', 'tomato', id),
        );
        final second = await at(
          november,
          () => endpoints.wardrobe.purchaseItem(
            owner,
            'padding',
            'navy',
            request(),
          ),
        );

        expect(first.balance, 250);
        expect(replayed.balance, 250);
        expect(second.balance, 100);
        expect(itemOf(second, 'padding').ownedColours, ['tomato', 'navy']);
        final ledger = await debits();
        expect(ledger.map((e) => e.entryKey), [
          'outfit:padding:tomato',
          'outfit:padding:navy',
        ]);
        expect(ledger.map((e) => e.amount), [-150, -150]);
        expect(
          ledger.map((e) => e.policyVersion),
          everyElement(wardrobePurchasePolicyVersion),
        );
        await expectLater(
          at(
            november,
            () => endpoints.wardrobe.purchaseItem(
              owner,
              'padding',
              'pine',
              request(),
            ),
          ),
          productError('insufficientPoints'),
        );
      },
    );

    test(
      'a set costs 20% less than the parts still missing in that colour',
      () async {
        await as('golden-retriever');
        await fund(1000);
        await at(
          november,
          () => endpoints.wardrobe.purchaseItem(
            owner,
            'padding',
            'tomato',
            request(),
          ),
        );

        final quoted = await wardrobe(november);
        expect(colourOf(quoted, 'winter', 'tomato').price, 320);
        expect(colourOf(quoted, 'winter', 'tomato').missingParts, 3);
        expect(colourOf(quoted, 'winter', 'pine').price, 440);

        final bought = await at(
          november,
          () => endpoints.wardrobe.purchaseSet(
            owner,
            'winter',
            'tomato',
            request(),
          ),
        );

        expect(bought.balance, 1000 - 150 - 320);
        expect(colourOf(bought, 'winter', 'tomato').purchasable, isFalse);
        expect(colourOf(bought, 'winter', 'tomato').price, 0);
        expect(colourOf(bought, 'winter', 'pine').price, 360);
        for (final item in ['padding', 'beanie', 'booties']) {
          expect(itemOf(bought, item).ownedColours, ['tomato'], reason: item);
        }
        expect(
          bought.backgrounds
              .singleWhere((b) => b.backgroundId == 'winter-dusk')
              .owned,
          isTrue,
        );
        expect((await debits()).last.entryKey, 'set:winter:tomato');
        await expectLater(
          at(
            november,
            () => endpoints.wardrobe.purchaseSet(
              owner,
              'winter',
              'tomato',
              request(),
            ),
          ),
          productError('setNotPurchasable'),
        );
      },
    );

    test(
      'a set is complete only in one colour over its own background',
      () async {
        await as('maltese');
        await fund(1000);
        await at(
          november,
          () => endpoints.wardrobe.purchaseSet(
            owner,
            'winter',
            'tomato',
            request(),
          ),
        );
        await at(
          november,
          () => endpoints.wardrobe.purchaseItem(
            owner,
            'beanie',
            'pine',
            request(),
          ),
        );
        Future<WardrobeStore> call(
          Future<WardrobeStore> Function(String) write,
        ) => at(november, () => write(request()));

        final complete = await call(
          (r) => endpoints.wardrobe.equipSet(owner, 'winter', 'tomato', r),
        );
        expect(complete.completeSetId, 'winter');
        expect(complete.completeColour, 'tomato');
        expect(complete.equippedBackground, 'winter-dusk');
        expect(
          complete.equipped.map((e) => e.slot),
          unorderedEquals([
            'feet',
            'head',
            'torso',
          ]),
        );

        final mixed = await call(
          (r) => endpoints.wardrobe.equipItem(owner, 'beanie', 'pine', r),
        );
        expect(mixed.completeSetId, isNull);

        final back = await call(
          (r) => endpoints.wardrobe.equipItem(owner, 'beanie', 'tomato', r),
        );
        expect(back.completeSetId, 'winter');

        final otherBackground = await call(
          (r) => endpoints.wardrobe.equipBackground(owner, 'sunny', r),
        );
        expect(otherBackground.completeSetId, isNull);
        expect(otherBackground.equipped, hasLength(3));

        final bare = await call(
          (r) => endpoints.wardrobe.unequipSlot(owner, 'feet', r),
        );
        expect(
          bare.equipped.map((e) => e.slot),
          unorderedEquals(['head', 'torso']),
        );

        await expectLater(
          call(
            (r) => endpoints.wardrobe.equipItem(owner, 'booties', 'navy', r),
          ),
          productError('outfitNotOwned'),
        );
        await expectLater(
          call((r) => endpoints.wardrobe.equipBackground(owner, 'rainy', r)),
          productError('themeNotOwned'),
        );
      },
    );

    test(
      'in the window a non-subscriber may look and try, never buy',
      () async {
        await as('maltese');
        await fund(1000);

        final store = await wardrobe(holidayOpen);
        final holiday = setOf(store, 'holiday');
        expect(holiday.season!.open, isTrue);
        expect(holiday.season!.granted, isFalse);
        expect(
          holiday.colours.map((c) => c.purchasable),
          everyElement(isFalse),
        );
        expect(itemOf(store, 'rudolph-band').sellable, isFalse);
        await expectLater(
          at(
            holidayOpen,
            () => endpoints.wardrobe.purchaseSet(
              owner,
              'holiday',
              'tomato',
              request(),
            ),
          ),
          productError('subscriptionRequired'),
        );
        await expectLater(
          at(
            holidayOpen,
            () => endpoints.wardrobe.purchaseItem(
              owner,
              'rudolph-band',
              'tomato',
              request(),
            ),
          ),
          productError('setOnly'),
        );
      },
    );

    test(
      'subscribers active at release get every colour, once, for free',
      () async {
        await as('maltese');
        await subscribe(kst(2026, 11, 1), kst(2027, 3, 1));

        await at(holidayRelease, () => grantReleasedSeasonSets(session));
        await at(holidayRelease, () => grantReleasedSeasonSets(session));

        final store = await wardrobe(holidayOpen);
        expect(store.subscriber, isTrue);
        expect(setOf(store, 'holiday').season!.granted, isTrue);
        expect(itemOf(store, 'rudolph-band').ownedColours, [
          'tomato',
          'pine',
          'navy',
        ]);
        expect(itemOf(store, 'santa-cape').ownedColours, hasLength(3));
        expect(
          store.backgrounds
              .singleWhere((b) => b.backgroundId == 'holiday-night')
              .owned,
          isTrue,
        );
        expect(await debits(), isEmpty);
        final grants = await SeasonGrant.db.find(
          session,
          where: (t) => t.authUserId.equals(authUserIdOf(userId)),
        );
        expect(grants.map((g) => (g.setId, g.reason)), [
          ('holiday', 'release'),
        ]);
        final owned = await OutfitOwnership.db.find(
          session,
          where: (t) => t.authUserId.equals(authUserIdOf(userId)),
        );
        expect(owned, hasLength(6));
        expect(owned.map((o) => o.source), everyElement('subscription'));
      },
    );

    test('unsubscribing keeps the gift and it can still be worn', () async {
      await as('dachshund');
      final purchase = await subscribe(kst(2026, 11, 1), kst(2026, 12, 31));
      await at(holidayRelease, () => grantReleasedSeasonSets(session));
      purchase
        ..state = 'expired'
        ..observedAt = kst(2027, 1, 2);
      await StoredPurchase.db.updateRow(session, purchase);

      final worn = await at(
        afterHoliday,
        () => endpoints.wardrobe.equipSet(owner, 'holiday', 'navy', request()),
      );

      expect(worn.subscriber, isFalse);
      expect(setOf(worn, 'holiday').season!.granted, isTrue);
      expect(worn.completeSetId, 'holiday');
      expect(worn.completeColour, 'navy');
    });

    test(
      'a subscriber who joins in the window receives it on subscribe',
      () async {
        await as('golden-retriever');
        await subscribe(kst(2026, 12, 10), kst(2027, 1, 10));

        final granted = await at(
          kst(2026, 12, 10, 9),
          () => ProductService.run(
            session,
            (s) => s.grantOpenSeasonSets('subscribe'),
          ),
        );
        final gift = await at(
          kst(2026, 12, 10, 9),
          () => endpoints.wardrobe.purchaseSet(
            owner,
            'holiday',
            'pine',
            request(),
          ),
        );

        expect(granted, ['holiday']);
        expect(setOf(gift, 'holiday').season!.granted, isTrue);
        expect(await debits(), isEmpty);
      },
    );

    test('a late subscriber does not receive a past set', () async {
      await as('maltese');
      await subscribe(kst(2027, 1, 15), kst(2027, 2, 15));

      final granted = await at(
        afterHoliday,
        () => ProductService.run(
          session,
          (s) => s.grantOpenSeasonSets('subscribe'),
        ),
      );
      await at(afterHoliday, () => grantReleasedSeasonSets(session));
      final store = await wardrobe(afterHoliday);

      expect(granted, isEmpty);
      expect(store.sets.map((s) => s.setId), ['winter']);
      expect(
        store.items.map((i) => i.itemId),
        isNot(contains('rudolph-band')),
      );
    });

    test('a past set can reopen as a limited-time point sale', () async {
      WardrobeCatalog.current = WardrobeCatalog(
        sets: {
          ...WardrobeCatalog.standard.sets,
          'holiday': WardrobeSet(
            name: '크리스마스 세트',
            items: const ['rudolph-band', 'santa-cape'],
            background: 'holiday-night',
            colours: const ['tomato', 'pine', 'navy'],
            effect: 'holiday',
            season: Season(
              window: WardrobeCatalog.standard.sets['holiday']!.season!.window,
              resale: Window(kst(2027, 11, 1), kst(2027, 11, 30)),
            ),
          ),
        },
      );
      await as('maltese');
      await fund(1000);
      final during = kst(2027, 11, 10);

      final quoted = await wardrobe(during);
      expect(setOf(quoted, 'holiday').season!.resaleOpen, isTrue);
      expect(colourOf(quoted, 'holiday', 'navy').price, 320);
      final bought = await at(
        during,
        () => endpoints.wardrobe.purchaseSet(
          owner,
          'holiday',
          'navy',
          request(),
        ),
      );

      expect(bought.balance, 680);
      expect(itemOf(bought, 'rudolph-band').ownedColours, ['navy']);
      expect(colourOf(bought, 'holiday', 'tomato').purchasable, isTrue);
      final closed = await wardrobe(kst(2027, 12, 5));
      expect(setOf(closed, 'holiday').season!.resaleOpen, isFalse);
      expect(
        setOf(closed, 'holiday').colours.map((c) => c.purchasable),
        everyElement(isFalse),
      );
    });

    test('home snapshot carries the worn wardrobe', () async {
      await as('maltese');
      await fund(500);
      await at(
        november,
        () => endpoints.wardrobe.purchaseSet(
          owner,
          'winter',
          'plum',
          request(),
        ),
      );
      await at(
        november,
        () => endpoints.wardrobe.equipSet(owner, 'winter', 'plum', request()),
      );

      final home = await at(
        november,
        () => endpoints.product.getHomeSnapshot(owner),
      );

      expect(home.wardrobe.completeSetId, 'winter');
      expect(home.wardrobe.completeColour, 'plum');
      expect(home.themes.equippedTheme, 'winter-dusk');
    });

    test('the legacy vest endpoints read and write vest/classic', () async {
      await as('shih-tzu');
      await fund(10);

      await endpoints.product.purchaseOutfit(owner, legacyVestOutfitId, 'v1');
      final legacy = await endpoints.product.equipOutfit(
        owner,
        legacyVestOutfitId,
        'v2',
      );
      final store = await wardrobe(november);

      expect(legacy.equippedOutfit, legacyVestOutfitId);
      expect(itemOf(store, 'vest').ownedColours, ['classic']);
      expect(store.equipped.single.itemId, 'vest');
      expect(store.equipped.single.colourId, 'classic');
    });
  });
}
