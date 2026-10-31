import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../billing/billing_service.dart';
import '../generated/protocol.dart';
import '../profile/profile_service.dart';
import 'outfit_service.dart';
import 'product_service.dart';
import 'quiz_theme_service.dart';

class ProductEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<DailyRecord> getDay(Session session, String date) =>
      ProductService.read(session, (s) async => s.view(await s.day(date)));

  /// Whole home screen from ONE read snapshot; see [homeSnapshot].
  Future<HomeSnapshot> getHomeSnapshot(Session session) =>
      ProductService.read(session, homeSnapshot);

  Future<List<DailyRecord>> listDays(
    Session session,
    String fromDate,
    String toDate,
  ) => ProductService.read(session, (s) => s.listDays(fromDate, toDate));

  Future<WalletView> getWallet(Session session) =>
      ProductService.read(session, (s) => s.wallet());

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
      ProductService.read(session, (s) => s.deletions(afterVersion));

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
      ProductService.read(session, (s) => s.quizHistory(beforeDate));

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
      ProductService.read(session, (s) => s.themes());

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

  Future<OutfitStore> listOutfits(Session session) =>
      ProductService.read(session, (s) => s.outfits());

  Future<OutfitStore> purchaseOutfit(
    Session session,
    String outfitId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.purchaseOutfit(outfitId, requestId),
  );

  Future<OutfitStore> equipOutfit(
    Session session,
    String outfitId,
    String requestId,
  ) => ProductService.run(session, (s) => s.equipOutfit(outfitId, requestId));

  Future<OutfitStore> unequipOutfit(Session session, String requestId) =>
      ProductService.run(session, (s) => s.unequipOutfit(requestId));
}

/// Builds every section inside the caller's single [ProductService.read]
/// transaction, so a write committed meanwhile is either wholly visible or
/// wholly absent. Routes are excluded (home never draws them), so no GPS
/// record is read. The quiz is left out because issuing it may write.
Future<HomeSnapshot> homeSnapshot(
  ProductService s, {
  // Test-only pause after day and wallet are read, before later sections.
  Future<void> Function()? afterWallet,
}) async {
  final today = localDate(clock.now());
  final profile = await s.getProfile();
  final day = await s.view(await s.day(today), routes: false);
  final wallet = await s.wallet();
  await afterWallet?.call();
  return HomeSnapshot(
    date: today,
    profile: profile,
    day: day,
    wallet: wallet,
    themes: await s.themes(),
    outfits: await s.outfits(),
    // Same window as the app's StepStreak.window: today and 30 days before.
    recentDays: await s.listDays(
      localDate(dayStart(today).subtract(const Duration(days: 30))),
      today,
    ),
  );
}
