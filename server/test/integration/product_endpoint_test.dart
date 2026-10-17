import 'dart:async';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
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
  withServerpod('Unconfigured product policy and authentication', (
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
    test('test mode cannot issue fixture points or prices', () async {
      await endpoints.product.registerStepStream(owner, 'register', 0);
      final day = await endpoints.product.submitSteps(owner, snapshot(7000));
      expect(day.steps, 7000);
      expect(day.claimablePoints, isNull);
      expect(day.fixtureLabel, isNull);
      expect(day.rewardStatus, 'policyUnconfigured');
      await expectLater(
        endpoints.product.claimDay(owner, date, 'claim', day.revision),
        productError('policyUnconfigured'),
      );
      await expectLater(
        endpoints.product.purchaseTheme(owner, 'cloudy', 'purchase'),
        productError('policyUnconfigured'),
      );
      await expectLater(
        endpoints.product.getQuiz(owner, date),
        productError('policyUnconfigured'),
      );
      expect(
        (await endpoints.product.listThemes(
          owner,
        )).items.every((t) => t.price == null),
        isTrue,
      );
      expect(await PointEntry.db.count(owner.build()), 0);
    });
  });

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
        expect(result.fixtureLabel, productFixtureLabel);
        expect((await b.product.getDay(today)).steps, isNull);
        final grant = await a.product.claimDay(today, 'claim', result.revision);
        expect(grant.amount, 7);
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
          (e) => e.code == 'nothingToClaim',
        ),
        isTrue,
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

    test(
      'downward correction keeps paid high water and incremental grants',
      () async {
        final s = await ready();
        final first = await at(() => endpoint.claimDay(s, date, 'first', 1));
        expect(first.amount, 7);
        var day = await at(
          () => endpoint.submitSteps(s, snapshot(8000, revision: 2)),
        );
        expect(
          (await at(
            () => endpoint.claimDay(s, date, 'second', day.revision),
          )).amount,
          1,
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
        expect(third.amount, 1);
        expect(third.fromUnits, 8);
        expect(third.throughUnits, 9);
        expect((await endpoint.getWallet(s)).balance, 9);
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
      'replay does not restart grace and delayed new units get 72 hours',
      () async {
        final s = await ready(on: '2026-10-01');
        final original = await ProductDay.db.findFirstRow(
          s,
          where: (t) => t.owner.equals(s.authenticated!.userIdentifier),
        );
        expect(
          original!.windows.single.freeUntil,
          fixedNow.add(const Duration(days: 3)),
        );
        await withClock(
          Clock.fixed(fixedNow.add(const Duration(days: 4))),
          () async {
            final replay = await endpoint.submitSteps(
              s,
              snapshot(7000, on: '2026-10-01'),
            );
            expect(replay.claimablePoints, 0);
            final delayed = await endpoint.submitSteps(
              s,
              snapshot(9000, revision: 2, on: '2026-10-01'),
            );
            expect(delayed.claimablePoints, 2);
            final grant = await endpoint.claimDay(
              s,
              '2026-10-01',
              'delayed',
              delayed.revision,
            );
            expect(grant.amount, 2);
          },
        );
        expect((await endpoint.getWallet(s)).balance, 2);
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
        expect((await endpoint.getWallet(a)).balance, 7);
        expect(
          (await endpoint.claimDay(a, date, 'claim', 1)).toJson(),
          grant.toJson(),
        );
        expect((await endpoint.getDay(a, date)).steps, isNull);
        await expectLater(
          at(() => endpoint.submitSteps(a, snapshot(9999, revision: 2))),
          productError('dayDeleted'),
        );
      },
    );

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
        final receipt = await records.saveConfirmed(a, input);
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
        final row = await StoredGpsRecord.db.findById(a, receipt.recordId);
        expect(row!.payload, isNull);
        expect(row.deleted, isTrue);
        final deleted = throwsA(
          isA<RecordException>().having((e) => e.code, 'code', 'dayDeleted'),
        );
        await expectLater(records.getMine(a, receipt.recordId), deleted);
        await expectLater(records.saveConfirmed(a, input), deleted);
        await expectLater(
          records.saveConfirmed(
            a,
            input.copyWith(clientRecordId: const Uuid().v4obj()),
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
        expect(await records.saveConfirmed(b, input), isA<RecordReceipt>());
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
        expect((await endpoint.getWallet(a)).balance, 2);
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
      expect((await endpoint.getWallet(a)).balance, 4);
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
