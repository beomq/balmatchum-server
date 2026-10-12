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

abstract class LoginChallenge
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LoginChallenge._({
    required this.attemptId,
    required this.nonce,
    required this.expiresAt,
  });

  factory LoginChallenge({
    required _is.UuidValue attemptId,
    required String nonce,
    required DateTime expiresAt,
  }) = _LoginChallengeImpl;

  factory LoginChallenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return LoginChallenge(
      attemptId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['attemptId'],
      ),
      nonce: jsonSerialization['nonce'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  _is.UuidValue attemptId;

  String nonce;

  DateTime expiresAt;

  /// Returns a shallow copy of this [LoginChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LoginChallenge copyWith({
    _is.UuidValue? attemptId,
    String? nonce,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LoginChallenge',
      'attemptId': attemptId.toJson(),
      'nonce': nonce,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LoginChallenge',
      'attemptId': attemptId.toJson(),
      'nonce': nonce,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _LoginChallengeImpl extends LoginChallenge {
  _LoginChallengeImpl({
    required _is.UuidValue attemptId,
    required String nonce,
    required DateTime expiresAt,
  }) : super._(
         attemptId: attemptId,
         nonce: nonce,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [LoginChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LoginChallenge copyWith({
    _is.UuidValue? attemptId,
    String? nonce,
    DateTime? expiresAt,
  }) {
    return LoginChallenge(
      attemptId: attemptId ?? this.attemptId,
      nonce: nonce ?? this.nonce,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
