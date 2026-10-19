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
import 'package:balmatchum_client/src/protocol/ads/ad_intent.dart' as _ib30o6kc;
import 'package:balmatchum_client/src/protocol/auth/login_challenge.dart'
    as _iypdqt9k;
import 'package:balmatchum_client/src/protocol/greetings/greeting.dart'
    as _ipkbb44w;
import 'package:balmatchum_client/src/protocol/product/daily_quiz.dart'
    as _ig075m1r;
import 'package:balmatchum_client/src/protocol/product/daily_record.dart'
    as _i6924b5v;
import 'package:balmatchum_client/src/protocol/product/daily_step_input.dart'
    as _ijhmyv9t;
import 'package:balmatchum_client/src/protocol/product/reward_grant.dart'
    as _itb00fx7;
import 'package:balmatchum_client/src/protocol/product/theme_store.dart'
    as _i65j0qt2;
import 'package:balmatchum_client/src/protocol/product/wallet_view.dart'
    as _iurawp5p;
import 'package:balmatchum_client/src/protocol/profile/profile_input.dart'
    as _i6wqbm42;
import 'package:balmatchum_client/src/protocol/profile/profile_view.dart'
    as _i9lgbyro;
import 'package:balmatchum_client/src/protocol/records/gps_record.dart'
    as _iy4m6z9c;
import 'package:balmatchum_client/src/protocol/records/gps_record_input.dart'
    as _i9inenda;
import 'package:balmatchum_client/src/protocol/records/record_receipt.dart'
    as _ixlh9bse;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// {@category Endpoint}
class EndpointAccount extends _isc.EndpointRef {
  EndpointAccount(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'account';

  /// Deletes only the authenticated account and its locally stored data.
  _ida.Future<void> deleteAccount() => caller.callServerEndpoint<void>(
    'account',
    'deleteAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointAds extends _isc.EndpointRef {
  EndpointAds(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'ads';

  _ida.Future<_ib30o6kc.AdIntent> createIntent(
    String purpose,
    String targetDate,
    int targetRevision,
  ) => caller.callServerEndpoint<_ib30o6kc.AdIntent>(
    'ads',
    'createIntent',
    {
      'purpose': purpose,
      'targetDate': targetDate,
      'targetRevision': targetRevision,
    },
  );

  _ida.Future<_ib30o6kc.AdIntent> getIntent(String intentId) =>
      caller.callServerEndpoint<_ib30o6kc.AdIntent>(
        'ads',
        'getIntent',
        {'intentId': intentId},
      );
}

/// {@category Endpoint}
class EndpointAppleIdp extends _iaic.EndpointAppleIdpBase {
  EndpointAppleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'appleIdp';

  _ida.Future<bool> isConfigured() => caller.callServerEndpoint<bool>(
    'appleIdp',
    'isConfigured',
    {},
  );

  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String identityToken,
    required String authorizationCode,
    required bool isNativeApplePlatformSignIn,
    String? firstName,
    String? lastName,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'appleIdp',
    'login',
    {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
      'isNativeApplePlatformSignIn': isNativeApplePlatformSignIn,
      'firstName': firstName,
      'lastName': lastName,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'appleIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointGoogleIdp extends _iaic.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  _ida.Future<bool> isConfigured() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'isConfigured',
    {},
  );

  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  @override
  _ida.Future<_iacc.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {
      'code': code,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// {@category Endpoint}
class EndpointKakao extends _isc.EndpointRef {
  EndpointKakao(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'kakao';

  _ida.Future<_iypdqt9k.LoginChallenge> beginLogin({
    required String provider,
  }) => caller.callServerEndpoint<_iypdqt9k.LoginChallenge>(
    'kakao',
    'beginLogin',
    {'provider': provider},
  );

  _ida.Future<_iacc.AuthSuccess> loginKakao({
    required _isc.UuidValue attemptId,
    required String idToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'kakao',
    'loginKakao',
    {
      'attemptId': attemptId,
      'idToken': idToken,
    },
  );
}

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
class EndpointProduct extends _isc.EndpointRef {
  EndpointProduct(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'product';

  _ida.Future<_i6924b5v.DailyRecord> getDay(String date) =>
      caller.callServerEndpoint<_i6924b5v.DailyRecord>(
        'product',
        'getDay',
        {'date': date},
      );

  _ida.Future<List<_i6924b5v.DailyRecord>> listDays(
    String fromDate,
    String toDate,
  ) => caller.callServerEndpoint<List<_i6924b5v.DailyRecord>>(
    'product',
    'listDays',
    {
      'fromDate': fromDate,
      'toDate': toDate,
    },
  );

  _ida.Future<_iurawp5p.WalletView> getWallet() =>
      caller.callServerEndpoint<_iurawp5p.WalletView>(
        'product',
        'getWallet',
        {},
      );

  _ida.Future<int> registerStepStream(
    String requestId,
    int expectedGeneration,
  ) => caller.callServerEndpoint<int>(
    'product',
    'registerStepStream',
    {
      'requestId': requestId,
      'expectedGeneration': expectedGeneration,
    },
  );

  _ida.Future<_i6924b5v.DailyRecord> submitSteps(
    _ijhmyv9t.DailyStepInput input,
  ) => caller.callServerEndpoint<_i6924b5v.DailyRecord>(
    'product',
    'submitSteps',
    {'input': input},
  );

  _ida.Future<_i6924b5v.DailyRecord> deleteDay(
    String date,
    String requestId,
  ) => caller.callServerEndpoint<_i6924b5v.DailyRecord>(
    'product',
    'deleteDay',
    {
      'date': date,
      'requestId': requestId,
    },
  );

  _ida.Future<List<_i6924b5v.DailyRecord>> listDeletions(int afterVersion) =>
      caller.callServerEndpoint<List<_i6924b5v.DailyRecord>>(
        'product',
        'listDeletions',
        {'afterVersion': afterVersion},
      );

  _ida.Future<_itb00fx7.RewardGrant> claimDay(
    String date,
    String requestId,
    int expectedRevision,
  ) => caller.callServerEndpoint<_itb00fx7.RewardGrant>(
    'product',
    'claimDay',
    {
      'date': date,
      'requestId': requestId,
      'expectedRevision': expectedRevision,
    },
  );

  _ida.Future<_ig075m1r.DailyQuiz> getQuiz(String date) =>
      caller.callServerEndpoint<_ig075m1r.DailyQuiz>(
        'product',
        'getQuiz',
        {'date': date},
      );

  _ida.Future<List<_ig075m1r.DailyQuiz>> listQuizHistory(String beforeDate) =>
      caller.callServerEndpoint<List<_ig075m1r.DailyQuiz>>(
        'product',
        'listQuizHistory',
        {'beforeDate': beforeDate},
      );

  _ida.Future<_ig075m1r.DailyQuiz> answerQuiz(
    String date,
    int answerIndex,
    String requestId,
  ) => caller.callServerEndpoint<_ig075m1r.DailyQuiz>(
    'product',
    'answerQuiz',
    {
      'date': date,
      'answerIndex': answerIndex,
      'requestId': requestId,
    },
  );

  _ida.Future<_i65j0qt2.ThemeStore> listThemes() =>
      caller.callServerEndpoint<_i65j0qt2.ThemeStore>(
        'product',
        'listThemes',
        {},
      );

  _ida.Future<_i65j0qt2.ThemeStore> purchaseTheme(
    String themeId,
    String requestId,
  ) => caller.callServerEndpoint<_i65j0qt2.ThemeStore>(
    'product',
    'purchaseTheme',
    {
      'themeId': themeId,
      'requestId': requestId,
    },
  );

  _ida.Future<_i65j0qt2.ThemeStore> equipTheme(
    String themeId,
    String requestId,
  ) => caller.callServerEndpoint<_i65j0qt2.ThemeStore>(
    'product',
    'equipTheme',
    {
      'themeId': themeId,
      'requestId': requestId,
    },
  );
}

/// {@category Endpoint}
class EndpointProfile extends _isc.EndpointRef {
  EndpointProfile(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'profile';

  _ida.Future<_i9lgbyro.ProfileView?> getProfile() =>
      caller.callServerEndpoint<_i9lgbyro.ProfileView?>(
        'profile',
        'getProfile',
        {},
      );

  _ida.Future<_i9lgbyro.ProfileView> createProfile(
    _i6wqbm42.ProfileInput input,
    String requestId,
  ) => caller.callServerEndpoint<_i9lgbyro.ProfileView>(
    'profile',
    'createProfile',
    {
      'input': input,
      'requestId': requestId,
    },
  );

  _ida.Future<_i9lgbyro.ProfileView> renameDog(
    String name,
    String requestId,
    int expectedRevision,
  ) => caller.callServerEndpoint<_i9lgbyro.ProfileView>(
    'profile',
    'renameDog',
    {
      'name': name,
      'requestId': requestId,
      'expectedRevision': expectedRevision,
    },
  );

  _ida.Future<_i9lgbyro.ProfileView> updateGoal(
    int goal,
    String requestId,
    int expectedRevision,
  ) => caller.callServerEndpoint<_i9lgbyro.ProfileView>(
    'profile',
    'updateGoal',
    {
      'goal': goal,
      'requestId': requestId,
      'expectedRevision': expectedRevision,
    },
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

class Modules {
  Modules(Client client) {
    serverpod_auth_core = _iacc.Caller(client);
    serverpod_auth_idp = _iaic.Caller(client);
  }

  late final _iacc.Caller serverpod_auth_core;

  late final _iaic.Caller serverpod_auth_idp;
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
    account = EndpointAccount(this);
    ads = EndpointAds(this);
    appleIdp = EndpointAppleIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    kakao = EndpointKakao(this);
    greeting = EndpointGreeting(this);
    product = EndpointProduct(this);
    profile = EndpointProfile(this);
    records = EndpointRecords(this);
    modules = Modules(this);
  }

  late final EndpointAccount account;

  late final EndpointAds ads;

  late final EndpointAppleIdp appleIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointKakao kakao;

  late final EndpointGreeting greeting;

  late final EndpointProduct product;

  late final EndpointProfile profile;

  late final EndpointRecords records;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'account': account,
    'ads': ads,
    'appleIdp': appleIdp,
    'googleIdp': googleIdp,
    'kakao': kakao,
    'greeting': greeting,
    'product': product,
    'profile': profile,
    'records': records,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_core': modules.serverpod_auth_core,
    'serverpod_auth_idp': modules.serverpod_auth_idp,
  };
}
