import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/profile/profile_endpoint.dart';
import 'package:balmatchum_server/src/records/records_endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    hide Protocol;
import 'package:test/test.dart';

import '../test_utils/kakao_test_keys.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

const _userColumns = {'owner', 'authUserId'};
const _naver = {
  'naverClientId': 'test-naver-client',
  'naverClientSecret': 'public-test-secret',
  'naverRedirectUri': 'https://example.test/naver/callback',
};

/// Every application table holding a user column, derived from the schema so
/// that a newly added table fails here until deletion and this seed cover it.
Map<String, Set<String>> _userTables() => {
  for (final table in Protocol().getTargetTableDefinitions())
    if (!table.name.startsWith('serverpod_') &&
        table.columns.any((c) => _userColumns.contains(c.name)))
      table.name: {
        for (final column in table.columns)
          if (_userColumns.contains(column.name)) column.name,
      },
};

void main() {
  late Directory directory;
  late Serverpod pod;
  late Session admin;
  var started = false;
  final revoked = <String>[];

  Future<http.Response> external(http.Request request) async {
    if (request.url.toString() != 'https://nid.naver.com/oauth2/revoke') {
      throw StateError('Unexpected external request host/path');
    }
    revoked.add(request.bodyFields['token']!);
    return http.Response('', 200);
  }

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('account-coverage-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        database: PostgresDatabaseConfig.embedded(
          dataPath: '${directory.path}/pgdata',
          name: 'account_coverage',
          maxConnectionCount: 10,
        ),
      ),
    );
    configureAuth(
      pod,
      audience: 'test-native-key',
      issuer: 'https://kauth.kakao.com',
      sessionPepper: 'public-account-coverage-test-only',
      loadJwks: () async => KakaoTestKeys.jwks(),
      providerPassword: (key) => _naver[key],
    );
    try {
      await http.runWithClient(
        () => pod.start(runInGuardedZone: false),
        () => MockClient(external),
      );
      admin = await pod.createSession(enableLogging: false);
      started = true;
    } catch (_) {
      await pod.shutdown(exitProcess: false);
      await directory.delete(recursive: true);
      rethrow;
    }
  });

  tearDownAll(() async {
    if (!started) return;
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  });

  test('deleteAccount removes the user from every user-column table', () async {
    final tables = _userTables();
    printOnFailure(tables.keys.join(','));
    expect(tables.length, greaterThanOrEqualTo(16));
    expect(
      tables.keys,
      containsAll([
        'ad_intent',
        'billing_account',
        'billing_purchase',
        'dog_profile',
        'external_identity',
        'gps_record',
        'naver_grant',
        'outfit_ownership',
        'point_entry',
        'product_account',
        'product_day',
        'product_request',
        'quiz_assignment',
        'quiz_state',
        'step_revision',
        'theme_ownership',
      ]),
      reason: tables.keys.join(','),
    );
    expect(tables['naver_grant'], contains('authUserId'));
    expect(tables['external_identity'], contains('authUserId'));

    // Kakao login fixture creates the AuthUser and its external_identity row.
    final client = api.Client('http://localhost:${pod.server.port}/');
    final session = await pod.createSession(enableLogging: false);
    try {
      final attempt = await client.kakao.beginLogin(provider: 'kakao');
      final now = DateTime.now().toUtc();
      final login = await client.kakao.loginKakao(
        attemptId: attempt.attemptId,
        idToken: KakaoTestKeys.sign({
          'iss': 'https://kauth.kakao.com',
          'aud': 'test-native-key',
          'sub': 'coverage-subject',
          'nonce': attempt.nonce,
          'iat': now.millisecondsSinceEpoch ~/ 1000,
          'exp':
              now.add(const Duration(minutes: 10)).millisecondsSinceEpoch ~/
              1000,
        }),
      );
      final id = login.authUserId;
      final owner = id.uuid;
      client.authKeyProvider = _Token(login.token);
      session.updateAuthenticated(
        await AuthServices.instance.authenticationHandler(
          session,
          login.token,
        ),
      );

      // Endpoint fixtures: profile, product account/request, steps, GPS.
      await ProfileEndpoint().createProfile(
        session,
        ProfileInput(
          breedId: 'jindo',
          name: '친구',
          sex: 'male',
          dailyGoal: 7000,
        ),
        'profile',
      );
      await ProductEndpoint().registerStepStream(session, 'stream', 0);
      await ProductEndpoint().submitSteps(
        session,
        DailyStepInput(
          date: '2026-10-14',
          streamGeneration: 1,
          revision: 1,
          windowStart: dayStart('2026-10-14'),
          windowEnd: dayStart('2026-10-15'),
          observedAt: DateTime.utc(2026, 10, 14),
          total: 7000,
          availability: 'confirmed',
        ),
      );
      await RecordsEndpoint().saveConfirmed(
        session,
        GpsRecordInput(
          schemaVersion: 1,
          clientRecordId: const Uuid().v4obj(),
          startedAt: DateTime.utc(2026, 10, 14),
          endedAt: DateTime.utc(2026, 10, 14, 0, 1),
          source: 'watch',
          routePoints: [],
        ),
      );

      // Direct rows for tables without a convenient endpoint fixture.
      final at = DateTime.utc(2026, 10, 14);
      await PointEntry.db.insertRow(
        admin,
        PointEntry(
          owner: owner,
          authUserId: id,
          entryKey: 'seed',
          kind: 'quiz',
          amount: 2,
          policyVersion: 'test',
          createdAt: at,
        ),
      );
      await QuizState.db.insertRow(
        admin,
        QuizState(
          owner: owner,
          authUserId: id,
          date: '2026-10-14',
          questionId: 'test',
        ),
      );
      await QuizAssignment.db.insertRow(
        admin,
        QuizAssignment(
          owner: owner,
          authUserId: id,
          date: '2026-10-14',
          slot: 'daily',
          questionId: 'test',
          version: 1,
          snapshot: '{}',
          policyVersion: 'test',
          issuedAt: at,
        ),
      );
      await ThemeOwnership.db.insertRow(
        admin,
        ThemeOwnership(
          owner: owner,
          authUserId: id,
          themeId: 'cloudy',
          purchasedAt: at,
        ),
      );
      await OutfitOwnership.db.insertRow(
        admin,
        OutfitOwnership(
          owner: owner,
          authUserId: id,
          outfitId: 'vest-low-v',
          purchasedAt: at,
        ),
      );
      await StoredAdIntent.db.insertRow(
        admin,
        StoredAdIntent(
          owner: owner,
          authUserId: id,
          nonce: 'coverage-nonce',
          purpose: 'test',
          targetDate: '2026-10-14',
          targetRevision: 1,
          adUnit: 'test',
          rewardItem: 'test',
          rewardAmount: '1',
          createdAt: at,
          eventExpiresAt: at,
          acceptUntil: at,
        ),
      );
      await BillingAccount.db.insertRow(
        admin,
        BillingAccount(
          owner: owner,
          authUserId: id,
          binding: 'coverage-binding',
        ),
      );
      await StoredPurchase.db.insertRow(
        admin,
        StoredPurchase(
          owner: owner,
          authUserId: id,
          identityHash: 'coverage-identity',
          store: 'google',
          environment: 'test',
          productId: 'test',
          kind: 'consumable',
          purchaseReference: 'coverage-reference',
          state: 'purchased',
          sequence: 1,
          observedAt: at,
          acknowledgementPending: false,
        ),
      );
      await NaverGrant.db.insertRow(
        admin,
        NaverGrant(
          authUserId: id,
          clientId: 'test-naver-client',
          refreshToken: 'coverage-refresh',
        ),
      );

      // Transition until todo 16 drops owner: a row is the user's under owner
      // or authUserId, whichever columns the table has.
      Future<Map<String, Map<String, int>>> counts() async {
        final parameters = QueryParameters.named({'o': owner});
        return {
          for (final MapEntry(key: table, value: columns) in tables.entries)
            table: {
              for (final column in columns)
                column:
                    (await admin.db.unsafeQuery(
                          column == 'owner'
                              ? 'SELECT count(*) FROM "$table" WHERE owner = @o'
                              : 'SELECT count(*) FROM "$table" '
                                    'WHERE "authUserId" = CAST(@o AS uuid)',
                          parameters: parameters,
                        )).single[0]
                        as int,
            },
        };
      }

      // A table missing from the seed must fail here, not pass vacuously.
      final before = await counts();
      for (final MapEntry(key: table, value: byColumn) in before.entries) {
        expect(
          byColumn.values.fold(0, (a, b) => a + b),
          greaterThan(0),
          reason: 'unseeded $table $byColumn',
        );
        if (byColumn.containsKey('owner')) {
          expect(
            byColumn['authUserId'],
            byColumn['owner'],
            reason: 'missing or mismatched foreign key in $table',
          );
        }
      }

      await client.account.deleteAccount();

      final after = await counts();
      for (final MapEntry(key: table, value: byColumn) in after.entries) {
        for (final MapEntry(key: column, value: count) in byColumn.entries) {
          expect(count, 0, reason: 'remaining $table.$column');
        }
      }
      expect(revoked, ['coverage-refresh']);
    } finally {
      client.close();
      await session.close();
    }
  });
}
