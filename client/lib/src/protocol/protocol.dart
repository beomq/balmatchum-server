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
import 'package:balmatchum_client/src/protocol/product/daily_quiz.dart'
    as _ig075m1r;
import 'package:balmatchum_client/src/protocol/product/daily_record.dart'
    as _i6924b5v;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'auth/login_challenge.dart' as _izhe0wsm;
import 'auth/login_exception.dart' as _iskwpc4e;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'product/daily_quiz.dart' as _i94q6xjz;
import 'product/daily_record.dart' as _ie37ihl8;
import 'product/daily_step_input.dart' as _i4z7ptb2;
import 'product/day_route.dart' as _i7moag3o;
import 'product/product_exception.dart' as _ixe21ogc;
import 'product/reward_grant.dart' as _iod7wzhm;
import 'product/theme_item.dart' as _i4gtfwun;
import 'product/theme_store.dart' as _iotuzcr6;
import 'product/wallet_view.dart' as _izf11uf3;
import 'records/gps_record.dart' as _ixays1el;
import 'records/gps_record_input.dart' as _ijl0tr6b;
import 'records/record_exception.dart' as _ihyrwhon;
import 'records/record_receipt.dart' as _ipyparvp;
import 'records/route_point.dart' as _ir7rvxr1;
export 'auth/login_challenge.dart';
export 'auth/login_exception.dart';
export 'greetings/greeting.dart';
export 'product/daily_quiz.dart';
export 'product/daily_record.dart';
export 'product/daily_step_input.dart';
export 'product/day_route.dart';
export 'product/product_exception.dart';
export 'product/reward_grant.dart';
export 'product/theme_item.dart';
export 'product/theme_store.dart';
export 'product/wallet_view.dart';
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
    if (t == _i94q6xjz.DailyQuiz) {
      return _i94q6xjz.DailyQuiz.fromJson(data) as T;
    }
    if (t == _ie37ihl8.DailyRecord) {
      return _ie37ihl8.DailyRecord.fromJson(data) as T;
    }
    if (t == _i4z7ptb2.DailyStepInput) {
      return _i4z7ptb2.DailyStepInput.fromJson(data) as T;
    }
    if (t == _i7moag3o.DayRoute) {
      return _i7moag3o.DayRoute.fromJson(data) as T;
    }
    if (t == _ixe21ogc.ProductException) {
      return _ixe21ogc.ProductException.fromJson(data) as T;
    }
    if (t == _iod7wzhm.RewardGrant) {
      return _iod7wzhm.RewardGrant.fromJson(data) as T;
    }
    if (t == _i4gtfwun.ThemeItem) {
      return _i4gtfwun.ThemeItem.fromJson(data) as T;
    }
    if (t == _iotuzcr6.ThemeStore) {
      return _iotuzcr6.ThemeStore.fromJson(data) as T;
    }
    if (t == _izf11uf3.WalletView) {
      return _izf11uf3.WalletView.fromJson(data) as T;
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
    if (t == _isc.getType<_i94q6xjz.DailyQuiz?>()) {
      return (data != null ? _i94q6xjz.DailyQuiz.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ie37ihl8.DailyRecord?>()) {
      return (data != null ? _ie37ihl8.DailyRecord.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4z7ptb2.DailyStepInput?>()) {
      return (data != null ? _i4z7ptb2.DailyStepInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i7moag3o.DayRoute?>()) {
      return (data != null ? _i7moag3o.DayRoute.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixe21ogc.ProductException?>()) {
      return (data != null ? _ixe21ogc.ProductException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iod7wzhm.RewardGrant?>()) {
      return (data != null ? _iod7wzhm.RewardGrant.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4gtfwun.ThemeItem?>()) {
      return (data != null ? _i4gtfwun.ThemeItem.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iotuzcr6.ThemeStore?>()) {
      return (data != null ? _iotuzcr6.ThemeStore.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izf11uf3.WalletView?>()) {
      return (data != null ? _izf11uf3.WalletView.fromJson(data) : null) as T;
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
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i7moag3o.DayRoute>) {
      return (data as List)
              .map((e) => deserialize<_i7moag3o.DayRoute>(e))
              .toList()
          as T;
    }
    if (t == List<_ir7rvxr1.RoutePoint>) {
      return (data as List)
              .map((e) => deserialize<_ir7rvxr1.RoutePoint>(e))
              .toList()
          as T;
    }
    if (t == List<_i4gtfwun.ThemeItem>) {
      return (data as List)
              .map((e) => deserialize<_i4gtfwun.ThemeItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i6924b5v.DailyRecord>) {
      return (data as List)
              .map((e) => deserialize<_i6924b5v.DailyRecord>(e))
              .toList()
          as T;
    }
    if (t == List<_ig075m1r.DailyQuiz>) {
      return (data as List)
              .map((e) => deserialize<_ig075m1r.DailyQuiz>(e))
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
      _i94q6xjz.DailyQuiz => 'DailyQuiz',
      _ie37ihl8.DailyRecord => 'DailyRecord',
      _i4z7ptb2.DailyStepInput => 'DailyStepInput',
      _i7moag3o.DayRoute => 'DayRoute',
      _ixe21ogc.ProductException => 'ProductException',
      _iod7wzhm.RewardGrant => 'RewardGrant',
      _i4gtfwun.ThemeItem => 'ThemeItem',
      _iotuzcr6.ThemeStore => 'ThemeStore',
      _izf11uf3.WalletView => 'WalletView',
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
      case _i94q6xjz.DailyQuiz():
        return 'DailyQuiz';
      case _ie37ihl8.DailyRecord():
        return 'DailyRecord';
      case _i4z7ptb2.DailyStepInput():
        return 'DailyStepInput';
      case _i7moag3o.DayRoute():
        return 'DayRoute';
      case _ixe21ogc.ProductException():
        return 'ProductException';
      case _iod7wzhm.RewardGrant():
        return 'RewardGrant';
      case _i4gtfwun.ThemeItem():
        return 'ThemeItem';
      case _iotuzcr6.ThemeStore():
        return 'ThemeStore';
      case _izf11uf3.WalletView():
        return 'WalletView';
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
    if (dataClassName == 'DailyQuiz') {
      return deserialize<_i94q6xjz.DailyQuiz>(data['data']);
    }
    if (dataClassName == 'DailyRecord') {
      return deserialize<_ie37ihl8.DailyRecord>(data['data']);
    }
    if (dataClassName == 'DailyStepInput') {
      return deserialize<_i4z7ptb2.DailyStepInput>(data['data']);
    }
    if (dataClassName == 'DayRoute') {
      return deserialize<_i7moag3o.DayRoute>(data['data']);
    }
    if (dataClassName == 'ProductException') {
      return deserialize<_ixe21ogc.ProductException>(data['data']);
    }
    if (dataClassName == 'RewardGrant') {
      return deserialize<_iod7wzhm.RewardGrant>(data['data']);
    }
    if (dataClassName == 'ThemeItem') {
      return deserialize<_i4gtfwun.ThemeItem>(data['data']);
    }
    if (dataClassName == 'ThemeStore') {
      return deserialize<_iotuzcr6.ThemeStore>(data['data']);
    }
    if (dataClassName == 'WalletView') {
      return deserialize<_izf11uf3.WalletView>(data['data']);
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
