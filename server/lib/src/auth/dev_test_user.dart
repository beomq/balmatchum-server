import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';

/// Only this disposable database may contain the local virtual identity.
const devTestDatabaseName = 'balmatchum_dev_test';
const devTestMethod = 'dev-test';

void requireDevTestDatabase(ServerpodConfig config) {
  final database = config.database;
  if (config.runMode != ServerpodRunMode.development ||
      database is! PostgresDatabaseConfig ||
      !{'localhost', '127.0.0.1', '::1'}.contains(database.host) ||
      database.name != devTestDatabaseName) {
    throw StateError('Requires development mode and isolated loopback dev DB.');
  }
}

/// Not an endpoint. Uses the same auth services as real login, without Kakao.
Future<AuthSuccess> bootstrapDevTestUser(Session session) async {
  requireDevTestDatabase(session.server.serverpod.config);
  final services = AuthServices.instance;
  return session.db.transaction((transaction) async {
    // Serialize repeated/concurrent CLI invocations for this one identity.
    await session.db.unsafeQuery(
      'SELECT pg_advisory_xact_lock(714031403)',
      transaction: transaction,
    );
    var identity = await ExternalIdentity.db.findFirstRow(
      session,
      where: (t) =>
          t.provider.equals(devTestMethod) &
          t.issuer.equals('local-development') &
          t.audience.equals(devTestDatabaseName) &
          t.subjectNamespace.equals('virtual-test') &
          t.subject.equals('single-user'),
      transaction: transaction,
    );
    if (identity == null) {
      final user = await services.authUsers.create(
        session,
        transaction: transaction,
      );
      identity = await ExternalIdentity.db.insertRow(
        session,
        ExternalIdentity(
          provider: devTestMethod,
          issuer: 'local-development',
          audience: devTestDatabaseName,
          subjectNamespace: 'virtual-test',
          subject: 'single-user',
          authUserId: user.id,
        ),
        transaction: transaction,
      );
    }
    final owner = identity.authUserId.toString();
    final account = await lockProductAccount(session, owner, transaction);
    // The identity and account locks serialize the existence check and credit.
    // Only an actually inserted starter entry changes the fixture balance.
    final starter = await PointEntry.db.findFirstRow(
      session,
      where: (t) =>
          t.authUserId.equals(authUserIdOf(owner)) &
          t.entryKey.equals('dev-harness-starter-v1'),
      transaction: transaction,
    );
    if (starter == null) {
      await ProductService(
        session,
        owner,
        transaction,
        account,
      ).appendPointEntry(
        PointEntry(
          authUserId: authUserIdOf(owner),
          entryKey: 'dev-harness-starter-v1',
          kind: 'fixture-starter',
          amount: 10,
          policyVersion: productFixtureLabel,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    }
    await services.tokenManager.revokeAllTokens(
      session,
      authUserId: identity.authUserId,
      method: devTestMethod,
      transaction: transaction,
    );
    return services.tokenManager.issueToken(
      session,
      authUserId: identity.authUserId,
      method: devTestMethod,
      transaction: transaction,
    );
  });
}
