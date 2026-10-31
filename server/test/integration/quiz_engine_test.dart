import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/account/account_endpoint.dart';
import 'package:balmatchum_server/src/ads/ad_config.dart';
import 'package:balmatchum_server/src/ads/ad_service.dart';
import 'package:balmatchum_server/src/ads/ad_verifier.dart';
import 'package:balmatchum_server/src/ads/ads_endpoint.dart';
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/quiz/quiz_bank.dart';
import 'package:balmatchum_server/src/quiz/quiz_endpoint.dart';
import 'package:balmatchum_server/src/quiz/quiz_service.dart';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../test_utils/ad_test_keys.dart';
import '../test_utils/quiz_fixture.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;
  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

void main() {
  late Directory directory;
  late Serverpod pod;
  late Session admin;
  late AdService ads;
  var now = DateTime.utc(2026, 10, 19, 3);
  var transactionSequence = 0;
  final sessions = <Session>[];
  final clients = <api.Client>[];
  final quiz = QuizEndpoint();
  final adEndpoint = AdsEndpoint();
  const bound = Duration(seconds: 15);
  Future<T> at<T>(Future<T> Function() body) =>
      withClock(Clock.fixed(now), body);
  Matcher error(String code) =>
      throwsA(isA<ProductException>().having((e) => e.code, 'code', code));
  Matcher adError(String code) =>
      throwsA(isA<AdException>().having((e) => e.code, 'code', code));

  Future<({Session session, api.Client client, String owner})> user() async {
    final u = await AuthServices.instance.authUsers.create(admin);
    final token = await AuthServices.instance.tokenManager.issueToken(
      admin,
      authUserId: u.id,
      method: 'quiz-test',
    );
    final s = await pod.createSession(enableLogging: false);
    s.updateAuthenticated(
      await AuthServices.instance.authenticationHandler(s, token.token),
    );
    sessions.add(s);
    final client = api.Client('http://localhost:${pod.server.port}/')
      ..authKeyProvider = _Token(token.token);
    clients.add(client);
    return (session: s, client: client, owner: u.id.uuid);
  }

  Future<QuizQuestion> answer(
    Session s,
    QuizQuestion q, [
    int index = 0,
    String? request,
  ]) => at(
    () => quiz.answer(
      s,
      q.assignmentId,
      q.questionId,
      q.version,
      index,
      request ?? 'answer-${q.assignmentId}',
    ),
  );

  Future<QuizToday> eligible(Session s) async {
    final today = await at(() => quiz.getToday(s));
    await answer(s, today.free!);
    return at(() => quiz.getToday(s));
  }

  Future<AdIntent> verified(Session s, QuizToday t) async {
    final i = await at(
      () => adEndpoint.createIntent(
        s,
        'extraQuiz',
        t.date,
        t.extraRevision!,
        AdPlatform.ios,
      ),
    );
    await ads.callback(
      admin,
      signAd(
        'ad_network=123&ad_unit=${i.adUnit}&custom_data=${i.customData}'
        '&reward_amount=1&reward_item=quiz'
        '&timestamp=${now.millisecondsSinceEpoch}&transaction_id=${(++transactionSequence).toRadixString(16)}'
        '&user_id=${i.userId}',
      ),
    );
    return i;
  }

  Future<int> points(String owner) async => (await PointEntry.db.find(
    admin,
    where: (t) => t.owner.equals(owner) & t.kind.equals('quiz'),
  )).fold<int>(0, (sum, p) => sum + p.amount);

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('quiz-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (c) => c.copyWith(
        database: PostgresDatabaseConfig(
          host: '127.0.0.1',
          port: 0,
          user: 'postgres',
          password: 'local-disposable-test-only',
          dataPath: '${directory.path}/pgdata',
          name: 'quiz_test',
        ),
      ),
    );
    configureAuth(pod, sessionPepper: 'public-quiz-test-only');
    await withClock(Clock(() => now), () => pod.start(runInGuardedZone: false));
    admin = await pod.createSession(enableLogging: false);
    final clock = Clock(() => now);
    ads = AdService(
      AdConfig({
        'extraQuiz': const AdPlacement(
          (
            ios: 'ca-app-pub-0000000000000001/2000000001',
            android: 'ca-app-pub-0000000000000001/2000000002',
          ),
          'quiz',
          '1',
        ),
        'dailyReward': const AdPlacement(
          (
            ios: 'ca-app-pub-0000000000000001/1000000001',
            android: 'ca-app-pub-0000000000000001/1000000002',
          ),
          'quiz',
          '1',
        ),
      }),
      AdVerifier(loadKeys: () async => adKeys(), clock: clock),
      clock: clock,
    );
    AdService.instances[pod] = ads;
  });
  setUp(() async {
    now = DateTime.utc(2026, 10, 19, 3);
    await configureQuizBank(pod, bank: fixtureBank());
  });
  tearDownAll(() async {
    for (final c in clients) {
      c.close();
    }
    for (final s in sessions) {
      await s.close();
    }
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  });

  test(
    'generated HTTP API authenticates all methods and hides answer data',
    () async {
      final a = await user();
      final b = await user();
      final anon = api.Client('http://localhost:${pod.server.port}/');
      clients.add(anon);
      for (final call in <Future<dynamic> Function()>[
        () => anon.quiz.getToday(),
        () => anon.quiz.unlockExtra('2026-10-19', 1, 'x', 'x'),
        () => anon.quiz.answer(1, 'x', 1, 0, 'x'),
        () => anon.quiz.listHistory(null),
        () => anon.quiz.review(1),
      ]) {
        await expectLater(
          call(),
          throwsA(isA<api.ServerpodClientUnauthorized>()),
        );
      }
      final q = (await a.client.quiz.getToday()).free!;
      expect(q.date, localDate(now));
      final json = q.toJson();
      expect(json['correctIndex'], isNull);
      expect(json['explanation'], isNull);
      expect(json['source'], isNull);
      expect(q.fixtureLabel, quizFixturePolicy);
      await expectLater(
        b.client.quiz.answer(
          q.assignmentId,
          q.questionId,
          q.version,
          0,
          'other',
        ),
        throwsA(
          isA<api.ProductException>().having(
            (e) => e.code,
            'code',
            'quizNotFound',
          ),
        ),
      );
      final result = await a.client.quiz.answer(
        q.assignmentId,
        q.questionId,
        q.version,
        1,
        'http-answer',
      );
      expect(result.awardedPoints, 2);
      expect(result.correctIndex, 0);
      expect(result.source, startsWith('https://example.invalid/'));
      expect(
        (await a.client.quiz.listHistory(null)).single.assignmentId,
        q.assignmentId,
      );
      expect(await b.client.quiz.listHistory(null), isEmpty);
      expect((await a.client.quiz.review(q.assignmentId)).answerIndex, 1);
      final today = await a.client.quiz.getToday();
      final intent = await a.client.ads.createIntent(
        'extraQuiz',
        today.date,
        today.extraRevision!,
        api.AdPlatform.ios,
      );
      await ads.callback(
        admin,
        signAd(
          'ad_network=123&ad_unit=${intent.adUnit}&custom_data=${intent.customData}'
          '&reward_amount=1&reward_item=quiz&timestamp=${now.millisecondsSinceEpoch}'
          '&transaction_id=${(++transactionSequence).toRadixString(16)}&user_id=${intent.userId}',
        ),
      );
      final extra = await a.client.quiz.unlockExtra(
        today.date,
        today.extraRevision!,
        intent.id,
        'http-unlock',
      );
      expect(extra.slot, 'extra');
      expect(extra.correctIndex, isNull);
      expect((await a.client.ads.getIntent(intent.id)).status, 'consumed');
      expect(
        (await a.client.quiz.answer(
          extra.assignmentId,
          extra.questionId,
          extra.version,
          0,
          'http-extra-answer',
        )).awardedPoints,
        2,
      );
      expect(await points(a.owner), 4);
      final account = (await ProductAccount.db.findFirstRow(
        admin,
        where: (t) => t.owner.equals(a.owner),
      ))!;
      expect(account.balance, 0);
      expect(account.fixtureBalance, 0);
      expect(await reconcilePointBalances(admin), isEmpty);
    },
  );

  test(
    'free and extra limits concurrent issuance answers and exact replay',
    () async {
      final a = await user();
      final initial = await at(
        () => Future.wait(List.generate(5, (_) => quiz.getToday(a.session))),
      );
      expect(initial.map((t) => t.free!.assignmentId).toSet(), hasLength(1));
      final free = initial.first.free!;
      expect(initial.first.paidEntitlement, isFalse);
      await expectLater(
        at(
          () => adEndpoint.createIntent(
            a.session,
            'extraQuiz',
            initial.first.date,
            free.assignmentId,
            AdPlatform.ios,
          ),
        ),
        error('freeRequired'),
      );
      final answered = await Future.wait(
        List.generate(5, (i) => answer(a.session, free, 1, 'concurrent-$i')),
      );
      expect(answered.every((q) => q.awardedPoints == 2), isTrue);
      expect(await points(a.owner), 2);
      await expectLater(
        answer(a.session, free, 0, 'changed'),
        error('alreadyAnswered'),
      );
      await expectLater(
        answer(a.session, free, 0, 'concurrent-0'),
        error('idempotencyConflict'),
      );
      final t = await at(() => quiz.getToday(a.session));
      final i = await verified(a.session, t);
      final grants = await at(
        () => Future.wait(
          List.generate(
            4,
            (_) => quiz.unlockExtra(
              a.session,
              t.date,
              t.extraRevision!,
              i.id,
              'unlock',
            ),
          ),
        ),
      );
      expect(grants.map((q) => q.assignmentId).toSet(), hasLength(1));
      final extra = grants.first;
      expect(extra.questionId, isNot(free.questionId));
      expect((await adEndpoint.getIntent(a.session, i.id)).status, 'consumed');
      await expectLater(
        at(
          () => quiz.unlockExtra(
            a.session,
            t.date,
            t.extraRevision!,
            i.id,
            'second',
          ),
        ),
        error('dailyLimitReached'),
      );
      await expectLater(
        at(
          () => adEndpoint.createIntent(
            a.session,
            'extraQuiz',
            t.date,
            t.extraRevision!,
            AdPlatform.ios,
          ),
        ),
        error('dailyLimitReached'),
      );
      await answer(a.session, extra);
      expect(await points(a.owner), 4);
      expect((await at(() => quiz.getToday(a.session))).extraStatus, 'issued');
      final history = await quiz.listHistory(a.session, null);
      expect(history, hasLength(2));
      expect(
        (await quiz.listHistory(
          a.session,
          history.first.assignmentId,
        )).single.assignmentId,
        free.assignmentId,
      );
      await quiz.review(a.session, free.assignmentId);
      await quiz.review(a.session, extra.assignmentId);
      expect(await points(a.owner), 4);
      // Synthetic bank grants never appear in the production wallet.
      expect((await ProductEndpoint().getWallet(a.session)).balance, 0);
    },
  );

  test(
    'wallet includes quiz policy without changing step or fixture balances',
    () async {
      final a = await user();
      // Production credit fixtures exercise policy routing; no test question is
      // represented as reviewed production content.
      for (final entry in [
        ('steps', stepPolicyVersion, 7),
        ('quiz', quizPolicyVersion, 2),
        ('legacy', productFixtureLabel, 50),
        ('synthetic', quizFixturePolicy, 50),
      ]) {
        await ProductService.run(
          a.session,
          (s) => s.appendPointEntry(
            PointEntry(
              owner: a.owner,
              entryKey: entry.$1,
              kind: entry.$1,
              amount: entry.$3,
              policyVersion: entry.$2,
              createdAt: now,
            ),
          ),
        );
      }
      expect((await a.client.product.getWallet()).balance, 9);
      expect((await a.client.product.listThemes()).balance, 9);
    },
  );

  test(
    'database uniqueness rejects duplicate slots and seen revisions',
    () async {
      final a = await user();
      final q = (await at(() => quiz.getToday(a.session))).free!;
      final stored = (await QuizAssignment.db.findById(admin, q.assignmentId))!;
      for (final duplicate in [
        stored.copyWith(id: null, questionId: 'different-question'),
        stored.copyWith(id: null, date: '2026-10-20'),
        stored.copyWith(id: null, date: '2026-10-20', version: 2),
      ]) {
        await expectLater(
          QuizAssignment.db.insertRow(admin, duplicate),
          throwsA(
            isA<DatabaseQueryException>().having(
              (e) => e.code,
              'code',
              '23505',
            ),
          ),
        );
      }
    },
  );

  test(
    'invalid answer identity cursor cross-owner and future-date rejection',
    () async {
      final a = await user();
      final b = await user();
      final q = (await at(() => quiz.getToday(a.session))).free!;
      await expectLater(answer(a.session, q, -1), error('invalidAnswer'));
      await expectLater(answer(a.session, q, 2), error('invalidAnswer'));
      await expectLater(
        at(
          () => quiz.answer(
            a.session,
            q.assignmentId,
            q.questionId,
            2,
            0,
            'version',
          ),
        ),
        error('staleQuestion'),
      );
      await expectLater(
        at(
          () =>
              quiz.answer(a.session, q.assignmentId, 'other', 1, 0, 'identity'),
        ),
        error('staleQuestion'),
      );
      await expectLater(answer(b.session, q), error('quizNotFound'));
      await expectLater(
        quiz.review(b.session, q.assignmentId),
        error('quizNotFound'),
      );
      await expectLater(
        quiz.review(a.session, q.assignmentId),
        error('notAnswered'),
      );
      await expectLater(quiz.listHistory(a.session, 0), error('invalidCursor'));
      await expectLater(
        at(
          () => quiz.unlockExtra(
            a.session,
            '2026-10-20',
            q.assignmentId,
            'x',
            'future',
          ),
        ),
        error('futureDate'),
      );
      expect(await points(a.owner), 0);
    },
  );

  test(
    'KST midnight closes unsubmitted and ad slots, resets only daily quota',
    () async {
      now = DateTime.utc(2026, 10, 19, 14, 59, 59, 999);
      final a = await user();
      final b = await user();
      final old = (await at(() => quiz.getToday(b.session))).free!;
      final t = await eligible(a.session);
      final i = await verified(a.session, t);
      now = DateTime.utc(2026, 10, 19, 15);
      await expectLater(
        at(
          () => quiz.unlockExtra(
            a.session,
            t.date,
            t.extraRevision!,
            i.id,
            'late',
          ),
        ),
        error('quizClosed'),
      );
      await expectLater(
        at(
          () => adEndpoint.createIntent(
            a.session,
            'extraQuiz',
            t.date,
            t.extraRevision!,
            AdPlatform.ios,
          ),
        ),
        error('quizClosed'),
      );
      await expectLater(answer(b.session, old), error('quizClosed'));
      final tomorrow = await at(() => quiz.getToday(a.session));
      expect(tomorrow.date, '2026-10-20');
      expect(tomorrow.free!.questionId, isNot(t.free!.questionId));
      expect((await adEndpoint.getIntent(a.session, i.id)).status, 'verified');
      final replay = await answer(
        a.session,
        t.free!,
        0,
        'answer-${t.free!.assignmentId}',
      );
      expect(replay.awardedPoints, 2);
      expect(await points(a.owner), 2);
    },
  );

  test(
    'empty and exhausted banks are distinct and never repeat new questions',
    () async {
      final a = await user();
      QuizBank.instances[pod] = null;
      expect(
        (await at(() => quiz.getToday(a.session))).status,
        'contentUnavailable',
      );
      await configureQuizBank(pod, bank: fixtureBank(0));
      expect((await at(() => quiz.getToday(a.session))).free, isNull);
      await configureQuizBank(pod, bank: fixtureBank(1));
      final t = await eligible(a.session);
      expect(t.extraStatus, 'exhausted');
      await expectLater(
        at(
          () => adEndpoint.createIntent(
            a.session,
            'extraQuiz',
            t.date,
            t.free!.assignmentId,
            AdPlatform.ios,
          ),
        ),
        error('exhausted'),
      );
      now = now.add(const Duration(days: 1));
      final exhausted = await at(() => quiz.getToday(a.session));
      expect(exhausted.status, 'exhausted');
      expect(exhausted.free, isNull);
      expect(
        (await quiz.listHistory(a.session, null)).single.questionId,
        t.free!.questionId,
      );
    },
  );

  test(
    'revision changes preserve snapshots and cannot regrant a seen identity',
    () async {
      await configureQuizBank(pod, bank: fixtureBank(1));
      final a = await user();
      final old = (await at(() => quiz.getToday(a.session))).free!;
      final changed = fixtureQuestion(1, version: 2)..['correctIndex'] = 1;
      await configureQuizBank(
        pod,
        bank: QuizBank.parse(fixturePack([changed])),
      );
      final result = await answer(a.session, old);
      expect(result.version, 1);
      expect(result.correctIndex, 0);
      final b = await user();
      final revised = (await at(() => quiz.getToday(b.session))).free!;
      expect(revised.version, 2);
      expect((await answer(b.session, revised, 1)).correctIndex, 1);
      await expectLater(
        configureQuizBank(
          pod,
          bank: QuizBank.parse(
            fixturePack([
              fixtureQuestion(1)..['correctIndex'] = 1,
            ]),
          ),
        ),
        throwsFormatException,
      );
      now = now.add(const Duration(days: 1));
      expect((await at(() => quiz.getToday(a.session))).status, 'exhausted');
      QuizBank.instances[pod] = null;
      final review = await quiz.review(a.session, old.assignmentId);
      expect(review.toJson(), result.toJson());
      expect(await points(a.owner), 2);
      expect(await points(b.owner), 2);
    },
  );

  test(
    'verified ad checks target owner purpose and rolls back with issue failure',
    () async {
      final a = await user();
      final b = await user();
      final t = await eligible(a.session);
      final other = await eligible(b.session);
      await expectLater(
        at(
          () => adEndpoint.createIntent(
            a.session,
            'extraQuiz',
            t.date,
            t.extraRevision! + 1,
            AdPlatform.ios,
          ),
        ),
        error('staleProjection'),
      );
      final pending = await at(
        () => adEndpoint.createIntent(
          a.session,
          'extraQuiz',
          t.date,
          t.extraRevision!,
          AdPlatform.ios,
        ),
      );
      await expectLater(
        at(
          () => quiz.unlockExtra(
            a.session,
            t.date,
            t.extraRevision!,
            pending.id,
            'pending',
          ),
        ),
        adError('intentNotVerified'),
      );
      final i = await verified(a.session, t);
      await expectLater(
        at(
          () => quiz.unlockExtra(
            b.session,
            other.date,
            other.extraRevision!,
            i.id,
            'cross',
          ),
        ),
        adError('intentNotFound'),
      );
      await configureQuizBank(pod, bank: fixtureBank(0));
      await expectLater(
        at(
          () => quiz.unlockExtra(
            a.session,
            t.date,
            t.extraRevision!,
            i.id,
            'empty',
          ),
        ),
        error('contentUnavailable'),
      );
      expect((await adEndpoint.getIntent(a.session, i.id)).status, 'verified');
      await configureQuizBank(pod, bank: fixtureBank());
      await admin.db.unsafeExecute(
        'CREATE FUNCTION reject_quiz_issue() RETURNS trigger LANGUAGE plpgsql '
        "AS 'BEGIN RAISE EXCEPTION ''test issue failure''; END'",
      );
      await admin.db.unsafeExecute(
        'CREATE TRIGGER reject_quiz_issue BEFORE INSERT ON quiz_assignment '
        'FOR EACH ROW EXECUTE FUNCTION reject_quiz_issue()',
      );
      try {
        await expectLater(
          at(
            () => quiz.unlockExtra(
              a.session,
              t.date,
              t.extraRevision!,
              i.id,
              'rollback',
            ),
          ),
          throwsA(isA<DatabaseQueryException>()),
        );
        expect(
          (await adEndpoint.getIntent(a.session, i.id)).status,
          'verified',
        );
        expect(
          (await QuizAssignment.db.find(
            admin,
            where: (q) => q.owner.equals(a.owner),
          )),
          hasLength(1),
        );
      } finally {
        await admin.db.unsafeExecute(
          'DROP TRIGGER reject_quiz_issue ON quiz_assignment',
        );
        await admin.db.unsafeExecute('DROP FUNCTION reject_quiz_issue()');
      }
      final q = await at(
        () => quiz.unlockExtra(
          a.session,
          t.date,
          t.extraRevision!,
          i.id,
          'rollback',
        ),
      );
      expect(q.slot, 'extra');
      expect((await adEndpoint.getIntent(a.session, i.id)).status, 'consumed');
    },
  );

  test('dailyReward proof cannot unlock extra or bypass its quota', () async {
    final a = await user();
    final t = await eligible(a.session);
    final product = ProductEndpoint();
    await product.registerStepStream(a.session, 'stream', 0);
    await at(
      () => product.submitSteps(
        a.session,
        DailyStepInput(
          date: t.date,
          streamGeneration: 1,
          revision: 1,
          windowStart: dayStart(t.date),
          windowEnd: dayStart(t.date).add(const Duration(days: 1)),
          observedAt: now,
          total: 100,
          availability: 'confirmed',
        ),
      ),
    );
    final reward = await at(
      () => adEndpoint.createIntent(
        a.session,
        'dailyReward',
        t.date,
        1,
        AdPlatform.android,
      ),
    );
    await ads.callback(
      admin,
      signAd(
        'ad_network=123&ad_unit=${reward.adUnit}&custom_data=${reward.customData}'
        '&reward_amount=1&reward_item=quiz&timestamp=${now.millisecondsSinceEpoch}'
        '&transaction_id=${(++transactionSequence).toRadixString(16)}&user_id=${reward.userId}',
      ),
    );
    await expectLater(
      at(
        () => quiz.unlockExtra(
          a.session,
          t.date,
          t.extraRevision!,
          reward.id,
          'wrong-purpose',
        ),
      ),
      adError('targetMismatch'),
    );
    expect(
      (await adEndpoint.getIntent(a.session, reward.id)).status,
      'verified',
    );
    expect((await at(() => quiz.getToday(a.session))).extra, isNull);
  });

  test(
    'answer transaction rollback cannot leave reward or replay behind',
    () async {
      final a = await user();
      final q = (await at(() => quiz.getToday(a.session))).free!;
      await expectLater(
        at(
          () => ProductService.run(a.session, (s) async {
            await QuizService(s).answer(
              q.assignmentId,
              q.questionId,
              q.version,
              1,
              'rollback-answer',
            );
            throw StateError('rollback');
          }),
        ),
        throwsStateError,
      );
      expect(await points(a.owner), 0);
      expect(
        (await at(() => quiz.getToday(a.session))).free!.answerIndex,
        isNull,
      );
      expect(
        (await answer(a.session, q, 1, 'rollback-answer')).awardedPoints,
        2,
      );
      expect(await points(a.owner), 2);
    },
  );

  test(
    'repeat getToday finishes while another session holds the account lock',
    () async {
      final a = await user();
      final first = await at(() => quiz.getToday(a.session));
      final locked = Completer<void>();
      final release = Completer<void>();
      final write = admin.db.transaction((tx) async {
        await lockProductAccount(admin, a.owner, tx);
        locked.complete();
        await release.future.timeout(bound);
      });
      try {
        await locked.future.timeout(bound);
        final again = await at(
          () => quiz.getToday(a.session),
        ).timeout(const Duration(seconds: 5));
        expect(again.status, 'ready');
        expect(again.free!.assignmentId, first.free!.assignmentId);
      } finally {
        release.complete();
        await write;
      }
    },
  );

  test('concurrent first getToday calls issue exactly one free slot', () async {
    final a = await user();
    final both = await at(
      () => Future.wait([quiz.getToday(a.session), quiz.getToday(a.session)]),
    );
    expect(both.map((t) => t.free!.assignmentId).toSet(), hasLength(1));
    expect(
      await QuizAssignment.db.count(
        admin,
        where: (t) => t.owner.equals(a.owner) & t.slot.equals('free'),
      ),
      1,
    );
  });

  test('getToday without bank content stays contentUnavailable', () async {
    final a = await user();
    await configureQuizBank(pod, bank: fixtureBank(0));
    for (var i = 0; i < 2; i++) {
      final today = await at(() => quiz.getToday(a.session));
      expect(today.status, 'contentUnavailable');
      expect(today.free, isNull);
    }
    expect(
      await QuizAssignment.db.count(
        admin,
        where: (t) => t.owner.equals(a.owner),
      ),
      0,
    );
  });

  test(
    'account deletion shares auth lock and purges quizzes without resurrection',
    () async {
      final a = await user();
      final b = await user();
      final t = await eligible(a.session);
      await verified(a.session, t);
      await eligible(b.session);
      final purged = Completer<void>();
      final release = Completer<void>();
      final deletion = admin.db.transaction((tx) async {
        await deleteAccountData(a.session, a.owner, tx);
        purged.complete();
        await release.future.timeout(bound);
      });
      await purged.future.timeout(bound);
      // getToday reads lock-free once issued; listHistory still takes the lock.
      final rejected = expectLater(
        at(() => quiz.listHistory(a.session, null)),
        throwsA(isA<NotAuthorizedException>()),
      );
      release.complete();
      await deletion.timeout(bound);
      await rejected.timeout(bound);
      await expectLater(
        at(() => quiz.getToday(a.session)),
        throwsA(isA<NotAuthorizedException>()),
      );
      expect(
        await QuizAssignment.db.find(
          admin,
          where: (q) => q.owner.equals(a.owner),
        ),
        isEmpty,
      );
      expect(
        await StoredAdIntent.db.find(
          admin,
          where: (q) => q.owner.equals(a.owner),
        ),
        isEmpty,
      );
      expect(
        await ProductRequest.db.find(
          admin,
          where: (q) => q.owner.equals(a.owner),
        ),
        isEmpty,
      );
      expect(await points(a.owner), 0);
      expect(await quiz.listHistory(b.session, null), hasLength(1));
      expect(await QuizContentRevision.db.count(admin), greaterThan(0));
      await expectLater(
        a.client.quiz.getToday(),
        throwsA(isA<api.ServerpodClientUnauthorized>()),
      );
    },
  );

  group('revision-backed assignments', () {
    Future<Map<String, dynamic>> revision(String id, int version) async =>
        jsonDecode(
              (await QuizContentRevision.db.findFirstRow(
                admin,
                where: (t) =>
                    t.questionId.equals(id) & t.version.equals(version),
              ))!.snapshot,
            )
            as Map<String, dynamic>;

    QuizAssignment answered(String owner, int question, String date) =>
        QuizAssignment(
          owner: owner,
          authUserId: authUserIdOf(owner),
          date: date,
          slot: 'free',
          questionId: 'test-question-$question',
          version: 1,
          policyVersion: quizFixturePolicy,
          issuedAt: now,
          answerIndex: 0,
          answeredAt: now,
        );

    test(
      'new rows store no snapshot and reads return the revision body',
      () async {
        final a = await user();
        final t = await eligible(a.session);
        final i = await verified(a.session, t);
        final extra = await at(
          () => quiz.unlockExtra(
            a.session,
            t.date,
            t.extraRevision!,
            i.id,
            'revision-unlock',
          ),
        );
        final rows = await QuizAssignment.db.find(
          admin,
          where: (q) => q.owner.equals(a.owner),
        );
        expect(rows, hasLength(2));
        expect(rows.map((r) => r.snapshot), everyElement(isNull));
        final graded = await answer(a.session, extra);
        final today = await at(() => quiz.getToday(a.session));
        final history = await quiz.listHistory(a.session, null);
        expect(history, hasLength(2));
        final reviews = [
          for (final r in rows) await quiz.review(a.session, r.id!),
        ];
        for (final q in [
          today.free!,
          today.extra!,
          graded,
          ...history,
          ...reviews,
        ]) {
          final body = await revision(q.questionId, q.version);
          expect(q.question, body['question']);
          expect(q.choices, body['choices']);
          expect(q.conditions, body['conditions']);
          expect(q.reviewedAt, body['reviewedAt']);
          expect(q.reviewedBy, body['reviewedBy']);
          expect(q.correctIndex, body['correctIndex']);
          expect(q.explanation, body['explanation']);
          expect(q.source, body['source']);
        }
      },
    );

    test('rows that still carry a snapshot read back identically', () async {
      final a = await user();
      final body = await revision('test-question-2', 1);
      final legacy = await QuizAssignment.db.insertRow(
        admin,
        answered(a.owner, 2, '2026-10-18').copyWith(snapshot: jsonEncode(body)),
      );
      final withCopy = await quiz.review(a.session, legacy.id!);
      final historyWithCopy = await quiz.listHistory(a.session, null);
      await QuizAssignment.db.updateRow(admin, legacy.copyWith(snapshot: null));
      expect(
        (await QuizAssignment.db.findById(admin, legacy.id!))!.snapshot,
        isNull,
      );
      final fromRevision = await quiz.review(a.session, legacy.id!);
      expect(withCopy.toJson(), fromRevision.toJson());
      expect(
        historyWithCopy.single.toJson(),
        (await quiz.listHistory(a.session, null)).single.toJson(),
      );
      expect(withCopy.question, body['question']);
    });

    test(
      'issuing a question without a content revision is contentUnavailable',
      () async {
        final a = await user();
        // Installed in memory only, so no quiz_content_revision row exists.
        QuizBank.instances[pod] = QuizBank.parse(
          fixturePack([fixtureQuestion(99)]),
        );
        await expectLater(
          at(() => quiz.getToday(a.session)),
          error('contentUnavailable'),
        );
        expect(
          await QuizAssignment.db.count(
            admin,
            where: (t) => t.owner.equals(a.owner),
          ),
          0,
        );
      },
    );

    test('malformed revision JSON fails in the existing decode path', () async {
      final a = await user();
      await QuizContentRevision.db.insertRow(
        admin,
        QuizContentRevision(
          questionId: 'test-question-malformed',
          version: 1,
          snapshot: '{not json',
        ),
      );
      final row = await QuizAssignment.db.insertRow(
        admin,
        answered(
          a.owner,
          0,
          '2026-10-18',
        ).copyWith(questionId: 'test-question-malformed'),
      );
      await expectLater(quiz.review(a.session, row.id!), throwsFormatException);
      await expectLater(
        quiz.listHistory(a.session, null),
        throwsFormatException,
      );
    });

    test(
      '30-row history page reads revisions in one query, not per row',
      () async {
        await configureQuizBank(pod, bank: fixtureBank(30));
        final a = await user();
        for (var i = 1; i <= 30; i++) {
          await QuizAssignment.db.insertRow(
            admin,
            answered(a.owner, i, '2026-09-${i.toString().padLeft(2, '0')}'),
          );
        }
        final original = pod.runtimeSettings;
        await pod.updateRuntimeSettings(
          original.copyWith(
            logSettings: original.logSettings.copyWith(
              logAllSessions: true,
              logAllQueries: true,
            ),
          ),
        );
        final before =
            (await admin.db.unsafeQuery(
                  'SELECT COALESCE(MAX(id), 0) FROM serverpod_session_log',
                )).first.first
                as int;
        final logged = await pod.createSession(enableLogging: true);
        final List<QuizQuestion> page;
        try {
          page = await logged.db.transaction(
            (tx) => QuizService(
              ProductService(
                logged,
                a.owner,
                tx,
                ProductAccount(owner: a.owner),
              ),
            ).history(null),
          );
        } finally {
          // Closing awaits the session log flush, so the rows are persisted.
          await logged.close();
          await pod.updateRuntimeSettings(original);
        }
        final queries = await admin.db.unsafeQuery(
          'SELECT q.query FROM serverpod_query_log q '
          'JOIN serverpod_session_log s ON s.id = q."sessionLogId" '
          'WHERE s.id > @before ORDER BY q."sessionLogId", q."order"',
          parameters: QueryParameters.named({'before': before}),
        );
        stdout.writeln(
          'QUERY-COUNT history rows=${page.length} '
          'serverpod_query_log rows=${queries.length}',
        );
        for (final q in queries) {
          stdout.writeln('QUERY-COUNT query: ${q.first}');
        }
        expect(page, hasLength(30));
        expect(page.map((q) => q.questionId).toSet(), hasLength(30));
        expect(queries, isNotEmpty);
        expect(queries.length, lessThanOrEqualTo(3));
      },
    );
  });
}
