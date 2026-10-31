import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/product/product_endpoint.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:balmatchum_server/src/quiz/quiz_bank.dart';
import 'package:balmatchum_server/src/quiz/quiz_service.dart';
import 'package:balmatchum_server/src/records/records_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../test_utils/quiz_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

Iterable<Map<String, dynamic>> _nodes(Map<String, dynamic> node) sync* {
  yield node;
  for (final child in (node['Plans'] as List?) ?? const []) {
    yield* _nodes((child as Map).cast<String, dynamic>());
  }
}

class _QuerySession extends InternalSession {
  _QuerySession({required super.server}) : super(enableLogging: false);

  final queries = <String>[];

  @override
  get logQuery =>
      ({
        required String query,
        required Duration duration,
        required int? numRowsAffected,
        required String? error,
        required StackTrace stackTrace,
      }) => queries.add(query);
}

void main() {
  withServerpod('AuthUser read paths', (builder, endpoints) {
    late Session session;
    late UuidValue id;

    setUp(() async {
      session = builder.build();
      id = (await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      )).id!;
      session.updateAuthenticated(
        AuthenticationInfo(id.uuid, {}, authId: 'test'),
      );
    });

    for (final (label, owner) in [
      (
        'SQL-shaped owner',
        "00000000-0000-0000-0000-000000000000' OR TRUE --",
      ),
      ('plain non-UUID owner', 'not-a-uuid'),
      ('unknown UUID owner', '00000000-0000-0000-0000-000000000000'),
    ]) {
      test(
        'getWallet rejects $label without returning another user row',
        () async {
          await ProductService.run(
            session,
            (s) => s.appendPointEntry(
              PointEntry(
                authUserId: id,
                entryKey: 'victim-credit',
                kind: 'steps',
                amount: 31337,
                policyVersion: stepPolicyVersion,
                createdAt: DateTime.utc(2026, 10, 31),
              ),
            ),
          );
          final endpoint = ProductEndpoint();
          expect((await endpoint.getWallet(session)).balance, 31337);
          final accountCount = await ProductAccount.db.count(session);
          session.updateAuthenticated(
            AuthenticationInfo(owner, {}, authId: 'test'),
          );
          final rejected = throwsA(
            isA<NotAuthorizedException>().having(
              (e) => e.reason,
              'reason',
              AuthenticationFailureReason.unauthenticated,
            ),
          );
          await expectLater(endpoint.getWallet(session), rejected);
          await expectLater(
            session.db.transaction(
              (tx) => lockProductAccount(session, owner, tx),
            ),
            rejected,
          );
          expect(await ProductAccount.db.count(session), accountCount);
          session.updateAuthenticated(
            AuthenticationInfo(id.uuid, {}, authId: 'test'),
          );
          expect((await endpoint.getWallet(session)).balance, 31337);
          expect(await reconcilePointBalances(session), isEmpty);
        },
      );
    }

    test(
      'lockProductAccount five separate transactions leave exactly one row',
      () async {
        final ids = <int>{};
        for (var i = 0; i < 5; i++) {
          final account = await session.db.transaction(
            (tx) => lockProductAccount(session, id.uuid, tx),
          );
          ids.add(account.id!);
          expect(account.authUserId, id);
        }
        expect(ids, hasLength(1));
        expect(
          await ProductAccount.db.count(
            session,
            where: (t) => t.authUserId.equals(id),
          ),
          1,
        );
      },
    );

    test(
      'authUserId unique index carries account identity',
      () async {
        // Only the authUserId unique index can reject the attempted insert and
        // recover this existing row.
        final existing = await ProductAccount.db.insertRow(
          session,
          ProductAccount(authUserId: id),
        );
        for (var i = 0; i < 5; i++) {
          final account = await session.db.transaction(
            (tx) => lockProductAccount(session, id.uuid, tx),
          );
          expect(account.id, existing.id);
        }
        expect(
          await ProductAccount.db.count(
            session,
            where: (t) => t.authUserId.equals(id),
          ),
          1,
        );
      },
    );

    test('concurrent lockProductAccount calls leave exactly one row', () async {
      const bound = Duration(seconds: 15);
      final locked = Completer<void>();
      final release = Completer<void>();
      final holder = session.db.transaction((tx) async {
        final account = await lockProductAccount(session, id.uuid, tx);
        locked.complete();
        await release.future.timeout(bound);
        return account;
      });
      final attempts = List.generate(5, (_) => Completer<void>());
      final sessions = List.generate(5, (_) => builder.build());
      var calls = <Future<ProductAccount>>[];
      try {
        await locked.future.timeout(bound);
        calls = [
          for (var i = 0; i < sessions.length; i++)
            sessions[i].db.transaction((tx) {
              attempts[i].complete();
              return lockProductAccount(sessions[i], id.uuid, tx);
            }),
        ];
        // All independent transactions have entered before the held lock is
        // released. No timer guesses whether the competing calls started.
        await Future.wait(attempts.map((a) => a.future)).timeout(bound);
      } finally {
        release.complete();
        final accounts = await Future.wait([holder, ...calls]).timeout(bound);
        expect(accounts.map((a) => a.id).toSet(), hasLength(1));
      }
      expect(
        await ProductAccount.db.count(
          session,
          where: (t) => t.authUserId.equals(id),
        ),
        1,
      );
    });

    test(
      'balance reads materialized columns without ledger aggregation',
      () async {
        await ProductService.run(session, (s) async {
          for (final (policy, amount) in [
            (stepPolicyVersion, 7),
            (productFixtureLabel, 11),
          ]) {
            await s.appendPointEntry(
              PointEntry(
                authUserId: authUserIdOf(id.uuid),
                entryKey: policy,
                kind: 'test-credit',
                amount: amount,
                policyVersion: policy,
                createdAt: DateTime.utc(2026, 10, 31),
              ),
            );
          }
        });
        expect(await reconcilePointBalances(session), isEmpty);
        await ProductService.read(session, (s) async {
          expect(await s.balance(), 7);
          expect(await s.balance(fixture: true), 11);
          // Deliberately change only the snapshot object, not the ledger or DB.
          // A SUM-based implementation would still return 7 and 11.
          s.account.balance = 19;
          s.account.fixtureBalance = 23;
          expect(await s.balance(), 19);
          expect(await s.balance(fixture: true), 23);
        });
        expect(await reconcilePointBalances(session), isEmpty);
      },
    );

    test(
      '8000-row tombstone fixture uses date index for saveConfirmed',
      () async {
        await session.db.unsafeExecute(
          '''
          INSERT INTO product_day ("authUserId", date, deleted, windows)
          SELECT CAST(@id AS uuid),
            to_char(date '2000-01-01' + n, 'YYYY-MM-DD'),
            n % 2 = 0, '[]'::json
          FROM generate_series(0, 7999) n
          ''',
          parameters: QueryParameters.named({'id': id.uuid}),
        );
        final counts = await session.db.unsafeQuery(
          'SELECT count(*), count(*) FILTER (WHERE deleted) FROM product_day '
          'WHERE "authUserId" = CAST(@id AS uuid)',
          parameters: QueryParameters.named({'id': id.uuid}),
        );
        expect(counts.single[0], 8000);
        expect(counts.single[1], 4000);
        await session.db.unsafeExecute('ANALYZE product_day');

        final input = GpsRecordInput(
          schemaVersion: 1,
          clientRecordId: const Uuid().v4obj(),
          startedAt: DateTime.utc(2000, 1, 1).add(const Duration(days: 4000)),
          endedAt: DateTime.utc(2000, 1, 1).add(const Duration(days: 4000)),
          source: 'watch',
          routePoints: [],
        );
        final measured = _QuerySession(server: session.server);
        try {
          measured.updateAuthenticated(
            AuthenticationInfo(id.uuid, {}, authId: 'test'),
          );
          await expectLater(
            RecordsEndpoint().saveConfirmed(measured, input),
            throwsA(
              isA<RecordException>().having(
                (e) => e.code,
                'code',
                'dayDeleted',
              ),
            ),
          );
          // Measure the endpoint's actual SQL, not a copy of its predicate:
          // removing its date bounds must also change the plan under test.
          final query = measured.queries.singleWhere(
            (q) => q.startsWith('SELECT') && q.contains('"product_day"'),
          );
          final result = await session.db.unsafeQuery(
            'EXPLAIN (ANALYZE, FORMAT JSON) $query',
          );
          final raw = result.single.single;
          final plan = (raw is String ? jsonDecode(raw) : raw) as List;
          stdout.writeln(
            'T27_FIXTURE rows=${counts.single[0]} deleted=${counts.single[1]}',
          );
          stdout.writeln('T27_QUERY=$query');
          stdout.writeln('T27_EXPLAIN_JSON=${jsonEncode(plan)}');
          final nodes = _nodes(
            ((plan.single as Map)['Plan'] as Map).cast<String, dynamic>(),
          ).toList();
          final used = nodes
              .where((n) => n['Index Name'] == 'product_day_auth_user_date')
              .toList();
          expect(used, hasLength(1), reason: jsonEncode(plan));
          expect(
            used.single['Node Type'],
            isIn(['Index Scan', 'Index Only Scan', 'Bitmap Index Scan']),
          );
          expect(
            used.single['Index Cond'],
            allOf(
              contains('"authUserId"'),
              contains('date >='),
              contains('date <='),
            ),
          );
          expect(
            nodes.where((n) => n['Node Type'] == 'Seq Scan'),
            isEmpty,
            reason: jsonEncode(plan),
          );
          expect(nodes.first['Actual Rows'], 1);
        } finally {
          await measured.close();
        }
      },
    );

    test(
      '8000-row fixtures use authUserId indexes for daily and history reads',
      () async {
        final users = await AuthUser.db.insert(session, [
          for (var i = 0; i < 100; i++) AuthUser(scopeNames: {}),
        ]);
        final ids = users.map((u) => u.id!).toList();
        await ProductAccount.db.insert(session, [
          for (final userId in ids)
            ProductAccount(
              authUserId: userId,
              balance: 80,
            ),
        ]);
        final params = QueryParameters.named({
          'users': jsonEncode(ids.map((i) => i.uuid).toList()),
        });
        await session.db.unsafeExecute(
          '''
          INSERT INTO point_entry
            ("authUserId", "entryKey", kind, date, amount,
             "policyVersion", "createdAt")
          SELECT u.value::uuid, 'credit-' || n, 'steps',
            to_char(date '2026-01-01' + n, 'YYYY-MM-DD'), 1,
            '$stepPolicyVersion', timestamp '2026-10-31'
          FROM jsonb_array_elements_text(CAST(@users AS jsonb)) u,
            generate_series(1, 80) n
          ''',
          parameters: params,
        );
        await session.db.unsafeExecute(
          '''
          INSERT INTO gps_record
            ("authUserId", "clientRecordId", "persistedAt", deleted,
             "firstLocalDay", "lastLocalDay")
          SELECT u.value::uuid, gen_random_uuid(),
            timestamp '2026-10-31', false, n, n + 2
          FROM jsonb_array_elements_text(CAST(@users AS jsonb)) u,
            generate_series(1, 80) n
          ''',
          parameters: params,
        );
        final body =
            jsonDecode(fixtureBank().snapshots.first) as Map<String, dynamic>;
        await QuizContentRevision.db.insert(session, [
          for (var n = 1; n <= 80; n++)
            QuizContentRevision(
              questionId: 't14-$n',
              version: 1,
              snapshot: jsonEncode({...body, 'questionId': 't14-$n'}),
            ),
        ]);
        await session.db.unsafeExecute(
          '''
          INSERT INTO quiz_assignment
            ("authUserId", date, slot, "questionId", version,
             "policyVersion", "issuedAt", "answerIndex", "answeredAt",
             "awardedPoints")
          SELECT u.value::uuid,
            to_char(date '2026-01-01' + n, 'YYYY-MM-DD'), 'free',
            't14-' || n, 1, '$quizPolicyVersion', timestamp '2026-10-31',
            0, timestamp '2026-10-31', 0
          FROM jsonb_array_elements_text(CAST(@users AS jsonb)) u,
            generate_series(1, 80) n
          ''',
          parameters: params,
        );
        final plans = <String, dynamic>{};
        for (final (table, predicate, suffix, index) in [
          (
            'point_entry',
            '''date >= '2026-02-01' AND date <= '2026-02-01'
               AND kind = 'steps' AND "policyVersion" = '$stepPolicyVersion' ''',
            '',
            'point_entry_auth_user_date',
          ),
          (
            'gps_record',
            '''deleted = false AND "firstLocalDay" <= 31
               AND "lastLocalDay" >= 31''',
            '',
            'gps_record_auth_user_day',
          ),
          (
            'quiz_assignment',
            '"answerIndex" IS NOT NULL AND id IS NOT NULL',
            'ORDER BY id DESC LIMIT 30',
            'quiz_assignment_auth_user_id',
          ),
        ]) {
          final count = await session.db.unsafeQuery(
            'SELECT count(*) FROM $table',
          );
          expect(count.single.single, greaterThanOrEqualTo(8000));
          await session.db.unsafeExecute('ANALYZE $table');
          final result = await session.db.unsafeQuery(
            'EXPLAIN (FORMAT JSON) SELECT * FROM $table '
            'WHERE "authUserId" = CAST(@id AS uuid) AND $predicate $suffix',
            parameters: QueryParameters.named({'id': ids.first.uuid}),
          );
          final raw = result.single.single;
          final plan = (raw is String ? jsonDecode(raw) : raw) as List;
          plans[table] = plan;
          final nodes = _nodes(
            ((plan.single as Map)['Plan'] as Map).cast<String, dynamic>(),
          ).toList();
          final used = nodes.where((n) => n['Index Name'] == index).toList();
          expect(used, isNotEmpty, reason: jsonEncode(plan));
          expect(
            used.single['Node Type'],
            isIn(['Index Scan', 'Index Only Scan', 'Bitmap Index Scan']),
          );
          expect(
            nodes.where((n) => n['Node Type'] == 'Seq Scan'),
            isEmpty,
            reason: jsonEncode(plan),
          );
          stdout.writeln(
            'T14_INDEX $table rows=${count.single.single} '
            'node=${used.single['Node Type']} index=$index',
          );
        }
        stdout.writeln('T14_EXPLAIN_JSON=${jsonEncode(plans)}');
        session.updateAuthenticated(
          AuthenticationInfo(ids.first.uuid, {}, authId: 'test'),
        );
        await ProductService.read(session, (s) async {
          expect(await s.stepEntries('2026-02-01', '2026-02-01'), hasLength(1));
          expect(await s.gpsRecordsOnDay('1970-02-01'), hasLength(3));
          expect(await QuizService(s).history(null), hasLength(30));
        });
        expect(await reconcilePointBalances(session), isEmpty);
        stdout.writeln('T14_RECONCILE mismatches=0');
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
