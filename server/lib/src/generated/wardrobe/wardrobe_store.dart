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
import 'package:balmatchum_server/src/generated/protocol.dart' as _iu3f2ih9;
import 'package:serverpod/serverpod.dart' as _is;
import '../wardrobe/wardrobe_background_view.dart' as _ik25z4ie;
import '../wardrobe/wardrobe_colour_view.dart' as _ikipyrsz;
import '../wardrobe/wardrobe_equip_view.dart' as _ivty70uq;
import '../wardrobe/wardrobe_item_view.dart' as _inhut6dh;
import '../wardrobe/wardrobe_set_view.dart' as _i7guy3zw;

/// Whole wardrobe state after every read or write. The server decides
/// prices, ownership, what may be worn, and whether a set is complete.
abstract class WardrobeStore
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WardrobeStore._({
    required this.colours,
    required this.items,
    required this.backgrounds,
    required this.sets,
    required this.equipped,
    required this.equippedBackground,
    this.completeSetId,
    this.completeColour,
    this.breedId,
    required this.balance,
    required this.subscriber,
    this.fixtureLabel,
  });

  factory WardrobeStore({
    required List<_ikipyrsz.WardrobeColourView> colours,
    required List<_inhut6dh.WardrobeItemView> items,
    required List<_ik25z4ie.WardrobeBackgroundView> backgrounds,
    required List<_i7guy3zw.WardrobeSetView> sets,
    required List<_ivty70uq.WardrobeEquipView> equipped,
    required String equippedBackground,
    String? completeSetId,
    String? completeColour,
    String? breedId,
    required int balance,
    required bool subscriber,
    String? fixtureLabel,
  }) = _WardrobeStoreImpl;

  factory WardrobeStore.fromJson(Map<String, dynamic> jsonSerialization) {
    return WardrobeStore(
      colours: _iu3f2ih9.Protocol()
          .deserialize<List<_ikipyrsz.WardrobeColourView>>(
            jsonSerialization['colours'],
          ),
      items: _iu3f2ih9.Protocol().deserialize<List<_inhut6dh.WardrobeItemView>>(
        jsonSerialization['items'],
      ),
      backgrounds: _iu3f2ih9.Protocol()
          .deserialize<List<_ik25z4ie.WardrobeBackgroundView>>(
            jsonSerialization['backgrounds'],
          ),
      sets: _iu3f2ih9.Protocol().deserialize<List<_i7guy3zw.WardrobeSetView>>(
        jsonSerialization['sets'],
      ),
      equipped: _iu3f2ih9.Protocol()
          .deserialize<List<_ivty70uq.WardrobeEquipView>>(
            jsonSerialization['equipped'],
          ),
      equippedBackground: jsonSerialization['equippedBackground'] as String,
      completeSetId: jsonSerialization['completeSetId'] as String?,
      completeColour: jsonSerialization['completeColour'] as String?,
      breedId: jsonSerialization['breedId'] as String?,
      balance: jsonSerialization['balance'] as int,
      subscriber: _is.BoolJsonExtension.fromJson(
        jsonSerialization['subscriber'],
      ),
      fixtureLabel: jsonSerialization['fixtureLabel'] as String?,
    );
  }

  List<_ikipyrsz.WardrobeColourView> colours;

  List<_inhut6dh.WardrobeItemView> items;

  List<_ik25z4ie.WardrobeBackgroundView> backgrounds;

  List<_i7guy3zw.WardrobeSetView> sets;

  List<_ivty70uq.WardrobeEquipView> equipped;

  String equippedBackground;

  /// Set whose items are all worn in one colour over its own background.
  String? completeSetId;

  String? completeColour;

  String? breedId;

  int balance;

  /// A subscription or lifetime purchase is active by the server's stored
  /// observation: this user receives the monthly gifts.
  bool subscriber;

  String? fixtureLabel;

  /// Returns a shallow copy of this [WardrobeStore]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WardrobeStore copyWith({
    List<_ikipyrsz.WardrobeColourView>? colours,
    List<_inhut6dh.WardrobeItemView>? items,
    List<_ik25z4ie.WardrobeBackgroundView>? backgrounds,
    List<_i7guy3zw.WardrobeSetView>? sets,
    List<_ivty70uq.WardrobeEquipView>? equipped,
    String? equippedBackground,
    String? completeSetId,
    String? completeColour,
    String? breedId,
    int? balance,
    bool? subscriber,
    String? fixtureLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeStore',
      'colours': colours.toJson(valueToJson: (v) => v.toJson()),
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      'backgrounds': backgrounds.toJson(valueToJson: (v) => v.toJson()),
      'sets': sets.toJson(valueToJson: (v) => v.toJson()),
      'equipped': equipped.toJson(valueToJson: (v) => v.toJson()),
      'equippedBackground': equippedBackground,
      if (completeSetId != null) 'completeSetId': completeSetId,
      if (completeColour != null) 'completeColour': completeColour,
      if (breedId != null) 'breedId': breedId,
      'balance': balance,
      'subscriber': subscriber,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeStore',
      'colours': colours.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'backgrounds': backgrounds.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'sets': sets.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'equipped': equipped.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'equippedBackground': equippedBackground,
      if (completeSetId != null) 'completeSetId': completeSetId,
      if (completeColour != null) 'completeColour': completeColour,
      if (breedId != null) 'breedId': breedId,
      'balance': balance,
      'subscriber': subscriber,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WardrobeStoreImpl extends WardrobeStore {
  _WardrobeStoreImpl({
    required List<_ikipyrsz.WardrobeColourView> colours,
    required List<_inhut6dh.WardrobeItemView> items,
    required List<_ik25z4ie.WardrobeBackgroundView> backgrounds,
    required List<_i7guy3zw.WardrobeSetView> sets,
    required List<_ivty70uq.WardrobeEquipView> equipped,
    required String equippedBackground,
    String? completeSetId,
    String? completeColour,
    String? breedId,
    required int balance,
    required bool subscriber,
    String? fixtureLabel,
  }) : super._(
         colours: colours,
         items: items,
         backgrounds: backgrounds,
         sets: sets,
         equipped: equipped,
         equippedBackground: equippedBackground,
         completeSetId: completeSetId,
         completeColour: completeColour,
         breedId: breedId,
         balance: balance,
         subscriber: subscriber,
         fixtureLabel: fixtureLabel,
       );

  /// Returns a shallow copy of this [WardrobeStore]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WardrobeStore copyWith({
    List<_ikipyrsz.WardrobeColourView>? colours,
    List<_inhut6dh.WardrobeItemView>? items,
    List<_ik25z4ie.WardrobeBackgroundView>? backgrounds,
    List<_i7guy3zw.WardrobeSetView>? sets,
    List<_ivty70uq.WardrobeEquipView>? equipped,
    String? equippedBackground,
    Object? completeSetId = _Undefined,
    Object? completeColour = _Undefined,
    Object? breedId = _Undefined,
    int? balance,
    bool? subscriber,
    Object? fixtureLabel = _Undefined,
  }) {
    return WardrobeStore(
      colours: colours ?? this.colours.map((e0) => e0.copyWith()).toList(),
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      backgrounds:
          backgrounds ?? this.backgrounds.map((e0) => e0.copyWith()).toList(),
      sets: sets ?? this.sets.map((e0) => e0.copyWith()).toList(),
      equipped: equipped ?? this.equipped.map((e0) => e0.copyWith()).toList(),
      equippedBackground: equippedBackground ?? this.equippedBackground,
      completeSetId: completeSetId is String?
          ? completeSetId
          : this.completeSetId,
      completeColour: completeColour is String?
          ? completeColour
          : this.completeColour,
      breedId: breedId is String? ? breedId : this.breedId,
      balance: balance ?? this.balance,
      subscriber: subscriber ?? this.subscriber,
      fixtureLabel: fixtureLabel is String? ? fixtureLabel : this.fixtureLabel,
    );
  }
}
