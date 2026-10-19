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
import '../product/reward_slice.dart' as _i03s1ada;

abstract class RewardGrant
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RewardGrant._({
    required this.ledgerId,
    required this.date,
    required this.amount,
    required this.fromUnits,
    required this.throughUnits,
    required this.grantedAt,
    this.fixtureLabel,
    this.policyVersion,
    this.basePoints,
    this.multiplier,
    this.slices,
  });

  factory RewardGrant({
    required int ledgerId,
    required String date,
    required int amount,
    required int fromUnits,
    required int throughUnits,
    required DateTime grantedAt,
    String? fixtureLabel,
    String? policyVersion,
    int? basePoints,
    int? multiplier,
    List<_i03s1ada.RewardSlice>? slices,
  }) = _RewardGrantImpl;

  factory RewardGrant.fromJson(Map<String, dynamic> jsonSerialization) {
    return RewardGrant(
      ledgerId: jsonSerialization['ledgerId'] as int,
      date: jsonSerialization['date'] as String,
      amount: jsonSerialization['amount'] as int,
      fromUnits: jsonSerialization['fromUnits'] as int,
      throughUnits: jsonSerialization['throughUnits'] as int,
      grantedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['grantedAt'],
      ),
      fixtureLabel: jsonSerialization['fixtureLabel'] as String?,
      policyVersion: jsonSerialization['policyVersion'] as String?,
      basePoints: jsonSerialization['basePoints'] as int?,
      multiplier: jsonSerialization['multiplier'] as int?,
      slices: jsonSerialization['slices'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<List<_i03s1ada.RewardSlice>>(
              jsonSerialization['slices'],
            ),
    );
  }

  int ledgerId;

  String date;

  int amount;

  int fromUnits;

  int throughUnits;

  DateTime grantedAt;

  String? fixtureLabel;

  String? policyVersion;

  int? basePoints;

  int? multiplier;

  List<_i03s1ada.RewardSlice>? slices;

  /// Returns a shallow copy of this [RewardGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RewardGrant copyWith({
    int? ledgerId,
    String? date,
    int? amount,
    int? fromUnits,
    int? throughUnits,
    DateTime? grantedAt,
    String? fixtureLabel,
    String? policyVersion,
    int? basePoints,
    int? multiplier,
    List<_i03s1ada.RewardSlice>? slices,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RewardGrant',
      'ledgerId': ledgerId,
      'date': date,
      'amount': amount,
      'fromUnits': fromUnits,
      'throughUnits': throughUnits,
      'grantedAt': grantedAt.toJson(),
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
      if (policyVersion != null) 'policyVersion': policyVersion,
      if (basePoints != null) 'basePoints': basePoints,
      if (multiplier != null) 'multiplier': multiplier,
      if (slices != null)
        'slices': slices?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RewardGrant',
      'ledgerId': ledgerId,
      'date': date,
      'amount': amount,
      'fromUnits': fromUnits,
      'throughUnits': throughUnits,
      'grantedAt': grantedAt.toJson(),
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
      if (policyVersion != null) 'policyVersion': policyVersion,
      if (basePoints != null) 'basePoints': basePoints,
      if (multiplier != null) 'multiplier': multiplier,
      if (slices != null)
        'slices': slices?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RewardGrantImpl extends RewardGrant {
  _RewardGrantImpl({
    required int ledgerId,
    required String date,
    required int amount,
    required int fromUnits,
    required int throughUnits,
    required DateTime grantedAt,
    String? fixtureLabel,
    String? policyVersion,
    int? basePoints,
    int? multiplier,
    List<_i03s1ada.RewardSlice>? slices,
  }) : super._(
         ledgerId: ledgerId,
         date: date,
         amount: amount,
         fromUnits: fromUnits,
         throughUnits: throughUnits,
         grantedAt: grantedAt,
         fixtureLabel: fixtureLabel,
         policyVersion: policyVersion,
         basePoints: basePoints,
         multiplier: multiplier,
         slices: slices,
       );

  /// Returns a shallow copy of this [RewardGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RewardGrant copyWith({
    int? ledgerId,
    String? date,
    int? amount,
    int? fromUnits,
    int? throughUnits,
    DateTime? grantedAt,
    Object? fixtureLabel = _Undefined,
    Object? policyVersion = _Undefined,
    Object? basePoints = _Undefined,
    Object? multiplier = _Undefined,
    Object? slices = _Undefined,
  }) {
    return RewardGrant(
      ledgerId: ledgerId ?? this.ledgerId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      fromUnits: fromUnits ?? this.fromUnits,
      throughUnits: throughUnits ?? this.throughUnits,
      grantedAt: grantedAt ?? this.grantedAt,
      fixtureLabel: fixtureLabel is String? ? fixtureLabel : this.fixtureLabel,
      policyVersion: policyVersion is String?
          ? policyVersion
          : this.policyVersion,
      basePoints: basePoints is int? ? basePoints : this.basePoints,
      multiplier: multiplier is int? ? multiplier : this.multiplier,
      slices: slices is List<_i03s1ada.RewardSlice>?
          ? slices
          : this.slices?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
