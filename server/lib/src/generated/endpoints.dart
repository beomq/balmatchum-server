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
import 'package:balmatchum_server/src/generated/product/daily_step_input.dart'
    as _if016xvg;
import 'package:balmatchum_server/src/generated/profile/profile_input.dart'
    as _ij17w8zz;
import 'package:balmatchum_server/src/generated/records/gps_record_input.dart'
    as _iax46414;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../account/account_endpoint.dart' as _it9bm8zx;
import '../ads/ads_endpoint.dart' as _ir7vocva;
import '../auth/apple_idp_endpoint.dart' as _ilq63su8;
import '../auth/google_idp_endpoint.dart' as _i71axiz0;
import '../auth/kakao_endpoint.dart' as _if7olpvl;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../product/product_endpoint.dart' as _itexbxyn;
import '../profile/profile_endpoint.dart' as _i6ky944g;
import '../records/records_endpoint.dart' as _imwf5oma;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'account': _it9bm8zx.AccountEndpoint()
        ..initialize(
          server,
          'account',
          null,
        ),
      'ads': _ir7vocva.AdsEndpoint()
        ..initialize(
          server,
          'ads',
          null,
        ),
      'appleIdp': _ilq63su8.AppleIdpEndpoint()
        ..initialize(
          server,
          'appleIdp',
          null,
        ),
      'googleIdp': _i71axiz0.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'kakao': _if7olpvl.KakaoEndpoint()
        ..initialize(
          server,
          'kakao',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'product': _itexbxyn.ProductEndpoint()
        ..initialize(
          server,
          'product',
          null,
        ),
      'profile': _i6ky944g.ProfileEndpoint()
        ..initialize(
          server,
          'profile',
          null,
        ),
      'records': _imwf5oma.RecordsEndpoint()
        ..initialize(
          server,
          'records',
          null,
        ),
    };
    connectors['account'] = _is.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'deleteAccount': _is.MethodConnector(
          name: 'deleteAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _it9bm8zx.AccountEndpoint)
                  .deleteAccount(session),
        ),
      },
    );
    connectors['ads'] = _is.EndpointConnector(
      name: 'ads',
      endpoint: endpoints['ads']!,
      methodConnectors: {
        'createIntent': _is.MethodConnector(
          name: 'createIntent',
          params: {
            'purpose': _is.ParameterDescription(
              name: 'purpose',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'targetDate': _is.ParameterDescription(
              name: 'targetDate',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'targetRevision': _is.ParameterDescription(
              name: 'targetRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['ads'] as _ir7vocva.AdsEndpoint).createIntent(
                    session,
                    params['purpose'],
                    params['targetDate'],
                    params['targetRevision'],
                  ),
        ),
        'getIntent': _is.MethodConnector(
          name: 'getIntent',
          params: {
            'intentId': _is.ParameterDescription(
              name: 'intentId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ads'] as _ir7vocva.AdsEndpoint).getIntent(
                session,
                params['intentId'],
              ),
        ),
      },
    );
    connectors['appleIdp'] = _is.EndpointConnector(
      name: 'appleIdp',
      endpoint: endpoints['appleIdp']!,
      methodConnectors: {
        'isConfigured': _is.MethodConnector(
          name: 'isConfigured',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appleIdp'] as _ilq63su8.AppleIdpEndpoint)
                  .isConfigured(session),
        ),
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'identityToken': _is.ParameterDescription(
              name: 'identityToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'authorizationCode': _is.ParameterDescription(
              name: 'authorizationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'isNativeApplePlatformSignIn': _is.ParameterDescription(
              name: 'isNativeApplePlatformSignIn',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'firstName': _is.ParameterDescription(
              name: 'firstName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'lastName': _is.ParameterDescription(
              name: 'lastName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['appleIdp'] as _ilq63su8.AppleIdpEndpoint).login(
                    session,
                    identityToken: params['identityToken'],
                    authorizationCode: params['authorizationCode'],
                    isNativeApplePlatformSignIn:
                        params['isNativeApplePlatformSignIn'],
                    firstName: params['firstName'],
                    lastName: params['lastName'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appleIdp'] as _ilq63su8.AppleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['googleIdp'] = _is.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'isConfigured': _is.MethodConnector(
          name: 'isConfigured',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i71axiz0.GoogleIdpEndpoint)
                  .isConfigured(session),
        ),
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'idToken': _is.ParameterDescription(
              name: 'idToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'accessToken': _is.ParameterDescription(
              name: 'accessToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _i71axiz0.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
        'loginWithCode': _is.MethodConnector(
          name: 'loginWithCode',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'codeVerifier': _is.ParameterDescription(
              name: 'codeVerifier',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'redirectUri': _is.ParameterDescription(
              name: 'redirectUri',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i71axiz0.GoogleIdpEndpoint)
                  .loginWithCode(
                    session,
                    code: params['code'],
                    codeVerifier: params['codeVerifier'],
                    redirectUri: params['redirectUri'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i71axiz0.GoogleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['kakao'] = _is.EndpointConnector(
      name: 'kakao',
      endpoint: endpoints['kakao']!,
      methodConnectors: {
        'beginLogin': _is.MethodConnector(
          name: 'beginLogin',
          params: {
            'provider': _is.ParameterDescription(
              name: 'provider',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['kakao'] as _if7olpvl.KakaoEndpoint).beginLogin(
                    session,
                    provider: params['provider'],
                  ),
        ),
        'loginKakao': _is.MethodConnector(
          name: 'loginKakao',
          params: {
            'attemptId': _is.ParameterDescription(
              name: 'attemptId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'idToken': _is.ParameterDescription(
              name: 'idToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['kakao'] as _if7olpvl.KakaoEndpoint).loginKakao(
                    session,
                    attemptId: params['attemptId'],
                    idToken: params['idToken'],
                  ),
        ),
      },
    );
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
    connectors['product'] = _is.EndpointConnector(
      name: 'product',
      endpoint: endpoints['product']!,
      methodConnectors: {
        'getDay': _is.MethodConnector(
          name: 'getDay',
          params: {
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _itexbxyn.ProductEndpoint).getDay(
                    session,
                    params['date'],
                  ),
        ),
        'listDays': _is.MethodConnector(
          name: 'listDays',
          params: {
            'fromDate': _is.ParameterDescription(
              name: 'fromDate',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'toDate': _is.ParameterDescription(
              name: 'toDate',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _itexbxyn.ProductEndpoint).listDays(
                    session,
                    params['fromDate'],
                    params['toDate'],
                  ),
        ),
        'getWallet': _is.MethodConnector(
          name: 'getWallet',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .getWallet(session),
        ),
        'registerStepStream': _is.MethodConnector(
          name: 'registerStepStream',
          params: {
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'expectedGeneration': _is.ParameterDescription(
              name: 'expectedGeneration',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .registerStepStream(
                    session,
                    params['requestId'],
                    params['expectedGeneration'],
                  ),
        ),
        'submitSteps': _is.MethodConnector(
          name: 'submitSteps',
          params: {
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_if016xvg.DailyStepInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .submitSteps(
                    session,
                    params['input'],
                  ),
        ),
        'deleteDay': _is.MethodConnector(
          name: 'deleteDay',
          params: {
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _itexbxyn.ProductEndpoint).deleteDay(
                    session,
                    params['date'],
                    params['requestId'],
                  ),
        ),
        'listDeletions': _is.MethodConnector(
          name: 'listDeletions',
          params: {
            'afterVersion': _is.ParameterDescription(
              name: 'afterVersion',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .listDeletions(
                    session,
                    params['afterVersion'],
                  ),
        ),
        'claimDay': _is.MethodConnector(
          name: 'claimDay',
          params: {
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'expectedRevision': _is.ParameterDescription(
              name: 'expectedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _itexbxyn.ProductEndpoint).claimDay(
                    session,
                    params['date'],
                    params['requestId'],
                    params['expectedRevision'],
                  ),
        ),
        'getQuiz': _is.MethodConnector(
          name: 'getQuiz',
          params: {
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['product'] as _itexbxyn.ProductEndpoint).getQuiz(
                    session,
                    params['date'],
                  ),
        ),
        'listQuizHistory': _is.MethodConnector(
          name: 'listQuizHistory',
          params: {
            'beforeDate': _is.ParameterDescription(
              name: 'beforeDate',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .listQuizHistory(
                    session,
                    params['beforeDate'],
                  ),
        ),
        'answerQuiz': _is.MethodConnector(
          name: 'answerQuiz',
          params: {
            'date': _is.ParameterDescription(
              name: 'date',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'answerIndex': _is.ParameterDescription(
              name: 'answerIndex',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .answerQuiz(
                    session,
                    params['date'],
                    params['answerIndex'],
                    params['requestId'],
                  ),
        ),
        'listThemes': _is.MethodConnector(
          name: 'listThemes',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .listThemes(session),
        ),
        'purchaseTheme': _is.MethodConnector(
          name: 'purchaseTheme',
          params: {
            'themeId': _is.ParameterDescription(
              name: 'themeId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .purchaseTheme(
                    session,
                    params['themeId'],
                    params['requestId'],
                  ),
        ),
        'equipTheme': _is.MethodConnector(
          name: 'equipTheme',
          params: {
            'themeId': _is.ParameterDescription(
              name: 'themeId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['product'] as _itexbxyn.ProductEndpoint)
                  .equipTheme(
                    session,
                    params['themeId'],
                    params['requestId'],
                  ),
        ),
      },
    );
    connectors['profile'] = _is.EndpointConnector(
      name: 'profile',
      endpoint: endpoints['profile']!,
      methodConnectors: {
        'getProfile': _is.MethodConnector(
          name: 'getProfile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i6ky944g.ProfileEndpoint)
                  .getProfile(session),
        ),
        'createProfile': _is.MethodConnector(
          name: 'createProfile',
          params: {
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_ij17w8zz.ProfileInput>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i6ky944g.ProfileEndpoint)
                  .createProfile(
                    session,
                    params['input'],
                    params['requestId'],
                  ),
        ),
        'renameDog': _is.MethodConnector(
          name: 'renameDog',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'expectedRevision': _is.ParameterDescription(
              name: 'expectedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['profile'] as _i6ky944g.ProfileEndpoint).renameDog(
                    session,
                    params['name'],
                    params['requestId'],
                    params['expectedRevision'],
                  ),
        ),
        'updateGoal': _is.MethodConnector(
          name: 'updateGoal',
          params: {
            'goal': _is.ParameterDescription(
              name: 'goal',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'requestId': _is.ParameterDescription(
              name: 'requestId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'expectedRevision': _is.ParameterDescription(
              name: 'expectedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i6ky944g.ProfileEndpoint)
                  .updateGoal(
                    session,
                    params['goal'],
                    params['requestId'],
                    params['expectedRevision'],
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
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
  }
}
