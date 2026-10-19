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

abstract class WalletView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WalletView._({
    required this.balance,
    required this.streamGeneration,
    this.fixtureLabel,
    required this.policyVersion,
  });

  factory WalletView({
    required int balance,
    required int streamGeneration,
    String? fixtureLabel,
    required String policyVersion,
  }) = _WalletViewImpl;

  factory WalletView.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletView(
      balance: jsonSerialization['balance'] as int,
      streamGeneration: jsonSerialization['streamGeneration'] as int,
      fixtureLabel: jsonSerialization['fixtureLabel'] as String?,
      policyVersion: jsonSerialization['policyVersion'] as String,
    );
  }

  int balance;

  int streamGeneration;

  String? fixtureLabel;

  String policyVersion;

  /// Returns a shallow copy of this [WalletView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WalletView copyWith({
    int? balance,
    int? streamGeneration,
    String? fixtureLabel,
    String? policyVersion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletView',
      'balance': balance,
      'streamGeneration': streamGeneration,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
      'policyVersion': policyVersion,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletView',
      'balance': balance,
      'streamGeneration': streamGeneration,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
      'policyVersion': policyVersion,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletViewImpl extends WalletView {
  _WalletViewImpl({
    required int balance,
    required int streamGeneration,
    String? fixtureLabel,
    required String policyVersion,
  }) : super._(
         balance: balance,
         streamGeneration: streamGeneration,
         fixtureLabel: fixtureLabel,
         policyVersion: policyVersion,
       );

  /// Returns a shallow copy of this [WalletView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WalletView copyWith({
    int? balance,
    int? streamGeneration,
    Object? fixtureLabel = _Undefined,
    String? policyVersion,
  }) {
    return WalletView(
      balance: balance ?? this.balance,
      streamGeneration: streamGeneration ?? this.streamGeneration,
      fixtureLabel: fixtureLabel is String? ? fixtureLabel : this.fixtureLabel,
      policyVersion: policyVersion ?? this.policyVersion,
    );
  }
}
