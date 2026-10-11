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

abstract class RecordException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  RecordException._({required this.code});

  factory RecordException({required String code}) = _RecordExceptionImpl;

  factory RecordException.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecordException(code: jsonSerialization['code'] as String);
  }

  String code;

  /// Returns a shallow copy of this [RecordException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecordException copyWith({String? code});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecordException',
      'code': code,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecordException',
      'code': code,
    };
  }

  @override
  String toString() {
    return 'RecordException(code: $code)';
  }
}

class _RecordExceptionImpl extends RecordException {
  _RecordExceptionImpl({required String code}) : super._(code: code);

  /// Returns a shallow copy of this [RecordException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecordException copyWith({String? code}) {
    return RecordException(code: code ?? this.code);
  }
}
