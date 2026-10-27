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
import '../product/outfit_item.dart' as _if659p5a;

abstract class OutfitStore
    implements _is.SerializableModel, _is.ProtocolSerialization {
  OutfitStore._({
    required this.items,
    this.equippedOutfit,
    this.breedId,
    required this.balance,
    this.fixtureLabel,
  });

  factory OutfitStore({
    required List<_if659p5a.OutfitItem> items,
    String? equippedOutfit,
    String? breedId,
    required int balance,
    String? fixtureLabel,
  }) = _OutfitStoreImpl;

  factory OutfitStore.fromJson(Map<String, dynamic> jsonSerialization) {
    return OutfitStore(
      items: _iu3f2ih9.Protocol().deserialize<List<_if659p5a.OutfitItem>>(
        jsonSerialization['items'],
      ),
      equippedOutfit: jsonSerialization['equippedOutfit'] as String?,
      breedId: jsonSerialization['breedId'] as String?,
      balance: jsonSerialization['balance'] as int,
      fixtureLabel: jsonSerialization['fixtureLabel'] as String?,
    );
  }

  List<_if659p5a.OutfitItem> items;

  String? equippedOutfit;

  String? breedId;

  int balance;

  String? fixtureLabel;

  /// Returns a shallow copy of this [OutfitStore]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OutfitStore copyWith({
    List<_if659p5a.OutfitItem>? items,
    String? equippedOutfit,
    String? breedId,
    int? balance,
    String? fixtureLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OutfitStore',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      if (equippedOutfit != null) 'equippedOutfit': equippedOutfit,
      if (breedId != null) 'breedId': breedId,
      'balance': balance,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OutfitStore',
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (equippedOutfit != null) 'equippedOutfit': equippedOutfit,
      if (breedId != null) 'breedId': breedId,
      'balance': balance,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OutfitStoreImpl extends OutfitStore {
  _OutfitStoreImpl({
    required List<_if659p5a.OutfitItem> items,
    String? equippedOutfit,
    String? breedId,
    required int balance,
    String? fixtureLabel,
  }) : super._(
         items: items,
         equippedOutfit: equippedOutfit,
         breedId: breedId,
         balance: balance,
         fixtureLabel: fixtureLabel,
       );

  /// Returns a shallow copy of this [OutfitStore]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OutfitStore copyWith({
    List<_if659p5a.OutfitItem>? items,
    Object? equippedOutfit = _Undefined,
    Object? breedId = _Undefined,
    int? balance,
    Object? fixtureLabel = _Undefined,
  }) {
    return OutfitStore(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      equippedOutfit: equippedOutfit is String?
          ? equippedOutfit
          : this.equippedOutfit,
      breedId: breedId is String? ? breedId : this.breedId,
      balance: balance ?? this.balance,
      fixtureLabel: fixtureLabel is String? ? fixtureLabel : this.fixtureLabel,
    );
  }
}
