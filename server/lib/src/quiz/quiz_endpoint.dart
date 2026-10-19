import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'quiz_service.dart';

class QuizEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<QuizToday> getToday(Session session) =>
      ProductService.run(session, (s) => QuizService(s).today());

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
