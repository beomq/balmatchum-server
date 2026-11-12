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

abstract class WardrobeColourView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WardrobeColourView._({
    required this.colourId,
    required this.name,
    required this.swatch,
  });

  factory WardrobeColourView({
    required String colourId,
    required String name,
    required int swatch,
  }) = _WardrobeColourViewImpl;

  factory WardrobeColourView.fromJson(Map<String, dynamic> jsonSerialization) {
    return WardrobeColourView(
      colourId: jsonSerialization['colourId'] as String,
      name: jsonSerialization['name'] as String,
      swatch: jsonSerialization['swatch'] as int,
    );
  }

  String colourId;

  String name;

  /// ARGB swatch for colour chips.
  int swatch;

  /// Returns a shallow copy of this [WardrobeColourView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WardrobeColourView copyWith({
    String? colourId,
    String? name,
    int? swatch,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeColourView',
      'colourId': colourId,
      'name': name,
      'swatch': swatch,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeColourView',
      'colourId': colourId,
      'name': name,
      'swatch': swatch,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WardrobeColourViewImpl extends WardrobeColourView {
  _WardrobeColourViewImpl({
    required String colourId,
    required String name,
    required int swatch,
  }) : super._(
         colourId: colourId,
         name: name,
         swatch: swatch,
       );

  /// Returns a shallow copy of this [WardrobeColourView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WardrobeColourView copyWith({
    String? colourId,
    String? name,
    int? swatch,
  }) {
    return WardrobeColourView(
      colourId: colourId ?? this.colourId,
      name: name ?? this.name,
      swatch: swatch ?? this.swatch,
    );
  }
}
