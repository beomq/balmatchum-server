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
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'auth/external_identity.dart' as _i8thru7x;
import 'auth/login_attempt.dart' as _i1apu3f2;
import 'auth/login_challenge.dart' as _izhe0wsm;
import 'auth/login_exception.dart' as _iskwpc4e;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'records/gps_record.dart' as _ixays1el;
import 'records/gps_record_input.dart' as _ijl0tr6b;
import 'records/record_exception.dart' as _ihyrwhon;
import 'records/record_receipt.dart' as _ipyparvp;
import 'records/route_point.dart' as _ir7rvxr1;
import 'records/stored_gps_record.dart' as _iyylbrve;
export 'auth/external_identity.dart';
export 'auth/login_attempt.dart';
export 'auth/login_challenge.dart';
export 'auth/login_exception.dart';
export 'greetings/greeting.dart';
export 'records/gps_record.dart';
export 'records/gps_record_input.dart';
export 'records/record_exception.dart';
export 'records/record_receipt.dart';
export 'records/route_point.dart';
export 'records/stored_gps_record.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'external_identity',
      dartName: 'ExternalIdentity',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'provider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'issuer',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'audience',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subjectNamespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subject',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'external_identity_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'external_identity_provider_subject',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'provider',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'issuer',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'audience',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'subjectNamespace',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'subject',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'gps_record',
      dartName: 'StoredGpsRecord',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'clientRecordId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'persistedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'payload',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:GpsRecordInput',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'gps_record_owner_client_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'clientRecordId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'login_attempt',
      dartName: 'LoginAttempt',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'nonceHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'consumedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    ..._iacs.Protocol.targetTableDefinitions,
    ..._iais.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i8thru7x.ExternalIdentity) {
      return _i8thru7x.ExternalIdentity.fromJson(data) as T;
    }
    if (t == _i1apu3f2.LoginAttempt) {
      return _i1apu3f2.LoginAttempt.fromJson(data) as T;
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
    if (t == _iyylbrve.StoredGpsRecord) {
      return _iyylbrve.StoredGpsRecord.fromJson(data) as T;
    }
    if (t == _is.getType<_i8thru7x.ExternalIdentity?>()) {
      return (data != null ? _i8thru7x.ExternalIdentity.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i1apu3f2.LoginAttempt?>()) {
      return (data != null ? _i1apu3f2.LoginAttempt.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izhe0wsm.LoginChallenge?>()) {
      return (data != null ? _izhe0wsm.LoginChallenge.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iskwpc4e.LoginException?>()) {
      return (data != null ? _iskwpc4e.LoginException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ixays1el.GpsRecord?>()) {
      return (data != null ? _ixays1el.GpsRecord.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijl0tr6b.GpsRecordInput?>()) {
      return (data != null ? _ijl0tr6b.GpsRecordInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihyrwhon.RecordException?>()) {
      return (data != null ? _ihyrwhon.RecordException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipyparvp.RecordReceipt?>()) {
      return (data != null ? _ipyparvp.RecordReceipt.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir7rvxr1.RoutePoint?>()) {
      return (data != null ? _ir7rvxr1.RoutePoint.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyylbrve.StoredGpsRecord?>()) {
      return (data != null ? _iyylbrve.StoredGpsRecord.fromJson(data) : null)
          as T;
    }
    if (t == List<_ir7rvxr1.RoutePoint>) {
      return (data as List)
              .map((e) => deserialize<_ir7rvxr1.RoutePoint>(e))
              .toList()
          as T;
    }
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i8thru7x.ExternalIdentity => 'ExternalIdentity',
      _i1apu3f2.LoginAttempt => 'LoginAttempt',
      _izhe0wsm.LoginChallenge => 'LoginChallenge',
      _iskwpc4e.LoginException => 'LoginException',
      _izw8z7ou.Greeting => 'Greeting',
      _ixays1el.GpsRecord => 'GpsRecord',
      _ijl0tr6b.GpsRecordInput => 'GpsRecordInput',
      _ihyrwhon.RecordException => 'RecordException',
      _ipyparvp.RecordReceipt => 'RecordReceipt',
      _ir7rvxr1.RoutePoint => 'RoutePoint',
      _iyylbrve.StoredGpsRecord => 'StoredGpsRecord',
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
      case _i8thru7x.ExternalIdentity():
        return 'ExternalIdentity';
      case _i1apu3f2.LoginAttempt():
        return 'LoginAttempt';
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
      case _iyylbrve.StoredGpsRecord():
        return 'StoredGpsRecord';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ExternalIdentity') {
      return deserialize<_i8thru7x.ExternalIdentity>(data['data']);
    }
    if (dataClassName == 'LoginAttempt') {
      return deserialize<_i1apu3f2.LoginAttempt>(data['data']);
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
    if (dataClassName == 'StoredGpsRecord') {
      return deserialize<_iyylbrve.StoredGpsRecord>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacs.Protocol().registerHostProtocol('balmatchum', this);
    _iais.Protocol().registerHostProtocol('balmatchum', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i8thru7x.ExternalIdentity:
        return _i8thru7x.ExternalIdentity.t;
      case _i1apu3f2.LoginAttempt:
        return _i1apu3f2.LoginAttempt.t;
      case _iyylbrve.StoredGpsRecord:
        return _iyylbrve.StoredGpsRecord.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
