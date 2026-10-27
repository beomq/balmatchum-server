import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/product/outfit_service.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const vest = 'vest-low-v';
final createdAt = DateTime.utc(2026, 10, 27);

Matcher productError(String code) =>
    throwsA(isA<ProductException>().having((e) => e.code, 'code', code));

void main() {
  withServerpod('Vest outfit purchases', (builder, endpoints) {
    late TestSessionBuilder owner;
    late Session session;
    late String userId;

    Future<TestSessionBuilder> user({String? breed}) async {
      final id = const Uuid().v4();
      final built = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(id, {}),
      );
      final s = built.build();
      await AuthUser.db.insertRow(
        s,
        AuthUser(id: UuidValue.fromString(id), scopeNames: {}),
      );
      if (breed != null) {
        await DogProfile.db.insertRow(
          s,
          DogProfile(
            owner: id,
            breedId: breed,
            name: 'Dog',
            sex: 'female',
            dailyGoal: 5000,
            firstMetAt: createdAt,
          ),
        );
      }
      return built;
    }

    Future<void> fund(int amount, {String? to}) => PointEntry.db.insertRow(
      session,
      PointEntry(
        owner: to ?? userId,
        entryKey: 'fund:$amount',
        kind: 'test-credit',
        amount: amount,
        policyVersion: stepPolicyVersion,
        createdAt: createdAt,
      ),
    );

    Future<List<PointEntry>> debits([String? of]) => PointEntry.db.find(
      session,
      where: (t) => t.owner.equals(of ?? userId) & t.kind.equals('purchase'),
    );

    Future<int> ownerships([String? of]) => OutfitOwnership.db.count(
      session,
      where: (t) => t.owner.equals(of ?? userId),
    );

    Future<void> as(String breed) async {
      owner = await user(breed: breed);
      session = owner.build();
      userId = session.authenticated!.userIdentifier;
    }

    test('outfit methods require authentication', () async {
      final calls = <Future<dynamic>>[
        endpoints.product.listOutfits(builder),
        endpoints.product.purchaseOutfit(builder, vest, 'purchase'),
        endpoints.product.equipOutfit(builder, vest, 'equip'),
        endpoints.product.unequipOutfit(builder, 'unequip'),
      ];
      await Future.wait(
        calls.map(
          (call) => expectLater(
            call,
            throwsA(isA<ServerpodUnauthenticatedException>()),
          ),
        ),
      );
    });

    for (final (breed, compatible) in [
      ('shih-tzu', true),
      ('dachshund', true),
      ('toy-poodle', false),
    ]) {
      test('catalog marks $breed compatible: $compatible', () async {
        // Given.
        await as(breed);

        // When.
        final store = await endpoints.product.listOutfits(owner);

        // Then.
        final item = store.items.single;
        expect(item.outfitId, vest);
        expect(item.price, vestOutfitPrice);
        expect(item.compatibleBreeds, ['shih-tzu', 'dachshund']);
        expect(item.compatible, compatible);
        expect(item.owned, isFalse);
        expect(store.breedId, breed);
        expect(store.equippedOutfit, isNull);
      });
    }

    test('a dog-less account sees the vest as incompatible', () async {
      // Given.
      owner = await user();

      // When.
      final store = await endpoints.product.listOutfits(owner);

      // Then.
      expect(store.breedId, isNull);
      expect(store.items.single.compatible, isFalse);
    });

    test('purchase debits the price once with the outfit policy', () async {
      // Given: production credit plus excluded fixture credit.
      await as('shih-tzu');
      await fund(vestOutfitPrice + 1);
      await PointEntry.db.insertRow(
        session,
        PointEntry(
          owner: userId,
          entryKey: 'fixture',
          kind: 'test-credit',
          amount: 100,
          policyVersion: productFixtureLabel,
          createdAt: createdAt,
        ),
      );

      // When.
      final store = await endpoints.product.purchaseOutfit(owner, vest, 'buy');

      // Then.
      expect(store.items.single.owned, isTrue);
      expect(store.balance, 1);
      expect(store.equippedOutfit, isNull);
      expect((await endpoints.product.getWallet(owner)).balance, 1);
      expect((await endpoints.product.listThemes(owner)).balance, 1);
      final debit = (await debits()).single;
      expect(debit.amount, -vestOutfitPrice);
      expect(debit.entryKey, 'outfit:$vest');
      expect(debit.policyVersion, outfitPurchasePolicyVersion);
      expect(await ownerships(), 1);
    });

    test('insufficient balance rejects without purchase writes', () async {
      // Given.
      await as('dachshund');
      await fund(vestOutfitPrice - 1);

      // When.
      await expectLater(
        endpoints.product.purchaseOutfit(owner, vest, 'buy'),
        productError('insufficientPoints'),
      );

      // Then.
      expect(
        (await endpoints.product.getWallet(owner)).balance,
        vestOutfitPrice - 1,
      );
      expect(await debits(), isEmpty);
      expect(await ownerships(), 0);
    });

    test('same key retry returns the original snapshot', () async {
      // Given: a later equip makes the current store differ from the receipt.
      await as('shih-tzu');
      await fund(vestOutfitPrice);
      final first = await endpoints.product.purchaseOutfit(owner, vest, 'buy');
      await endpoints.product.equipOutfit(owner, vest, 'equip');

      // When.
      final replay = await endpoints.product.purchaseOutfit(owner, vest, 'buy');

      // Then.
      expect(replay.toJson(), first.toJson());
      expect(replay.equippedOutfit, isNull);
      expect((await debits()).single.amount, -vestOutfitPrice);
      expect(await ownerships(), 1);
      await expectLater(
        endpoints.product.purchaseOutfit(owner, 'cape', 'buy'),
        productError('idempotencyConflict'),
      );
    });

    test('five parallel purchases debit the vest once', () async {
      for (var round = 0; round < 3; round++) {
        // Given: a fresh owner per round with exactly the vest price.
        await as('dachshund');
        await fund(vestOutfitPrice);

        // When: distinct and repeated keys race.
        final stores = await Future.wait([
          for (var i = 0; i < 5; i++)
            endpoints.product.purchaseOutfit(owner, vest, 'race-${i % 3}'),
        ]);

        // Then.
        final reason = 'round $round';
        expect(stores.every((s) => s.items.single.owned), isTrue);
        expect(stores.map((s) => s.balance).toSet(), {0}, reason: reason);
        expect((await debits()).single.amount, -vestOutfitPrice);
        expect(await ownerships(), 1, reason: reason);
        expect((await endpoints.product.getWallet(owner)).balance, 0);
      }
    });

    test('parallel outfit and theme purchases cannot overspend', () async {
      // Given: credit for exactly one of the two items.
      await as('shih-tzu');
      await fund(vestOutfitPrice);

      // When.
      final outcomes = await Future.wait<Object>([
        endpoints.product
            .purchaseOutfit(owner, vest, 'vest')
            .then<Object>((s) => s, onError: (Object e) => e),
        endpoints.product
            .purchaseTheme(owner, 'cloudy', 'theme')
            .then<Object>((s) => s, onError: (Object e) => e),
      ]);

      // Then.
      final balance = (await endpoints.product.getWallet(owner)).balance;
      expect(balance, greaterThanOrEqualTo(0));
      expect(
        outcomes.whereType<ProductException>().map((e) => e.code),
        contains('insufficientPoints'),
      );
      expect(await debits(), hasLength(1));
    });

    test('equip and unequip keep ownership', () async {
      // Given.
      await as('dachshund');
      await fund(vestOutfitPrice);
      await endpoints.product.purchaseOutfit(owner, vest, 'buy');

      // When.
      final worn = await endpoints.product.equipOutfit(owner, vest, 'equip');
      final bare = await endpoints.product.unequipOutfit(owner, 'unequip');

      // Then.
      expect(worn.equippedOutfit, vest);
      expect(bare.equippedOutfit, isNull);
      expect(bare.items.single.owned, isTrue);
      expect((await endpoints.product.listOutfits(owner)).equippedOutfit, null);
      expect(
        (await endpoints.product.unequipOutfit(owner, 'unequip')).toJson(),
        bare.toJson(),
      );
      expect(await ownerships(), 1);
    });

    test('incompatible breed may own but cannot equip the vest', () async {
      // Given: ownership seeded directly because purchase is blocked.
      await as('toy-poodle');
      await OutfitOwnership.db.insertRow(
        session,
        OutfitOwnership(owner: userId, outfitId: vest, purchasedAt: createdAt),
      );

      // When.
      await expectLater(
        endpoints.product.equipOutfit(owner, vest, 'equip'),
        productError('outfitIncompatible'),
      );

      // Then.
      final store = await endpoints.product.listOutfits(owner);
      expect(store.items.single.owned, isTrue);
      expect(store.equippedOutfit, isNull);
      expect(await ownerships(), 1);
    });

    test('incompatible breed purchase is rejected without writes', () async {
      // Given.
      await as('toy-poodle');
      await fund(vestOutfitPrice);

      // When.
      await expectLater(
        endpoints.product.purchaseOutfit(owner, vest, 'buy'),
        productError('outfitIncompatible'),
      );

      // Then.
      expect(
        (await endpoints.product.getWallet(owner)).balance,
        vestOutfitPrice,
      );
      expect(await debits(), isEmpty);
      expect(await ownerships(), 0);
      expect(
        (await endpoints.product.listOutfits(owner)).items.single.owned,
        isFalse,
      );
    });

    test('dog-less account purchase is rejected without writes', () async {
      // Given.
      owner = await user();
      session = owner.build();
      userId = session.authenticated!.userIdentifier;
      await fund(vestOutfitPrice);

      // When.
      await expectLater(
        endpoints.product.purchaseOutfit(owner, vest, 'buy'),
        productError('outfitIncompatible'),
      );

      // Then.
      expect(
        (await endpoints.product.getWallet(owner)).balance,
        vestOutfitPrice,
      );
      expect(await debits(), isEmpty);
      expect(await ownerships(), 0);
    });

    test('equip requires ownership', () async {
      // Given.
      await as('shih-tzu');

      // When / Then.
      await expectLater(
        endpoints.product.equipOutfit(owner, vest, 'equip'),
        productError('outfitNotOwned'),
      );
      expect((await endpoints.product.listOutfits(owner)).equippedOutfit, null);
    });

    for (final call in ['purchase', 'equip']) {
      test('unknown outfit is rejected on $call', () async {
        // Given.
        await as('shih-tzu');
        await fund(vestOutfitPrice);

        // When.
        final result = call == 'purchase'
            ? endpoints.product.purchaseOutfit(owner, 'cape', 'x')
            : endpoints.product.equipOutfit(owner, 'cape', 'x');

        // Then.
        await expectLater(result, productError('unknownOutfit'));
        expect(await debits(), isEmpty);
        expect(await ownerships(), 0);
      });
    }

    test('outfit purchase leaves theme state untouched', () async {
      // Given.
      await as('shih-tzu');
      await fund(vestOutfitPrice + 3);
      await endpoints.product.purchaseTheme(owner, 'cloudy', 'theme');
      await endpoints.product.equipTheme(owner, 'cloudy', 'equip-theme');

      // When.
      await endpoints.product.purchaseOutfit(owner, vest, 'vest');
      await endpoints.product.equipOutfit(owner, vest, 'equip-vest');

      // Then.
      final themes = await endpoints.product.listThemes(owner);
      expect(themes.items.map((t) => t.price), [0, 3, 3, 3]);
      expect(themes.equippedTheme, 'cloudy');
      expect(themes.balance, 0);
      expect(
        themes.items.where((t) => t.owned).map((t) => t.themeId),
        ['sunny', 'cloudy'],
      );
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
