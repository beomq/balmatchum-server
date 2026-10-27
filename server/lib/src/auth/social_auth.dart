import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/apple.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import '../generated/protocol.dart';
import 'kakao_provider.dart';

/// Settings belong to the pod, not the SDK's process-global provider registry.
final socialAuthSettings = Expando<SocialAuthSettings>();

class SocialAuthSettings {
  SocialAuthSettings({
    required this.google,
    required this.apple,
    required this.sessionsEnabled,
    this.cleanupSessions = removeOlderSessions,
  });

  final GoogleIdpConfig? google;
  final AppleIdpConfig? apple;
  final bool sessionsEnabled;
  final Future<void> Function(Session, UuidValue) cleanupSessions;

  factory SocialAuthSettings.fromPasswords(
    String? Function(String) password, {
    required bool sessionsEnabled,
    Future<void> Function(Session, UuidValue) cleanupSessions =
        removeOlderSessions,
  }) {
    GoogleIdpConfig? google;
    final googleSecret = password('googleClientSecret');
    if (googleSecret != null) {
      try {
        final secret = GoogleClientSecret.fromJsonString(googleSecret);
        if (secret.clientId.trim().isEmpty ||
            secret.clientSecret.trim().isEmpty ||
            secret.redirectUris.isEmpty ||
            secret.redirectUris.any((uri) => !_absoluteHttpUri(uri))) {
          throw const FormatException();
        }
        google = GoogleIdpConfig(
          clientSecret: secret,
          googleAccountDetailsValidation: validateGoogleSubject,
        );
      } catch (_) {
        // Do not expose JSON, client secrets, or parser exceptions in logs.
        throw StateError('Invalid Google authentication configuration.');
      }
    }
    const appleKeys = [
      'appleServiceIdentifier',
      'appleBundleIdentifier',
      'appleRedirectUri',
      'appleTeamId',
      'appleKeyId',
      'appleKey',
      'appleAndroidPackageIdentifier',
      'appleWebRedirectUri',
    ];
    final values = {for (final key in appleKeys) key: password(key)};
    AppleIdpConfig? apple;
    if (values.values.any((value) => value != null)) {
      try {
        if (appleKeys
                .take(6)
                .any(
                  (key) => values[key] == null || values[key]!.trim().isEmpty,
                ) ||
            values.values.any(
              (value) => value != null && value.trim().isEmpty,
            ) ||
            !_absoluteHttpUri(values['appleRedirectUri']!, httpsOnly: true) ||
            (values['appleWebRedirectUri'] != null &&
                !_absoluteHttpUri(values['appleWebRedirectUri']!)) ||
            ECPrivateKey(values['appleKey']!).size != 32) {
          throw const FormatException();
        }
        apple = AppleIdpConfig(
          serviceIdentifier: values['appleServiceIdentifier']!,
          bundleIdentifier: values['appleBundleIdentifier']!,
          redirectUri: values['appleRedirectUri']!,
          teamId: values['appleTeamId']!,
          keyId: values['appleKeyId']!,
          key: values['appleKey']!,
          androidPackageIdentifier: values['appleAndroidPackageIdentifier'],
          webRedirectUri: values['appleWebRedirectUri'],
        );
      } catch (_) {
        throw StateError('Invalid Apple authentication configuration.');
      }
    }
    return SocialAuthSettings(
      google: google,
      apple: apple,
      sessionsEnabled: sessionsEnabled,
      cleanupSessions: cleanupSessions,
    );
  }
}

bool _absoluteHttpUri(String value, {bool httpsOnly = false}) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      !uri.hasFragment &&
      (uri.scheme == 'https' || (!httpsOnly && uri.scheme == 'http'));
}

/// The SDK has already verified signature, issuer, audience and timestamps.
/// Names and email verification are not identity requirements. SDK 4.0.3 still
/// requires an email claim to parse its account model; it never links by email.
void validateGoogleSubject(GoogleAccountDetails details) {
  if (details.userIdentifier.trim().isEmpty) {
    throw GoogleUserInfoMissingDataException();
  }
}

/// The app keeps dog profiles only. SDK providers still create a profile row,
/// with its email copy unchanged, but never store names or provider photos.
const providerProfileConfig = UserProfileConfig(
  onBeforeUserProfileCreated: _withoutNames,
  imageFetchFunc: _refuseProviderImage,
);

UserProfileData _withoutNames(
  Session session,
  UuidValue authUserId,
  UserProfileData profile, {
  required Transaction transaction,
}) => UserProfileData(email: profile.email);

/// SDK 4.0.3 fetches provider pictures only here, before any storage write,
/// and continues the login with an error log when the fetch fails.
Uint8List _refuseProviderImage(Uri url) =>
    throw UnsupportedError('Provider profile images are not stored.');

SocialAuthSettings requireSocialAuth(Session session, {required bool apple}) {
  final settings = socialAuthSettings[session.serverpod];
  if (settings == null ||
      !settings.sessionsEnabled ||
      (apple ? settings.apple == null : settings.google == null)) {
    throw LoginException(code: 'configurationMissing');
  }
  return settings;
}

/// Must wrap a complete SDK login, not its new-account callback or token issuer:
/// those execute before commit and are not called for every login method.
Future<AuthSuccess> finishSocialLogin(
  Session session,
  SocialAuthSettings settings,
  Future<AuthSuccess> Function() login,
) async {
  final success = await login();
  try {
    await settings.cleanupSessions(session, success.authUserId);
  } catch (_) {
    session.log(
      'Post-commit session cleanup failed; retry on next login.',
      level: LogLevel.warning,
    );
  }
  return success;
}
