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
import 'package:serverpod/serverpod.dart' as _is;

abstract class WardrobeEquipView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WardrobeEquipView._({
    required this.slot,
    required this.itemId,
    required this.colourId,
  });

  factory WardrobeEquipView({
    required String slot,
    required String itemId,
    required String colourId,
  }) = _WardrobeEquipViewImpl;

  factory WardrobeEquipView.fromJson(Map<String, dynamic> jsonSerialization) {
    return WardrobeEquipView(
      slot: jsonSerialization['slot'] as String,
      itemId: jsonSerialization['itemId'] as String,
      colourId: jsonSerialization['colourId'] as String,
    );
  }

  String slot;

  String itemId;

  String colourId;

  /// Returns a shallow copy of this [WardrobeEquipView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WardrobeEquipView copyWith({
    String? slot,
    String? itemId,
    String? colourId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeEquipView',
      'slot': slot,
      'itemId': itemId,
      'colourId': colourId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeEquipView',
      'slot': slot,
      'itemId': itemId,
      'colourId': colourId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _WardrobeEquipViewImpl extends WardrobeEquipView {
  _WardrobeEquipViewImpl({
    required String slot,
    required String itemId,
    required String colourId,
  }) : super._(
         slot: slot,
         itemId: itemId,
         colourId: colourId,
       );

  /// Returns a shallow copy of this [WardrobeEquipView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WardrobeEquipView copyWith({
    String? slot,
    String? itemId,
    String? colourId,
  }) {
    return WardrobeEquipView(
      slot: slot ?? this.slot,
      itemId: itemId ?? this.itemId,
      colourId: colourId ?? this.colourId,
    );
  }
}
