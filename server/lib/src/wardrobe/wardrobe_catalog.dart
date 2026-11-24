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

/// Breeds with layered art (item layer + cut, combinable with other items):
/// all 30 breeds.
const layeredBreeds = [
  'alaskan-malamute',
  'beagle',
  'bichon-frise',
  'border-collie',
  'boston-terrier',
  'bulldog',
  'chihuahua',
  'cocker-spaniel',
  'dachshund',
  'dalmatian',
  'french-bulldog',
  'german-shepherd',
  'golden-retriever',
  'jindo',
  'labrador-retriever',
  'maltese',
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
  'sakura': WardrobeColour('벚꽃 분홍', 0xFFEE9AB5),
  'forsythia': WardrobeColour('개나리 노랑', 0xFFF2C340),
  'lilac': WardrobeColour('라일락', 0xFFB095E0),
  'mint': WardrobeColour('민트', 0xFF5CC4A8),
  'cherry': WardrobeColour('체리 빨강', 0xFFD9434F),
  'sky': WardrobeColour('하늘', 0xFF5FA3DB),
  'butter': WardrobeColour('버터 노랑', 0xFFEFC75A),
  'chick': WardrobeColour('병아리 노랑', 0xFFF2C93A),
  'pink': WardrobeColour('분홍', 0xFFE883AB),
  'frog': WardrobeColour('개구리 초록', 0xFF5DB548),
  'ocean': WardrobeColour('바다 파랑', 0xFF2E86C8),
  'watermelon': WardrobeColour('수박 빨강', 0xFFE2445A),
  'lemon': WardrobeColour('레몬', 0xFFF2D53A),
  'yellow-watermelon': WardrobeColour('노란 수박', 0xFFF2C94A),
  'peach': WardrobeColour('복숭아', 0xFFF59F7E),
  'melon': WardrobeColour('멜론 연두', 0xFF9CCB4A),
  'teal': WardrobeColour('청록', 0xFF2A9D8F),
  'jaju': WardrobeColour('자주', 0xFFA3357E),
  'ginkgo': WardrobeColour('은행 노랑', 0xFFEEC52E),
  'purple': WardrobeColour('보라', 0xFF7A45B0),
  'black': WardrobeColour('밤 검정', 0xFF40364C),
  'slime': WardrobeColour('슬라임 초록', 0xFF7CC22E),
  'burgundy': WardrobeColour('버건디', 0xFF9A2842),
  'maple': WardrobeColour('단풍 주황', 0xFFE0632A),
  'mustard': WardrobeColour('머스터드', 0xFFD9A92E),
  'wine': WardrobeColour('와인', 0xFF8E2A46),
  'olive': WardrobeColour('올리브', 0xFF828E2C),
  'cream': WardrobeColour('크림', 0xFFDCC5A0),
  'grey': WardrobeColour('회색', 0xFF80868F),
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
  for (final MapEntry(key: id, value: (slot, name, colours))
      in _monthlyGiftItems.entries)
    id: WardrobeItem(
      slot: slot,
      name: name,
      colours: colours,
      breeds: layeredBreeds,
      sellable: false,
    ),
  for (final MapEntry(key: id, value: (slot, name)) in _basicItems.entries)
    id: WardrobeItem(
      slot: slot,
      name: name,
      colours: _basicColours,
      breeds: layeredBreeds,
    ),
};

/// Gift-only items of the monthly sets: id -> (slot, name, colours).
const _monthlyGiftItems = {
  'knit': ('torso', '봄 니트', ['sakura', 'forsythia', 'lilac', 'mint']),
  'blossom': ('head', '벚꽃 머리핀', ['sakura', 'forsythia', 'lilac', 'mint']),
  'overall': ('torso', '체크 멜빵 조끼', ['cherry', 'sky', 'yeondu', 'butter']),
  'flower-crown': ('head', '꽃 화관', ['cherry', 'sky', 'yeondu', 'butter']),
  'smock': ('torso', '세일러 원복', ['chick', 'sky', 'pink', 'yeondu']),
  'kinder-hat': ('head', '유치원 모자', ['chick', 'sky', 'pink', 'yeondu']),
  'raincoat': ('torso', '우비', ['chick', 'sky', 'frog', 'tomato']),
  'rain-hat': ('head', '방수 모자', ['chick', 'sky', 'frog', 'tomato']),
  'rashguard': (
    'torso',
    '줄무늬 래시가드',
    ['ocean', 'watermelon', 'lemon', 'mint'],
  ),
  'straw-hat': ('head', '밀짚모자', ['ocean', 'watermelon', 'lemon', 'mint']),
  'melon-vest': (
    'torso',
    '수박 조끼',
    ['watermelon', 'yellow-watermelon', 'peach', 'melon'],
  ),
  'melon-clip': (
    'head',
    '수박 머리핀',
    ['watermelon', 'yellow-watermelon', 'peach', 'melon'],
  ),
  'baeja': ('torso', '배자', ['teal', 'jaju', 'ginkgo', 'jjok']),
  'rabbit-band': ('head', '달토끼 머리띠', ['teal', 'jaju', 'ginkgo', 'jjok']),
  'witch-cape': (
    'torso',
    '핼러윈 망토',
    ['purple', 'black', 'slime', 'burgundy'],
  ),
  'witch-hat': ('head', '마녀 모자', ['purple', 'black', 'slime', 'burgundy']),
  'muffler': ('torso', '단풍 머플러', ['maple', 'mustard', 'wine', 'olive']),
  'beret': ('head', '베레', ['maple', 'mustard', 'wine', 'olive']),
};

/// Always-on basics sold in [_basicColours]: id -> (slot, name).
const _basicItems = {
  'stripe-tee': ('torso', '줄무늬 티셔츠'),
  'hoodie': ('torso', '후드티'),
  'knit-vest': ('torso', '니트 조끼'),
  'puffer-vest': ('torso', '패딩 조끼'),
  'rib-beanie': ('head', '기본 비니'),
  'bandana': ('torso', '반다나'),
};
const _basicColours = ['cream', 'navy', 'grey', 'tomato'];

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
  'spring-blossom': WardrobeBackground('벚꽃 마당'),
  'picnic-meadow': WardrobeBackground('봄 소풍 잔디'),
  'kids-day-park': WardrobeBackground('어린이날 마당'),
  'monsoon-rain': WardrobeBackground('장마 마당'),
  'summer-beach': WardrobeBackground('한여름 물놀이'),
  'summer-night': WardrobeBackground('여름밤 마당'),
  'chuseok-moon': WardrobeBackground('보름달 밤'),
  'halloween-dusk': WardrobeBackground('핼러윈 저녁'),
  'autumn-maple': WardrobeBackground('단풍 마당'),
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
      'spring': WardrobeSet(
        name: '봄 벚꽃 세트',
        items: ['knit', 'blossom'],
        background: 'spring-blossom',
        colours: ['sakura', 'forsythia', 'lilac', 'mint'],
        effect: 'spring',
        sellable: false,
      ),
      'picnic': WardrobeSet(
        name: '봄 소풍 세트',
        items: ['overall', 'flower-crown'],
        background: 'picnic-meadow',
        colours: ['cherry', 'sky', 'yeondu', 'butter'],
        effect: 'picnic',
        sellable: false,
      ),
      'kids-day': WardrobeSet(
        name: '어린이날 세트',
        items: ['smock', 'kinder-hat'],
        background: 'kids-day-park',
        colours: ['chick', 'sky', 'pink', 'yeondu'],
        effect: 'kids-day',
        sellable: false,
      ),
      'monsoon': WardrobeSet(
        name: '장마 세트',
        items: ['raincoat', 'rain-hat'],
        background: 'monsoon-rain',
        colours: ['chick', 'sky', 'frog', 'tomato'],
        effect: 'monsoon',
        sellable: false,
      ),
      'sea': WardrobeSet(
        name: '여름 바다 세트',
        items: ['rashguard', 'straw-hat'],
        background: 'summer-beach',
        colours: ['ocean', 'watermelon', 'lemon', 'mint'],
        effect: 'summer',
        sellable: false,
      ),
      'watermelon': WardrobeSet(
        name: '수박 세트',
        items: ['melon-vest', 'melon-clip'],
        background: 'summer-night',
        colours: ['watermelon', 'yellow-watermelon', 'peach', 'melon'],
        effect: 'summer-night',
        sellable: false,
      ),
      'chuseok': WardrobeSet(
        name: '추석 세트',
        items: ['baeja', 'rabbit-band'],
        background: 'chuseok-moon',
        colours: ['teal', 'jaju', 'ginkgo', 'jjok'],
        effect: 'chuseok',
        sellable: false,
      ),
      'halloween': WardrobeSet(
        name: '핼러윈 세트',
        items: ['witch-cape', 'witch-hat'],
        background: 'halloween-dusk',
        colours: ['purple', 'black', 'slime', 'burgundy'],
        effect: 'halloween',
        sellable: false,
      ),
      'autumn': WardrobeSet(
        name: '단풍 세트',
        items: ['muffler', 'beret'],
        background: 'autumn-maple',
        colours: ['maple', 'mustard', 'wine', 'olive'],
        effect: 'autumn',
        sellable: false,
      ),
    },
    // Every gift opens on the 1st at 00:00 KST. November 2026 ships now
    // (owner, 2026-11-24); the rest stay closed until their month.
    gifts: {
      '2026-11': MonthlyGift.set('autumn'),
      '2026-12': MonthlyGift.set('holiday'),
      '2027-01': MonthlyGift.set('winter'),
      // Opens Feb 1 like every month. Seollal 2027 is Feb 7 (KASI 2027
      // 월력요항, korea.kr press release newsId=156768474).
      '2027-02': MonthlyGift.set('seollal'),
      '2027-03': MonthlyGift.set('spring'),
      '2027-04': MonthlyGift.set('picnic'),
      '2027-05': MonthlyGift.set('kids-day'),
      '2027-06': MonthlyGift.set('monsoon'),
      '2027-07': MonthlyGift.set('sea'),
      '2027-08': MonthlyGift.set('watermelon'),
      '2027-09': MonthlyGift.set('chuseok'),
      '2027-10': MonthlyGift.set('halloween'),
    },
  );

  /// Tests swap the catalog (for example to open a resale window).
  static WardrobeCatalog current = standard;
}
