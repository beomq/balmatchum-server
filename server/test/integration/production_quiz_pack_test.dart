import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_client/balmatchum_client.dart' as api;
import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/quiz/quiz_bank.dart';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

class _Token implements api.ClientAuthKeyProvider {
  _Token(this.value);
  final String value;

  @override
  Future<String?> get authHeaderValue async => 'Bearer $value';
}

void main() {
  final reviewClock = Clock.fixed(DateTime.utc(2026, 10, 27, 3));
  late QuizBank bank;
  late Directory directory;
  late Serverpod pod;
  late Session admin;

  setUpAll(() async {
    final content = await File('assets/quiz/reviewed-v1.json').readAsString();
    bank = withClock(reviewClock, () => QuizBank.parse(content));
    directory = await Directory.systemTemp.createTemp('production-quiz-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (c) => c.copyWith(
        database: PostgresDatabaseConfig(
          host: '127.0.0.1',
          port: 0,
          user: 'postgres',
          password: 'local-disposable-test-only',
          dataPath: '${directory.path}/pgdata',
          name: 'production_quiz_test',
        ),
      ),
    );
    configureAuth(pod, sessionPepper: 'public-production-quiz-test-only');
    await withClock(reviewClock, () => pod.start(runInGuardedZone: false));
    await configureQuizBank(pod, bank: bank);
    admin = await pod.createSession(enableLogging: false);
  });

  tearDownAll(() async {
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  });

  test('candidate pack loads 110 sourced and explained questions', () {
    // Given: the exact bundled candidate, parsed by the production loader.
    final installed = QuizBank.instances[pod]!;

    // When: inspecting the installed snapshots.
    final questions = installed.snapshots.map(
      (snapshot) => jsonDecode(snapshot) as Map<String, dynamic>,
    );

    // Then: all 110 nonfixture questions retain their evidence.
    expect(installed.fixture, isFalse);
    expect(questions, hasLength(110));
    for (final question in questions) {
      expect(
        question['source'],
        isA<String>().having((s) => s.trim(), 'source', isNotEmpty),
      );
      expect(
        question['explanation'],
        isA<String>().having((s) => s.trim(), 'explanation', isNotEmpty),
      );
    }
  });

  test('authenticated quiz call issues a bundled nonfixture question', () async {
    // Given: an authenticated user with no prior quiz assignments.
    final user = await AuthServices.instance.authUsers.create(admin);
    final token = await AuthServices.instance.tokenManager.issueToken(
      admin,
      authUserId: user.id,
      method: 'production-quiz-test',
    );
    final client = api.Client('http://localhost:${pod.server.port}/')
      ..authKeyProvider = _Token(token.token);
    addTearDown(client.close);

    // When: calling the real generated HTTP client.
    final today = await client.quiz.getToday();

    // Then: the first supplied question is issued under the production policy.
    expect(today.status, 'ready');
    expect(today.free?.questionId, 'quiz-walk-001');
    expect(today.free?.policyVersion, quizPolicyVersion);
    expect(today.free?.fixtureLabel, isNull);
  });
}
