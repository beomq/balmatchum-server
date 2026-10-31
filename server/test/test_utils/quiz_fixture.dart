import 'dart:convert';

import 'package:balmatchum_server/src/quiz/quiz_bank.dart';

/// Synthetic test data, NOT reviewed dog-care content or an approved pack.
Map<String, Object> fixtureQuestion(int id, {int version = 1}) => {
  'questionId': 'test-question-$id',
  'version': version,
  'question': '[NONPRODUCTION TEST] Select fixture A or B: $id',
  'choices': ['fixture A', 'fixture B'],
  'correctIndex': 0,
  'explanation': 'Synthetic explanation $id version $version',
  'source': 'https://example.invalid/fixture/$id',
  'conditions': 'Only for automated testing, no animal-care advice.',
  'reviewedAt': '2026-10-01',
  'reviewedBy': 'automated-test-not-a-content-reviewer',
  'reviewStatus': 'testFixture',
};

String fixturePack(List<Map<String, Object>> questions) => jsonEncode({
  'schemaVersion': 1,
  'kind': 'testFixture',
  'questions': questions,
});

QuizBank fixtureBank([int count = 6]) => QuizBank.parse(
  fixturePack(List.generate(count, (i) => fixtureQuestion(i + 1))),
);
