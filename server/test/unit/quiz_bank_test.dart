import 'dart:convert';

import 'package:balmatchum_server/src/quiz/quiz_bank.dart';
import 'package:test/test.dart';

import '../test_utils/quiz_fixture.dart';

void main() {
  test('fixture bank is explicitly nonproduction and immutable', () {
    final bank = fixtureBank();
    expect(bank.fixture, isTrue);
    expect(bank.snapshots, hasLength(6));
    expect(() => bank.snapshots.clear(), throwsUnsupportedError);
    expect(fixtureBank(0).snapshots, isEmpty);
  });

  test('reviewed pack never implicitly approves test or missing metadata', () {
    final pack = jsonDecode(fixturePack([fixtureQuestion(1)])) as Map;
    pack['kind'] = 'reviewed';
    expect(() => QuizBank.parse(jsonEncode(pack)), throwsFormatException);
    for (final field in [
      'reviewStatus',
      'reviewedAt',
      'reviewedBy',
      'conditions',
      'source',
      'questionId',
      'version',
      'correctIndex',
    ]) {
      final question = fixtureQuestion(1)..remove(field);
      expect(
        () => QuizBank.parse(fixturePack([question])),
        throwsA(anything),
        reason: field,
      );
    }
  });

  test('invalid choices identity source dates and versions are rejected', () {
    for (final override in <Map<String, Object>>[
      {
        'choices': ['duplicate', 'duplicate'],
      },
      {
        'choices': ['only'],
      },
      {'correctIndex': -1},
      {'correctIndex': 2},
      {'version': 0},
      {'source': 'http://example.invalid'},
      {'reviewedAt': '2099-01-01'},
      {'reviewedAt': '2026-02-30'},
      {'reviewedBy': ''},
    ]) {
      expect(
        () => QuizBank.parse(
          fixturePack([
            fixtureQuestion(1)..addAll(override),
          ]),
        ),
        throwsA(anything),
      );
    }
    expect(
      () => QuizBank.parse(
        fixturePack([
          fixtureQuestion(1),
          fixtureQuestion(1, version: 2),
        ]),
      ),
      throwsFormatException,
    );
  });
}
