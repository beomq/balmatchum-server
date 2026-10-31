import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import '../maintenance/schema_guard.dart';
import 'kakao_provider.dart';

class KakaoEndpoint extends Endpoint {
  Future<LoginChallenge> beginLogin(
    Session session, {
    required String provider,
  }) {
    SchemaGuard.requireLogin();
    return KakaoProvider.current.beginLogin(session, provider: provider);
  }

  Future<AuthSuccess> loginKakao(
    Session session, {
    required UuidValue attemptId,
    required String idToken,
  }) {
    SchemaGuard.requireLogin();
    return KakaoProvider.current.login(
      session,
      attemptId: attemptId,
      idToken: idToken,
    );
  }
}
