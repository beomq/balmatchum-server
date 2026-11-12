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

abstract class WardrobeItemView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WardrobeItemView._({
    required this.itemId,
    required this.slot,
    required this.name,
    required this.price,
    required this.colours,
    required this.ownedColours,
    required this.wearableColours,
    required this.sellable,
    required this.setIds,
  });

  factory WardrobeItemView({
    required String itemId,
    required String slot,
    required String name,
    required int price,
    required List<String> colours,
    required List<String> ownedColours,
    required List<String> wearableColours,
    required bool sellable,
    required List<String> setIds,
  }) = _WardrobeItemViewImpl;

  factory WardrobeItemView.fromJson(Map<String, dynamic> jsonSerialization) {
    return WardrobeItemView(
      itemId: jsonSerialization['itemId'] as String,
      slot: jsonSerialization['slot'] as String,
      name: jsonSerialization['name'] as String,
      price: jsonSerialization['price'] as int,
      colours: _i5u3fx7i.Protocol().deserialize<List<String>>(
        jsonSerialization['colours'],
      ),
      ownedColours: _i5u3fx7i.Protocol().deserialize<List<String>>(
        jsonSerialization['ownedColours'],
      ),
      wearableColours: _i5u3fx7i.Protocol().deserialize<List<String>>(
        jsonSerialization['wearableColours'],
      ),
      sellable: _isc.BoolJsonExtension.fromJson(jsonSerialization['sellable']),
      setIds: _i5u3fx7i.Protocol().deserialize<List<String>>(
        jsonSerialization['setIds'],
      ),
    );
  }

  String itemId;

  /// feet, torso, head (draw order is the app catalog's).
  String slot;

  String name;

  int price;

  /// Every colour the item comes in.
  List<String> colours;

  List<String> ownedColours;

  /// Colours the profile's breed can wear; empty means "곧 입을 수 있어요".
  List<String> wearableColours;

  /// False for season items, which come only with their set.
  bool sellable;

  List<String> setIds;

  /// Returns a shallow copy of this [WardrobeItemView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WardrobeItemView copyWith({
    String? itemId,
    String? slot,
    String? name,
    int? price,
    List<String>? colours,
    List<String>? ownedColours,
    List<String>? wearableColours,
    bool? sellable,
    List<String>? setIds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeItemView',
      'itemId': itemId,
      'slot': slot,
      'name': name,
      'price': price,
      'colours': colours.toJson(),
      'ownedColours': ownedColours.toJson(),
      'wearableColours': wearableColours.toJson(),
      'sellable': sellable,
      'setIds': setIds.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeItemView',
      'itemId': itemId,
      'slot': slot,
      'name': name,
      'price': price,
      'colours': colours.toJson(),
      'ownedColours': ownedColours.toJson(),
      'wearableColours': wearableColours.toJson(),
      'sellable': sellable,
      'setIds': setIds.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WardrobeItemViewImpl extends WardrobeItemView {
  _WardrobeItemViewImpl({
    required String itemId,
    required String slot,
    required String name,
    required int price,
    required List<String> colours,
    required List<String> ownedColours,
    required List<String> wearableColours,
    required bool sellable,
    required List<String> setIds,
  }) : super._(
         itemId: itemId,
         slot: slot,
         name: name,
         price: price,
         colours: colours,
         ownedColours: ownedColours,
         wearableColours: wearableColours,
         sellable: sellable,
         setIds: setIds,
       );

  /// Returns a shallow copy of this [WardrobeItemView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WardrobeItemView copyWith({
    String? itemId,
    String? slot,
    String? name,
    int? price,
    List<String>? colours,
    List<String>? ownedColours,
    List<String>? wearableColours,
    bool? sellable,
    List<String>? setIds,
  }) {
    return WardrobeItemView(
      itemId: itemId ?? this.itemId,
      slot: slot ?? this.slot,
      name: name ?? this.name,
      price: price ?? this.price,
      colours: colours ?? this.colours.map((e0) => e0).toList(),
      ownedColours: ownedColours ?? this.ownedColours.map((e0) => e0).toList(),
      wearableColours:
          wearableColours ?? this.wearableColours.map((e0) => e0).toList(),
      sellable: sellable ?? this.sellable,
      setIds: setIds ?? this.setIds.map((e0) => e0).toList(),
    );
  }
}
