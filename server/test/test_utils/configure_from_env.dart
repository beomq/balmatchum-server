import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/ads/ad_setup.dart';
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/auth/kakao_provider.dart';
import 'package:balmatchum_server/src/auth/naver_provider.dart';
import 'package:balmatchum_server/src/auth/social_auth.dart';
import 'package:balmatchum_server/src/billing/billing_service.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart';

/// Runs the production configuration entry points with passwords supplied
/// only through SERVERPOD_PASSWORD_* (as Serverpod Cloud does) and prints what
/// they parsed. Spawned by secret_whitespace_test.dart with public test values.
Future<void> main() async {
  final pod = Serverpod(['--mode=test']);
  configureAuth(pod);
  BillingService.configure(pod);
  final ads = await configureAdMob(pod);
  final kakao = KakaoProvider.current;
  final apple = socialAuthSettings[pod]?.apple;
  final naver = naverSettings[pod];
  final billing = BillingService.instances[pod]?.config;
  stdout.writeln(
    jsonEncode({
      'kakaoAudience': kakao.audience,
      'kakaoVerifier': kakao.verifier != null,
      'google': socialAuthSettings[pod]?.google != null,
      'appleServiceIdentifier': apple?.serviceIdentifier,
      'appleBundleIdentifier': apple?.bundleIdentifier,
      'appleRedirectUri': apple?.redirectUri,
      'naverClientId': naver?.clientId,
      'naverRedirectUri': naver?.redirectUri,
      'billingAppleBundleId': billing?.apple?.bundleId,
      'billingAppleEnvironment': billing?.apple?.environment.name,
      'billingGooglePackageName': billing?.google?.packageName,
      'billingGoogleEnvironment': billing?.google?.environment.name,
      'admobDailyIos': ads?.config.placements['dailyReward']?.units.ios,
    }),
  );
  exit(0);
}
