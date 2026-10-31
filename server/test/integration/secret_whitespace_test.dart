@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../test_utils/social_test_config.dart';
import '../unit/billing/billing_fixture.dart' as billing;

/// Public disposable values. Files uploaded with `password set --from-file`
/// usually end with a newline that both the CLI and Serverpod keep verbatim.
final _clean = {
  'serverSideSessionKeyHashPepper': 'public-whitespace-test-only',
  'kakaoAudience': 'test-native-key',
  'kakaoIssuer': 'https://kauth.kakao.com',
  'naverClientId': 'test-naver-client',
  'naverClientSecret': 'public-naver-secret',
  'naverRedirectUri': 'https://example.test/naver/callback',
  ...socialTestPasswords(),
  'billingIdentityHmacKey': base64Encode(List.filled(32, 7)),
  ...billing.passwords(),
  'admobPlacements': jsonEncode({
    'dailyReward': {
      'adUnits': {
        'ios': 'ca-app-pub-1234567890123456/1111111111',
        'android': 'ca-app-pub-1234567890123456/2222222222',
      },
      'rewardItem': 'point',
      'rewardAmount': '1',
    },
  }),
};

Future<Map<String, dynamic>> _configure(
  Map<String, String> passwords,
  String kernelPath,
) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    [kernelPath],
    environment: {
      'SERVERPOD_PASSWORD_database': 'local-disposable-test-only',
      for (final MapEntry(:key, :value) in passwords.entries)
        'SERVERPOD_PASSWORD_$key': value,
    },
  );
  // Only public test values are configured, so stderr is safe to show.
  expect(result.exitCode, 0, reason: result.stderr as String);
  return jsonDecode(LineSplitter.split(result.stdout as String).last)
      as Map<String, dynamic>;
}

void main() {
  late String kernelPath;

  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp(
      'secret-whitespace-',
    );
    addTearDown(() => directory.delete(recursive: true));
    kernelPath = '${directory.path}/configure.dill';
    // This configuration-only probe never loads native libraries. Compile once
    // into a unique directory: concurrent `dart run` calls otherwise rewrite
    // the same .dart_tool/lib assets while otool/codesign are reading them.
    final result = await Process.run(Platform.resolvedExecutable, [
      'compile',
      'kernel',
      'test/test_utils/configure_from_env.dart',
      '-o',
      kernelPath,
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  test(
    'secrets ending in a newline configure exactly like clean values',
    () async {
      // Given identical passwords except for the uploaded file's final newline.
      // When separate processes read the real SERVERPOD_PASSWORD_* environment.
      final [clean, newline] = await Future.wait([
        _configure(_clean, kernelPath),
        _configure(
          _clean.map((key, value) => MapEntry(key, '$value\n')),
          kernelPath,
        ),
      ]);
      // Then both processes configure the expected providers and identifiers.
      expect(clean, {
        'kakaoAudience': 'test-native-key',
        'kakaoVerifier': true,
        'google': true,
        'appleServiceIdentifier': 'test.apple.service',
        'appleBundleIdentifier': 'test.apple.bundle',
        'appleRedirectUri': 'https://example.test/apple/callback',
        'naverClientId': 'test-naver-client',
        'naverRedirectUri': 'https://example.test/naver/callback',
        'billingAppleBundleId': 'test.app',
        'billingAppleEnvironment': 'sandbox',
        'billingGooglePackageName': 'test.app',
        'billingGoogleEnvironment': 'sandbox',
        'admobDailyIos': 'ca-app-pub-1234567890123456/1111111111',
      });
      expect(newline, clean);
    },
  );
}
