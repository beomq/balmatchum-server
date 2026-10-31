import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../ads/ad_service.dart';
import '../billing/billing_service.dart';
import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'quiz_bank.dart';

class QuizService {
  QuizService(this.s) : bank = QuizBank.instances[s.session.server.serverpod];
  final ProductService s;
  final QuizBank? bank;

  QuizQuestion view(QuizAssignment a) {
    final q = jsonDecode(a.snapshot!) as Map<String, dynamic>;
    final answered = a.answerIndex != null;
    return QuizQuestion(
      assignmentId: a.id!,
      date: a.date,
      slot: a.slot,
      questionId: a.questionId,
      version: a.version,
      question: q['question'] as String,
      choices: (q['choices'] as List).cast<String>(),
      conditions: q['conditions'] as String,
      reviewedAt: q['reviewedAt'] as String,
      reviewedBy: q['reviewedBy'] as String,
      answerIndex: a.answerIndex,
      correctIndex: answered ? q['correctIndex'] as int : null,
      explanation: answered ? q['explanation'] as String : null,
      source: answered ? q['source'] as String : null,
      answeredAt: a.answeredAt,
      awardedPoints: a.awardedPoints,
      policyVersion: a.policyVersion,
      fixtureLabel: q['fixture'] == true ? quizFixturePolicy : null,
    );
  }

  Future<QuizAssignment?> slot(String date, String slot) =>
      QuizAssignment.db.findFirstRow(
        s.session,
        where: (t) =>
            t.owner.equals(s.owner) & t.date.equals(date) & t.slot.equals(slot),
        transaction: s.tx,
      );

  Future<String?> candidate() async {
    final seen = await QuizAssignment.db.find(
      s.session,
      where: (t) => t.owner.equals(s.owner),
      transaction: s.tx,
    );
    final ids = seen.map((a) => a.questionId).toSet();
    for (final snapshot in bank?.snapshots ?? <String>[]) {
      final q = jsonDecode(snapshot) as Map<String, dynamic>;
      // A corrected revision is not a newly earned question for prior readers.
      if (!ids.contains(q['questionId'])) return snapshot;
    }
    return null;
  }

  String get unavailable => bank == null || bank!.snapshots.isEmpty
      ? 'contentUnavailable'
      : 'exhausted';

  Future<QuizAssignment> issue(String date, String slot, String snapshot) {
    final q = jsonDecode(snapshot) as Map<String, dynamic>;
    return QuizAssignment.db.insertRow(
      s.session,
      QuizAssignment(
        owner: s.owner,
        date: date,
        slot: slot,
        questionId: q['questionId'] as String,
        version: q['version'] as int,
        snapshot: snapshot,
        policyVersion: bank!.fixture ? quizFixturePolicy : quizPolicyVersion,
        issuedAt: clock.now().toUtc(),
      ),
      transaction: s.tx,
    );
  }

  /// Issue-free projection for lock-free reads; null when today's free slot
  /// is still missing and [today] must issue it under the account lock.
  Future<QuizToday?> todayView({BillingBenefit? premium}) async {
    final date = localDate(clock.now());
    final free = await slot(date, 'free');
    return free == null ? null : project(date, free, premium);
  }

  Future<QuizToday> today({BillingBenefit? premium}) async {
    final date = localDate(clock.now());
    var free = await slot(date, 'free');
    if (free == null) {
      final next = await candidate();
      if (next != null) free = await issue(date, 'free', next);
    }
    return project(date, free, premium);
  }

  Future<QuizToday> project(
    String date,
    QuizAssignment? free,
    BillingBenefit? premium,
  ) async {
    final paid = premium != null && await premium.isActive(s);
    final extra = await slot(date, 'extra');
    final extraStatus = extra != null
        ? 'issued'
        : free?.answerIndex == null
        ? 'freeRequired'
        : await candidate() == null
        ? unavailable
        : paid
        ? 'premiumAvailable'
        : 'adRequired';
    return QuizToday(
      date: date,
      status: free == null ? unavailable : 'ready',
      free: free == null ? null : view(free),
      extra: extra == null ? null : view(extra),
      extraStatus: extraStatus,
      // Immutable assignment ID is the extra-slot eligibility revision.
      extraRevision: {'adRequired', 'premiumAvailable'}.contains(extraStatus)
          ? free!.id
          : null,
      paidEntitlement: paid,
      premiumStatus: premium == null
          ? 'notChecked'
          : paid
          ? 'active'
          : 'inactive',
    );
  }

  Future<String> extraTarget(String date, int revision) async {
    dayStart(date);
    final today = localDate(clock.now());
    if (date.compareTo(today) > 0) throw ProductException(code: 'futureDate');
    if (date != today) throw ProductException(code: 'quizClosed');
    final free = await slot(date, 'free');
    if (free?.answerIndex == null) throw ProductException(code: 'freeRequired');
    if (free!.id != revision) throw ProductException(code: 'staleProjection');
    if (await slot(date, 'extra') != null) {
      throw ProductException(code: 'dailyLimitReached');
    }
    final next = await candidate();
    if (next == null) throw ProductException(code: unavailable);
    return next;
  }

  Future<QuizQuestion> unlock(
    String date,
    int revision,
    String? intentId,
    String requestId, {
    BillingBenefit? premium,
  }) async {
    final payload = premium != null
        ? ['quiz.unlockPremium', date, revision]
        : ['quiz.unlock', date, revision, intentId];
    final replay = await s.replay(requestId, payload);
    if (replay != null) {
      return QuizQuestion.fromJson(jsonDecode(replay) as Map<String, dynamic>);
    }
    if (premium != null) await premium.requireActive(s);
    final next = await extraTarget(date, revision);
    if (premium == null) {
      final ads = AdService.instances[s.session.server.serverpod];
      if (ads == null) throw AdException(code: 'configurationMissing');
      await ads.consume(
        s.session,
        s.tx,
        owner: s.owner,
        intentId: intentId!,
        purpose: 'extraQuiz',
        targetDate: date,
        targetRevision: revision,
      );
    }
    final result = view(await issue(date, 'extra', next));
    await s.remember(requestId, payload, result.toJson());
    return result;
  }

  Future<QuizAssignment> owned(int id) async {
    final a = await QuizAssignment.db.findFirstRow(
      s.session,
      where: (t) => t.id.equals(id) & t.owner.equals(s.owner),
      transaction: s.tx,
    );
    if (a == null) throw ProductException(code: 'quizNotFound');
    return a;
  }

  Future<QuizQuestion> answer(
    int id,
    String questionId,
    int version,
    int answerIndex,
    String requestId,
  ) async {
    final payload = ['quiz.answer', id, questionId, version, answerIndex];
    final replay = await s.replay(requestId, payload);
    if (replay != null) {
      return QuizQuestion.fromJson(jsonDecode(replay) as Map<String, dynamic>);
    }
    final a = await owned(id);
    if (a.questionId != questionId || a.version != version) {
      throw ProductException(code: 'staleQuestion');
    }
    final q = jsonDecode(a.snapshot!) as Map<String, dynamic>;
    if (answerIndex < 0 || answerIndex >= (q['choices'] as List).length) {
      throw ProductException(code: 'invalidAnswer');
    }
    if (a.answerIndex != null) {
      if (a.answerIndex != answerIndex) {
        throw ProductException(code: 'alreadyAnswered');
      }
    } else {
      if (a.date != localDate(clock.now())) {
        throw ProductException(code: 'quizClosed');
      }
      a.answerIndex = answerIndex;
      a.answeredAt = clock.now().toUtc();
      a.awardedPoints = 2;
      await s.appendPointEntry(
        PointEntry(
          owner: s.owner,
          entryKey: 'quiz-assignment:${a.id}',
          kind: 'quiz',
          date: a.date,
          amount: 2,
          policyVersion: a.policyVersion,
          createdAt: a.answeredAt!,
        ),
      );
      await QuizAssignment.db.updateRow(s.session, a, transaction: s.tx);
    }
    final result = view(a);
    await s.remember(requestId, payload, result.toJson());
    return result;
  }

  Future<QuizQuestion> review(int id) async {
    final a = await owned(id);
    if (a.answerIndex == null) throw ProductException(code: 'notAnswered');
    return view(a);
  }

  Future<List<QuizQuestion>> history(int? before) async {
    if (before != null && before <= 0) {
      throw ProductException(code: 'invalidCursor');
    }
    final rows = await QuizAssignment.db.find(
      s.session,
      where: (t) =>
          t.owner.equals(s.owner) &
          t.answerIndex.notEquals(null) &
          (before == null ? t.id.notEquals(null) : t.id < before),
      orderBy: (t) => t.id.desc(),
      limit: 30,
      transaction: s.tx,
    );
    return rows.map(view).toList();
  }
}
