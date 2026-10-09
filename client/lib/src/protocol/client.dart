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
import 'dart:async' as _ida;
import 'package:balmatchum_client/src/protocol/greetings/greeting.dart'
    as _ipkbb44w;
import 'package:balmatchum_client/src/protocol/records/gps_record.dart'
    as _iy4m6z9c;
import 'package:balmatchum_client/src/protocol/records/gps_record_input.dart'
    as _i9inenda;
import 'package:balmatchum_client/src/protocol/records/record_receipt.dart'
    as _ixlh9bse;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_ipkbb44w.Greeting> hello(String name) =>
      caller.callServerEndpoint<_ipkbb44w.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// {@category Endpoint}
class EndpointRecords extends _isc.EndpointRef {
  EndpointRecords(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'records';

  _ida.Future<_ixlh9bse.RecordReceipt> saveConfirmed(
    _i9inenda.GpsRecordInput input,
  ) => caller.callServerEndpoint<_ixlh9bse.RecordReceipt>(
    'records',
    'saveConfirmed',
    {'input': input},
  );

  _ida.Future<_iy4m6z9c.GpsRecord> getMine(_isc.UuidValue recordId) =>
      caller.callServerEndpoint<_iy4m6z9c.GpsRecord>(
        'records',
        'getMine',
        {'recordId': recordId},
      );
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    greeting = EndpointGreeting(this);
    records = EndpointRecords(this);
  }

  late final EndpointGreeting greeting;

  late final EndpointRecords records;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'greeting': greeting,
    'records': records,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {};
}
