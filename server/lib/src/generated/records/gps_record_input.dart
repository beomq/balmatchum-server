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
import '../records/route_point.dart' as _intzm3dt;

abstract class GpsRecordInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  GpsRecordInput._({
    required this.schemaVersion,
    required this.clientRecordId,
    required this.startedAt,
    required this.endedAt,
    required this.source,
    required this.routePoints,
  });

  factory GpsRecordInput({
    required int schemaVersion,
    required _is.UuidValue clientRecordId,
    required DateTime startedAt,
    required DateTime endedAt,
    required String source,
    required List<_intzm3dt.RoutePoint> routePoints,
  }) = _GpsRecordInputImpl;

  factory GpsRecordInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return GpsRecordInput(
      schemaVersion: jsonSerialization['schemaVersion'] as int,
      clientRecordId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientRecordId'],
      ),
      startedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      endedAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      source: jsonSerialization['source'] as String,
      routePoints: _iu3f2ih9.Protocol().deserialize<List<_intzm3dt.RoutePoint>>(
        jsonSerialization['routePoints'],
      ),
    );
  }

  int schemaVersion;

  _is.UuidValue clientRecordId;

  DateTime startedAt;

  DateTime endedAt;

  String source;

  List<_intzm3dt.RoutePoint> routePoints;

  /// Returns a shallow copy of this [GpsRecordInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GpsRecordInput copyWith({
    int? schemaVersion,
    _is.UuidValue? clientRecordId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? source,
    List<_intzm3dt.RoutePoint>? routePoints,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GpsRecordInput',
      'schemaVersion': schemaVersion,
      'clientRecordId': clientRecordId.toJson(),
      'startedAt': startedAt.toJson(),
      'endedAt': endedAt.toJson(),
      'source': source,
      'routePoints': routePoints.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GpsRecordInput',
      'schemaVersion': schemaVersion,
      'clientRecordId': clientRecordId.toJson(),
      'startedAt': startedAt.toJson(),
      'endedAt': endedAt.toJson(),
      'source': source,
      'routePoints': routePoints.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _GpsRecordInputImpl extends GpsRecordInput {
  _GpsRecordInputImpl({
    required int schemaVersion,
    required _is.UuidValue clientRecordId,
    required DateTime startedAt,
    required DateTime endedAt,
    required String source,
    required List<_intzm3dt.RoutePoint> routePoints,
  }) : super._(
         schemaVersion: schemaVersion,
         clientRecordId: clientRecordId,
         startedAt: startedAt,
         endedAt: endedAt,
         source: source,
         routePoints: routePoints,
       );

  /// Returns a shallow copy of this [GpsRecordInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GpsRecordInput copyWith({
    int? schemaVersion,
    _is.UuidValue? clientRecordId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? source,
    List<_intzm3dt.RoutePoint>? routePoints,
  }) {
    return GpsRecordInput(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      clientRecordId: clientRecordId ?? this.clientRecordId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      source: source ?? this.source,
      routePoints:
          routePoints ?? this.routePoints.map((e0) => e0.copyWith()).toList(),
    );
  }
}
