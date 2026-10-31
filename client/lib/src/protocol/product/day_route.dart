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
import '../records/route_point.dart' as _intzm3dt;

abstract class DayRoute
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DayRoute._({
    required this.recordId,
    required this.source,
    required this.points,
  });

  factory DayRoute({
    required _isc.UuidValue recordId,
    required String source,
    required List<_intzm3dt.RoutePoint> points,
  }) = _DayRouteImpl;

  factory DayRoute.fromJson(Map<String, dynamic> jsonSerialization) {
    return DayRoute(
      recordId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['recordId'],
      ),
      source: jsonSerialization['source'] as String,
      points: _i5u3fx7i.Protocol().deserialize<List<_intzm3dt.RoutePoint>>(
        jsonSerialization['points'],
      ),
    );
  }

  _isc.UuidValue recordId;

  String source;

  List<_intzm3dt.RoutePoint> points;

  /// Returns a shallow copy of this [DayRoute]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DayRoute copyWith({
    _isc.UuidValue? recordId,
    String? source,
    List<_intzm3dt.RoutePoint>? points,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DayRoute',
      'recordId': recordId.toJson(),
      'source': source,
      'points': points.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DayRoute',
      'recordId': recordId.toJson(),
      'source': source,
      'points': points.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DayRouteImpl extends DayRoute {
  _DayRouteImpl({
    required _isc.UuidValue recordId,
    required String source,
    required List<_intzm3dt.RoutePoint> points,
  }) : super._(
         recordId: recordId,
         source: source,
         points: points,
       );

  /// Returns a shallow copy of this [DayRoute]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DayRoute copyWith({
    _isc.UuidValue? recordId,
    String? source,
    List<_intzm3dt.RoutePoint>? points,
  }) {
    return DayRoute(
      recordId: recordId ?? this.recordId,
      source: source ?? this.source,
      points: points ?? this.points.map((e0) => e0.copyWith()).toList(),
    );
  }
}
