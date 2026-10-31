import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/auth/login_attempt_cleanup.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

Iterable<Map<String, dynamic>> _nodes(Map<String, dynamic> node) sync* {
  yield node;
  for (final child in (node['Plans'] as List?) ?? const []) {
    yield* _nodes((child as Map).cast<String, dynamic>());
  }
}

void main() {
  late Directory directory;
  late generated.Serverpod pod;
  late Session session;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('login-explain-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        database: PostgresDatabaseConfig.embedded(
          dataPath: '${directory.path}/pgdata',
          name: 'login_explain_test',
          maxConnectionCount: 10,
        ),
        futureCall: const FutureCallConfig(enabled: false),
      ),
    );
    await pod.start(runInGuardedZone: false);
    session = await pod.createSession(enableLogging: false);
    stdout.writeln('T28_DATABASE temporary=${directory.path}');
  });

  tearDownAll(() async {
    await session.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
    stdout.writeln(
      'T28_CLEANUP database=stopped temporaryDirectoryRemoved='
      '${!await directory.exists()}',
    );
  });

  test(
    'stale login cleanup uses expiresAt indexes and preserves every retained row',
    () async {
      final now = DateTime.utc(2026, 10, 31, 12);
      final cutoff = now.subtract(expiredAttemptRetention);
      final parameters = QueryParameters.named({'cutoff': cutoff});
      const tables = ['login_attempt', 'naver_login_attempt'];
      final retained = <String, Set<Object?>>{};
      final plans = <String, dynamic>{};

      for (final table in tables) {
        final naver = table == 'naver_login_attempt';
        // Only 80/8200 rows are stale: a realistic selective cleanup backlog.
        // Row 81 is exactly at cutoff, row 82 expired within the retained day.
        await session.db.unsafeExecute(
          '''
          INSERT INTO $table
            (id, "nonceHash", "expiresAt"
             ${naver ? ', "stateHash", "codeChallenge", "clientId", "redirectUri"' : ''})
          SELECT gen_random_uuid(), 't28-' || n,
            CASE WHEN n <= 80 THEN CAST(@cutoff AS timestamp) - interval '1 day'
                 WHEN n = 81 THEN CAST(@cutoff AS timestamp)
                 WHEN n = 82 THEN CAST(@cutoff AS timestamp) + interval '23 hours'
                 ELSE CAST(@cutoff AS timestamp) + interval '2 days' END
            ${naver ? ", 'state-' || n, 'challenge', 'client', 'https://example.test/callback'" : ''}
          FROM generate_series(1, 8200) n
          ''',
          parameters: parameters,
        );
        final count = await session.db.unsafeQuery(
          'SELECT count(*) FROM $table',
        );
        expect(count.single.single, 8200);
        retained[table] = (await session.db.unsafeQuery(
          'SELECT id FROM $table WHERE "expiresAt" >= @cutoff',
          parameters: parameters,
        )).map((row) => row.single).toSet();
        expect(retained[table], hasLength(8120));
        await session.db.unsafeExecute('ANALYZE $table');

        // Same strict predicate as deleteStaleLoginAttempts, with its injected
        // clock. SELECT measures the candidate rows without deleting them.
        final result = await session.db.unsafeQuery(
          'EXPLAIN (ANALYZE, FORMAT JSON) SELECT * FROM $table '
          'WHERE "expiresAt" < @cutoff',
          parameters: parameters,
        );
        final raw = result.single.single;
        final plan = (raw is String ? jsonDecode(raw) : raw) as List;
        plans[table] = plan;
      }
      // Print before assertions so an unexpected Seq Scan is evidence too.
      stdout.writeln('T28_EXPLAIN_JSON=${jsonEncode(plans)}');
      for (final table in tables) {
        final plan = plans[table] as List;
        final root = ((plan.single as Map)['Plan'] as Map)
            .cast<String, dynamic>();
        final nodes = _nodes(root).toList();
        final index = '${table}_expires_at';
        final used = nodes
            .where((node) => node['Index Name'] == index)
            .toList();
        expect(used, isNotEmpty, reason: jsonEncode(plan));
        expect(
          used.single['Node Type'],
          isIn(['Index Scan', 'Index Only Scan', 'Bitmap Index Scan']),
          reason: jsonEncode(plan),
        );
        expect(
          nodes.where((node) => node['Node Type'] == 'Seq Scan'),
          isEmpty,
          reason: jsonEncode(plan),
        );
        expect(root['Actual Rows'], 80, reason: jsonEncode(plan));
        stdout.writeln(
          'T28_INDEX $table rows=8200 node=${used.single['Node Type']} '
          'index=$index actualRows=${root['Actual Rows']} seqScans=0',
        );
      }

      expect(
        await deleteStaleLoginAttempts(session, clock: Clock.fixed(now)),
        160,
      );
      for (final table in tables) {
        final remaining = await session.db.unsafeQuery('SELECT id FROM $table');
        expect(remaining.map((row) => row.single).toSet(), retained[table]);
        final stale = await session.db.unsafeQuery(
          'SELECT count(*) FROM $table WHERE "expiresAt" < @cutoff',
          parameters: parameters,
        );
        expect(stale.single.single, 0);
        stdout.writeln(
          'T28_ROWS $table deleted=80 retained=${remaining.length} '
          'stale=0 boundaryAndRecentlyExpired=preserved',
        );
      }
      expect(
        await deleteStaleLoginAttempts(session, clock: Clock.fixed(now)),
        0,
      );
    },
  );
}
