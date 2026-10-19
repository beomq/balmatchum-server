import 'dart:convert';

/// Console metadata, not application point quantities.
class AdPlacement {
  const AdPlacement(this.unit, this.rewardItem, this.rewardAmount);
  final String unit;
  final String rewardItem;
  final String rewardAmount;
}

class AdConfig {
  AdConfig(this.placements, this.port);
  final Map<String, AdPlacement> placements;
  final int port;

  static AdConfig? fromPasswords(String? Function(String) password) {
    final json = password('admobPlacements');
    final port = password('admobSsvPort');
    if (json == null && port == null) return null;
    if (json == null || port == null) {
      throw StateError('AdMob requires admobPlacements and admobSsvPort');
    }
    final value = jsonDecode(json);
    final number = int.tryParse(port);
    if (value is! Map<String, dynamic> ||
        value.isEmpty ||
        number == null ||
        number < 0 ||
        number > 65535) {
      throw StateError('Invalid AdMob configuration');
    }
    final placements = <String, AdPlacement>{};
    for (final entry in value.entries) {
      final v = entry.value;
      if (!{'dailyReward', 'extraQuiz'}.contains(entry.key) ||
          v is! Map<String, dynamic> ||
          v['adUnit'] is! String ||
          (v['adUnit'] as String).isEmpty ||
          v['rewardItem'] is! String ||
          (v['rewardItem'] as String).isEmpty ||
          v['rewardAmount'] is! String ||
          !RegExp(r'^[0-9]+$').hasMatch(v['rewardAmount'] as String)) {
        throw StateError('Invalid AdMob placement');
      }
      placements[entry.key] = AdPlacement(
        v['adUnit'] as String,
        v['rewardItem'] as String,
        v['rewardAmount'] as String,
      );
    }
    return AdConfig(Map.unmodifiable(placements), number);
  }
}
