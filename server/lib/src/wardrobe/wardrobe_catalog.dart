/// Wardrobe catalog: colour SKUs, items, backgrounds and sets.
///
/// Prices follow the owner's decision of 2026-11-12: every item colour 150P,
/// a background 100P, a set 20% off the parts the user does not own yet,
/// walk points only. The app bundles the art ahead of time and draws only
/// what the server returns, so a season set stays hidden until [Season.releaseAt].
library;

const itemPrice = 150;
const backgroundPrice = 100;
const setDiscountPct = 20;

/// Breeds with layered art (item layer + cut, combinable with other items).
const layeredBreeds = ['maltese', 'dachshund', 'golden-retriever'];

/// Breeds whose only art is the tomato padding baked onto the whole dog. It
/// replaces the sprite, so it is worn alone. Every other item shows
/// "곧 입을 수 있어요" for them.
const bakedPaddingBreeds = [
  'alaskan-malamute',
  'beagle',
  'bichon-frise',
  'border-collie',
  'boston-terrier',
  'bulldog',
  'chihuahua',
  'cocker-spaniel',
  'dalmatian',
  'french-bulldog',
  'german-shepherd',
  'jindo',
  'labrador-retriever',
  'miniature-pinscher',
  'miniature-schnauzer',
  'norwich-terrier',
  'pekingese',
  'pembroke-welsh-corgi',
  'pomeranian',
  'pug',
  'samoyed',
  'shiba-inu',
  'shih-tzu',
  'siberian-husky',
  'toy-poodle',
  'west-highland-white-terrier',
  'yorkshire-terrier',
];

class WardrobeColour {
  const WardrobeColour(this.name, this.swatch);
  final String name;
  final int swatch;
}

const wardrobeColours = {
  'tomato': WardrobeColour('토마토 레드', 0xFFE0453A),
  'pine': WardrobeColour('소나무 초록', 0xFF2E9A5E),
  'plum': WardrobeColour('자두 보라', 0xFF8A4FC8),
  'navy': WardrobeColour('밤하늘 남색', 0xFF2B4C9B),
  'dahong': WardrobeColour('다홍', 0xFFE05436),
  'jjok': WardrobeColour('쪽빛', 0xFF3558B0),
  'yeondu': WardrobeColour('연두', 0xFF8CC23A),
  'bunhong': WardrobeColour('분홍', 0xFFE0669A),
  'classic': WardrobeColour('기본', 0xFF6B7F5A),
};

class WardrobeItem {
  const WardrobeItem({
    required this.slot,
    required this.name,
    required this.colours,
    required this.breeds,
    this.extraBreeds = const {},
    this.sellable = true,
  });

  final String slot;
  final String name;
  final List<String> colours;

  /// Breeds that can wear every colour.
  final List<String> breeds;

  /// More breeds, each limited to the listed colours.
  final Map<String, List<String>> extraBreeds;

  /// False for season items: they come only with their set.
  final bool sellable;

  List<String> wearableColours(String? breed) {
    if (breed == null) return const [];
    if (breeds.contains(breed)) return colours;
    return extraBreeds[breed] ?? const [];
  }
}

const vestItemId = 'vest';
const vestColourId = 'classic';

/// The pre-wardrobe vest id still used by the legacy outfit endpoints and by
/// the old ledger key `outfit:vest-low-v`.
const legacyVestOutfitId = 'vest-low-v';

final wardrobeItems = {
  'padding': WardrobeItem(
    slot: 'torso',
    name: '패딩',
    colours: ['tomato', 'pine', 'plum', 'navy'],
    breeds: layeredBreeds,
    extraBreeds: {
      for (final breed in bakedPaddingBreeds) breed: ['tomato'],
    },
  ),
  'beanie': WardrobeItem(
    slot: 'head',
    name: '방울 비니',
    colours: ['tomato', 'pine', 'plum', 'navy'],
    breeds: layeredBreeds,
  ),
  'booties': WardrobeItem(
    slot: 'feet',
    name: '부티',
    colours: ['tomato', 'pine', 'plum', 'navy'],
    breeds: layeredBreeds,
  ),
  'rudolph-band': WardrobeItem(
    slot: 'head',
    name: '루돌프 머리띠',
    colours: ['tomato', 'pine', 'navy'],
    breeds: layeredBreeds,
    sellable: false,
  ),
  'santa-cape': WardrobeItem(
    slot: 'torso',
    name: '산타 망토',
    colours: ['tomato', 'pine', 'navy'],
    breeds: layeredBreeds,
    sellable: false,
  ),
  'saekdong-jeogori': WardrobeItem(
    slot: 'torso',
    name: '색동저고리',
    colours: ['dahong', 'jjok', 'yeondu', 'bunhong'],
    breeds: layeredBreeds,
    sellable: false,
  ),
  'gulle': WardrobeItem(
    slot: 'head',
    name: '굴레',
    colours: ['dahong', 'jjok', 'yeondu', 'bunhong'],
    breeds: layeredBreeds,
    sellable: false,
  ),
  vestItemId: WardrobeItem(
    slot: 'torso',
    name: '조끼',
    colours: [vestColourId],
    breeds: ['shih-tzu', 'dachshund'],
  ),
};

class WardrobeBackground {
  const WardrobeBackground(this.name, {this.price = backgroundPrice});
  final String name;
  final int price;
}

/// Backgrounds share theme_ownership and product_account.equippedTheme with
/// the legacy theme store. 'sunny' is free and always owned.
const defaultBackgroundId = 'sunny';
const wardrobeBackgrounds = {
  'sunny': WardrobeBackground('맑음', price: 0),
  'cloudy': WardrobeBackground('흐림'),
  'rainy': WardrobeBackground('비'),
  'snowy': WardrobeBackground('눈'),
  'winter-dusk': WardrobeBackground('겨울 저녁'),
  'holiday-night': WardrobeBackground('크리스마스 밤'),
  'seollal-morning': WardrobeBackground('설날 아침'),
};

/// A window as KST wall-clock instants, stored in UTC.
class Window {
  const Window(this.opensAt, this.endsAt);
  final DateTime opensAt;
  final DateTime endsAt;
  bool contains(DateTime now) => !now.isBefore(opensAt) && !now.isAfter(endsAt);
}

/// One month's gift for paying members (owner decision 2026-11-12: monthly,
/// because the subscription is monthly): a whole set or a single item. The
/// art ships in the app ahead of time; the server opens it on the 1st (KST).
class MonthlyGift {
  const MonthlyGift.set(String this.setId, {this.resale}) : itemId = null;
  const MonthlyGift.item(String this.itemId, {this.resale}) : setId = null;

  final String? setId;
  final String? itemId;

  /// A later limited-time point sale of this past gift; null while closed.
  /// Fill it here and deploy the server; the app needs no release.
  final Window? resale;
}

class WardrobeSet {
  const WardrobeSet({
    required this.name,
    required this.items,
    required this.background,
    required this.colours,
    required this.effect,
    this.sellable = true,
  });

  final String name;
  final List<String> items;
  final String background;
  final List<String> colours;
  final String effect;

  /// False for a gift-only set: its items and background come with the
  /// monthly gift (or a later resale), never from the regular shop.
  final bool sellable;
}

DateTime kst(int y, int m, int d, [int h = 0, int min = 0, int s = 0]) =>
    DateTime.utc(y, m, d, h, min, s).subtract(const Duration(hours: 9));

/// The KST calendar month of [instant] as `yyyy-MM`.
String kstMonth(DateTime instant) {
  final local = instant.toUtc().add(const Duration(hours: 9));
  return '${local.year}-${local.month.toString().padLeft(2, '0')}';
}

/// From the 1st 00:00 KST to the last second of that month.
Window monthWindow(String month) {
  final [y, m] = [for (final part in month.split('-')) int.parse(part)];
  return Window(
    kst(y, m, 1),
    kst(y, m + 1, 1).subtract(const Duration(seconds: 1)),
  );
}

class WardrobeCatalog {
  const WardrobeCatalog({required this.sets, required this.gifts});
  final Map<String, WardrobeSet> sets;

  /// `yyyy-MM` (KST) -> that month's gift. A month without one gives nothing.
  final Map<String, MonthlyGift> gifts;

  Map<String, WardrobeItem> get items => wardrobeItems;
  Map<String, WardrobeBackground> get backgrounds => wardrobeBackgrounds;

  /// The set whose background this is, if any.
  String? setOfBackground(String backgroundId) {
    for (final MapEntry(:key, :value) in sets.entries) {
      if (value.background == backgroundId) return key;
    }
    return null;
  }

  /// A gift-only set's background is not sold singly.
  bool giftOnlyBackground(String backgroundId) {
    final setId = setOfBackground(backgroundId);
    return setId != null && !sets[setId]!.sellable;
  }

  /// The month whose gift [match]es: open now, else the latest past one,
  /// else the next one. Null when it is never a gift.
  String? giftMonth(bool Function(MonthlyGift) match, DateTime now) {
    final months = [
      for (final MapEntry(:key, :value) in gifts.entries)
        if (match(value)) key,
    ]..sort();
    if (months.isEmpty) return null;
    final current = kstMonth(now);
    if (months.contains(current)) return current;
    final past = months.where((m) => m.compareTo(current) < 0);
    return past.isNotEmpty ? past.last : months.first;
  }

  String? giftMonthOfSet(String setId, DateTime now) =>
      giftMonth((g) => g.setId == setId, now);

  String? giftMonthOfItem(String itemId, DateTime now) =>
      giftMonth((g) => g.itemId == itemId, now);

  static final standard = WardrobeCatalog(
    sets: {
      'winter': WardrobeSet(
        name: '겨울 세트',
        items: ['padding', 'beanie', 'booties'],
        background: 'winter-dusk',
        colours: ['tomato', 'pine', 'plum', 'navy'],
        effect: 'snow',
      ),
      'holiday': WardrobeSet(
        name: '크리스마스 세트',
        items: ['rudolph-band', 'santa-cape'],
        background: 'holiday-night',
        colours: ['tomato', 'pine', 'navy'],
        effect: 'holiday',
        sellable: false,
      ),
      'seollal': WardrobeSet(
        name: '설날 세트',
        items: ['saekdong-jeogori', 'gulle'],
        background: 'seollal-morning',
        colours: ['dahong', 'jjok', 'yeondu', 'bunhong'],
        effect: 'seollal',
        sellable: false,
      ),
    },
    // Months with art so far; an art lane fills the rest.
    gifts: {
      '2026-12': MonthlyGift.set('holiday'),
      '2027-01': MonthlyGift.set('winter'),
      // Opens Feb 1 like every month. Seollal 2027 is Feb 7 (KASI 2027
      // 월력요항, korea.kr press release newsId=156768474).
      '2027-02': MonthlyGift.set('seollal'),
    },
  );

  /// Tests swap the catalog (for example to open a resale window).
  static WardrobeCatalog current = standard;
}
