import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/apple.dart';
import 'package:sign_in_with_apple_server/sign_in_with_apple_server.dart';

import '../generated/protocol.dart';
import 'social_auth.dart';

/// Called with the account's AuthUser lock held and before deleting any data.
/// Apple cannot participate in the DB transaction. Retain its token on any
/// failure so the caller can retry the idempotent revoke before local deletion.
Future<void> revokeAppleAccount(
  Session session,
  UuidValue authUserId,
  Transaction transaction,
) async {
  final accounts = await AppleAccount.db.find(
    session,
    where: (t) => t.authUserId.equals(authUserId),
    transaction: transaction,
  );
  if (accounts.isEmpty) return;
  final config = requireSocialAuth(session, apple: true).apple!;
  final apple = SignInWithApple(
    config: config.toSignInWithAppleConfiguration(),
  );
  try {
    for (final account in accounts) {
      await apple
          .revokeAuthorization(
            refreshToken: account.refreshToken,
            useBundleIdentifier:
                account.refreshTokenRequestedWithBundleIdentifier,
          )
          .timeout(const Duration(seconds: 10));
      // SDK documents that 200 alone can also mean a wrong client identifier.
      try {
        await apple
            .validateRefreshToken(
              account.refreshToken,
              useBundleIdentifier:
                  account.refreshTokenRequestedWithBundleIdentifier,
            )
            .timeout(const Duration(seconds: 10));
      } on RevokedTokenException {
        continue;
      }
      throw StateError('Apple authorization remains valid.');
    }
  } catch (_) {
    // SDK exceptions contain Apple's response body; never propagate them.
    throw LoginException(code: 'appleRevocationFailed');
  }
}
