import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../auth/apple_revocation.dart';
import '../auth/naver_revocation.dart';
import '../billing/billing_service.dart';
import '../maintenance/schema_guard.dart';
import '../product/product_service.dart';

class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Deletes only the authenticated account and its locally stored data.
  Future<void> deleteAccount(Session session) async {
    SchemaGuard.require();
    final owner = session.authenticated?.userIdentifier;
    if (owner == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
      );
    }
    await session.db.transaction((tx) => deleteAccountData(session, owner, tx));
    // Never notify a revocation that may still roll back. The committed session
    // cascade already rejects subsequent HTTP token authentication.
    await session.messages.authenticationRevoked(
      owner,
      RevokedAuthenticationUser(),
    );
  }
}

/// The caller owns the transaction; notifications belong after its commit.
Future<void> deleteAccountData(
  Session session,
  String owner,
  Transaction tx,
) async {
  // Same AuthUser -> ProductAccount order as every product/profile/GPS call.
  await lockProductAccount(session, owner, tx);
  await revokeAppleAccount(session, authUserIdOf(owner), tx);
  await revokeNaverAccount(session, authUserIdOf(owner), tx);
  await deleteBillingData(session, owner, tx);
  await StoredAdIntent.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await DogProfile.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await StoredGpsRecord.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await StepRevision.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await ProductDay.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await PointEntry.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await QuizState.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await QuizAssignment.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await ThemeOwnership.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await OutfitOwnership.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await ProductRequest.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  await ProductAccount.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    transaction: tx,
  );
  final authUserId = authUserIdOf(owner);
  // This application relation is RESTRICT, unlike the SDK auth cascades.
  await ExternalIdentity.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserId),
    transaction: tx,
  );
  // The auth cascade removes profile rows but leaves stored image files public.
  await AuthServices.instance.userProfiles.deleteProfileForUser(
    session,
    authUserId,
    transaction: tx,
  );
  await AuthServices.instance.authUsers.delete(
    session,
    authUserId: authUserId,
    transaction: tx,
  );
}
