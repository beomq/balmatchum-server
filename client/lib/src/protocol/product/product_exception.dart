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

abstract class ProductException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  ProductException._({required this.code});

  factory ProductException({required String code}) = _ProductExceptionImpl;

  factory ProductException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductException(code: jsonSerialization['code'] as String);
  }

  String code;

  /// Returns a shallow copy of this [ProductException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProductException copyWith({String? code});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProductException',
      'code': code,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProductException',
      'code': code,
    };
  }

  @override
  String toString() {
    return 'ProductException(code: $code)';
  }
}

class _ProductExceptionImpl extends ProductException {
  _ProductExceptionImpl({required String code}) : super._(code: code);

  /// Returns a shallow copy of this [ProductException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProductException copyWith({String? code}) {
    return ProductException(code: code ?? this.code);
  }
}
