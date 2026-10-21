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

abstract class NaverLoginChallenge
    implements _is.SerializableModel, _is.ProtocolSerialization {
  NaverLoginChallenge._({
    required this.attemptId,
    required this.authorizationUrl,
    required this.state,
    required this.redirectUri,
    required this.expiresAt,
  });

  factory NaverLoginChallenge({
    required _is.UuidValue attemptId,
    required String authorizationUrl,
    required String state,
    required String redirectUri,
    required DateTime expiresAt,
  }) = _NaverLoginChallengeImpl;

  factory NaverLoginChallenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return NaverLoginChallenge(
      attemptId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['attemptId'],
      ),
      authorizationUrl: jsonSerialization['authorizationUrl'] as String,
      state: jsonSerialization['state'] as String,
      redirectUri: jsonSerialization['redirectUri'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  _is.UuidValue attemptId;

  String authorizationUrl;

  String state;

  String redirectUri;

  DateTime expiresAt;

  /// Returns a shallow copy of this [NaverLoginChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NaverLoginChallenge copyWith({
    _is.UuidValue? attemptId,
    String? authorizationUrl,
    String? state,
    String? redirectUri,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NaverLoginChallenge',
      'attemptId': attemptId.toJson(),
      'authorizationUrl': authorizationUrl,
      'state': state,
      'redirectUri': redirectUri,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NaverLoginChallenge',
      'attemptId': attemptId.toJson(),
      'authorizationUrl': authorizationUrl,
      'state': state,
      'redirectUri': redirectUri,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _NaverLoginChallengeImpl extends NaverLoginChallenge {
  _NaverLoginChallengeImpl({
    required _is.UuidValue attemptId,
    required String authorizationUrl,
    required String state,
    required String redirectUri,
    required DateTime expiresAt,
  }) : super._(
         attemptId: attemptId,
         authorizationUrl: authorizationUrl,
         state: state,
         redirectUri: redirectUri,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [NaverLoginChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NaverLoginChallenge copyWith({
    _is.UuidValue? attemptId,
    String? authorizationUrl,
    String? state,
    String? redirectUri,
    DateTime? expiresAt,
  }) {
    return NaverLoginChallenge(
      attemptId: attemptId ?? this.attemptId,
      authorizationUrl: authorizationUrl ?? this.authorizationUrl,
      state: state ?? this.state,
      redirectUri: redirectUri ?? this.redirectUri,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
