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

abstract class RewardSlice
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RewardSlice._({
    required this.fromUnits,
    required this.throughUnits,
    required this.basePoints,
    required this.multiplier,
  });

  factory RewardSlice({
    required int fromUnits,
    required int throughUnits,
    required int basePoints,
    required int multiplier,
  }) = _RewardSliceImpl;

  factory RewardSlice.fromJson(Map<String, dynamic> jsonSerialization) {
    return RewardSlice(
      fromUnits: jsonSerialization['fromUnits'] as int,
      throughUnits: jsonSerialization['throughUnits'] as int,
      basePoints: jsonSerialization['basePoints'] as int,
      multiplier: jsonSerialization['multiplier'] as int,
    );
  }

  int fromUnits;

  int throughUnits;

  int basePoints;

  int multiplier;

  /// Returns a shallow copy of this [RewardSlice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RewardSlice copyWith({
    int? fromUnits,
    int? throughUnits,
    int? basePoints,
    int? multiplier,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RewardSlice',
      'fromUnits': fromUnits,
      'throughUnits': throughUnits,
      'basePoints': basePoints,
      'multiplier': multiplier,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RewardSlice',
      'fromUnits': fromUnits,
      'throughUnits': throughUnits,
      'basePoints': basePoints,
      'multiplier': multiplier,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RewardSliceImpl extends RewardSlice {
  _RewardSliceImpl({
    required int fromUnits,
    required int throughUnits,
    required int basePoints,
    required int multiplier,
  }) : super._(
         fromUnits: fromUnits,
         throughUnits: throughUnits,
         basePoints: basePoints,
         multiplier: multiplier,
       );

  /// Returns a shallow copy of this [RewardSlice]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RewardSlice copyWith({
    int? fromUnits,
    int? throughUnits,
    int? basePoints,
    int? multiplier,
  }) {
    return RewardSlice(
      fromUnits: fromUnits ?? this.fromUnits,
      throughUnits: throughUnits ?? this.throughUnits,
      basePoints: basePoints ?? this.basePoints,
      multiplier: multiplier ?? this.multiplier,
    );
  }
}
