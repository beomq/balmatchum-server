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
import '../records/gps_record_input.dart' as _i7qho75c;
import '../records/record_receipt.dart' as _iiocqx4y;

abstract class GpsRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GpsRecord._({
    required this.receipt,
    required this.payload,
  });

  factory GpsRecord({
    required _iiocqx4y.RecordReceipt receipt,
    required _i7qho75c.GpsRecordInput payload,
  }) = _GpsRecordImpl;

  factory GpsRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return GpsRecord(
      receipt: _i5u3fx7i.Protocol().deserialize<_iiocqx4y.RecordReceipt>(
        jsonSerialization['receipt'],
      ),
      payload: _i5u3fx7i.Protocol().deserialize<_i7qho75c.GpsRecordInput>(
        jsonSerialization['payload'],
      ),
    );
  }

  _iiocqx4y.RecordReceipt receipt;

  _i7qho75c.GpsRecordInput payload;

  /// Returns a shallow copy of this [GpsRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GpsRecord copyWith({
    _iiocqx4y.RecordReceipt? receipt,
    _i7qho75c.GpsRecordInput? payload,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GpsRecord',
      'receipt': receipt.toJson(),
      'payload': payload.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GpsRecord',
      'receipt': receipt.toJsonForProtocol(),
      'payload': payload.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _GpsRecordImpl extends GpsRecord {
  _GpsRecordImpl({
    required _iiocqx4y.RecordReceipt receipt,
    required _i7qho75c.GpsRecordInput payload,
  }) : super._(
         receipt: receipt,
         payload: payload,
       );

  /// Returns a shallow copy of this [GpsRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GpsRecord copyWith({
    _iiocqx4y.RecordReceipt? receipt,
    _i7qho75c.GpsRecordInput? payload,
  }) {
    return GpsRecord(
      receipt: receipt ?? this.receipt.copyWith(),
      payload: payload ?? this.payload.copyWith(),
    );
  }
}
