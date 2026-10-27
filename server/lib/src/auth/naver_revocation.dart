import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'naver_client.dart';
import 'naver_provider.dart';

/// AuthUser lock is held by deletion; failed revocation preserves every grant.
/// Each successful login can mint a token pair. Do not retain only the latest:
/// Naver documents pairwise cascade, not revocation of all earlier grants.
Future<void> revokeNaverAccount(
  Session session,
  UuidValue authUserId,
  Transaction transaction,
) async {
  final grants = await NaverGrant.db.find(
    session,
    where: (t) => t.authUserId.equals(authUserId),
    transaction: transaction,
  );
  if (grants.isEmpty) return;
  final config = naverSettings[session.serverpod];
  if (config == null ||
      grants.any((grant) => grant.clientId != config.clientId)) {
    throw LoginException(code: 'configurationMissing');
  }
  final client = NaverClient(config);
  for (final grant in grants) {
    await client.revoke(grant.refreshToken);
  }
}
