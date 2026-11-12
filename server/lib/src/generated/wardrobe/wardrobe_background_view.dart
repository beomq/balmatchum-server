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

abstract class WardrobeBackgroundView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WardrobeBackgroundView._({
    required this.backgroundId,
    required this.name,
    required this.price,
    required this.owned,
    required this.sellable,
    this.setId,
  });

  factory WardrobeBackgroundView({
    required String backgroundId,
    required String name,
    required int price,
    required bool owned,
    required bool sellable,
    String? setId,
  }) = _WardrobeBackgroundViewImpl;

  factory WardrobeBackgroundView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return WardrobeBackgroundView(
      backgroundId: jsonSerialization['backgroundId'] as String,
      name: jsonSerialization['name'] as String,
      price: jsonSerialization['price'] as int,
      owned: _is.BoolJsonExtension.fromJson(jsonSerialization['owned']),
      sellable: _is.BoolJsonExtension.fromJson(jsonSerialization['sellable']),
      setId: jsonSerialization['setId'] as String?,
    );
  }

  String backgroundId;

  String name;

  int price;

  bool owned;

  /// False for a gift-only set's background, which comes only with it.
  bool sellable;

  String? setId;

  /// Returns a shallow copy of this [WardrobeBackgroundView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WardrobeBackgroundView copyWith({
    String? backgroundId,
    String? name,
    int? price,
    bool? owned,
    bool? sellable,
    String? setId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeBackgroundView',
      'backgroundId': backgroundId,
      'name': name,
      'price': price,
      'owned': owned,
      'sellable': sellable,
      if (setId != null) 'setId': setId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeBackgroundView',
      'backgroundId': backgroundId,
      'name': name,
      'price': price,
      'owned': owned,
      'sellable': sellable,
      if (setId != null) 'setId': setId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WardrobeBackgroundViewImpl extends WardrobeBackgroundView {
  _WardrobeBackgroundViewImpl({
    required String backgroundId,
    required String name,
    required int price,
    required bool owned,
    required bool sellable,
    String? setId,
  }) : super._(
         backgroundId: backgroundId,
         name: name,
         price: price,
         owned: owned,
         sellable: sellable,
         setId: setId,
       );

  /// Returns a shallow copy of this [WardrobeBackgroundView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WardrobeBackgroundView copyWith({
    String? backgroundId,
    String? name,
    int? price,
    bool? owned,
    bool? sellable,
    Object? setId = _Undefined,
  }) {
    return WardrobeBackgroundView(
      backgroundId: backgroundId ?? this.backgroundId,
      name: name ?? this.name,
      price: price ?? this.price,
      owned: owned ?? this.owned,
      sellable: sellable ?? this.sellable,
      setId: setId is String? ? setId : this.setId,
    );
  }
}
