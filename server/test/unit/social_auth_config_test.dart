import 'package:balmatchum_server/src/auth/social_auth.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:test/test.dart';

import '../test_utils/social_test_config.dart';

void main() {
  test('absent providers are optional even with disabled sessions', () {
    for (final enabled in [true, false]) {
      final settings = SocialAuthSettings.fromPasswords(
        (_) => null,
        sessionsEnabled: enabled,
      );
      expect(settings.google, isNull);
      expect(settings.apple, isNull);
      expect(settings.sessionsEnabled, enabled);
    }
  });

  test('complete configuration builds pinned SDK providers', () {
    final settings = SocialAuthSettings.fromPasswords(
      (key) => socialTestPasswords()[key],
      sessionsEnabled: true,
    );
    expect(settings.google!.clientSecret.clientId, 'test-google-client');
    expect(settings.apple!.bundleIdentifier, 'test.apple.bundle');
  });

  for (final value in ['', '{}', '{secret', '{"web":{}}']) {
    test('supplied invalid Google configuration fails with no secret', () {
      expect(
        () => SocialAuthSettings.fromPasswords(
          (key) => key == 'googleClientSecret' ? value : null,
          sessionsEnabled: false,
        ),
        throwsA(isA<StateError>()),
      );
    });
  }

  for (final key in socialTestPasswords().keys.where(
    (key) => key.startsWith('apple'),
  )) {
    test('partially supplied Apple configuration rejects missing $key', () {
      final values = socialTestPasswords()..remove(key);
      expect(
        () => SocialAuthSettings.fromPasswords(
          (name) => values[name],
          sessionsEnabled: false,
        ),
        throwsA(isA<StateError>()),
      );
    });
  }

  test('optional Apple setting alone is partial configuration', () {
    expect(
      () => SocialAuthSettings.fromPasswords(
        (key) => key == 'appleWebRedirectUri' ? 'https://example.test' : null,
        sessionsEnabled: true,
      ),
      throwsA(isA<StateError>()),
    );
  });

  for (final entry in {
    'appleKey': 'not-a-private-key',
    'appleRedirectUri': 'http://example.test',
    'appleTeamId': '',
  }.entries) {
    test('rejects invalid Apple field ${entry.key}', () {
      final values = socialTestPasswords()..[entry.key] = entry.value;
      expect(
        () => SocialAuthSettings.fromPasswords(
          (key) => values[key],
          sessionsEnabled: true,
        ),
        throwsA(isA<StateError>()),
      );
    });
  }

  test(
    'minimal validation accepts no names or verified email, not empty sub',
    () {
      final details = (
        userIdentifier: 'verified-subject',
        email: '',
        name: null,
        fullName: null,
        image: null,
        verifiedEmail: false,
      );
      validateGoogleSubject(details);
      expect(
        () => GoogleIdpConfig.validateGoogleAccountDetails(details),
        throwsA(isA<GoogleUserInfoMissingDataException>()),
      );
      expect(
        () => validateGoogleSubject((
          userIdentifier: '',
          email: '',
          name: null,
          fullName: null,
          image: null,
          verifiedEmail: null,
        )),
        throwsA(isA<GoogleUserInfoMissingDataException>()),
      );
    },
  );
}
