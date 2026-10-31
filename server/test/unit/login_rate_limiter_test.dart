import 'package:balmatchum_server/src/auth/login_rate_limiter.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:clock/clock.dart';
import 'package:test/test.dart';

final _tooMany = throwsA(
  isA<LoginException>().having((e) => e.code, 'code', 'tooManyAttempts'),
);

void main() {
  late DateTime now;
  late LoginRateLimiter limiter;

  setUp(() {
    now = DateTime.utc(2026, 10, 31);
    limiter = LoginRateLimiter(clock: Clock(() => now));
  });

  test('same key allows 30 starts and rejects the 31st', () {
    for (var i = 0; i < loginRatePerKeyLimit; i++) {
      limiter.checkKey('203.0.113.7');
    }
    expect(() => limiter.checkKey('203.0.113.7'), _tooMany);
    // A different key still has its own budget.
    limiter.checkKey('203.0.113.8');
  });

  test('window slides: allowed again once 60 seconds have passed', () {
    for (var i = 0; i < loginRatePerKeyLimit; i++) {
      limiter.checkKey('203.0.113.7');
    }
    now = now.add(loginRateWindow - const Duration(milliseconds: 1));
    expect(() => limiter.checkKey('203.0.113.7'), _tooMany);
    now = now.add(const Duration(milliseconds: 1));
    limiter.checkKey('203.0.113.7');
  });

  test('missing header uses only the global limit', () {
    expect(LoginRateLimiter.keyFor(null), loginRateGlobalKey);
    expect(LoginRateLimiter.keyFor({}), loginRateGlobalKey);
    for (var i = 0; i < loginRateGlobalLimit; i++) {
      limiter.checkKey(loginRateGlobalKey);
    }
    expect(() => limiter.checkKey(loginRateGlobalKey), _tooMany);
    expect(limiter.trackedKeys, 0);
  });

  test('global limit applies across keys', () {
    for (var i = 0; i < loginRateGlobalLimit; i++) {
      limiter.checkKey('198.51.100.${i % 100}');
    }
    expect(() => limiter.checkKey('203.0.113.99'), _tooMany);
  });

  test('key is the rightmost X-Forwarded-For entry', () {
    expect(
      LoginRateLimiter.keyFor({
        'x-forwarded-for': ['10.0.0.1, 10.0.0.2, 203.0.113.7'],
      }),
      '203.0.113.7',
    );
    expect(
      LoginRateLimiter.keyFor({
        'x-forwarded-for': ['10.0.0.1', '2001:db8::1'],
      }),
      '2001:db8::1',
    );
  });

  test('malformed X-Forwarded-For falls back to global and never throws', () {
    for (final value in [
      '',
      ' ',
      ',',
      '203.0.113.7,',
      '203.0.113.7, ',
      '203.0.113.7, garbage',
      'a, b, c',
      '999.1.1.1',
      '\u0000',
    ]) {
      expect(
        LoginRateLimiter.keyFor({
          'x-forwarded-for': [value],
        }),
        loginRateGlobalKey,
        reason: 'value ${value.codeUnits}',
      );
    }
    expect(
      LoginRateLimiter.keyFor({'x-forwarded-for': <String>[]}),
      loginRateGlobalKey,
    );
  });

  test('tracked keys stay bounded', () {
    final limiter = LoginRateLimiter(
      clock: Clock(() => now),
      globalLimit: loginRateMaxKeys * 2,
    );
    for (var i = 0; i < loginRateMaxKeys + 5; i++) {
      limiter.checkKey('key-$i');
    }
    expect(limiter.trackedKeys, lessThanOrEqualTo(loginRateMaxKeys));
    // Expired keys are dropped before live ones.
    now = now.add(loginRateWindow);
    limiter.checkKey('fresh');
    expect(limiter.trackedKeys, lessThanOrEqualTo(loginRateMaxKeys));
  });
}
