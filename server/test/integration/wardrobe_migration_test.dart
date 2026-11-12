@Timeout(Duration(minutes: 3))
library;

import 'dart:io';

import 'package:test/test.dart';

import 'support/scratch_database.dart';

// Fresh test databases start from the latest definition.sql, so the vest data
// migration only runs here: previous schema + legacy rows -> wardrobe-sets.
const _scratch = 'balmatchum_wardrobe_migration';
const _previous = 'migrations/20261112092351704-photo-composite/definition.sql';
const _wearer = '0190b000-0000-7000-8000-00000000000a';
const _owner = '0190b000-0000-7000-8000-00000000000b';
const _both = '0190b000-0000-7000-8000-00000000000c';

String _wardrobeMigration() => Directory('migrations')
    .listSync()
    .whereType<Directory>()
    .singleWhere((d) => d.path.endsWith('-wardrobe-sets'))
    .path;

void main() {
  late ScratchDatabase scratch;

  setUpAll(() async {
    scratch = await ScratchDatabase.create(_scratch, 'wardrobe-migration');
    await scratch.runFile(_previous);
    await scratch.runSql('''
INSERT INTO "serverpod_auth_core_user" ("id", "createdAt", "scopeNames", "blocked")
  VALUES ('$_wearer', now(), '[]', false), ('$_owner', now(), '[]', false),
  ('$_both', now(), '[]', false);
INSERT INTO "product_account" ("authUserId", "equippedOutfit")
  VALUES ('$_wearer', 'vest-low-v'), ('$_owner', NULL);
INSERT INTO "outfit_ownership" ("authUserId", "outfitId", "purchasedAt")
  VALUES ('$_wearer', 'vest-low-v', now()), ('$_owner', 'vest-low-v', now()),
  ('$_both', 'vest-low-v', now()), ('$_both', 'vest', now());
INSERT INTO "theme_ownership" ("authUserId", "themeId", "purchasedAt")
  VALUES ('$_owner', 'cloudy', now());
''');
    await scratch.runFile('${_wardrobeMigration()}/migration.sql');
  });

  tearDownAll(() => scratch.dispose('wardrobe-migration'));

  test('legacy vest owners own vest/classic from migration', () async {
    expect(
      await scratch.count(
        "SELECT count(*)::int FROM outfit_ownership WHERE \"outfitId\" = 'vest' "
        "AND \"colourId\" = 'classic' AND source = 'migration'",
      ),
      2,
    );
    expect(
      await scratch.count(
        "SELECT count(*)::int FROM outfit_ownership "
        "WHERE \"outfitId\" = 'vest-low-v'",
      ),
      0,
    );
  });

  test('a user holding both vest ids keeps exactly one vest/classic', () async {
    expect(
      await scratch.count(
        "SELECT count(*)::int FROM outfit_ownership WHERE \"authUserId\" = "
        "'$_both' AND \"outfitId\" = 'vest' AND \"colourId\" = 'classic'",
      ),
      1,
    );
  });

  test(
    'the worn vest moves to the torso slot and the old column empties',
    () async {
      expect(
        await scratch.count(
          "SELECT count(*)::int FROM outfit_equip WHERE \"authUserId\" = "
          "'$_wearer' AND slot = 'torso' AND \"outfitId\" = 'vest' "
          "AND \"colourId\" = 'classic'",
        ),
        1,
      );
      expect(await scratch.count('SELECT count(*)::int FROM outfit_equip'), 1);
      expect(
        await scratch.count(
          'SELECT count(*)::int FROM product_account '
          'WHERE "equippedOutfit" IS NOT NULL',
        ),
        0,
      );
    },
  );

  test('existing background purchases default to source purchase', () async {
    expect(
      await scratch.count(
        "SELECT count(*)::int FROM theme_ownership WHERE source = 'purchase'",
      ),
      1,
    );
  });
}
