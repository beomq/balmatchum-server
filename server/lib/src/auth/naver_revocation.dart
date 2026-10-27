import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'naver_client.dart';
import 'naver_provider.dart';

/// AuthUser lock is held by deletion; failed revocation preserves every grant.
/// Guide 4.3 also removes the app's linked-service entry on successful revoke.
/// Legacy accumulated grants are tried newest-first within one overall budget.
Future<void> revokeNaverAccount(
  Session session,
  UuidValue authUserId,
  Transaction transaction,
) async {
  final grants = await NaverGrant.db.find(
    session,
    where: (t) => t.authUserId.equals(authUserId),
    orderBy: (t) => t.id.desc(),
    transaction: transaction,
  );
  if (grants.isEmpty) return;
  final config = naverSettings[session.serverpod];
  if (config == null ||
      grants.any((grant) => grant.clientId != config.clientId)) {
    throw LoginException(code: 'configurationMissing');
  }
  final client = NaverClient(config);
  final elapsed = Stopwatch()..start();
  for (final grant in grants) {
    final remaining = const Duration(seconds: 10) - elapsed.elapsed;
    if (remaining <= Duration.zero) break;
    try {
      await client.revoke(grant.refreshToken, timeout: remaining);
      return;
    } on LoginException {
      // Try another retained credential, but never reset the timeout budget.
    }
  }
  throw LoginException(code: 'naverRevocationFailed');
}
