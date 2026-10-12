import 'dart:convert';

import 'package:balmatchum_server/src/auth/kakao_token_verifier.dart';
import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:test/test.dart';

import '../test_utils/kakao_test_keys.dart';

void main() {
  final now = DateTime.utc(2026, 10, 12);
  final seconds = now.millisecondsSinceEpoch ~/ 1000;
  final nonceHash = sha256.convert(utf8.encode('test-nonce')).toString();
  late Map<String, dynamic> claims;
  late Map<String, dynamic> jwks;
  late KakaoTokenVerifier verifier;

  setUp(() {
    claims = {
      'iss': 'https://kauth.kakao.com',
      'aud': 'native-app-key',
      'sub': '12345678901234567890',
      'iat': seconds - 30,
      'exp': seconds + 300,
      'nonce': 'test-nonce',
    };
    jwks = KakaoTestKeys.jwks();
    verifier = KakaoTokenVerifier(
      audience: 'native-app-key',
      loadJwks: () async => jwks,
      clock: Clock.fixed(now),
    );
  });

  Future<String> verify({Map<String, dynamic>? header}) => verifier.verify(
    KakaoTestKeys.sign(claims, header: header),
    nonceHash: nonceHash,
  );

  test('returns verified subject without numeric conversion', () async {
    expect(await verify(), claims['sub']);
  });

  test('accepts a singleton audience list without azp', () async {
    claims['aud'] = ['native-app-key'];
    expect(await verify(), claims['sub']);
  });

  test('accepts multiple audiences only with matching azp', () async {
    claims['aud'] = ['another-client', 'native-app-key'];
    claims['azp'] = 'native-app-key';
    expect(await verify(), claims['sub']);
  });

  final invalidClaims = <String, Map<String, dynamic>>{
    'issuer': {'iss': 'https://attacker.example'},
    'missing issuer': {'iss': null},
    'audience': {'aud': 'other-key'},
    'missing audience': {'aud': null},
    'empty audience list': {'aud': <String>[]},
    'non-string audience member': {
      'aud': ['native-app-key', 42],
    },
    'multi audience missing azp': {
      'aud': ['native-app-key', 'other'],
    },
    'multi audience wrong azp': {
      'aud': ['native-app-key', 'other'],
      'azp': 'other',
    },
    'single audience wrong azp': {'azp': 'other'},
    'expiration boundary': {'exp': seconds},
    'expired': {'exp': seconds - 1},
    'missing expiration': {'exp': null},
    'string expiration': {'exp': '$seconds'},
    'missing issued at': {'iat': null},
    'future issued at': {'iat': seconds + 1},
    'string issued at': {'iat': '$seconds'},
    'issued at expiration': {'iat': seconds + 300},
    'future not before': {'nbf': seconds + 1},
    'invalid not before': {'nbf': 'soon'},
    'nonce mismatch': {'nonce': 'another-nonce'},
    'empty nonce': {'nonce': ''},
    'missing nonce': {'nonce': null},
    'numeric nonce': {'nonce': 42},
    'empty subject': {'sub': ''},
    'blank subject': {'sub': ' '},
    'missing subject': {'sub': null},
    'numeric subject': {'sub': 42},
  };
  for (final entry in invalidClaims.entries) {
    test('rejects ${entry.key}', () async {
      claims.addAll(entry.value);
      await expectLater(verify(), throwsFormatException);
    });
  }

  test('uses injected clock at expiration boundary', () async {
    verifier = KakaoTokenVerifier(
      audience: 'native-app-key',
      loadJwks: () async => jwks,
      clock: Clock.fixed(now.add(const Duration(seconds: 300))),
    );
    await expectLater(verify(), throwsFormatException);
  });

  test('accepts issued-at and not-before equal to current time', () async {
    claims['iat'] = seconds;
    claims['nbf'] = seconds;
    expect(await verify(), claims['sub']);
  });

  for (final alg in ['none', 'HS256', 'RS384', 'RS512']) {
    test('rejects algorithm header $alg', () async {
      await expectLater(verify(header: {'alg': alg}), throwsFormatException);
    });
  }

  test('rejects actual HMAC token with matching kid', () async {
    final token = KakaoTestKeys.sign(
      claims,
      algorithm: JWTAlgorithm.HS256,
      key: SecretKey('public-key-is-not-a-secret'),
    );
    await expectLater(
      verifier.verify(token, nonceHash: nonceHash),
      throwsFormatException,
    );
  });

  for (final kid in [null, '', ' ', 'unknown', 42]) {
    test('rejects invalid kid $kid', () async {
      await expectLater(verify(header: {'kid': kid}), throwsFormatException);
    });
  }

  test('rejects unsupported critical headers', () async {
    await expectLater(
      verify(
        header: {
          'crit': ['custom'],
          'custom': true,
        },
      ),
      throwsFormatException,
    );
  });

  final invalidKeys = <String, Map<String, dynamic>>{
    'non-RSA key': {'kty': 'EC'},
    'encryption key': {'use': 'enc'},
    'wrong key algorithm': {'alg': 'RS512'},
    'sign-only key': {
      'key_ops': ['sign'],
    },
    'invalid key operations': {'key_ops': 'verify'},
    'missing modulus': {'n': null},
    'malformed exponent': {'e': '*'},
  };
  for (final entry in invalidKeys.entries) {
    test('rejects ${entry.key}', () async {
      (jwks['keys'] as List).single.addAll(entry.value);
      await expectLater(verify(), throwsFormatException);
    });
  }

  test('accepts optional JWK metadata and verify operation', () async {
    final key = (jwks['keys'] as List).single as Map<String, dynamic>;
    key.remove('alg');
    key.remove('use');
    key['key_ops'] = ['verify'];
    expect(await verify(), claims['sub']);
  });

  test('rejects duplicate matching keys', () async {
    final keys = jwks['keys'] as List;
    keys.add(Map<String, dynamic>.from(keys.single as Map));
    await expectLater(verify(), throwsFormatException);
  });

  for (final keys in [null, 'invalid', <dynamic>[]]) {
    test('rejects invalid or empty JWKS $keys', () async {
      jwks['keys'] = keys;
      await expectLater(verify(), throwsFormatException);
    });
  }

  test('rejects tampered signed payload', () async {
    final parts = KakaoTestKeys.sign(claims).split('.');
    claims['sub'] = 'attacker';
    parts[1] = base64Url
        .encode(utf8.encode(jsonEncode(claims)))
        .replaceAll('=', '');
    await expectLater(
      verifier.verify(parts.join('.'), nonceHash: nonceHash),
      throwsFormatException,
    );
  });

  test('rejects damaged signature', () async {
    final parts = KakaoTestKeys.sign(claims).split('.');
    parts[2] =
        '${parts[2].startsWith('A') ? 'B' : 'A'}${parts[2].substring(1)}';
    await expectLater(
      verifier.verify(parts.join('.'), nonceHash: nonceHash),
      throwsFormatException,
    );
  });

  for (final token in ['', 'one.two', 'one.two.three.four', '..', '*.e30.AA']) {
    test('rejects malformed compact token $token', () async {
      await expectLater(
        verifier.verify(token, nonceHash: nonceHash),
        throwsFormatException,
      );
    });
  }

  test('rejects empty configured audience', () async {
    verifier = KakaoTokenVerifier(
      audience: '',
      loadJwks: () async => jwks,
      clock: Clock.fixed(now),
    );
    await expectLater(verify(), throwsFormatException);
  });

  test('rejects wrong or empty stored nonce digest', () async {
    final token = KakaoTestKeys.sign(claims);
    for (final digest in ['', 'wrong-digest']) {
      await expectLater(
        verifier.verify(token, nonceHash: digest),
        throwsFormatException,
      );
    }
  });
}
