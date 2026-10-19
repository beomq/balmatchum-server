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
import '../billing/purchase_product.dart' as _ih1g4pyv;

abstract class PurchaseConfiguration
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PurchaseConfiguration._({
    required this.store,
    required this.environment,
    required this.accountBinding,
    required this.products,
  });

  factory PurchaseConfiguration({
    required String store,
    required String environment,
    required String accountBinding,
    required List<_ih1g4pyv.PurchaseProduct> products,
  }) = _PurchaseConfigurationImpl;

  factory PurchaseConfiguration.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PurchaseConfiguration(
      store: jsonSerialization['store'] as String,
      environment: jsonSerialization['environment'] as String,
      accountBinding: jsonSerialization['accountBinding'] as String,
      products: _iu3f2ih9.Protocol()
          .deserialize<List<_ih1g4pyv.PurchaseProduct>>(
            jsonSerialization['products'],
          ),
    );
  }

  String store;

  String environment;

  String accountBinding;

  List<_ih1g4pyv.PurchaseProduct> products;

  /// Returns a shallow copy of this [PurchaseConfiguration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PurchaseConfiguration copyWith({
    String? store,
    String? environment,
    String? accountBinding,
    List<_ih1g4pyv.PurchaseProduct>? products,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseConfiguration',
      'store': store,
      'environment': environment,
      'accountBinding': accountBinding,
      'products': products.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PurchaseConfiguration',
      'store': store,
      'environment': environment,
      'accountBinding': accountBinding,
      'products': products.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PurchaseConfigurationImpl extends PurchaseConfiguration {
  _PurchaseConfigurationImpl({
    required String store,
    required String environment,
    required String accountBinding,
    required List<_ih1g4pyv.PurchaseProduct> products,
  }) : super._(
         store: store,
         environment: environment,
         accountBinding: accountBinding,
         products: products,
       );

  /// Returns a shallow copy of this [PurchaseConfiguration]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PurchaseConfiguration copyWith({
    String? store,
    String? environment,
    String? accountBinding,
    List<_ih1g4pyv.PurchaseProduct>? products,
  }) {
    return PurchaseConfiguration(
      store: store ?? this.store,
      environment: environment ?? this.environment,
      accountBinding: accountBinding ?? this.accountBinding,
      products: products ?? this.products.map((e0) => e0.copyWith()).toList(),
    );
  }
}
