import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../billing/billing_service.dart';
import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'quiz_service.dart';

class QuizEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<QuizToday> getToday(Session session) =>
      ProductService.run(session, (s) => QuizService(s).today());

  Future<QuizToday> getTodayWithPremium(Session session) =>
      BillingService.run(session, (billing, db) async {
        final premium = await billing.revalidateBenefit(db);
        return ProductService.run(
          db,
          (s) => QuizService(s).today(premium: premium),
        );
      });

  Future<QuizQuestion> unlockExtraWithPremium(
    Session session,
    String date,
    int expectedRevision,
    String requestId,
  ) async {
    final previous = await ProductService.run(
      session,
      (s) =>
          s.replay(requestId, ['quiz.unlockPremium', date, expectedRevision]),
    );
    if (previous != null) {
      return QuizQuestion.fromJson(
        jsonDecode(previous) as Map<String, dynamic>,
      );
    }
    return BillingService.run(session, (billing, db) async {
      final premium = await billing.revalidateBenefit(db);
      return ProductService.run(
        db,
        (s) => QuizService(s).unlock(
          date,
          expectedRevision,
          null,
          requestId,
          premium: premium,
        ),
      );
    });
  }

  Future<QuizQuestion> unlockExtra(
    Session session,
    String date,
    int expectedRevision,
    String intentId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => QuizService(s).unlock(date, expectedRevision, intentId, requestId),
  );

  Future<QuizQuestion> answer(
    Session session,
    int assignmentId,
    String questionId,
    int version,
    int answerIndex,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => QuizService(s).answer(
      assignmentId,
      questionId,
      version,
      answerIndex,
      requestId,
    ),
  );

  Future<List<QuizQuestion>> listHistory(
    Session session,
    int? beforeAssignmentId,
  ) => ProductService.run(
    session,
    (s) => QuizService(s).history(beforeAssignmentId),
  );

  Future<QuizQuestion> review(Session session, int assignmentId) =>
      ProductService.run(session, (s) => QuizService(s).review(assignmentId));
}
