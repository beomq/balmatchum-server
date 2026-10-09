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
import 'package:balmatchum_server/src/generated/records/gps_record_input.dart'
    as _iax46414;
import 'package:serverpod/serverpod.dart' as _is;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../records/records_endpoint.dart' as _imwf5oma;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'records': _imwf5oma.RecordsEndpoint()
        ..initialize(
          server,
          'records',
          null,
        ),
    };
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['records'] = _is.EndpointConnector(
      name: 'records',
      endpoint: endpoints['records']!,
      methodConnectors: {
        'saveConfirmed': _is.MethodConnector(
          name: 'saveConfirmed',
          params: {
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_iax46414.GpsRecordInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['records'] as _imwf5oma.RecordsEndpoint)
                  .saveConfirmed(
                    session,
                    params['input'],
                  ),
        ),
        'getMine': _is.MethodConnector(
          name: 'getMine',
          params: {
            'recordId': _is.ParameterDescription(
              name: 'recordId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['records'] as _imwf5oma.RecordsEndpoint).getMine(
                    session,
                    params['recordId'],
                  ),
        ),
      },
    );
  }
}
