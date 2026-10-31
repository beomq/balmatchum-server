import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/maintenance/schema_guard.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Thrown by an entry point while the startup schema check has not passed.
bool _starting(Object e) =>
    (e is ProductException && e.code == 'serverStarting') ||
    (e is LoginException && e.code == 'serverStarting');

GpsRecordInput _record() => GpsRecordInput(
  schemaVersion: 1,
  clientRecordId: const Uuid().v4obj(),
  startedAt: DateTime.utc(2026, 10, 9, 10),
  endedAt: DateTime.utc(2026, 10, 9, 10, 1),
  source: 'watch',
  routePoints: [],
);

void main() {
  withServerpod('Startup schema guard', (builder, endpoints) {
    final user = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );

    setUp(() async {
      final session = user.build();
      await AuthUser.db.insertRow(
        session,
        AuthUser(
          id: UuidValue.fromString(session.authenticated!.userIdentifier),
          scopeNames: {},
        ),
      );
    });

    tearDown(() => SchemaGuard.ready = true);

    test('the migrated test database has no mismatches', () async {
      expect(await schemaMismatches(builder.build()), isEmpty);
    });

    // Each call is the first thing its entry point does, so all of them are
    // rejected the same way regardless of configuration.
    final calls = <String, Future<Object?> Function()>{
      'getWallet': () => endpoints.product.getWallet(user),
      'beginLogin': () =>
          endpoints.kakao.beginLogin(builder, provider: 'kakao'),
      'saveConfirmed': () => endpoints.records.saveConfirmed(user, _record()),
      'verifyPurchase': () => endpoints.billing.verifyPurchase(
        user,
        PurchaseInput(store: 'apple', productId: 'p', purchaseReference: 'r'),
      ),
    };

    test('entry points answer serverStarting until the guard passes', () async {
      SchemaGuard.ready = false;
      for (final MapEntry(key: name, value: call) in calls.entries) {
        await expectLater(
          call(),
          throwsA(predicate(_starting, 'serverStarting')),
          reason: name,
        );
      }
      expect(
        await ProductAccount.db.count(builder.build()),
        0,
        reason: 'a rejected request must not touch the database',
      );
    });

    test('after the guard passes the same calls go through', () async {
      SchemaGuard.ready = false;
      await expectLater(
        endpoints.product.getWallet(user),
        throwsA(predicate(_starting, 'serverStarting')),
      );
      SchemaGuard.ready = true;
      expect((await endpoints.product.getWallet(user)).balance, 0);
      final receipt = await endpoints.records.saveConfirmed(user, _record());
      expect(receipt.schemaVersion, 1);
      // Kakao and billing are unconfigured here: past the gate they fail on
      // configuration instead, which proves the gate no longer answers.
      for (final name in ['beginLogin', 'verifyPurchase']) {
        Object? error;
        try {
          await calls[name]!();
        } catch (e) {
          error = e;
        }
        expect(
          error == null || !_starting(error),
          isTrue,
          reason: '$name: $error',
        );
      }
    });
  });
}
