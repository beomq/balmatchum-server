import 'package:balmatchum_server/src/auth/naver_client.dart';
import 'package:test/test.dart';

void main() {
  const valid = {
    'naverClientId': 'test-naver-client',
    'naverClientSecret': 'public-test-secret',
    'naverRedirectUri': 'https://example.test/naver/callback',
  };
  test('missing provider is disabled', () {
    expect(NaverConfig.fromPasswords((_) => null), isNull);
  });
  test('complete configuration pins the callback', () {
    final config = NaverConfig.fromPasswords((key) => valid[key])!;
    expect(config.clientId, valid['naverClientId']);
    expect(config.redirectUri, valid['naverRedirectUri']);
  });
  for (final redirect in [
    'com.beomq.balmatchum.dev://naver/callback',
    'com.beomq.balmatchum://naver/callback',
  ]) {
    test('permits only the literal mobile callback $redirect', () {
      expect(
        NaverConfig.fromPasswords(
          (key) => key == 'naverRedirectUri' ? redirect : valid[key],
        )!.redirectUri,
        redirect,
      );
    });
  }
  for (final key in valid.keys) {
    for (final value in [null, '', ' ']) {
      test('rejects missing or empty $key value $value', () {
        final values = <String, String?>{...valid, key: value};
        expect(
          () => NaverConfig.fromPasswords((key) => values[key]),
          throwsStateError,
        );
      });
    }
  }
  for (final redirect in [
    'http://example.test/callback',
    'https:///callback',
    'https://user:secret@example.test/callback',
    'https://example.test/callback?next=evil',
    'https://example.test/callback#fragment',
    'https://example.test/callback?',
    'https://example.test/callback#',
    'javascript:alert(1)',
    'https://',
    '/callback',
    'com.beomq.balmatchum://evil/callback',
    'com.beomq.balmatchum.dev://naver/other',
    'com.beomq.balmatchum.dev://naver:123/callback',
    'com.beomq.balmatchum.dev://naver/callback/',
    'untrusted://naver/callback',
  ]) {
    test('rejects unsafe redirect $redirect', () {
      expect(
        () => NaverConfig.fromPasswords(
          (key) => key == 'naverRedirectUri' ? redirect : valid[key],
        ),
        throwsStateError,
      );
    });
  }
}
