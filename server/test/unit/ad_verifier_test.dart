import 'dart:async';
import 'package:balmatchum_server/src/ads/ad_verifier.dart';
import 'package:balmatchum_server/src/ads/ad_config.dart';
import 'package:clock/clock.dart';
import 'package:test/test.dart';
import '../test_utils/ad_test_keys.dart';

void main() {
  final raw =
      'ad_network=123&ad_unit=unit&custom_data=${'n' * 43}'
      '&reward_amount=7&reward_item=a%2fb%20%63&timestamp=1792368000000'
      '&transaction_id=abcdef&user_id=owner';
  test(
    'ECDSA DER authenticates exact encoded bytes, not decoded/re-encoded values',
    () async {
      final v = AdVerifier(loadKeys: () async => adKeys());
      final signed = signAd(raw);
      expect((await v.verify(signed)).rewardItem, 'a/b c');
      for (final modified in [
        signed.replaceFirst('%2f', '%2F'),
        signed.replaceFirst('%63', 'c'),
        signed.replaceFirst('reward_amount=7', 'reward_amount=9'),
        '$signed&extra=1',
        signed.replaceFirst('&key_id=1', '&key_id=2'),
        signAd('$raw&user_id=other'),
      ]) {
        await expectLater(v.verify(modified), throwsFormatException);
      }
    },
  );
  test(
    'cache refresh coalesces and never uses keys past TTL after failure',
    () async {
      var now = DateTime.utc(2026, 10, 19);
      var calls = 0;
      var fail = false;
      final loaded = Completer<void>();
      final release = Completer<void>();
      final v = AdVerifier(
        clock: Clock(() => now),
        loadKeys: () async {
          calls++;
          if (calls == 1) {
            loaded.complete();
            await release.future;
          }
          if (fail) throw StateError('offline');
          return adKeys();
        },
      );
      final first = v.verify(signAd(raw));
      await loaded.future.timeout(const Duration(seconds: 5));
      final second = v.verify(signAd(raw));
      release.complete();
      await Future.wait([first, second]);
      expect(calls, 1);
      now = now.add(const Duration(hours: 22));
      await v.verify(signAd(raw));
      expect(calls, 1);
      now = now.add(const Duration(hours: 1));
      fail = true;
      await expectLater(
        v.verify(signAd(raw)),
        throwsA(isA<AdKeysUnavailable>()),
      );
      expect(calls, 2);
    },
  );
  test('known ID with wrong actual EC key fails cryptographically', () async {
    final verifier = AdVerifier(
      loadKeys: () async => {
        'keys': [
          {'keyId': 1, 'pem': wrongAdPublicPem},
        ],
      },
    );
    await expectLater(verifier.verify(signAd(raw)), throwsFormatException);
  });
  test(
    'unknown key refresh rotates and failed synchronous fetch can recover',
    () async {
      var calls = 0;
      var offline = true;
      final v = AdVerifier(
        loadKeys: () {
          calls++;
          if (offline) throw StateError('offline');
          return Future.value({
            'keys': [
              {'keyId': 1, 'pem': adPublicPem},
              if (calls >= 3) {'keyId': 2, 'pem': adPublicPem},
            ],
          });
        },
      );
      await expectLater(
        v.verify(signAd(raw)),
        throwsA(isA<AdKeysUnavailable>()),
      );
      offline = false;
      await v.verify(signAd(raw));
      await v.verify(signAd(raw, keyId: 2));
      expect(calls, 3);
    },
  );
  test('disabled and partial config fail closed without guessed metadata', () {
    expect(AdConfig.fromPasswords((_) => null), isNull);
    expect(
      () => AdConfig.fromPasswords((k) => k == 'admobPlacements' ? '{}' : null),
      throwsStateError,
    );
  });
}
