import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'product_service.dart';

/// Test content only. The production reviewed question bank is not configured.
const _questionId = 'fixture-walk-water-v1';
const _defaultThemePrice = 0;
const _paidThemePrice = 3;
const _themes = {
  'sunny': ('맑음', 0xfff5eedc),
  'cloudy': ('흐림', 0xffe4e7e9),
  'rainy': ('비', 0xffdce8ef),
  'snowy': ('눈', 0xffeef3f6),
};

extension QuizThemeService on ProductService {
  DailyQuiz quizView(QuizState value) => DailyQuiz(
    date: value.date,
    questionId: value.questionId,
    question: '[개발 fixture] 산책 중 강아지에게 준비할 것은?',
    choices: ['깨끗한 물', '초콜릿'],
    answerIndex: value.answerIndex,
    correctIndex: value.answerIndex == null ? null : 0,
    explanation: value.answerIndex == null
        ? null
        : '깨끗한 물을 준비하고 상태를 확인해요. 개발 검증용 문항입니다.',
    awardedPoints: value.awardedPoints,
    fixtureLabel: productFixtureLabel,
  );

  Future<QuizState> quizState(String date) async {
    dayStart(date);
    requireProductFixtures(session);
    final existing = await QuizState.db.findFirstRow(
      session,
      where: (t) => t.owner.equals(owner) & t.date.equals(date),
      transaction: tx,
    );
    if (existing != null) return existing;
    if (date != localDate(clock.now())) {
      throw ProductException(code: 'quizUnavailable');
    }
    return QuizState.db.insertRow(
      session,
      QuizState(owner: owner, date: date, questionId: _questionId),
      transaction: tx,
    );
  }

  Future<DailyQuiz> quiz(String date) async => quizView(await quizState(date));

  Future<List<DailyQuiz>> quizHistory(String beforeDate) async {
    dayStart(beforeDate);
    requireProductFixtures(session);
    final values = await QuizState.db.find(
      session,
      where: (t) =>
          t.owner.equals(owner) &
          t.answerIndex.notEquals(null) &
          (t.date < beforeDate),
      orderBy: (t) => t.date.desc(),
      limit: 30,
      transaction: tx,
    );
    return values.map(quizView).toList();
  }

  Future<DailyQuiz> answerQuiz(
    String date,
    int answerIndex,
    String requestId,
  ) async {
    final payload = ['answerQuiz', date, answerIndex];
    final previous = await replay(requestId, payload);
    if (previous != null) {
      return DailyQuiz.fromJson(jsonDecode(previous) as Map<String, dynamic>);
    }
    if (answerIndex < 0 || answerIndex > 1) {
      throw ProductException(code: 'invalidAnswer');
    }
    final value = await quizState(date);
    if (value.answerIndex != null) {
      if (value.answerIndex != answerIndex) {
        throw ProductException(code: 'alreadyAnswered');
      }
    } else {
      if (date != localDate(clock.now())) {
        throw ProductException(code: 'quizClosed');
      }
      value.answerIndex = answerIndex;
      value.answeredAt = clock.now().toUtc();
      value.awardedPoints = answerIndex == 0 ? 2 : 0;
      if (value.awardedPoints > 0) {
        await PointEntry.db.insertRow(
          session,
          PointEntry(
            owner: owner,
            entryKey: 'quiz:$date',
            kind: 'quiz',
            date: date,
            amount: value.awardedPoints,
            policyVersion: productFixtureLabel,
            createdAt: value.answeredAt!,
          ),
          transaction: tx,
        );
      }
      await QuizState.db.updateRow(session, value, transaction: tx);
    }
    final result = quizView(value);
    await remember(requestId, payload, result.toJson());
    return result;
  }

  Future<ThemeStore> themes() async {
    final owned = await ThemeOwnership.db.find(
      session,
      where: (t) => t.owner.equals(owner),
      transaction: tx,
    );
    final fixture = productFixturesEnabled(session);
    return ThemeStore(
      items: [
        for (final entry in _themes.entries)
          ThemeItem(
            themeId: entry.key,
            name: entry.value.$1,
            colorValue: entry.value.$2,
            price: entry.key == 'sunny' ? _defaultThemePrice : _paidThemePrice,
            owned:
                entry.key == 'sunny' ||
                owned.any((o) => o.themeId == entry.key),
          ),
      ],
      equippedTheme: account.equippedTheme,
      balance: await balance(fixture: fixture),
      fixtureLabel: fixture ? productFixtureLabel : null,
    );
  }

  Future<ThemeStore> purchase(String themeId, String requestId) async {
    final payload = ['purchaseTheme', themeId];
    final previous = await replay(requestId, payload);
    if (previous != null) {
      return ThemeStore.fromJson(jsonDecode(previous) as Map<String, dynamic>);
    }
    final store = await themes();
    final matches = store.items.where((item) => item.themeId == themeId);
    if (matches.isEmpty) throw ProductException(code: 'unknownTheme');
    final item = matches.single;
    if (!item.owned) {
      if (store.balance < item.price!) {
        throw ProductException(code: 'insufficientPoints');
      }
      await PointEntry.db.insertRow(
        session,
        PointEntry(
          owner: owner,
          entryKey: 'theme:$themeId',
          kind: 'purchase',
          amount: -item.price!,
          policyVersion: productFixturesEnabled(session)
              ? productFixtureLabel
              : themePurchasePolicyVersion,
          createdAt: clock.now().toUtc(),
        ),
        transaction: tx,
      );
      await ThemeOwnership.db.insertRow(
        session,
        ThemeOwnership(
          owner: owner,
          themeId: themeId,
          purchasedAt: clock.now().toUtc(),
        ),
        transaction: tx,
      );
    }
    final result = await themes();
    await remember(requestId, payload, result.toJson());
    return result;
  }

  Future<ThemeStore> equip(String themeId, String requestId) async {
    final payload = ['equipTheme', themeId];
    final previous = await replay(requestId, payload);
    if (previous != null) {
      return ThemeStore.fromJson(jsonDecode(previous) as Map<String, dynamic>);
    }
    final store = await themes();
    if (!store.items.any((item) => item.themeId == themeId && item.owned)) {
      throw ProductException(code: 'themeNotOwned');
    }
    account.equippedTheme = themeId;
    await ProductAccount.db.updateRow(session, account, transaction: tx);
    final result = await themes();
    await remember(requestId, payload, result.toJson());
    return result;
  }
}
