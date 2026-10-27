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

abstract class OutfitItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  OutfitItem._({
    required this.outfitId,
    required this.name,
    required this.price,
    required this.compatibleBreeds,
    required this.compatible,
    required this.owned,
  });

  factory OutfitItem({
    required String outfitId,
    required String name,
    required int price,
    required List<String> compatibleBreeds,
    required bool compatible,
    required bool owned,
  }) = _OutfitItemImpl;

  factory OutfitItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return OutfitItem(
      outfitId: jsonSerialization['outfitId'] as String,
      name: jsonSerialization['name'] as String,
      price: jsonSerialization['price'] as int,
      compatibleBreeds: _i5u3fx7i.Protocol().deserialize<List<String>>(
        jsonSerialization['compatibleBreeds'],
      ),
      compatible: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['compatible'],
      ),
      owned: _isc.BoolJsonExtension.fromJson(jsonSerialization['owned']),
    );
  }

  String outfitId;

  String name;

  int price;

  List<String> compatibleBreeds;

  bool compatible;

  bool owned;

  /// Returns a shallow copy of this [OutfitItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  OutfitItem copyWith({
    String? outfitId,
    String? name,
    int? price,
    List<String>? compatibleBreeds,
    bool? compatible,
    bool? owned,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OutfitItem',
      'outfitId': outfitId,
      'name': name,
      'price': price,
      'compatibleBreeds': compatibleBreeds.toJson(),
      'compatible': compatible,
      'owned': owned,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OutfitItem',
      'outfitId': outfitId,
      'name': name,
      'price': price,
      'compatibleBreeds': compatibleBreeds.toJson(),
      'compatible': compatible,
      'owned': owned,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _OutfitItemImpl extends OutfitItem {
  _OutfitItemImpl({
    required String outfitId,
    required String name,
    required int price,
    required List<String> compatibleBreeds,
    required bool compatible,
    required bool owned,
  }) : super._(
         outfitId: outfitId,
         name: name,
         price: price,
         compatibleBreeds: compatibleBreeds,
         compatible: compatible,
         owned: owned,
       );

  /// Returns a shallow copy of this [OutfitItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  OutfitItem copyWith({
    String? outfitId,
    String? name,
    int? price,
    List<String>? compatibleBreeds,
    bool? compatible,
    bool? owned,
  }) {
    return OutfitItem(
      outfitId: outfitId ?? this.outfitId,
      name: name ?? this.name,
      price: price ?? this.price,
      compatibleBreeds:
          compatibleBreeds ?? this.compatibleBreeds.map((e0) => e0).toList(),
      compatible: compatible ?? this.compatible,
      owned: owned ?? this.owned,
    );
  }
}
