import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../billing/billing_service.dart';
import '../generated/protocol.dart';
import 'product_service.dart';
import 'quiz_theme_service.dart';

class ProductEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<DailyRecord> getDay(Session session, String date) =>
      ProductService.run(session, (s) async => s.view(await s.day(date)));

  Future<List<DailyRecord>> listDays(
    Session session,
    String fromDate,
    String toDate,
  ) => ProductService.run(session, (s) => s.listDays(fromDate, toDate));

  Future<WalletView> getWallet(Session session) =>
      ProductService.run(session, (s) => s.wallet());

  Future<int> registerStepStream(
    Session session,
    String requestId,
    int expectedGeneration,
  ) => ProductService.run(
    session,
    (s) => s.registerStream(requestId, expectedGeneration),
  );

  Future<DailyRecord> submitSteps(Session session, DailyStepInput input) =>
      ProductService.run(session, (s) => s.submitSteps(input));

  Future<DailyRecord> deleteDay(
    Session session,
    String date,
    String requestId,
  ) => ProductService.run(session, (s) => s.deleteDay(date, requestId));

  Future<List<DailyRecord>> listDeletions(Session session, int afterVersion) =>
      ProductService.run(session, (s) => s.deletions(afterVersion));

  Future<RewardGrant> claimDay(
    Session session,
    String date,
    String requestId,
    int expectedRevision,
  ) => ProductService.run(
    session,
    (s) => s.claim(date, requestId, expectedRevision),
  );

  Future<RewardGrant> claimDayWithAd(
    Session session,
    String date,
    String requestId,
    int expectedRevision,
    String intentId,
  ) => ProductService.run(
    session,
    (s) => s.claim(date, requestId, expectedRevision, intentId: intentId),
  );

  Future<DailyQuiz> getQuiz(Session session, String date) =>
      ProductService.run(session, (s) => s.quiz(date));

  Future<RewardGrant> claimDayWithPremium(
    Session session,
    String date,
    String requestId,
    int expectedRevision,
  ) async {
    final previous = await ProductService.run(
      session,
      (s) =>
          s.replay(requestId, ['claimDayWithPremium', date, expectedRevision]),
    );
    if (previous != null) {
      return RewardGrant.fromJson(jsonDecode(previous) as Map<String, dynamic>);
    }
    return BillingService.run(session, (billing, db) async {
      final premium = await billing.revalidateBenefit(db);
      return ProductService.run(
        db,
        (s) => s.claim(date, requestId, expectedRevision, premium: premium),
      );
    });
  }

  Future<List<DailyQuiz>> listQuizHistory(Session session, String beforeDate) =>
      ProductService.run(session, (s) => s.quizHistory(beforeDate));

  Future<DailyQuiz> answerQuiz(
    Session session,
    String date,
    int answerIndex,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.answerQuiz(date, answerIndex, requestId),
  );

  Future<ThemeStore> listThemes(Session session) =>
      ProductService.run(session, (s) => s.themes());

  Future<ThemeStore> purchaseTheme(
    Session session,
    String themeId,
    String requestId,
  ) => ProductService.run(session, (s) => s.purchase(themeId, requestId));

  Future<ThemeStore> equipTheme(
    Session session,
    String themeId,
    String requestId,
  ) => ProductService.run(session, (s) => s.equip(themeId, requestId));
}
