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

abstract class PhotoException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  PhotoException._({required this.code});

  factory PhotoException({required String code}) = _PhotoExceptionImpl;

  factory PhotoException.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoException(code: jsonSerialization['code'] as String);
  }

  String code;

  /// Returns a shallow copy of this [PhotoException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PhotoException copyWith({String? code});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PhotoException',
      'code': code,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PhotoException',
      'code': code,
    };
  }

  @override
  String toString() {
    return 'PhotoException(code: $code)';
  }
}

class _PhotoExceptionImpl extends PhotoException {
  _PhotoExceptionImpl({required String code}) : super._(code: code);

  /// Returns a shallow copy of this [PhotoException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PhotoException copyWith({String? code}) {
    return PhotoException(code: code ?? this.code);
  }
}
