import 'dart:convert';

import '../generated/protocol.dart';

/// Console metadata, not application point quantities. Both platforms' units
/// of one purpose must carry the same console reward item and amount.
class AdPlacement {
  const AdPlacement(this.units, this.rewardItem, this.rewardAmount);

  /// Full AdMob ad unit IDs (`ca-app-pub-<publisher>/<unit>`) the app loads.
  final ({String ios, String android}) units;
  final String rewardItem;
  final String rewardAmount;

  String unit(AdPlatform platform) => switch (platform) {
    AdPlatform.ios => units.ios,
    AdPlatform.android => units.android,
  };
}

class AdConfig {
  AdConfig(this.placements);
  final Map<String, AdPlacement> placements;

  static final _unitId = RegExp(r'^ca-app-pub-[0-9]{16}/[0-9]{10}$');
  static const _shape =
      'expected {"adUnits": {"ios": "ca-app-pub-<16 digits>/<10 digits>", '
      '"android": "ca-app-pub-<16 digits>/<10 digits>"}, '
      '"rewardItem": "<non-empty>", "rewardAmount": "<digits>"}';

  static AdConfig? fromPasswords(String? Function(String) password) {
    final json = password('admobPlacements');
    if (json == null) return null;
    final Object? value;
    try {
      value = jsonDecode(json);
    } on FormatException {
      throw StateError(
        'Invalid AdMob configuration: admobPlacements is not JSON',
      );
    }
    if (value is! Map<String, dynamic> || value.isEmpty) {
      throw StateError(
        'Invalid AdMob configuration: admobPlacements must be a non-empty '
        'object keyed by dailyReward/extraQuiz',
      );
    }
    final placements = <String, AdPlacement>{};
    // Google's SSV ad_unit is the numeric unit ID, so it must be unique across
    // every purpose and platform for the callback to identify one binding.
    final unitNumbers = <String>{};
    for (final MapEntry(:key, value: raw) in value.entries) {
      Never invalid(String reason) =>
          throw StateError('Invalid AdMob placement "$key": $reason');
      if (!{'dailyReward', 'extraQuiz'}.contains(key)) {
        invalid('unknown purpose, expected dailyReward or extraQuiz');
      }
      final placement = switch (raw) {
        {
                  'adUnits':
                      {
                        'ios': final String ios,
                        'android': final String android,
                      } &&
                      final Map<String, dynamic> units,
                  'rewardItem': final String item,
                  'rewardAmount': final String amount,
                } &&
                final Map<String, dynamic> fields
            when fields.length == 3 && units.length == 2 =>
          AdPlacement((ios: ios, android: android), item, amount),
        _ => invalid(_shape),
      };
      if (placement.rewardItem.isEmpty ||
          !RegExp(r'^[0-9]+$').hasMatch(placement.rewardAmount)) {
        invalid(_shape);
      }
      for (final platform in AdPlatform.values) {
        final unit = placement.unit(platform);
        if (!_unitId.hasMatch(unit)) {
          invalid('adUnits.${platform.name} $_shape');
        }
        if (!unitNumbers.add(unit.split('/').last)) {
          invalid('adUnits.${platform.name} reuses another placement unit');
        }
      }
      placements[key] = placement;
    }
    return AdConfig(Map.unmodifiable(placements));
  }
}
