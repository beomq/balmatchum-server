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

abstract class RecordReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RecordReceipt._({
    required this.clientRecordId,
    required this.recordId,
    required this.persistedAt,
    required this.schemaVersion,
  });

  factory RecordReceipt({
    required _isc.UuidValue clientRecordId,
    required _isc.UuidValue recordId,
    required DateTime persistedAt,
    required int schemaVersion,
  }) = _RecordReceiptImpl;

  factory RecordReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecordReceipt(
      clientRecordId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientRecordId'],
      ),
      recordId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['recordId'],
      ),
      persistedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['persistedAt'],
      ),
      schemaVersion: jsonSerialization['schemaVersion'] as int,
    );
  }

  _isc.UuidValue clientRecordId;

  _isc.UuidValue recordId;

  DateTime persistedAt;

  int schemaVersion;

  /// Returns a shallow copy of this [RecordReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RecordReceipt copyWith({
    _isc.UuidValue? clientRecordId,
    _isc.UuidValue? recordId,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _RecordReceiptImpl extends RecordReceipt {
  _RecordReceiptImpl({
    required _isc.UuidValue clientRecordId,
    required _isc.UuidValue recordId,
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
  @_isc.useResult
  @override
  RecordReceipt copyWith({
    _isc.UuidValue? clientRecordId,
    _isc.UuidValue? recordId,
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
