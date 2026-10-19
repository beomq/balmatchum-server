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

abstract class PurchaseInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PurchaseInput._({
    required this.store,
    required this.productId,
    required this.purchaseReference,
  });

  factory PurchaseInput({
    required String store,
    required String productId,
    required String purchaseReference,
  }) = _PurchaseInputImpl;

  factory PurchaseInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseInput(
      store: jsonSerialization['store'] as String,
      productId: jsonSerialization['productId'] as String,
      purchaseReference: jsonSerialization['purchaseReference'] as String,
    );
  }

  String store;

  String productId;

  String purchaseReference;

  /// Returns a shallow copy of this [PurchaseInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PurchaseInput copyWith({
    String? store,
    String? productId,
    String? purchaseReference,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseInput',
      'store': store,
      'productId': productId,
      'purchaseReference': purchaseReference,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PurchaseInput',
      'store': store,
      'productId': productId,
      'purchaseReference': purchaseReference,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PurchaseInputImpl extends PurchaseInput {
  _PurchaseInputImpl({
    required String store,
    required String productId,
    required String purchaseReference,
  }) : super._(
         store: store,
         productId: productId,
         purchaseReference: purchaseReference,
       );

  /// Returns a shallow copy of this [PurchaseInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PurchaseInput copyWith({
    String? store,
    String? productId,
    String? purchaseReference,
  }) {
    return PurchaseInput(
      store: store ?? this.store,
      productId: productId ?? this.productId,
      purchaseReference: purchaseReference ?? this.purchaseReference,
    );
  }
}
