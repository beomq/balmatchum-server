import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/ads/ad_config.dart';
import 'package:balmatchum_server/src/ads/ad_service.dart';
import 'package:balmatchum_server/src/ads/ad_verifier.dart';
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/auth/dev_test_user.dart';
import 'package:balmatchum_server/src/billing/billing_service.dart';
import 'package:balmatchum_server/src/billing/billing_verifier.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/outfit_service.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/product/quiz_theme_service.dart';
import 'package:balmatchum_server/src/profile/profile_service.dart';
import 'package:balmatchum_server/src/quiz/quiz_bank.dart';
import 'package:balmatchum_server/src/quiz/quiz_service.dart';
import 'package:balmatchum_server/src/records/records_endpoint.dart';
import 'package:clock/clock.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    hide Protocol;
import 'package:test/test.dart';

import '../test_utils/quiz_fixture.dart';
import '../unit/billing/billing_fixture.dart' as billing;

final _ownerTables = [
  for (final table in Protocol().getTargetTableDefinitions())
    if (table.columns.any((c) => c.name == 'owner')) table.name,
];
const _restrict = ['billing_account', 'billing_purchase', 'external_identity'];

void main() {
  late Directory directory;
  late Serverpod pod;
  late Session session;
  var started = false;
  final now = billing.now;
  final fixedClock = Clock.fixed(now);

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('auth-user-relations-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        runMode: 'development',
        database: PostgresDatabaseConfig(
          host: '127.0.0.1',
          port: 0,
          user: 'postgres',
          password: 'local-disposable-test-only',
          dataPath: '${directory.path}/pgdata',
          name: devTestDatabaseName,
        ),
      ),
    );
    configureAuth(pod, sessionPepper: 'public-relation-test-only');
    try {
      await pod.start(runInGuardedZone: false);
      session = await pod.createSession(enableLogging: false);
      started = true;
    } catch (_) {
      await pod.shutdown(exitProcess: false);
      await directory.delete(recursive: true);
      rethrow;
    }
  });

  tearDownAll(() async {
    if (!started) return;
    await session.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  });

  test('malformed owner fails closed before persistence', () async {
    // UuidValue.fromString does not validate (uuid 4.x); the AuthUser lookup
    // that precedes every user-row insert rejects the value instead.
    await expectLater(
      session.db.transaction(
        (tx) => lockProductAccount(session, 'not-a-uuid', tx),
      ),
      throwsA(
        isA<DatabaseQueryException>().having((e) => e.code, 'code', '22P02'),
      ),
    );
    expect(await ProductAccount.db.count(session), 0);
  });

  test('every write path stores the owner FK with no NULL rows', () async {
    expect(_ownerTables, hasLength(14));
    final login = await bootstrapDevTestUser(session);
    final id = login.authUserId;
    final owner = id.uuid;
    session.updateAuthenticated(AuthenticationInfo(owner, {}, authId: 'test'));
    QuizBank.instances[pod] = fixtureBank();
    final date = localDate(now);
    final gps = GpsRecordInput(
      schemaVersion: 1,
      clientRecordId: const Uuid().v4obj(),
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 1)),
      source: 'watch',
      routePoints: [],
    );
    final ads = AdService(
      AdConfig({
        'dailyReward': const AdPlacement(
          (ios: 'test-ios', android: 'test-android'),
          'reward',
          '1',
        ),
      }),
      AdVerifier(),
      clock: fixedClock,
    );
    await withClock(fixedClock, () async {
      await ProductService.run(session, (s) async {
        await s.createProfile(
          ProfileInput(
            breedId: 'shih-tzu',
            name: '친구',
            sex: 'male',
            dailyGoal: 7000,
          ),
          'profile',
        );
        await s.registerStream('register', 0);
        final day = await s.submitSteps(
          DailyStepInput(
            date: date,
            streamGeneration: 1,
            revision: 1,
            windowStart: dayStart(date),
            windowEnd: dayStart(date).add(const Duration(days: 1)),
            observedAt: now,
            total: 7000,
            availability: 'confirmed',
          ),
        );
        // Retry the same request without creating another row.
        await s.registerStream('register', 0);
        await ads.create(
          s,
          'dailyReward',
          date,
          day.revision,
          AdPlatform.android,
        );
        await s.claim(date, 'claim', day.revision);
        await s.answerQuiz(date, 0, 'fixture-answer');
        await s.purchase('cloudy', 'theme');
        await s.purchaseOutfit('vest-low-v', 'outfit');
        await QuizService(s).today();
      });
      await RecordsEndpoint().saveConfirmed(session, gps);
      await RecordsEndpoint().saveConfirmed(session, gps);
    });

    final settings = billing.config();
    var binding = '';
    final service = BillingService(
      settings,
      base64Encode(List.filled(32, 42)),
      clock: fixedClock,
      google: GoogleBillingClient(
        settings.google!,
        clock: fixedClock,
        clientFactory: () => MockClient((request) async {
          if (request.url.host == 'oauth2.googleapis.com') {
            return http.Response(
              jsonEncode({
                'access_token': 'public-test-token',
                'token_type': 'Bearer',
                'expires_in': 3600,
              }),
              200,
            );
          }
          expect(request.method, 'GET');
          return http.Response(
            jsonEncode(
              billing.lifetimePurchase()
                ..['obfuscatedExternalAccountId'] = binding,
            ),
            200,
          );
        }),
      ),
    );
    binding = (await service.configuration(session, 'google')).accountBinding;
    final input = PurchaseInput(
      store: 'google',
      productId: 'lifetime',
      purchaseReference: 'relation-test-purchase',
    );
    await service.verify(session, input);
    await service.verify(session, input); // Existing-purchase update.
    await bootstrapDevTestUser(session); // Existing dev identity/starter.

    for (final table in _ownerTables) {
      final rows = await session.db.unsafeQuery(
        'SELECT owner, "authUserId" FROM "$table"',
      );
      expect(rows, isNotEmpty, reason: 'unexercised $table write path');
      for (final row in rows) {
        expect(row[0], owner, reason: table);
        expect(row[1].toString(), id.toString(), reason: '$table.authUserId');
      }
      final nulls = await session.db.unsafeQuery(
        'SELECT count(*) FROM "$table" WHERE "authUserId" IS NULL',
      );
      expect(nulls.single[0], 0, reason: '$table NULL authUserId');
    }

    // Remove only the explicitly restrictive records, then prove real cascading
    // deletion of all twelve other populated tables (not a schema-only check).
    for (final table in _restrict) {
      await session.db.unsafeQuery('DELETE FROM "$table"');
    }
    await AuthUser.db.deleteWhere(session, where: (t) => t.id.equals(id));
    final cascade = _ownerTables.where((t) => !_restrict.contains(t)).toList();
    expect(cascade, hasLength(12));
    for (final table in cascade) {
      final rows = await session.db.unsafeQuery(
        'SELECT count(*) FROM "$table"',
      );
      expect(rows.single[0], 0, reason: '$table did not cascade');
    }
  });

  for (final table in _restrict) {
    test('$table alone restricts direct AuthUser deletion', () async {
      final user = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      );
      final id = user.id!;
      if (table == 'external_identity') {
        await ExternalIdentity.db.insertRow(
          session,
          ExternalIdentity(
            provider: 'test',
            issuer: 'test',
            audience: 'test',
            subjectNamespace: 'test',
            subject: id.uuid,
            authUserId: id,
          ),
        );
      } else if (table == 'billing_account') {
        session.updateAuthenticated(
          AuthenticationInfo(id.uuid, {}, authId: 'test'),
        );
        await BillingService(
          billing.config(),
          base64Encode(List.filled(32, 42)),
        ).configuration(session, 'google');
      } else {
        await StoredPurchase.db.insertRow(
          session,
          StoredPurchase(
            owner: id.uuid,
            authUserId: id,
            identityHash: id.uuid,
            store: 'google',
            environment: 'sandbox',
            productId: 'lifetime',
            kind: 'lifetime',
            purchaseReference: 'test',
            state: 'purchased',
            sequence: 1,
            observedAt: now,
            acknowledgementPending: false,
          ),
        );
      }
      await expectLater(
        AuthUser.db.deleteWhere(session, where: (t) => t.id.equals(id)),
        throwsA(
          isA<DatabaseQueryException>()
              .having((e) => e.code, 'code', '23503')
              .having((e) => e.tableName, 'table', table),
        ),
      );
      expect(await AuthUser.db.findById(session, id), isNotNull);
      await session.db.unsafeQuery('DELETE FROM "$table"');
      await AuthUser.db.deleteWhere(session, where: (t) => t.id.equals(id));
      expect(await AuthUser.db.findById(session, id), isNull);
    });
  }
}
