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

abstract class RecordReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RecordReceipt._({
    required this.clientRecordId,
    required this.recordId,
    required this.persistedAt,
    required this.schemaVersion,
  });

  factory RecordReceipt({
    required _is.UuidValue clientRecordId,
    required _is.UuidValue recordId,
    required DateTime persistedAt,
    required int schemaVersion,
  }) = _RecordReceiptImpl;

  factory RecordReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecordReceipt(
      clientRecordId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientRecordId'],
      ),
      recordId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['recordId'],
      ),
      persistedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['persistedAt'],
      ),
      schemaVersion: jsonSerialization['schemaVersion'] as int,
    );
  }

  _is.UuidValue clientRecordId;

  _is.UuidValue recordId;

  DateTime persistedAt;

  int schemaVersion;

  /// Returns a shallow copy of this [RecordReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecordReceipt copyWith({
    _is.UuidValue? clientRecordId,
    _is.UuidValue? recordId,
    DateTime? persistedAt,
    int? schemaVersion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecordReceipt',
      'clientRecordId': clientRecordId.toJson(),
      'recordId': recordId.toJson(),
      'persistedAt': persistedAt.toJson(),
      'schemaVersion': schemaVersion,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecordReceipt',
      'clientRecordId': clientRecordId.toJson(),
      'recordId': recordId.toJson(),
      'persistedAt': persistedAt.toJson(),
      'schemaVersion': schemaVersion,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RecordReceiptImpl extends RecordReceipt {
  _RecordReceiptImpl({
    required _is.UuidValue clientRecordId,
    required _is.UuidValue recordId,
    required DateTime persistedAt,
    required int schemaVersion,
  }) : super._(
         clientRecordId: clientRecordId,
         recordId: recordId,
         persistedAt: persistedAt,
         schemaVersion: schemaVersion,
       );

  /// Returns a shallow copy of this [RecordReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecordReceipt copyWith({
    _is.UuidValue? clientRecordId,
    _is.UuidValue? recordId,
    DateTime? persistedAt,
    int? schemaVersion,
  }) {
    return RecordReceipt(
      clientRecordId: clientRecordId ?? this.clientRecordId,
      recordId: recordId ?? this.recordId,
      persistedAt: persistedAt ?? this.persistedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
