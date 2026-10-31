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

abstract class PurchaseProduct
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PurchaseProduct._({
    required this.productId,
    required this.kind,
  });

  factory PurchaseProduct({
    required String productId,
    required String kind,
  }) = _PurchaseProductImpl;

  factory PurchaseProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseProduct(
      productId: jsonSerialization['productId'] as String,
      kind: jsonSerialization['kind'] as String,
    );
  }

  String productId;

  String kind;

  /// Returns a shallow copy of this [PurchaseProduct]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PurchaseProduct copyWith({
    String? productId,
    String? kind,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseProduct',
      'productId': productId,
      'kind': kind,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PurchaseProduct',
      'productId': productId,
      'kind': kind,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PurchaseProductImpl extends PurchaseProduct {
  _PurchaseProductImpl({
    required String productId,
    required String kind,
  }) : super._(
         productId: productId,
         kind: kind,
       );

  /// Returns a shallow copy of this [PurchaseProduct]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PurchaseProduct copyWith({
    String? productId,
    String? kind,
  }) {
    return PurchaseProduct(
      productId: productId ?? this.productId,
      kind: kind ?? this.kind,
    );
  }
}
