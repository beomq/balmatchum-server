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
import '../quiz/quiz_question.dart' as _idjigf1h;

abstract class QuizToday
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  QuizToday._({
    required this.date,
    required this.status,
    this.free,
    this.extra,
    required this.extraStatus,
    this.extraRevision,
    bool? paidEntitlement,
    String? premiumStatus,
  }) : paidEntitlement = paidEntitlement ?? false,
       premiumStatus = premiumStatus ?? 'notChecked';

  factory QuizToday({
    required String date,
    required String status,
    _idjigf1h.QuizQuestion? free,
    _idjigf1h.QuizQuestion? extra,
    required String extraStatus,
    int? extraRevision,
    bool? paidEntitlement,
    String? premiumStatus,
  }) = _QuizTodayImpl;

  factory QuizToday.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuizToday(
      date: jsonSerialization['date'] as String,
      status: jsonSerialization['status'] as String,
      free: jsonSerialization['free'] == null
          ? null
          : _i5u3fx7i.Protocol().deserialize<_idjigf1h.QuizQuestion>(
              jsonSerialization['free'],
            ),
      extra: jsonSerialization['extra'] == null
          ? null
          : _i5u3fx7i.Protocol().deserialize<_idjigf1h.QuizQuestion>(
              jsonSerialization['extra'],
            ),
      extraStatus: jsonSerialization['extraStatus'] as String,
      extraRevision: jsonSerialization['extraRevision'] as int?,
      paidEntitlement: jsonSerialization['paidEntitlement'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['paidEntitlement'],
            ),
      premiumStatus: jsonSerialization['premiumStatus'] as String?,
    );
  }

  String date;

  String status;

  _idjigf1h.QuizQuestion? free;

  _idjigf1h.QuizQuestion? extra;

  String extraStatus;

  int? extraRevision;

  bool paidEntitlement;

  String premiumStatus;

  /// Returns a shallow copy of this [QuizToday]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  QuizToday copyWith({
    String? date,
    String? status,
    _idjigf1h.QuizQuestion? free,
    _idjigf1h.QuizQuestion? extra,
    String? extraStatus,
    int? extraRevision,
    bool? paidEntitlement,
    String? premiumStatus,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuizToday',
      'date': date,
      'status': status,
      if (free != null) 'free': free?.toJson(),
      if (extra != null) 'extra': extra?.toJson(),
      'extraStatus': extraStatus,
      if (extraRevision != null) 'extraRevision': extraRevision,
      'paidEntitlement': paidEntitlement,
      'premiumStatus': premiumStatus,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'QuizToday',
      'date': date,
      'status': status,
      if (free != null) 'free': free?.toJsonForProtocol(),
      if (extra != null) 'extra': extra?.toJsonForProtocol(),
      'extraStatus': extraStatus,
      if (extraRevision != null) 'extraRevision': extraRevision,
      'paidEntitlement': paidEntitlement,
      'premiumStatus': premiumStatus,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuizTodayImpl extends QuizToday {
  _QuizTodayImpl({
    required String date,
    required String status,
    _idjigf1h.QuizQuestion? free,
    _idjigf1h.QuizQuestion? extra,
    required String extraStatus,
    int? extraRevision,
    bool? paidEntitlement,
    String? premiumStatus,
  }) : super._(
         date: date,
         status: status,
         free: free,
         extra: extra,
         extraStatus: extraStatus,
         extraRevision: extraRevision,
         paidEntitlement: paidEntitlement,
         premiumStatus: premiumStatus,
       );

  /// Returns a shallow copy of this [QuizToday]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  QuizToday copyWith({
    String? date,
    String? status,
    Object? free = _Undefined,
    Object? extra = _Undefined,
    String? extraStatus,
    Object? extraRevision = _Undefined,
    bool? paidEntitlement,
    String? premiumStatus,
  }) {
    return QuizToday(
      date: date ?? this.date,
      status: status ?? this.status,
      free: free is _idjigf1h.QuizQuestion? ? free : this.free?.copyWith(),
      extra: extra is _idjigf1h.QuizQuestion? ? extra : this.extra?.copyWith(),
      extraStatus: extraStatus ?? this.extraStatus,
      extraRevision: extraRevision is int? ? extraRevision : this.extraRevision,
      paidEntitlement: paidEntitlement ?? this.paidEntitlement,
      premiumStatus: premiumStatus ?? this.premiumStatus,
    );
  }
}
