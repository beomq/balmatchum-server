/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'auth/login_challenge.dart' as _izhe0wsm;
import 'auth/login_exception.dart' as _iskwpc4e;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'records/gps_record.dart' as _ixays1el;
import 'records/gps_record_input.dart' as _ijl0tr6b;
import 'records/record_exception.dart' as _ihyrwhon;
import 'records/record_receipt.dart' as _ipyparvp;
import 'records/route_point.dart' as _ir7rvxr1;
export 'auth/login_challenge.dart';
export 'auth/login_exception.dart';
export 'greetings/greeting.dart';
export 'records/gps_record.dart';
export 'records/gps_record_input.dart';
export 'records/record_exception.dart';
export 'records/record_receipt.dart';
export 'records/route_point.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _izhe0wsm.LoginChallenge) {
      return _izhe0wsm.LoginChallenge.fromJson(data) as T;
    }
    if (t == _iskwpc4e.LoginException) {
      return _iskwpc4e.LoginException.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ixays1el.GpsRecord) {
      return _ixays1el.GpsRecord.fromJson(data) as T;
    }
    if (t == _ijl0tr6b.GpsRecordInput) {
      return _ijl0tr6b.GpsRecordInput.fromJson(data) as T;
    }
    if (t == _ihyrwhon.RecordException) {
      return _ihyrwhon.RecordException.fromJson(data) as T;
    }
    if (t == _ipyparvp.RecordReceipt) {
      return _ipyparvp.RecordReceipt.fromJson(data) as T;
    }
    if (t == _ir7rvxr1.RoutePoint) {
      return _ir7rvxr1.RoutePoint.fromJson(data) as T;
    }
    if (t == _isc.getType<_izhe0wsm.LoginChallenge?>()) {
      return (data != null ? _izhe0wsm.LoginChallenge.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iskwpc4e.LoginException?>()) {
      return (data != null ? _iskwpc4e.LoginException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixays1el.GpsRecord?>()) {
      return (data != null ? _ixays1el.GpsRecord.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijl0tr6b.GpsRecordInput?>()) {
      return (data != null ? _ijl0tr6b.GpsRecordInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihyrwhon.RecordException?>()) {
      return (data != null ? _ihyrwhon.RecordException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ipyparvp.RecordReceipt?>()) {
      return (data != null ? _ipyparvp.RecordReceipt.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ir7rvxr1.RoutePoint?>()) {
      return (data != null ? _ir7rvxr1.RoutePoint.fromJson(data) : null) as T;
    }
    if (t == List<_ir7rvxr1.RoutePoint>) {
      return (data as List)
              .map((e) => deserialize<_ir7rvxr1.RoutePoint>(e))
              .toList()
          as T;
    }
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _izhe0wsm.LoginChallenge => 'LoginChallenge',
      _iskwpc4e.LoginException => 'LoginException',
      _izw8z7ou.Greeting => 'Greeting',
      _ixays1el.GpsRecord => 'GpsRecord',
      _ijl0tr6b.GpsRecordInput => 'GpsRecordInput',
      _ihyrwhon.RecordException => 'RecordException',
      _ipyparvp.RecordReceipt => 'RecordReceipt',
      _ir7rvxr1.RoutePoint => 'RoutePoint',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('balmatchum.', '');
    }

    switch (data) {
      case _izhe0wsm.LoginChallenge():
        return 'LoginChallenge';
      case _iskwpc4e.LoginException():
        return 'LoginException';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ixays1el.GpsRecord():
        return 'GpsRecord';
      case _ijl0tr6b.GpsRecordInput():
        return 'GpsRecordInput';
      case _ihyrwhon.RecordException():
        return 'RecordException';
      case _ipyparvp.RecordReceipt():
        return 'RecordReceipt';
      case _ir7rvxr1.RoutePoint():
        return 'RoutePoint';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'LoginChallenge') {
      return deserialize<_izhe0wsm.LoginChallenge>(data['data']);
    }
    if (dataClassName == 'LoginException') {
      return deserialize<_iskwpc4e.LoginException>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'GpsRecord') {
      return deserialize<_ixays1el.GpsRecord>(data['data']);
    }
    if (dataClassName == 'GpsRecordInput') {
      return deserialize<_ijl0tr6b.GpsRecordInput>(data['data']);
    }
    if (dataClassName == 'RecordException') {
      return deserialize<_ihyrwhon.RecordException>(data['data']);
    }
    if (dataClassName == 'RecordReceipt') {
      return deserialize<_ipyparvp.RecordReceipt>(data['data']);
    }
    if (dataClassName == 'RoutePoint') {
      return deserialize<_ir7rvxr1.RoutePoint>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacc.Protocol().registerHostProtocol('balmatchum', this);
    _iaic.Protocol().registerHostProtocol('balmatchum', this);
  }

  @override
  String getModuleName() => 'balmatchum';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
