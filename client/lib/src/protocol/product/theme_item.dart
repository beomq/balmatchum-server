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

abstract class ThemeItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ThemeItem._({
    required this.themeId,
    required this.name,
    required this.colorValue,
    this.price,
    required this.owned,
  });

  factory ThemeItem({
    required String themeId,
    required String name,
    required int colorValue,
    int? price,
    required bool owned,
  }) = _ThemeItemImpl;

  factory ThemeItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return ThemeItem(
      themeId: jsonSerialization['themeId'] as String,
      name: jsonSerialization['name'] as String,
      colorValue: jsonSerialization['colorValue'] as int,
      price: jsonSerialization['price'] as int?,
      owned: _isc.BoolJsonExtension.fromJson(jsonSerialization['owned']),
    );
  }

  String themeId;

  String name;

  int colorValue;

  int? price;

  bool owned;

  /// Returns a shallow copy of this [ThemeItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ThemeItem copyWith({
    String? themeId,
    String? name,
    int? colorValue,
    int? price,
    bool? owned,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ThemeItem',
      'themeId': themeId,
      'name': name,
      'colorValue': colorValue,
      if (price != null) 'price': price,
      'owned': owned,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ThemeItem',
      'themeId': themeId,
      'name': name,
      'colorValue': colorValue,
      if (price != null) 'price': price,
      'owned': owned,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ThemeItemImpl extends ThemeItem {
  _ThemeItemImpl({
    required String themeId,
    required String name,
    required int colorValue,
    int? price,
    required bool owned,
  }) : super._(
         themeId: themeId,
         name: name,
         colorValue: colorValue,
         price: price,
         owned: owned,
       );

  /// Returns a shallow copy of this [ThemeItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ThemeItem copyWith({
    String? themeId,
    String? name,
    int? colorValue,
    Object? price = _Undefined,
    bool? owned,
  }) {
    return ThemeItem(
      themeId: themeId ?? this.themeId,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      price: price is int? ? price : this.price,
      owned: owned ?? this.owned,
    );
  }
}
