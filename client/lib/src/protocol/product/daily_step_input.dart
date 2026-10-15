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

abstract class DailyStepInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DailyStepInput._({
    required this.date,
    required this.streamGeneration,
    required this.revision,
    required this.windowStart,
    required this.windowEnd,
    required this.observedAt,
    this.total,
    required this.availability,
  });

  factory DailyStepInput({
    required String date,
    required int streamGeneration,
    required int revision,
    required DateTime windowStart,
    required DateTime windowEnd,
    required DateTime observedAt,
    int? total,
    required String availability,
  }) = _DailyStepInputImpl;

  factory DailyStepInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyStepInput(
      date: jsonSerialization['date'] as String,
      streamGeneration: jsonSerialization['streamGeneration'] as int,
      revision: jsonSerialization['revision'] as int,
      windowStart: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['windowStart'],
      ),
      windowEnd: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['windowEnd'],
      ),
      observedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['observedAt'],
      ),
      total: jsonSerialization['total'] as int?,
      availability: jsonSerialization['availability'] as String,
    );
  }

  String date;

  int streamGeneration;

  int revision;

  DateTime windowStart;

  DateTime windowEnd;

  DateTime observedAt;

  int? total;

  String availability;

  /// Returns a shallow copy of this [DailyStepInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DailyStepInput copyWith({
    String? date,
    int? streamGeneration,
    int? revision,
    DateTime? windowStart,
    DateTime? windowEnd,
    DateTime? observedAt,
    int? total,
    String? availability,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyStepInput',
      'date': date,
      'streamGeneration': streamGeneration,
      'revision': revision,
      'windowStart': windowStart.toJson(),
      'windowEnd': windowEnd.toJson(),
      'observedAt': observedAt.toJson(),
      if (total != null) 'total': total,
      'availability': availability,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyStepInput',
      'date': date,
      'streamGeneration': streamGeneration,
      'revision': revision,
      'windowStart': windowStart.toJson(),
      'windowEnd': windowEnd.toJson(),
      'observedAt': observedAt.toJson(),
      if (total != null) 'total': total,
      'availability': availability,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyStepInputImpl extends DailyStepInput {
  _DailyStepInputImpl({
    required String date,
    required int streamGeneration,
    required int revision,
    required DateTime windowStart,
    required DateTime windowEnd,
    required DateTime observedAt,
    int? total,
    required String availability,
  }) : super._(
         date: date,
         streamGeneration: streamGeneration,
         revision: revision,
         windowStart: windowStart,
         windowEnd: windowEnd,
         observedAt: observedAt,
         total: total,
         availability: availability,
       );

  /// Returns a shallow copy of this [DailyStepInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DailyStepInput copyWith({
    String? date,
    int? streamGeneration,
    int? revision,
    DateTime? windowStart,
    DateTime? windowEnd,
    DateTime? observedAt,
    Object? total = _Undefined,
    String? availability,
  }) {
    return DailyStepInput(
      date: date ?? this.date,
      streamGeneration: streamGeneration ?? this.streamGeneration,
      revision: revision ?? this.revision,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      observedAt: observedAt ?? this.observedAt,
      total: total is int? ? total : this.total,
      availability: availability ?? this.availability,
    );
  }
}
