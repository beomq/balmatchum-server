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

abstract class AdIntent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AdIntent._({
    required this.id,
    required this.purpose,
    required this.targetDate,
    required this.targetRevision,
    required this.adUnit,
    required this.userId,
    required this.customData,
    required this.status,
    required this.createdAt,
    required this.eventExpiresAt,
    required this.acceptUntil,
    this.verifiedAt,
    this.consumedAt,
  });

  factory AdIntent({
    required String id,
    required String purpose,
    required String targetDate,
    required int targetRevision,
    required String adUnit,
    required String userId,
    required String customData,
    required String status,
    required DateTime createdAt,
    required DateTime eventExpiresAt,
    required DateTime acceptUntil,
    DateTime? verifiedAt,
    DateTime? consumedAt,
  }) = _AdIntentImpl;

  factory AdIntent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdIntent(
      id: jsonSerialization['id'] as String,
      purpose: jsonSerialization['purpose'] as String,
      targetDate: jsonSerialization['targetDate'] as String,
      targetRevision: jsonSerialization['targetRevision'] as int,
      adUnit: jsonSerialization['adUnit'] as String,
      userId: jsonSerialization['userId'] as String,
      customData: jsonSerialization['customData'] as String,
      status: jsonSerialization['status'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      eventExpiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['eventExpiresAt'],
      ),
      acceptUntil: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['acceptUntil'],
      ),
      verifiedAt: jsonSerialization['verifiedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['verifiedAt']),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
    );
  }

  String id;

  String purpose;

  String targetDate;

  int targetRevision;

  String adUnit;

  String userId;

  String customData;

  String status;

  DateTime createdAt;

  DateTime eventExpiresAt;

  DateTime acceptUntil;

  DateTime? verifiedAt;

  DateTime? consumedAt;

  /// Returns a shallow copy of this [AdIntent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AdIntent copyWith({
    String? id,
    String? purpose,
    String? targetDate,
    int? targetRevision,
    String? adUnit,
    String? userId,
    String? customData,
    String? status,
    DateTime? createdAt,
    DateTime? eventExpiresAt,
    DateTime? acceptUntil,
    DateTime? verifiedAt,
    DateTime? consumedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdIntent',
      'id': id,
      'purpose': purpose,
      'targetDate': targetDate,
      'targetRevision': targetRevision,
      'adUnit': adUnit,
      'userId': userId,
      'customData': customData,
      'status': status,
      'createdAt': createdAt.toJson(),
      'eventExpiresAt': eventExpiresAt.toJson(),
      'acceptUntil': acceptUntil.toJson(),
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdIntent',
      'id': id,
      'purpose': purpose,
      'targetDate': targetDate,
      'targetRevision': targetRevision,
      'adUnit': adUnit,
      'userId': userId,
      'customData': customData,
      'status': status,
      'createdAt': createdAt.toJson(),
      'eventExpiresAt': eventExpiresAt.toJson(),
      'acceptUntil': acceptUntil.toJson(),
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdIntentImpl extends AdIntent {
  _AdIntentImpl({
    required String id,
    required String purpose,
    required String targetDate,
    required int targetRevision,
    required String adUnit,
    required String userId,
    required String customData,
    required String status,
    required DateTime createdAt,
    required DateTime eventExpiresAt,
    required DateTime acceptUntil,
    DateTime? verifiedAt,
    DateTime? consumedAt,
  }) : super._(
         id: id,
         purpose: purpose,
         targetDate: targetDate,
         targetRevision: targetRevision,
         adUnit: adUnit,
         userId: userId,
         customData: customData,
         status: status,
         createdAt: createdAt,
         eventExpiresAt: eventExpiresAt,
         acceptUntil: acceptUntil,
         verifiedAt: verifiedAt,
         consumedAt: consumedAt,
       );

  /// Returns a shallow copy of this [AdIntent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AdIntent copyWith({
    String? id,
    String? purpose,
    String? targetDate,
    int? targetRevision,
    String? adUnit,
    String? userId,
    String? customData,
    String? status,
    DateTime? createdAt,
    DateTime? eventExpiresAt,
    DateTime? acceptUntil,
    Object? verifiedAt = _Undefined,
    Object? consumedAt = _Undefined,
  }) {
    return AdIntent(
      id: id ?? this.id,
      purpose: purpose ?? this.purpose,
      targetDate: targetDate ?? this.targetDate,
      targetRevision: targetRevision ?? this.targetRevision,
      adUnit: adUnit ?? this.adUnit,
      userId: userId ?? this.userId,
      customData: customData ?? this.customData,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      eventExpiresAt: eventExpiresAt ?? this.eventExpiresAt,
      acceptUntil: acceptUntil ?? this.acceptUntil,
      verifiedAt: verifiedAt is DateTime? ? verifiedAt : this.verifiedAt,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
    );
  }
}
