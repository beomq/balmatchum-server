import 'dart:async';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/quiz/quiz_bank.dart';
import 'package:balmatchum_server/src/records/records_endpoint.dart';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const date = '2026-10-14';
final fixedNow = DateTime.utc(2026, 10, 14, 3);
final fixedClock = Clock.fixed(fixedNow);

DailyStepInput snapshot(
  int total, {
  int revision = 1,
  int generation = 1,
  String on = date,
}) => DailyStepInput(
  date: on,
  streamGeneration: generation,
  revision: revision,
  windowStart: dayStart(on),
  windowEnd: dayStart(on).add(const Duration(days: 1)),
  observedAt: fixedNow,
  total: total,
  availability: 'confirmed',
);

Matcher productError(String code) =>
    throwsA(isA<ProductException>().having((e) => e.code, 'code', code));

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

void main() {
  withServerpod('Production steps and fixture authentication', (
    builder,
    endpoints,
  ) {
    final owner = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    setUp(() async {
      final session = owner.build();
      await AuthUser.db.insertRow(
        session,
        AuthUser(
          id: UuidValue.fromString(session.authenticated!.userIdentifier),
          scopeNames: {},
        ),
      );
    });
    test('every product method requires authentication', () async {
      final calls = <Future<dynamic>>[
        endpoints.product.getDay(builder, date),
        endpoints.product.listDays(builder, date, date),
        endpoints.product.getWallet(builder),
        endpoints.product.registerStepStream(builder, 'register', 0),
        endpoints.product.submitSteps(builder, snapshot(0)),
        endpoints.product.deleteDay(builder, date, 'delete'),
        endpoints.product.listDeletions(builder, 0),
        endpoints.product.claimDay(builder, date, 'claim', 0),
        endpoints.product.claimDayWithAd(builder, date, 'ad', 0, 'intent'),
        endpoints.product.getQuiz(builder, date),
        endpoints.product.listQuizHistory(builder, date),
        endpoints.product.answerQuiz(builder, date, 0, 'answer'),
        endpoints.product.listThemes(builder),
        endpoints.product.purchaseTheme(builder, 'cloudy', 'purchase'),
        endpoints.product.equipTheme(builder, 'sunny', 'equip'),
      ];
      await Future.wait(
        calls.map(
          (call) => expectLater(
            call,
            throwsA(isA<ServerpodUnauthenticatedException>()),
          ),
        ),
      );
    });
    test(
      'production steps and theme prices are enabled but fixture quiz is not',
      () async {
        await withClock(fixedClock, () async {
          await endpoints.product.registerStepStream(owner, 'register', 0);
          final day = await endpoints.product.submitSteps(
            owner,
            snapshot(7000),
          );
          expect(day.claimablePoints, 70);
          expect(day.adClaimablePoints, 140);
          expect(day.fixtureLabel, isNull);
          expect(day.policyVersion, stepPolicyVersion);
          final grant = await endpoints.product.claimDay(
            owner,
            date,
            'claim',
            day.revision,
          );
          expect(grant.amount, 70);
          expect(grant.fixtureLabel, isNull);
          final session = owner.build();
          await PointEntry.db.insertRow(
            session,
            PointEntry(
              owner: session.authenticated!.userIdentifier,
              entryKey: 'legacy-fixture',
              kind: 'quiz',
              amount: 2,
              policyVersion: productFixtureLabel,
              createdAt: fixedNow,
            ),
          );
          expect((await endpoints.product.getWallet(owner)).balance, 70);
          expect((await endpoints.product.listThemes(owner)).balance, 70);
          await expectLater(
            endpoints.product.getQuiz(owner, date),
            productError('policyUnconfigured'),
          );
          expect(
            (await endpoints.product.listThemes(
              owner,
            )).items.map((t) => t.price),
            [0, 3, 3, 3],
          );
        });
      },
    );
  });

  withServerpod('Production theme purchases', (builder, endpoints) {
    late TestSessionBuilder owner;
    late Session session;
    late String userId;

    setUp(() async {
      userId = const Uuid().v4();
      owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(userId, {}),
      );
      session = owner.build();
      expect(productFixturesEnabled(session), isFalse);
      await AuthUser.db.insertRow(
        session,
        AuthUser(id: UuidValue.fromString(userId), scopeNames: {}),
      );
    });

    Future<void> fund(int amount, {String policy = stepPolicyVersion}) async {
      await PointEntry.db.insertRow(
        session,
        PointEntry(
          owner: userId,
          entryKey: 'fund:$policy',
          kind: 'test-credit',
          amount: amount,
          policyVersion: policy,
          createdAt: fixedNow,
        ),
      );
    }

    Future<List<PointEntry>> debits() => PointEntry.db.find(
      session,
      where: (t) => t.owner.equals(userId) & t.kind.equals('purchase'),
    );

    Future<int> ownerships() => ThemeOwnership.db.count(
      session,
      where: (t) => t.owner.equals(userId),
    );

    test('sufficient balance buys and equips a three point theme', () async {
      // Given: both production reward policies, plus excluded fixture credit.
      await fund(1);
      await fund(2, policy: quizPolicyVersion);
      await fund(100, policy: productFixtureLabel);
      final before = await endpoints.product.getWallet(owner);

      // When.
      final result = await endpoints.product.purchaseTheme(
        owner,
        'cloudy',
        'purchase',
      );

      // Then.
      expect(before.balance, 3);
      expect(result.items.map((t) => t.price), [0, 3, 3, 3]);
      expect(result.fixtureLabel, isNull);
      expect(
        result.items.firstWhere((t) => t.themeId == 'cloudy').owned,
        isTrue,
      );
      expect(result.balance, before.balance - 3);
      expect(
        (await endpoints.product.getWallet(owner)).balance,
        before.balance - 3,
      );
      final debit = (await debits()).single;
      expect(debit.amount, -3);
      expect(debit.policyVersion, themePurchasePolicyVersion);
      expect(await ownerships(), 1);
      expect(
        (await endpoints.product.equipTheme(
          owner,
          'cloudy',
          'equip',
        )).equippedTheme,
        'cloudy',
      );
      expect(
        (await endpoints.product.listThemes(owner)).equippedTheme,
        'cloudy',
      );
    });

    test('insufficient balance rejects without any purchase writes', () async {
      // Given.
      await fund(2);
      await fund(100, policy: productFixtureLabel);
      final before = await endpoints.product.getWallet(owner);

      // When.
      await expectLater(
        endpoints.product.purchaseTheme(owner, 'rainy', 'purchase'),
        productError('insufficientPoints'),
      );

      // Then.
      expect(
        (await endpoints.product.getWallet(owner)).balance,
        before.balance,
      );
      expect(await debits(), isEmpty);
      expect(await ownerships(), 0);
      expect(
        await ProductRequest.db.count(
          session,
          where: (t) => t.owner.equals(userId),
        ),
        0,
      );
    });

    test(
      'same key retries return the original snapshot and one debit',
      () async {
        // Given: later purchases make the current store differ from the receipt.
        await fund(6);
        final first = await endpoints.product.purchaseTheme(
          owner,
          'cloudy',
          'first',
        );
        await endpoints.product.purchaseTheme(owner, 'rainy', 'second');

        // When.
        final replay = await endpoints.product.purchaseTheme(
          owner,
          'cloudy',
          'first',
        );

        // Then.
        expect(replay.toJson(), first.toJson());
        expect(replay.balance, 3);
        expect((await endpoints.product.getWallet(owner)).balance, 0);
        expect(
          (await debits()).where((e) => e.entryKey == 'theme:cloudy'),
          hasLength(1),
        );
        expect(await ownerships(), 2);
      },
    );

    for (final sameKey in [true, false]) {
      test(
        'parallel duplicate purchases debit once (same key: $sameKey)',
        () async {
          // Given: independent endpoint sessions and real committed transactions.
          await fund(3);

          // When.
          final results = await Future.wait([
            endpoints.product.purchaseTheme(owner, 'cloudy', 'first'),
            endpoints.product.purchaseTheme(
              owner,
              'cloudy',
              sameKey ? 'first' : 'second',
            ),
          ]);

          // Then.
          expect(results.map((s) => s.balance), [0, 0]);
          expect(
            results.every(
              (s) => s.items.firstWhere((t) => t.themeId == 'cloudy').owned,
            ),
            isTrue,
          );
          expect(results.first.toJson(), results.last.toJson());
          expect((await endpoints.product.getWallet(owner)).balance, 0);
          expect((await debits()).single.amount, -3);
          expect(await ownerships(), 1);
        },
      );
    }

    test('parallel different themes cannot overspend the wallet', () async {
      // Given.
      await fund(3);

      // When.
      final outcomes = await Future.wait(
        ['cloudy', 'rainy'].map((theme) async {
          try {
            return await endpoints.product.purchaseTheme(owner, theme, theme);
          } on ProductException catch (error) {
            return error;
          }
        }),
      );

      // Then.
      expect(outcomes.whereType<ThemeStore>(), hasLength(1));
      expect(
        outcomes.whereType<ProductException>().single.code,
        'insufficientPoints',
      );
      expect((await endpoints.product.getWallet(owner)).balance, 0);
      expect((await debits()).single.amount, -3);
      expect(await ownerships(), 1);
    });

    test(
      'five parallel purchases across paid themes never overspend six points',
      () async {
        for (var round = 0; round < 3; round++) {
          // Given: a fresh owner per round with exactly two themes of credit.
          final roundUser = const Uuid().v4();
          final roundOwner = builder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              roundUser,
              {},
            ),
          );
          final roundSession = roundOwner.build();
          await AuthUser.db.insertRow(
            roundSession,
            AuthUser(id: UuidValue.fromString(roundUser), scopeNames: {}),
          );
          await PointEntry.db.insertRow(
            roundSession,
            PointEntry(
              owner: roundUser,
              entryKey: 'fund:round-$round',
              kind: 'test-credit',
              amount: 6,
              policyVersion: stepPolicyVersion,
              createdAt: fixedNow,
            ),
          );

          // When: distinct keys race over three paid themes.
          final themes = ['cloudy', 'rainy', 'snowy', 'cloudy', 'rainy'];
          final outcomes = await Future.wait([
            for (var i = 0; i < themes.length; i++)
              () async {
                try {
                  return await endpoints.product.purchaseTheme(
                    roundOwner,
                    themes[i],
                    'race-$round-$i',
                  );
                } on ProductException catch (error) {
                  return error;
                }
              }(),
          ]);

          // Then: exactly two paid themes are bought for six points total.
          final reason = 'round $round: $outcomes';
          expect(outcomes.whereType<ThemeStore>(), isNotEmpty, reason: reason);
          expect(
            outcomes.whereType<ThemeStore>().every((s) => s.balance >= 0),
            isTrue,
            reason: reason,
          );
          expect(
            outcomes.whereType<ProductException>().map((e) => e.code).toSet(),
            anyOf(isEmpty, {'insufficientPoints'}),
            reason: reason,
          );
          final roundDebits = await PointEntry.db.find(
            roundSession,
            where: (t) => t.owner.equals(roundUser) & t.kind.equals('purchase'),
          );
          expect(roundDebits, hasLength(2), reason: reason);
          expect(
            roundDebits.fold<int>(0, (sum, e) => sum + e.amount),
            -6,
            reason: reason,
          );
          expect(
            await ThemeOwnership.db.count(
              roundSession,
              where: (t) => t.owner.equals(roundUser),
            ),
            2,
            reason: reason,
          );
          expect(
            (await endpoints.product.getWallet(roundOwner)).balance,
            0,
            reason: reason,
          );
        }
      },
    );

    test('default theme is free without a debit or ownership write', () async {
      // Given: a new account with no credits.
      final before = await endpoints.product.getWallet(owner);

      // When.
      final result = await endpoints.product.purchaseTheme(
        owner,
        'sunny',
        'free',
      );

      // Then.
      final item = result.items.firstWhere((t) => t.themeId == 'sunny');
      expect(item.price, 0);
      expect(item.owned, isTrue);
      expect(result.balance, before.balance);
      expect(
        (await endpoints.product.getWallet(owner)).balance,
        before.balance,
      );
      expect(await debits(), isEmpty);
      expect(await ownerships(), 0);
    });

    test('an already owned theme needs no balance or second debit', () async {
      // Given.
      await fund(3);
      await endpoints.product.purchaseTheme(owner, 'snowy', 'first');

      // When.
      final result = await endpoints.product.purchaseTheme(
        owner,
        'snowy',
        'second',
      );

      // Then.
      expect(
        result.items.firstWhere((t) => t.themeId == 'snowy').owned,
        isTrue,
      );
      expect(result.balance, 0);
      expect((await debits()).single.amount, -3);
      expect(await ownerships(), 1);
    });

    test('reusing a purchase key for a different theme is rejected', () async {
      // Given.
      await fund(6);
      await endpoints.product.purchaseTheme(owner, 'cloudy', 'same');

      // When.
      await expectLater(
        endpoints.product.purchaseTheme(owner, 'rainy', 'same'),
        productError('idempotencyConflict'),
      );

      // Then.
      expect((await endpoints.product.getWallet(owner)).balance, 3);
      expect(await debits(), hasLength(1));
      expect(await ownerships(), 1);
    });

    for (final (theme, key, error) in [
      ('unknown', 'purchase', 'unknownTheme'),
      ('cloudy', '', 'invalidRequestId'),
      ('cloudy', 'x' * 129, 'invalidRequestId'),
    ]) {
      test(
        'rejects malformed purchase input: $error (${key.length})',
        () async {
          // Given.
          await fund(3);

          // When.
          await expectLater(
            endpoints.product.purchaseTheme(owner, theme, key),
            productError(error),
          );

          // Then.
          expect((await endpoints.product.getWallet(owner)).balance, 3);
          expect(await debits(), isEmpty);
          expect(await ownerships(), 0);
        },
      );
    }
  }, rollbackDatabase: RollbackDatabase.disabled);

  group('Product fixtures on disposable development database', () {
    late Directory directory;
    late Serverpod pod;
    final sessions = <Session>[];
    final clients = <api.Client>[];
    final endpoint = ProductEndpoint();
    final records = RecordsEndpoint();

    Future<Session> owner([String? id]) async {
      final s = await pod.createSession(enableLogging: false);
      final userId =
          id ?? (await AuthServices.instance.authUsers.create(s)).id.uuid;
      s.updateAuthenticated(
        AuthenticationInfo(userId, {}, authId: 'test'),
      );
      sessions.add(s);
      return s;
    }

    Future<T> at<T>(Future<T> Function() body) => withClock(fixedClock, body);

    Future<Session> ready({int steps = 7000, String on = date}) async {
      final s = await owner();
      await endpoint.registerStepStream(s, 'register', 0);
      await at(() => endpoint.submitSteps(s, snapshot(steps, on: on)));
      return s;
    }

    setUpAll(() async {
      directory = await Directory.systemTemp.createTemp('product-fixtures-');
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
            name: 'balmatchum_dev_test',
          ),
        ),
      );
      configureAuth(pod, sessionPepper: 'public-product-test-only');
      await pod.start(runInGuardedZone: false);
    });

    tearDown(() async {
      for (final s in sessions) {
        await s.close();
      }
      sessions.clear();
      for (final c in clients) {
        c.close();
      }
      clients.clear();
    });
    tearDownAll(() async {
      await pod.shutdown(exitProcess: false);
      await directory.delete(recursive: true);
    });

    test(
      'real HTTP authentication and generated client isolate owners',
      () async {
        final admin = await owner();
        admin.updateAuthenticated(null);
        Future<api.Client> client() async {
          final user = await AuthServices.instance.authUsers.create(admin);
          final token = await AuthServices.instance.tokenManager.issueToken(
            admin,
            authUserId: user.id,
            method: 'product-test',
          );
          final c = api.Client('http://localhost:${pod.server.port}/')
            ..authKeyProvider = _Token(token.token);
          clients.add(c);
          return c;
        }

        final a = await client();
        final b = await client();
        final anonymous = api.Client('http://localhost:${pod.server.port}/');
        clients.add(anonymous);
        await expectLater(
          anonymous.product.getWallet(),
          throwsA(isA<api.ServerpodClientUnauthorized>()),
        );
        final generation = await a.product.registerStepStream('register', 0);
        final today = localDate(DateTime.now());
        final start = dayStart(today);
        final result = await a.product.submitSteps(
          api.DailyStepInput(
            date: today,
            streamGeneration: generation,
            revision: 1,
            windowStart: start,
            windowEnd: start.add(const Duration(days: 1)),
            observedAt: DateTime.now().toUtc(),
            total: 7000,
            availability: 'confirmed',
          ),
        );
        expect(result.steps, 7000);
        expect(result.fixtureLabel, isNull);
        expect((await b.product.getDay(today)).steps, isNull);
        final grant = await a.product.claimDay(today, 'claim', result.revision);
        expect(grant.amount, 70);
        expect((await b.product.getWallet()).balance, 0);
        await a.product.deleteDay(today, 'delete');
        expect(await b.product.listDeletions(0), isEmpty);
      },
    );

    test(
      'snapshot replacement, unknown zero and historical revision conflicts',
      () async {
        final s = await ready();
        var day = await at(
          () => endpoint.submitSteps(s, snapshot(8000, revision: 3)),
        );
        expect(day.steps, 8000);
        day = await at(
          () => endpoint.submitSteps(s, snapshot(6500, revision: 4)),
        );
        expect(day.steps, 6500);
        final stale = await at(
          () => endpoint.submitSteps(s, snapshot(9000, revision: 2)),
        );
        expect(stale.steps, 6500);
        await expectLater(
          at(() => endpoint.submitSteps(s, snapshot(7001))),
          productError('snapshotConflict'),
        );
        day = await at(() => endpoint.submitSteps(s, snapshot(0, revision: 5)));
        expect(day.steps, 0);
        expect(day.availability, 'confirmed');
        day = await at(
          () => endpoint.submitSteps(
            s,
            snapshot(
              0,
              revision: 6,
            ).copyWith(total: null, availability: 'queryFailed'),
          ),
        );
        expect(day.steps, isNull);
        expect(day.claimablePoints, isNull);
        expect(day.rewardStatus, 'pending');
      },
    );

    test(
      'generation is explicit CAS and snapshot cannot select active stream',
      () async {
        final s = await ready();
        expect(await endpoint.registerStepStream(s, 'replace', 1), 2);
        expect(await endpoint.registerStepStream(s, 'replace', 1), 2);
        await expectLater(
          endpoint.registerStepStream(s, 'replace', 2),
          productError('idempotencyConflict'),
        );
        await expectLater(
          endpoint.registerStepStream(s, 'old-register', 1),
          productError('staleGeneration'),
        );
        await expectLater(
          at(() => endpoint.submitSteps(s, snapshot(9999, revision: 100))),
          productError('staleGeneration'),
        );
        final day = await at(
          () => endpoint.submitSteps(s, snapshot(2000, generation: 2)),
        );
        expect(day.steps, 2000);
      },
    );

    test(
      'calendar includes absent days and never another owner data',
      () async {
        final a = await ready();
        final b = await owner();
        final days = await at(() => endpoint.listDays(a, '2026-10-13', date));
        expect(days.map((d) => d.steps), [null, 7000]);
        expect((await at(() => endpoint.getDay(b, date))).steps, isNull);
        await endpoint.deleteDay(a, date, 'delete');
        expect(await endpoint.listDeletions(b, 0), isEmpty);
        expect((await endpoint.listDeletions(a, 0)).single.date, date);
        await expectLater(
          endpoint.getDay(a, '2026-02-30'),
          productError('invalidDate'),
        );
        await expectLater(
          endpoint.listDays(a, '2026-01-01', date),
          productError('invalidRange'),
        );
      },
    );

    test(
      '100 step threshold, daily cap and goal-independent increments',
      () async {
        final s = await ready(steps: 99);
        await at(() async {
          var day = await endpoint.getDay(s, date);
          expect(day.claimablePoints, 0);
          expect(day.basePoints, 0);
          expect(day.stepsPerPoint, 100);
          expect(day.dailyBaseCap, 100);
          await expectLater(
            endpoint.claimDay(s, date, 'below', day.revision),
            productError('nothingToClaim'),
          );
          day = await endpoint.submitSteps(s, snapshot(100, revision: 2));
          expect(day.claimablePoints, 1);
          expect(
            (await endpoint.claimDay(s, date, 'one', day.revision)).amount,
            1,
          );
          day = await endpoint.submitSteps(s, snapshot(199, revision: 3));
          expect(day.claimablePoints, 0);
          day = await endpoint.submitSteps(s, snapshot(9999, revision: 4));
          expect(
            (await endpoint.claimDay(
              s,
              date,
              'ninety-eight',
              day.revision,
            )).amount,
            98,
          );
          day = await endpoint.submitSteps(s, snapshot(10000, revision: 5));
          expect(
            (await endpoint.claimDay(s, date, 'cap', day.revision)).amount,
            1,
          );
          day = await endpoint.submitSteps(s, snapshot(90000, revision: 6));
          expect(day.claimablePoints, 0);
          expect(day.basePoints, 100);
          expect((await endpoint.getWallet(s)).balance, 100);
        });
      },
    );

    test('free deadline is exclusive next midnight plus seven days', () async {
      final s = await ready();
      final deadline = dayStart('2026-10-22');
      final value = await ProductDay.db.findFirstRow(
        s,
        where: (t) => t.owner.equals(s.authenticated!.userIdentifier),
      );
      expect(value!.windows.single.freeUntil, deadline);
      await withClock(
        Clock.fixed(deadline.subtract(const Duration(microseconds: 1))),
        () async {
          expect((await endpoint.getDay(s, date)).claimablePoints, 70);
        },
      );
      await withClock(Clock.fixed(deadline), () async {
        expect((await endpoint.getDay(s, date)).claimablePoints, 0);
        expect((await endpoint.getDay(s, date)).adClaimablePoints, 140);
        await expectLater(
          endpoint.claimDay(s, date, 'at-deadline', 1),
          productError('adRequired'),
        );
        await endpoint.submitSteps(s, snapshot(7000, revision: 2));
        final unchanged = await ProductDay.db.findById(s, value.id!);
        expect(unchanged!.windows.single.freeUntil, deadline);
      });
    });

    test('legacy fixture and unversioned days are never revalued', () async {
      final s = await owner();
      final id = s.authenticated!.userIdentifier;
      await endpoint.registerStepStream(s, 'register', 0);
      await ProductDay.db.insertRow(
        s,
        ProductDay(
          owner: id,
          date: date,
          steps: 7000,
          availability: 'confirmed',
          policyVersion: productFixtureLabel,
          grantedUnits: 7,
          confirmedUnits: 7,
          windows: [
            RewardWindow(
              fromUnits: 0,
              throughUnits: 7,
              confirmedAt: fixedNow,
              freeUntil: fixedNow.add(const Duration(days: 7)),
            ),
          ],
        ),
      );
      await PointEntry.db.insertRow(
        s,
        PointEntry(
          owner: id,
          entryKey: 'steps:$date:7',
          kind: 'steps',
          date: date,
          amount: 7,
          policyVersion: productFixtureLabel,
          createdAt: fixedNow,
        ),
      );
      await ProductDay.db.insertRow(
        s,
        ProductDay(owner: id, date: '2026-10-13', windows: []),
      );
      await at(() async {
        final day = await endpoint.submitSteps(s, snapshot(9000, revision: 2));
        expect(day.rewardStatus, 'legacyPolicyExcluded');
        expect(day.fixtureLabel, productFixtureLabel);
        expect(day.claimablePoints, isNull);
        expect(day.grantedPoints, 0);
        await expectLater(
          endpoint.claimDay(s, date, 'legacy', day.revision),
          productError('legacyPolicyExcluded'),
        );
        final unversioned = await endpoint.submitSteps(
          s,
          snapshot(9000, on: '2026-10-13'),
        );
        expect(unversioned.rewardStatus, 'legacyPolicyExcluded');
        expect(unversioned.policyVersion, isNull);
        expect((await endpoint.getWallet(s)).balance, 0);
        final row = await ProductDay.db.findFirstRow(
          s,
          where: (t) => t.owner.equals(id) & t.date.equals(date),
        );
        expect(row!.grantedUnits, 7);
        expect(row.confirmedUnits, 7);
        expect(row.windows.single.throughUnits, 7);
      });
      expect((await endpoint.listThemes(s)).balance, 7);
    });

    test('future dates never permit free or ad grants', () async {
      final s = await ready();
      await at(() async {
        expect(
          (await endpoint.getDay(s, '2026-10-15')).rewardStatus,
          'futureDate',
        );
        await expectLater(
          endpoint.claimDay(s, '2026-10-15', 'future', 0),
          productError('futureDate'),
        );
        await expectLater(
          endpoint.claimDayWithAd(s, '2026-10-15', 'future-ad', 0, 'any'),
          productError('futureDate'),
        );
        await expectLater(
          endpoint.submitSteps(s, snapshot(100, on: '2026-10-15')),
          productError('invalidSnapshot'),
        );
      });
    });

    test('parallel claims produce exactly one immutable grant', () async {
      final a = await ready();
      final b = await owner(a.authenticated!.userIdentifier);
      final outcomes = await at(
        () => Future.wait(
          List.generate(12, (i) async {
            try {
              return await endpoint.claimDay(
                i.isEven ? a : b,
                date,
                'claim-$i',
                1,
              );
            } on ProductException catch (e) {
              return e;
            }
          }),
        ),
      );
      expect(outcomes.whereType<RewardGrant>(), hasLength(1));
      expect(
        outcomes.whereType<ProductException>().every(
          (e) => e.code == 'staleProjection',
        ),
        isTrue,
      );
      expect((await endpoint.getWallet(a)).balance, 70);
      expect(
        await PointEntry.db.count(
          a,
          where: (t) => t.owner.equals(a.authenticated!.userIdentifier),
        ),
        1,
      );
    });

    test(
      'downward correction keeps paid high water and incremental grants',
      () async {
        final s = await ready();
        final first = await at(() => endpoint.claimDay(s, date, 'first', 1));
        expect(first.amount, 70);
        var day = await at(
          () => endpoint.submitSteps(s, snapshot(8000, revision: 2)),
        );
        expect(
          (await at(
            () => endpoint.claimDay(s, date, 'second', day.revision),
          )).amount,
          10,
        );
        for (final (revision, steps) in [(3, 6500), (4, 7500)]) {
          day = await at(
            () => endpoint.submitSteps(s, snapshot(steps, revision: revision)),
          );
          expect(day.claimablePoints, 0);
          await expectLater(
            at(
              () => endpoint.claimDay(s, date, 'none-$revision', day.revision),
            ),
            productError('nothingToClaim'),
          );
        }
        day = await at(
          () => endpoint.submitSteps(s, snapshot(9500, revision: 5)),
        );
        final third = await at(
          () => endpoint.claimDay(s, date, 'third', day.revision),
        );
        expect(third.amount, 15);
        expect(third.fromUnits, 80);
        expect(third.throughUnits, 95);
        expect((await endpoint.getWallet(s)).balance, 95);
        final replay = await at(() => endpoint.claimDay(s, date, 'first', 1));
        expect(replay.toJson(), first.toJson());
        await expectLater(
          at(() => endpoint.claimDay(s, date, 'first', 5)),
          productError('idempotencyConflict'),
        );
        await expectLater(
          at(() => endpoint.claimDay(s, date, 'stale', 1)),
          productError('staleProjection'),
        );
      },
    );

    test(
      'late tranches keep exclusive deadlines without extending old units',
      () async {
        final s = await ready(on: '2026-10-01');
        final original = await ProductDay.db.findFirstRow(
          s,
          where: (t) => t.owner.equals(s.authenticated!.userIdentifier),
        );
        expect(
          original!.windows.single.freeUntil,
          fixedNow.add(const Duration(hours: 72)),
        );
        expect(original.windows.single.confirmedAt, fixedNow);
        await withClock(
          Clock.fixed(
            fixedNow
                .add(const Duration(hours: 72))
                .subtract(const Duration(microseconds: 1)),
          ),
          () async {
            expect(
              (await endpoint.getDay(s, '2026-10-01')).claimablePoints,
              70,
            );
          },
        );
        await withClock(
          Clock.fixed(fixedNow.add(const Duration(hours: 72))),
          () async {
            expect((await endpoint.getDay(s, '2026-10-01')).claimablePoints, 0);
            await expectLater(
              endpoint.claimDay(s, '2026-10-01', 'deadline', 1),
              productError('adRequired'),
            );
          },
        );
        await withClock(
          Clock.fixed(fixedNow.add(const Duration(days: 4))),
          () async {
            final replay = await endpoint.submitSteps(
              s,
              snapshot(7000, on: '2026-10-01'),
            );
            expect(replay.rewardStatus, 'adRequired');
            expect(replay.claimablePoints, 0);
            final delayed = await endpoint.submitSteps(
              s,
              snapshot(9000, revision: 2, on: '2026-10-01'),
            );
            expect(delayed.claimablePoints, 20);
            expect(delayed.adClaimablePoints, 180);
            final grant = await endpoint.claimDay(
              s,
              '2026-10-01',
              'delayed',
              delayed.revision,
            );
            expect(grant.amount, 20);
            expect(grant.slices!.single.fromUnits, 70);
            final remaining = await endpoint.getDay(s, '2026-10-01');
            expect(remaining.claimablePoints, 0);
            expect(remaining.adClaimablePoints, 140);
          },
        );
        final updated = await ProductDay.db.findById(s, original.id!);
        expect(updated!.windows.map((w) => w.throughUnits), [70, 90]);
        expect(
          updated.windows.first.confirmedAt,
          original.windows.first.confirmedAt,
        );
        expect(
          updated.windows.last.confirmedAt,
          fixedNow.add(const Duration(days: 4)),
        );
        expect(
          updated.windows.first.freeUntil,
          original.windows.first.freeUntil,
        );
        expect(
          updated.windows.last.freeUntil,
          fixedNow.add(const Duration(days: 7)),
        );
        expect((await endpoint.getWallet(s)).balance, 20);
      },
    );

    test(
      'claim first then delete keeps grant and safe successful replay',
      () async {
        final a = await ready();
        final b = await owner(a.authenticated!.userIdentifier);
        final locked = Completer<void>();
        final release = Completer<void>();
        final claim = at(
          () => ProductService.run(a, (s) async {
            locked.complete();
            await release.future.timeout(const Duration(seconds: 10));
            return s.claim(date, 'claim', 1);
          }),
        );
        await locked.future.timeout(const Duration(seconds: 10));
        final deletion = endpoint.deleteDay(b, date, 'delete');
        release.complete();
        final grant = await claim;
        expect((await deletion).deleted, isTrue);
        expect((await endpoint.getWallet(a)).balance, 70);
        final replay = await endpoint.claimDay(a, date, 'claim', 1);
        expect(replay.ledgerId, grant.ledgerId);
        expect(replay.amount, grant.amount);
        expect([replay.fromUnits, replay.throughUnits], [0, 0]);
        expect(replay.slices, isNull);
        expect(replay.basePoints, isNull);
        expect((await endpoint.getDay(a, date)).steps, isNull);
        await expectLater(
          at(() => endpoint.submitSteps(a, snapshot(9999, revision: 2))),
          productError('dayDeleted'),
        );
      },
    );

    test('reads finish while a write holds the account lock', () async {
      final a = await ready();
      final b = await owner(a.authenticated!.userIdentifier);
      final locked = Completer<void>();
      final release = Completer<void>();
      final write = ProductService.run(a, (s) async {
        locked.complete();
        await release.future.timeout(const Duration(seconds: 10));
        return s.wallet();
      });
      try {
        await locked.future.timeout(const Duration(seconds: 10));
        final reads = await at(
          () => Future.wait<Object>([
            endpoint.getWallet(b),
            endpoint.getDay(b, date),
            endpoint.listDays(b, date, date),
            endpoint.listDeletions(b, 0),
            endpoint.listThemes(b),
            endpoint.listOutfits(b),
          ]).timeout(const Duration(seconds: 5)),
        );
        expect((reads[0] as WalletView).balance, 0);
        expect((reads[1] as DailyRecord).steps, 7000);
      } finally {
        release.complete();
        await write;
      }
    });

    test('day deletion clears units while preserving ledger amounts', () async {
      // Given: two paid tranches and an unrelated owner's same date.
      final a = await ready(steps: 700);
      final b = await ready(steps: 300);
      await at(() async {
        final first = await endpoint.getDay(a, date);
        await endpoint.claimDay(a, date, 'first', first.revision);
        final second = await endpoint.submitSteps(
          a,
          snapshot(900, revision: 2),
        );
        await endpoint.claimDay(a, date, 'second', second.revision);
        final other = await endpoint.getDay(b, date);
        await endpoint.claimDay(b, date, 'other', other.revision);
      });
      final before = await PointEntry.db.find(
        a,
        where: (t) => t.owner.equals(a.authenticated!.userIdentifier),
      );

      // When.
      await endpoint.deleteDay(a, date, 'delete-units');

      // Then: tombstone, identities and amounts survive, unit detail does not.
      final day = (await ProductDay.db.find(
        a,
        where: (t) => t.owner.equals(a.authenticated!.userIdentifier),
      )).single;
      expect(day.deleted, isTrue);
      expect(day.steps, isNull);
      expect(day.windows, isEmpty);
      expect([day.grantedUnits, day.confirmedUnits], [0, 0]);
      expect(
        await StepRevision.db.count(
          a,
          where: (t) => t.owner.equals(a.authenticated!.userIdentifier),
        ),
        0,
      );
      final entries = await PointEntry.db.find(
        a,
        where: (t) => t.owner.equals(a.authenticated!.userIdentifier),
        orderBy: (t) => t.id,
      );
      expect(entries.map((e) => e.amount), [7, 2]);
      expect(entries.map((e) => e.entryKey), before.map((e) => e.entryKey));
      for (final entry in entries) {
        expect(entry.fromUnits, isNull);
        expect(entry.throughUnits, isNull);
        expect(entry.slices, isNull);
      }
      final receipt = await endpoint.claimDay(a, date, 'first', 1);
      expect([receipt.fromUnits, receipt.throughUnits], [0, 0]);
      expect(receipt.slices, isNull);
      expect(receipt.basePoints, isNull);
      expect((await endpoint.getWallet(a)).balance, 9);
      expect((await endpoint.getWallet(b)).balance, 3);
      final other = (await PointEntry.db.find(
        b,
        where: (t) => t.owner.equals(b.authenticated!.userIdentifier),
      )).single;
      expect(other.throughUnits, 3);
    });

    for (final total in [700, 9900]) {
      test('deleted day rejects resync of $total without regrant', () async {
        // Given: a claimed day with its unit fields cleared by deletion.
        final a = await ready(steps: 700);
        final day = await at(() => endpoint.getDay(a, date));
        await at(() => endpoint.claimDay(a, date, 'paid', day.revision));
        final deleted = await endpoint.deleteDay(a, date, 'delete');

        // When: same or higher step totals return through the endpoint.
        await expectLater(
          at(() => endpoint.submitSteps(a, snapshot(total, revision: 2))),
          productError('dayDeleted'),
        );

        // Then: neither a new key nor replay of the paid key adds points.
        await expectLater(
          at(() => endpoint.claimDay(a, date, 'new', deleted.revision)),
          productError('dayDeleted'),
        );
        expect(
          (await endpoint.claimDay(a, date, 'paid', day.revision)).amount,
          7,
        );
        expect((await endpoint.getWallet(a)).balance, 7);
        expect(
          await PointEntry.db.count(
            a,
            where: (t) => t.owner.equals(a.authenticated!.userIdentifier),
          ),
          1,
        );
      });
    }

    test('delete first wins claim race without ledger insertion', () async {
      final a = await ready();
      final b = await owner(a.authenticated!.userIdentifier);
      final locked = Completer<void>();
      final release = Completer<void>();
      final deletion = ProductService.run(a, (s) async {
        locked.complete();
        await release.future.timeout(const Duration(seconds: 10));
        return s.deleteDay(date, 'delete');
      });
      await locked.future.timeout(const Duration(seconds: 10));
      final rejected = expectLater(
        at(() => endpoint.claimDay(b, date, 'claim', 1)),
        productError('dayDeleted'),
      );
      release.complete();
      await deletion;
      await rejected;
      expect((await endpoint.getWallet(a)).balance, 0);
    });

    test(
      'GPS deletion purges full crossing payload and rejects entire v1 upload',
      () async {
        final a = await owner();
        final input = GpsRecordInput(
          schemaVersion: 1,
          clientRecordId: const Uuid().v4obj(),
          startedAt: DateTime.utc(2026, 10, 13, 14, 59),
          endedAt: DateTime.utc(2026, 10, 13, 15, 1),
          source: 'watch',
          routePoints: [
            RoutePoint(
              recordedAt: DateTime.utc(2026, 10, 13, 14, 59),
              latitude: 37,
              longitude: 127,
            ),
            RoutePoint(
              recordedAt: DateTime.utc(2026, 10, 13, 15, 1),
              latitude: 38,
              longitude: 128,
            ),
          ],
        );
        // Pre-launch legacy rows may contain coordinates; deletion must still
        // purge them even though the upload endpoint now refuses location.
        final legacy = await StoredGpsRecord.db.insertRow(
          a,
          StoredGpsRecord(
            owner: a.authenticated!.userIdentifier,
            clientRecordId: input.clientRecordId,
            persistedAt: fixedNow,
            payload: input,
          ),
        );
        expect(
          (await endpoint.getDay(a, '2026-10-13')).routes.single.points,
          hasLength(1),
        );
        expect(
          (await endpoint.getDay(a, date)).routes.single.points,
          hasLength(1),
        );
        await endpoint.deleteDay(a, date, 'delete');
        expect((await endpoint.getDay(a, '2026-10-13')).routes, isEmpty);
        final row = await StoredGpsRecord.db.findById(a, legacy.id!);
        expect(row!.payload, isNull);
        expect(row.deleted, isTrue);
        final deleted = throwsA(
          isA<RecordException>().having((e) => e.code, 'code', 'dayDeleted'),
        );
        await expectLater(records.getMine(a, legacy.id!), deleted);
        await expectLater(
          records.saveConfirmed(a, input.copyWith(routePoints: [])),
          deleted,
        );
        await expectLater(
          records.saveConfirmed(
            a,
            input.copyWith(
              clientRecordId: const Uuid().v4obj(),
              routePoints: [],
            ),
          ),
          deleted,
        );
        expect(
          await StoredGpsRecord.db.count(
            a,
            where: (t) => t.owner.equals(a.authenticated!.userIdentifier),
          ),
          1,
        );
        final b = await owner();
        expect(
          await records.saveConfirmed(b, input.copyWith(routePoints: [])),
          isA<RecordReceipt>(),
        );
      },
    );

    test(
      'daily assignment answer review and duplicate requests pay once',
      () async {
        final a = await owner();
        final b = await owner(a.authenticated!.userIdentifier);
        final assignment = await at(() => endpoint.getQuiz(a, date));
        expect(assignment.correctIndex, isNull);
        expect(assignment.explanation, isNull);
        final answers = await at(
          () => Future.wait([
            endpoint.answerQuiz(a, date, 0, 'answer-a'),
            endpoint.answerQuiz(b, date, 0, 'answer-b'),
          ]),
        );
        expect(answers.map((q) => q.awardedPoints), [2, 2]);
        expect((await endpoint.getWallet(a)).balance, 0);
        expect((await endpoint.listThemes(a)).balance, 2);
        final review = await withClock(
          Clock.fixed(fixedNow.add(const Duration(days: 1))),
          () => endpoint.getQuiz(a, date),
        );
        expect(review.correctIndex, 0);
        expect(
          (await endpoint.listQuizHistory(a, '2026-10-15')).single.date,
          date,
        );
        expect(await endpoint.listQuizHistory(a, date), isEmpty);
        await expectLater(
          at(() => endpoint.getQuiz(a, '2026-10-13')),
          productError('quizUnavailable'),
        );
        await expectLater(
          at(() => endpoint.answerQuiz(a, date, 1, 'change')),
          productError('alreadyAnswered'),
        );
        await expectLater(
          at(() => endpoint.answerQuiz(a, date, 1, 'answer-a')),
          productError('idempotencyConflict'),
        );
        final other = await owner();
        expect(await endpoint.listQuizHistory(other, '2026-10-15'), isEmpty);
        expect(
          (await at(() => endpoint.getQuiz(other, date))).answerIndex,
          isNull,
        );
        expect((await endpoint.getWallet(other)).balance, 0);
      },
    );

    test('purchase races debit once and ownership gates equip', () async {
      final a = await ready();
      final b = await owner(a.authenticated!.userIdentifier);
      await at(() => endpoint.claimDay(a, date, 'claim', 1));
      await PointEntry.db.insertRow(
        a,
        PointEntry(
          owner: a.authenticated!.userIdentifier,
          entryKey: 'fixture-test',
          kind: 'fixture',
          amount: 7,
          policyVersion: productFixtureLabel,
          createdAt: fixedNow,
        ),
      );
      final stores = await Future.wait([
        endpoint.purchaseTheme(a, 'cloudy', 'buy-a'),
        endpoint.purchaseTheme(b, 'cloudy', 'buy-b'),
      ]);
      expect(
        stores.every(
          (s) => s.items.firstWhere((t) => t.themeId == 'cloudy').owned,
        ),
        isTrue,
      );
      expect((await endpoint.getWallet(a)).balance, 70);
      expect((await endpoint.listThemes(a)).balance, 4);
      expect((await endpoint.listThemes(a)).equippedTheme, 'sunny');
      expect(
        (await endpoint.equipTheme(a, 'cloudy', 'equip')).equippedTheme,
        'cloudy',
      );
      expect((await endpoint.purchaseTheme(a, 'cloudy', 'buy-a')).balance, 4);
      final other = await owner();
      await expectLater(
        endpoint.equipTheme(other, 'cloudy', 'equip'),
        productError('themeNotOwned'),
      );
      await expectLater(
        endpoint.purchaseTheme(other, 'rainy', 'purchase'),
        productError('insufficientPoints'),
      );
      await expectLater(
        endpoint.purchaseTheme(a, 'rainy', 'buy-a'),
        productError('idempotencyConflict'),
      );
      expect((await endpoint.getWallet(other)).balance, 0);
    });
  });
}
