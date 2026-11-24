/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:balmatchum_client/src/protocol/protocol.dart' as _i5u3fx7i;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../wardrobe/wardrobe_season_view.dart' as _iind78px;
import '../wardrobe/wardrobe_set_colour_view.dart' as _iayw7x7n;

abstract class WardrobeSetView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WardrobeSetView._({
    required this.setId,
    required this.name,
    required this.itemIds,
    required this.backgroundId,
    required this.colours,
    required this.effect,
    required this.fullPrice,
    required this.discountPct,
    required this.sellable,
    this.season,
  });

  factory WardrobeSetView({
    required String setId,
    required String name,
    required List<String> itemIds,
    required String backgroundId,
    required List<_iayw7x7n.WardrobeSetColourView> colours,
    required String effect,
    required int fullPrice,
    required int discountPct,
    required bool sellable,
    _iind78px.WardrobeSeasonView? season,
  }) = _WardrobeSetViewImpl;

  factory WardrobeSetView.fromJson(Map<String, dynamic> jsonSerialization) {
    return WardrobeSetView(
      setId: jsonSerialization['setId'] as String,
      name: jsonSerialization['name'] as String,
      itemIds: _i5u3fx7i.Protocol().deserialize<List<String>>(
        jsonSerialization['itemIds'],
      ),
      backgroundId: jsonSerialization['backgroundId'] as String,
      colours: _i5u3fx7i.Protocol()
          .deserialize<List<_iayw7x7n.WardrobeSetColourView>>(
            jsonSerialization['colours'],
          ),
      effect: jsonSerialization['effect'] as String,
      fullPrice: jsonSerialization['fullPrice'] as int,
      discountPct: jsonSerialization['discountPct'] as int,
      sellable: _isc.BoolJsonExtension.fromJson(jsonSerialization['sellable']),
      season: jsonSerialization['season'] == null
          ? null
          : _i5u3fx7i.Protocol().deserialize<_iind78px.WardrobeSeasonView>(
              jsonSerialization['season'],
            ),
    );
  }

  String setId;

  String name;

  List<String> itemIds;

  String backgroundId;

  List<_iayw7x7n.WardrobeSetColourView> colours;

  /// Effect preset name in the app's effects/presets.json.
  String effect;

  /// Undiscounted sum of every part.
  int fullPrice;

  int discountPct;

  /// False for a gift-only set (never in the regular shop).
  bool sellable;

  /// The set's monthly gift window, if it is ever a gift.
  _iind78px.WardrobeSeasonView? season;

  /// Returns a shallow copy of this [WardrobeSetView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WardrobeSetView copyWith({
    String? setId,
    String? name,
    List<String>? itemIds,
    String? backgroundId,
    List<_iayw7x7n.WardrobeSetColourView>? colours,
    String? effect,
    int? fullPrice,
    int? discountPct,
    bool? sellable,
    _iind78px.WardrobeSeasonView? season,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeSetView',
      'setId': setId,
      'name': name,
      'itemIds': itemIds.toJson(),
      'backgroundId': backgroundId,
      'colours': colours.toJson(valueToJson: (v) => v.toJson()),
      'effect': effect,
      'fullPrice': fullPrice,
      'discountPct': discountPct,
      'sellable': sellable,
      if (season != null) 'season': season?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeSetView',
      'setId': setId,
      'name': name,
      'itemIds': itemIds.toJson(),
      'backgroundId': backgroundId,
      'colours': colours.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'effect': effect,
      'fullPrice': fullPrice,
      'discountPct': discountPct,
      'sellable': sellable,
      if (season != null) 'season': season?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WardrobeSetViewImpl extends WardrobeSetView {
  _WardrobeSetViewImpl({
    required String setId,
    required String name,
    required List<String> itemIds,
    required String backgroundId,
    required List<_iayw7x7n.WardrobeSetColourView> colours,
    required String effect,
    required int fullPrice,
    required int discountPct,
    required bool sellable,
    _iind78px.WardrobeSeasonView? season,
  }) : super._(
         setId: setId,
         name: name,
         itemIds: itemIds,
         backgroundId: backgroundId,
         colours: colours,
         effect: effect,
         fullPrice: fullPrice,
         discountPct: discountPct,
         sellable: sellable,
         season: season,
       );

  /// Returns a shallow copy of this [WardrobeSetView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WardrobeSetView copyWith({
    String? setId,
    String? name,
    List<String>? itemIds,
    String? backgroundId,
    List<_iayw7x7n.WardrobeSetColourView>? colours,
    String? effect,
    int? fullPrice,
    int? discountPct,
    bool? sellable,
    Object? season = _Undefined,
  }) {
    return WardrobeSetView(
      setId: setId ?? this.setId,
      name: name ?? this.name,
      itemIds: itemIds ?? this.itemIds.map((e0) => e0).toList(),
      backgroundId: backgroundId ?? this.backgroundId,
      colours: colours ?? this.colours.map((e0) => e0.copyWith()).toList(),
      effect: effect ?? this.effect,
      fullPrice: fullPrice ?? this.fullPrice,
      discountPct: discountPct ?? this.discountPct,
      sellable: sellable ?? this.sellable,
      season: season is _iind78px.WardrobeSeasonView?
          ? season
          : this.season?.copyWith(),
    );
  }
}
