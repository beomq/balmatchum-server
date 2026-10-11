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

abstract class RoutePoint
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RoutePoint._({
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    this.horizontalAccuracyMeters,
  });

  factory RoutePoint({
    required DateTime recordedAt,
    required double latitude,
    required double longitude,
    double? horizontalAccuracyMeters,
  }) = _RoutePointImpl;

  factory RoutePoint.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoutePoint(
      recordedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      horizontalAccuracyMeters:
          (jsonSerialization['horizontalAccuracyMeters'] as num?)?.toDouble(),
    );
  }

  DateTime recordedAt;

  double latitude;

  double longitude;

  double? horizontalAccuracyMeters;

  /// Returns a shallow copy of this [RoutePoint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RoutePoint copyWith({
    DateTime? recordedAt,
    double? latitude,
    double? longitude,
    double? horizontalAccuracyMeters,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoutePoint',
      'recordedAt': recordedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      if (horizontalAccuracyMeters != null)
        'horizontalAccuracyMeters': horizontalAccuracyMeters,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoutePoint',
      'recordedAt': recordedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      if (horizontalAccuracyMeters != null)
        'horizontalAccuracyMeters': horizontalAccuracyMeters,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoutePointImpl extends RoutePoint {
  _RoutePointImpl({
    required DateTime recordedAt,
    required double latitude,
    required double longitude,
    double? horizontalAccuracyMeters,
  }) : super._(
         recordedAt: recordedAt,
         latitude: latitude,
         longitude: longitude,
         horizontalAccuracyMeters: horizontalAccuracyMeters,
       );

  /// Returns a shallow copy of this [RoutePoint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RoutePoint copyWith({
    DateTime? recordedAt,
    double? latitude,
    double? longitude,
    Object? horizontalAccuracyMeters = _Undefined,
  }) {
    return RoutePoint(
      recordedAt: recordedAt ?? this.recordedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      horizontalAccuracyMeters: horizontalAccuracyMeters is double?
          ? horizontalAccuracyMeters
          : this.horizontalAccuracyMeters,
    );
  }
}
