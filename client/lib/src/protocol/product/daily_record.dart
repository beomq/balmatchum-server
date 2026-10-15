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
import 'package:balmatchum_client/src/protocol/protocol.dart' as _i5u3fx7i;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../product/day_route.dart' as _iurwpayh;

abstract class DailyRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DailyRecord._({
    required this.date,
    required this.revision,
    required this.deleted,
    required this.deletionVersion,
    this.steps,
    required this.availability,
    required this.streamGeneration,
    required this.stepRevision,
    required this.rewardStatus,
    this.claimablePoints,
    required this.grantedPoints,
    this.fixtureLabel,
    required this.routes,
  });

  factory DailyRecord({
    required String date,
    required int revision,
    required bool deleted,
    required int deletionVersion,
    int? steps,
    required String availability,
    required int streamGeneration,
    required int stepRevision,
    required String rewardStatus,
    int? claimablePoints,
    required int grantedPoints,
    String? fixtureLabel,
    required List<_iurwpayh.DayRoute> routes,
  }) = _DailyRecordImpl;

  factory DailyRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyRecord(
      date: jsonSerialization['date'] as String,
      revision: jsonSerialization['revision'] as int,
      deleted: _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
      deletionVersion: jsonSerialization['deletionVersion'] as int,
      steps: jsonSerialization['steps'] as int?,
      availability: jsonSerialization['availability'] as String,
      streamGeneration: jsonSerialization['streamGeneration'] as int,
      stepRevision: jsonSerialization['stepRevision'] as int,
      rewardStatus: jsonSerialization['rewardStatus'] as String,
      claimablePoints: jsonSerialization['claimablePoints'] as int?,
      grantedPoints: jsonSerialization['grantedPoints'] as int,
      fixtureLabel: jsonSerialization['fixtureLabel'] as String?,
      routes: _i5u3fx7i.Protocol().deserialize<List<_iurwpayh.DayRoute>>(
        jsonSerialization['routes'],
      ),
    );
  }

  String date;

  int revision;

  bool deleted;

  int deletionVersion;

  int? steps;

  String availability;

  int streamGeneration;

  int stepRevision;

  String rewardStatus;

  int? claimablePoints;

  int grantedPoints;

  String? fixtureLabel;

  List<_iurwpayh.DayRoute> routes;

  /// Returns a shallow copy of this [DailyRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DailyRecord copyWith({
    String? date,
    int? revision,
    bool? deleted,
    int? deletionVersion,
    int? steps,
    String? availability,
    int? streamGeneration,
    int? stepRevision,
    String? rewardStatus,
    int? claimablePoints,
    int? grantedPoints,
    String? fixtureLabel,
    List<_iurwpayh.DayRoute>? routes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyRecord',
      'date': date,
      'revision': revision,
      'deleted': deleted,
      'deletionVersion': deletionVersion,
      if (steps != null) 'steps': steps,
      'availability': availability,
      'streamGeneration': streamGeneration,
      'stepRevision': stepRevision,
      'rewardStatus': rewardStatus,
      if (claimablePoints != null) 'claimablePoints': claimablePoints,
      'grantedPoints': grantedPoints,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
      'routes': routes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyRecord',
      'date': date,
      'revision': revision,
      'deleted': deleted,
      'deletionVersion': deletionVersion,
      if (steps != null) 'steps': steps,
      'availability': availability,
      'streamGeneration': streamGeneration,
      'stepRevision': stepRevision,
      'rewardStatus': rewardStatus,
      if (claimablePoints != null) 'claimablePoints': claimablePoints,
      'grantedPoints': grantedPoints,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
      'routes': routes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyRecordImpl extends DailyRecord {
  _DailyRecordImpl({
    required String date,
    required int revision,
    required bool deleted,
    required int deletionVersion,
    int? steps,
    required String availability,
    required int streamGeneration,
    required int stepRevision,
    required String rewardStatus,
    int? claimablePoints,
    required int grantedPoints,
    String? fixtureLabel,
    required List<_iurwpayh.DayRoute> routes,
  }) : super._(
         date: date,
         revision: revision,
         deleted: deleted,
         deletionVersion: deletionVersion,
         steps: steps,
         availability: availability,
         streamGeneration: streamGeneration,
         stepRevision: stepRevision,
         rewardStatus: rewardStatus,
         claimablePoints: claimablePoints,
         grantedPoints: grantedPoints,
         fixtureLabel: fixtureLabel,
         routes: routes,
       );

  /// Returns a shallow copy of this [DailyRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DailyRecord copyWith({
    String? date,
    int? revision,
    bool? deleted,
    int? deletionVersion,
    Object? steps = _Undefined,
    String? availability,
    int? streamGeneration,
    int? stepRevision,
    String? rewardStatus,
    Object? claimablePoints = _Undefined,
    int? grantedPoints,
    Object? fixtureLabel = _Undefined,
    List<_iurwpayh.DayRoute>? routes,
  }) {
    return DailyRecord(
      date: date ?? this.date,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
      deletionVersion: deletionVersion ?? this.deletionVersion,
      steps: steps is int? ? steps : this.steps,
      availability: availability ?? this.availability,
      streamGeneration: streamGeneration ?? this.streamGeneration,
      stepRevision: stepRevision ?? this.stepRevision,
      rewardStatus: rewardStatus ?? this.rewardStatus,
      claimablePoints: claimablePoints is int?
          ? claimablePoints
          : this.claimablePoints,
      grantedPoints: grantedPoints ?? this.grantedPoints,
      fixtureLabel: fixtureLabel is String? ? fixtureLabel : this.fixtureLabel,
      routes: routes ?? this.routes.map((e0) => e0.copyWith()).toList(),
    );
  }
}
