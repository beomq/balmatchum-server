import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';

const quizPolicyVersion = 'quiz-v1-20261019';
const quizFixturePolicy = 'quiz-test-fixture-not-production';

/// A parsed pack is immutable. Approval is supplied by accountable reviewers,
/// never inferred from prose, a source URL, or the desired corpus size.
class QuizBank {
  QuizBank._(this.snapshots, this.fixture);
  final List<String> snapshots;
  final bool fixture;
  static final instances = Expando<QuizBank>();

  factory QuizBank.parse(String content) {
    final raw = jsonDecode(content) as Map<String, dynamic>;
    if (raw['schemaVersion'] != 1 ||
        !{'reviewed', 'testFixture'}.contains(raw['kind'])) {
      throw const FormatException('Invalid quiz pack header');
    }
    final fixture = raw['kind'] == 'testFixture';
    final ids = <String>{};
    final snapshots = <String>[];
    for (final item in raw['questions'] as List<dynamic>) {
      final q = item as Map<String, dynamic>;
      String text(String key) {
        final value = q[key];
        if (value is! String || value.trim().isEmpty) {
          throw FormatException('Missing quiz field: $key');
        }
        return value;
      }

      final id = text('questionId');
      final version = q['version'];
      final choices = q['choices'];
      final correct = q['correctIndex'];
      final reviewedAt = text('reviewedAt');
      dayStart(reviewedAt);
      final source = text('source');
      final uri = Uri.tryParse(source);
      if (!RegExp(r'^[a-z0-9][a-z0-9_-]{0,95}$').hasMatch(id) ||
          !ids.add(id) ||
          version is! int ||
          version < 1 ||
          choices is! List ||
          choices.length < 2 ||
          choices.length > 8 ||
          choices.any((c) => c is! String || c.trim().isEmpty) ||
          choices.toSet().length != choices.length ||
          correct is! int ||
          correct < 0 ||
          correct >= choices.length ||
          reviewedAt.compareTo(localDate(clock.now())) > 0 ||
          q['reviewStatus'] != (fixture ? 'testFixture' : 'approved') ||
          uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty) {
        throw const FormatException('Invalid quiz review or question');
      }
      snapshots.add(
        jsonEncode({
          'questionId': id,
          'version': version,
          'question': text('question'),
          'choices': choices,
          'correctIndex': correct,
          'explanation': text('explanation'),
          'source': source,
          'conditions': text('conditions'),
          'reviewedAt': reviewedAt,
          'reviewedBy': text('reviewedBy'),
          'reviewStatus': q['reviewStatus'],
          'fixture': fixture,
        }),
      );
    }
    return QuizBank._(List.unmodifiable(snapshots), fixture);
  }
}

/// An absent path leaves new issuance unavailable, not backed by fake content.
Future<void> configureQuizBank(Serverpod pod, {QuizBank? bank}) async {
  if (bank == null) {
    final path = Platform.environment['BALMATCHUM_QUIZ_BANK_PATH'];
    if (path == null) return;
    bank = QuizBank.parse(await File(path).readAsString());
  }
  if (bank.fixture && pod.config.runMode != ServerpodRunMode.test) {
    throw const FormatException('Quiz fixtures require test run mode');
  }
  final session = await pod.createSession(enableLogging: false);
  try {
    await session.db.transaction((tx) async {
      // All pack installs serialize, including different server processes.
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(71430)',
        transaction: tx,
      );
      for (final snapshot in bank!.snapshots) {
        final q = jsonDecode(snapshot) as Map<String, dynamic>;
        final existing = await QuizContentRevision.db.findFirstRow(
          session,
          where: (t) =>
              t.questionId.equals(q['questionId'] as String) &
              t.version.equals(q['version'] as int),
          transaction: tx,
        );
        if (existing != null) {
          if (existing.snapshot != snapshot) {
            throw const FormatException('Quiz revision identity conflict');
          }
        } else {
          await QuizContentRevision.db.insertRow(
            session,
            QuizContentRevision(
              questionId: q['questionId'] as String,
              version: q['version'] as int,
              snapshot: snapshot,
            ),
            transaction: tx,
          );
        }
      }
    });
    QuizBank.instances[pod] = bank;
  } finally {
    await session.close();
  }
}
