import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'naver_provider.dart';

class NaverEndpoint extends Endpoint {
  Future<bool> isConfigured(Session session) async =>
      naverSettings[session.serverpod] != null;

  Future<NaverLoginChallenge> beginLogin(
    Session session, {
    required String codeChallenge,
  }) => NaverProvider.require(session).beginLogin(
    session,
    codeChallenge: codeChallenge,
  );

  Future<AuthSuccess> completeLogin(
    Session session, {
    required UuidValue attemptId,
    required String code,
    required String state,
    required String codeVerifier,
  }) => NaverProvider.require(session).completeLogin(
    session,
    attemptId: attemptId,
    code: code,
    state: state,
    codeVerifier: codeVerifier,
  );
}
