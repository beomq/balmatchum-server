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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A set in one colour, priced for this user.
abstract class WardrobeSetColourView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WardrobeSetColourView._({
    required this.colourId,
    required this.price,
    required this.missingParts,
    required this.purchasable,
    required this.wearable,
  });

  factory WardrobeSetColourView({
    required String colourId,
    required int price,
    required int missingParts,
    required bool purchasable,
    required bool wearable,
  }) = _WardrobeSetColourViewImpl;

  factory WardrobeSetColourView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return WardrobeSetColourView(
      colourId: jsonSerialization['colourId'] as String,
      price: jsonSerialization['price'] as int,
      missingParts: jsonSerialization['missingParts'] as int,
      purchasable: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['purchasable'],
      ),
      wearable: _isc.BoolJsonExtension.fromJson(jsonSerialization['wearable']),
    );
  }

  String colourId;

  /// Points to pay now: 20% off the parts not owned yet. 0 when all owned.
  int price;

  /// Parts (items + background) still missing in this colour.
  int missingParts;

  /// Can be bought with points right now.
  bool purchasable;

  /// The profile's breed can wear every item of the set in this colour.
  bool wearable;

  /// Returns a shallow copy of this [WardrobeSetColourView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WardrobeSetColourView copyWith({
    String? colourId,
    int? price,
    int? missingParts,
    bool? purchasable,
    bool? wearable,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeSetColourView',
      'colourId': colourId,
      'price': price,
      'missingParts': missingParts,
      'purchasable': purchasable,
      'wearable': wearable,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeSetColourView',
      'colourId': colourId,
      'price': price,
      'missingParts': missingParts,
      'purchasable': purchasable,
      'wearable': wearable,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WardrobeSetColourViewImpl extends WardrobeSetColourView {
  _WardrobeSetColourViewImpl({
    required String colourId,
    required int price,
    required int missingParts,
    required bool purchasable,
    required bool wearable,
  }) : super._(
         colourId: colourId,
         price: price,
         missingParts: missingParts,
         purchasable: purchasable,
         wearable: wearable,
       );

  /// Returns a shallow copy of this [WardrobeSetColourView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WardrobeSetColourView copyWith({
    String? colourId,
    int? price,
    int? missingParts,
    bool? purchasable,
    bool? wearable,
  }) {
    return WardrobeSetColourView(
      colourId: colourId ?? this.colourId,
      price: price ?? this.price,
      missingParts: missingParts ?? this.missingParts,
      purchasable: purchasable ?? this.purchasable,
      wearable: wearable ?? this.wearable,
    );
  }
}
