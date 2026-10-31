@Timeout(Duration(minutes: 3))
library;

import 'package:balmatchum_server/src/billing/billing_retention.dart';
import 'package:balmatchum_server/src/generated/protocol.dart'
    show StoredPurchase;
import 'package:balmatchum_server/src/maintenance/schema_guard.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import 'support/scratch_database.dart';

// Fresh test databases are created from the latest definition.sql, so the
// normal suite never runs the migration.sql backfills. This test replays the
// pre-normalization schema -> step1 -> step2 in a scratch database it owns.
const _scratch = 'balmatchum_migration_replay';

const _userA = '0190a000-0000-7000-8000-00000000000a';
const _userB = '0190a000-0000-7000-8000-00000000000b';
const _orphan = '0190a000-0000-7000-8000-0000000000cc';

const _ownerTables = [
  'ad_intent',
  'billing_account',
  'billing_purchase',
  'dog_profile',
  'gps_record',
  'outfit_ownership',
  'point_entry',
  'product_account',
  'product_day',
  'product_request',
  'quiz_assignment',
  'quiz_state',
  'step_revision',
  'theme_ownership',
];

// Every index the step-1 migration creates (todo 7).
const _step1Indexes = [
  'ad_intent_auth_user_target',
  'billing_account_auth_user',
  'billing_purchase_auth_user_id',
  'billing_purchase_auth_user_identity',
  'dog_profile_auth_user',
  'external_identity_auth_user',
  'gps_record_auth_user_client',
  'gps_record_auth_user_day',
  'login_attempt_expires_at',
  'naver_grant_owner',
  'naver_login_attempt_expires_at',
  'outfit_ownership_auth_user_key',
  'point_entry_auth_user_key',
  'point_entry_auth_user_date',
  'product_account_auth_user',
  'product_day_auth_user_date',
  'product_day_auth_user_deleted',
  'product_request_auth_user_key',
  'product_request_created_at',
  'quiz_assignment_auth_user_slot',
  'quiz_assignment_auth_user_question',
  'quiz_assignment_auth_user_id',
  'quiz_state_auth_user_key',
  'step_revision_auth_user_key',
  'theme_ownership_auth_user_key',
];

class _Gps {
  const _Gps(this.id, this.owner, this.startedAt, this.endedAt, this.deleted);
  final String id;
  final String owner;
  final String? startedAt;
  final String? endedAt;
  final bool deleted;
}

const _gpsRows = [
  // Crosses KST midnight: 23:59:59 on 10-30 -> 00:00:00 on 10-31.
  _Gps(
    '0190a000-0000-7000-8000-000000000101',
    _userA,
    '2026-10-30T14:59:59.000Z',
    '2026-10-30T15:00:00.000Z',
    false,
  ),
  _Gps(
    '0190a000-0000-7000-8000-000000000102',
    _userA,
    '2026-10-31T00:30:00.000Z',
    '2026-10-31T01:00:00.000Z',
    false,
  ),
  // Before the epoch: the day number must floor, not truncate.
  _Gps(
    '0190a000-0000-7000-8000-000000000103',
    _userB,
    '1969-12-31T14:59:59.000Z',
    '1969-12-31T15:00:01.000Z',
    false,
  ),
  _Gps(
    '0190a000-0000-7000-8000-000000000104',
    _orphan,
    '2026-10-29T20:00:00.000Z',
    '2026-10-29T21:00:00.000Z',
    false,
  ),
  // Deleted tombstone without payload is left alone by the backfill.
  _Gps('0190a000-0000-7000-8000-000000000105', _userA, null, null, true),
];

class _Point {
  const _Point(this.owner, this.key, this.amount, this.policy);
  final String owner;
  final String key;
  final int amount;
  final String policy;
}

const _points = [
  _Point(_userA, 'steps:1', 30, stepPolicyVersion),
  _Point(_userA, 'quiz:1', 10, 'quiz-v1-20261019'),
  _Point(_userA, 'theme:1', -20, themePurchasePolicyVersion),
  _Point(_userA, 'outfit:1', -5, outfitPurchasePolicyVersion),
  _Point(_userA, 'fixture:1', 50, productFixtureLabel),
  _Point(_userA, 'fixture:2', 7, productFixtureLabel),
  _Point(_userA, 'legacy:1', 1000, 'unknown-policy-v0'),
  _Point(_userB, 'steps:1', 4, stepPolicyVersion),
];

const _balancePolicies = {
  stepPolicyVersion,
  'quiz-v1-20261019',
  themePurchasePolicyVersion,
  outfitPurchasePolicyVersion,
};

void _log(String line) => scratchLog('migration-replay', line);

// Orphan billing rows (their AuthUser is gone) that step2 must retain as a
// tombstone and an anonymous payment record before deleting them.
final _orphanObserved = DateTime.utc(2026, 10, 1, 12);
final _orphanPurchased = DateTime.utc(2025, 10, 1, 12);
final _orphanExpires = DateTime.utc(2026, 9, 1, 12);

/// Rows each table must lose in step2: exactly the AuthUser-less orphans.
const _orphanRows = {
  'gps_record': 1,
  'billing_account': 1,
  'billing_purchase': 1,
};

String _fixtureSql() {
  final b = StringBuffer();
  for (final user in [_userA, _userB]) {
    b.writeln(
      'INSERT INTO "serverpod_auth_core_user" ("id", "createdAt", '
      '"scopeNames", "blocked") VALUES (\'$user\', now(), \'[]\', false);',
    );
  }
  for (final g in _gpsRows) {
    final payload = g.startedAt == null
        ? 'NULL'
        : '\'{"clientRecordId":"${g.id}","startedAt":"${g.startedAt}",'
              '"endedAt":"${g.endedAt}","distanceMeters":1200}\'';
    b.writeln(
      'INSERT INTO "gps_record" ("id", "owner", "clientRecordId", '
      '"persistedAt", "payload", "deleted") VALUES (\'${g.id}\', '
      '\'${g.owner}\', \'${g.id}\', now(), $payload, ${g.deleted});',
    );
  }
  for (final p in _points) {
    b.writeln(
      'INSERT INTO "point_entry" ("owner", "entryKey", "kind", "date", '
      '"amount", "policyVersion", "createdAt") VALUES (\'${p.owner}\', '
      '\'${p.key}\', \'grant\', \'2026-10-30\', ${p.amount}, '
      '\'${p.policy}\', now());',
    );
  }
  b.writeln('''
INSERT INTO "product_account" ("owner") VALUES ('$_userA'), ('$_userB');
INSERT INTO "ad_intent" ("owner", "nonce", "purpose", "targetDate",
  "targetRevision", "adUnit", "rewardItem", "rewardAmount", "createdAt",
  "eventExpiresAt", "acceptUntil")
  VALUES ('$_userA', 'n1', 'steps', '2026-10-30', 1, 'unit', 'item', '1',
  now(), now(), now());
INSERT INTO "billing_account" ("owner", "binding") VALUES ('$_userA', 'b1'),
  ('$_orphan', 'b-orphan');
INSERT INTO "billing_purchase" ("owner", "identityHash", "store",
  "environment", "productId", "kind", "purchaseReference", "state",
  "sequence", "observedAt", "acknowledgementPending")
  VALUES ('$_userA', 'h1', 'apple', 'sandbox', 'p1', 'subscription', 'r1',
  'active', 1, now(), false);
INSERT INTO "billing_purchase" ("owner", "identityHash", "store",
  "environment", "productId", "kind", "purchaseReference", "transactionId",
  "state", "sequence", "observedAt", "purchasedAt", "expiresAt",
  "acknowledgementPending")
  VALUES ('$_orphan', 'h-orphan', 'apple', 'production', 'p1', 'subscription',
  'orig-orphan', 'tx-orphan', 'expired', 1,
  '${_orphanObserved.toIso8601String()}',
  '${_orphanPurchased.toIso8601String()}',
  '${_orphanExpires.toIso8601String()}', false);
INSERT INTO "dog_profile" ("owner", "breedId", "name", "sex", "dailyGoal",
  "firstMetAt") VALUES ('$_userA', 'maltese', 'Bori', 'female', 5000, now());
INSERT INTO "outfit_ownership" ("owner", "outfitId", "purchasedAt")
  VALUES ('$_userA', 'scarf', now());
INSERT INTO "product_day" ("owner", "date", "windows")
  VALUES ('$_userA', '2026-10-30', '[]');
INSERT INTO "product_request" ("owner", "requestId", "digest", "result")
  VALUES ('$_userA', 'req-1', 'd1', '{}');
INSERT INTO "quiz_assignment" ("owner", "date", "slot", "questionId",
  "version", "snapshot", "policyVersion", "issuedAt")
  VALUES ('$_userA', '2026-10-30', 'first', 'q1', 1, '{}', 'quiz-v1-20261019',
  now());
INSERT INTO "quiz_state" ("owner", "date", "questionId")
  VALUES ('$_userB', '2026-10-30', 'q1');
INSERT INTO "step_revision" ("owner", "date", "generation", "revision",
  "digest") VALUES ('$_userB', '2026-10-30', 1, 1, 'd1');
INSERT INTO "theme_ownership" ("owner", "themeId", "purchasedAt")
  VALUES ('$_userB', 'night', now());
''');
  return b.toString();
}

String _inList(Iterable<String> names) =>
    names.map((name) => "'$name'").join(', ');

void main() {
  late ScratchDatabase scratch;
  late pg.Connection db;

  Future<int> count(String sql) => scratch.count(sql);

  Future<Map<String, int>> tableCounts() async => {
    for (final table in _ownerTables)
      table: await count('SELECT count(*)::int FROM "$table"'),
  };

  Future<String?> balmatchumVersion() async =>
      (await db.execute(
            "SELECT version FROM serverpod_migrations WHERE module = 'balmatchum'",
          )).first[0]
          as String?;

  Future<List<String>> mismatches() async =>
      schemaMismatchesFrom(await db.execute(schemaGuardQuery));

  setUpAll(() async {
    scratch = await ScratchDatabase.create(_scratch, 'migration-replay');
    db = scratch.db;

    await scratch.runFile(oldDefinitionSql);
    final seenVersionBefore = await count(
      "SELECT count(*)::int FROM pg_indexes WHERE schemaname = "
      "current_schema() AND indexname = 'quiz_assignment_seen_version'",
    );
    _log('old schema quiz_assignment_seen_version present: $seenVersionBefore');
    expect(seenVersionBefore, 1, reason: 'old schema must be loaded');

    await scratch.runSql(_fixtureSql());
    for (final table in _ownerTables) {
      final rows = await count('SELECT count(*)::int FROM "$table"');
      _log('fixture rows $table=$rows');
      expect(rows, greaterThanOrEqualTo(1), reason: table);
    }

    await scratch.runFile(step1MigrationSql);
    final version = await balmatchumVersion();
    _log('serverpod_migrations balmatchum=$version');
    expect(version, step1Id);
  });

  tearDownAll(() => scratch.dispose('migration-replay'));

  test(
    '(a) live gps_record rows all have payload and ordered day numbers',
    () async {
      final rows = await db.execute(
        'SELECT count(*) FILTER (WHERE NOT deleted)::int, '
        'count(*) FILTER (WHERE NOT deleted AND (payload IS NULL OR '
        '"firstLocalDay" IS NULL OR "lastLocalDay" IS NULL OR '
        '"firstLocalDay" > "lastLocalDay"))::int, '
        'count(*) FILTER (WHERE deleted AND "firstLocalDay" IS NOT NULL)::int '
        'FROM gps_record',
      );
      final [live, broken, deletedFilled] = rows.first;
      _log('(a) live=$live broken=$broken deletedBackfilled=$deletedFilled');
      expect(live, 4);
      expect(broken, 0);
      expect(deletedFilled, 0);
    },
  );

  test('(b) authUserId is backfilled wherever the AuthUser exists', () async {
    for (final table in _ownerTables) {
      final rows = await db.execute(
        'SELECT '
        'count(*) FILTER (WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 '
        'FROM serverpod_auth_core_user u WHERE u.id = t.owner::uuid))::int, '
        'count(*) FILTER (WHERE "authUserId" IS NULL)::int, '
        'count(*) FILTER (WHERE "authUserId" IS NOT NULL AND '
        '"authUserId" <> owner::uuid)::int '
        'FROM "$table" t',
      );
      final [missing, nulls, wrong] = rows.first;
      _log('(b) $table missingWithUser=$missing null=$nulls mismatched=$wrong');
      expect(missing, 0, reason: table);
      expect(wrong, 0, reason: table);
      expect(nulls, _orphanRows[table] ?? 0, reason: table);
    }
    final orphan = await db.execute(
      'SELECT owner FROM gps_record WHERE "authUserId" IS NULL',
    );
    _log('(b) null authUserId owners=${orphan.map((r) => r[0]).toList()}');
    expect(orphan.map((r) => r[0]), [_orphan]);
  });

  test(
    '(c) product_account balances equal the per-policy point sums',
    () async {
      final rows = await db.execute(
        'SELECT owner, balance, "fixtureBalance" FROM product_account '
        'ORDER BY owner',
      );
      expect(rows, hasLength(2));
      for (final row in rows) {
        final owner = row[0] as String;
        final mine = _points.where((p) => p.owner == owner);
        final expectedBalance = mine
            .where((p) => _balancePolicies.contains(p.policy))
            .fold<int>(0, (sum, p) => sum + p.amount);
        final expectedFixture = mine
            .where((p) => p.policy == productFixtureLabel)
            .fold<int>(0, (sum, p) => sum + p.amount);
        _log(
          '(c) $owner balance=${row[1]} expected=$expectedBalance '
          'fixtureBalance=${row[2]} expected=$expectedFixture',
        );
        expect(row[1], expectedBalance, reason: owner);
        expect(row[2], expectedFixture, reason: owner);
      }
    },
  );

  test(
    '(d) SQL day backfill matches Dart localDayNumber for every row',
    () async {
      final rows = await db.execute(
        'SELECT id::text, "firstLocalDay", "lastLocalDay" FROM gps_record',
      );
      final byId = {for (final r in rows) r[0] as String: r};
      for (final g in _gpsRows) {
        final row = byId[g.id]!;
        if (g.startedAt == null) {
          _log('(d) ${g.id} deleted first=${row[1]} last=${row[2]}');
          expect(row[1], isNull);
          expect(row[2], isNull);
          continue;
        }
        final first = localDayNumber(DateTime.parse(g.startedAt!));
        final last = localDayNumber(DateTime.parse(g.endedAt!));
        _log(
          '(d) ${g.id} sql=${row[1]}..${row[2]} dart=$first..$last '
          '(${g.startedAt} .. ${g.endedAt})',
        );
        expect(row[1], first, reason: '${g.id} firstLocalDay');
        expect(row[2], last, reason: '${g.id} lastLocalDay');
      }
    },
  );

  test('(e) step-1 indexes exist and the seen-version index is gone', () async {
    final rows = await db.execute(
      'SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = '
      'current_schema() AND indexname IN '
      "(${_inList([..._step1Indexes, 'quiz_assignment_seen_version'])})",
    );
    final found = {for (final r in rows) r[0] as String: r[1] as String};
    final missing = _step1Indexes.where((n) => !found.containsKey(n)).toList();
    _log(
      '(e) found=${found.length}/${_step1Indexes.length} missing=$missing '
      'seenVersion=${found.containsKey('quiz_assignment_seen_version')}',
    );
    _log('(e) naver_grant_owner: ${found['naver_grant_owner']}');
    expect(missing, isEmpty);
    expect(found.containsKey('quiz_assignment_seen_version'), isFalse);
    expect(found['naver_grant_owner'], contains('"authUserId"'));
  });

  test('(f) authUserId stays nullable on the 14 owner tables', () async {
    final rows = await db.execute(
      'SELECT table_name, is_nullable FROM information_schema.columns '
      "WHERE table_schema = current_schema() AND column_name = 'authUserId' "
      'AND table_name IN (${_inList(_ownerTables)}) ORDER BY table_name',
    );
    final nullable = {for (final r in rows) r[0] as String: r[1] as String};
    _log('(f) $nullable');
    expect(nullable.keys.toSet(), _ownerTables.toSet());
    expect(nullable.values.toSet(), {'YES'});
  });

  test('(g) the schema guard reports all three step1 mismatches', () async {
    final found = await mismatches();
    _log('(g) step1 mismatches=${found.length} $found');
    expect(found, [
      for (final table in normalizedTables) '$table.authUserId is nullable',
      'product_account.owner still exists',
      'quiz_assignment.snapshot still exists',
    ]);
  });

  group('step2 replay', () {
    late Map<String, int> before;
    late Object variantError;
    late List<int> afterVariant;

    setUpAll(() async {
      // A server still writing only owner between the two rollouts.
      await db.execute(
        'INSERT INTO "product_request" ("owner", "requestId", "digest", '
        "\"result\") VALUES ('$_userB', 'req-between', 'd2', '{}')",
      );
      before = await tableCounts();
      _log('step2 before counts=$before');

      try {
        await scratch.runSql(step2WithoutDeletes());
        fail('step2 without orphan DELETEs must abort');
      } on pg.ServerException catch (e) {
        variantError = e;
      }
      // The aborted simple query leaves its explicit transaction open.
      await db.execute('ROLLBACK');
      _log('variant without DELETE aborted: $variantError');
      afterVariant = [
        await count(
          'SELECT count(*)::int FROM information_schema.columns WHERE '
          "table_schema = current_schema() AND column_name = 'owner'",
        ),
        await count(
          'SELECT count(*)::int FROM billing_purchase_tombstone',
        ),
        await count(
          'SELECT count(*)::int FROM gps_record WHERE "authUserId" IS NULL',
        ),
      ];
      _log(
        'after aborted variant: version=${await balmatchumVersion()} '
        'ownerColumns=${afterVariant[0]} tombstones=${afterVariant[1]} '
        'gpsNulls=${afterVariant[2]}',
      );
      expect(await balmatchumVersion(), step1Id);

      await scratch.runFile(step2MigrationSql);
      _log('serverpod_migrations balmatchum=${await balmatchumVersion()}');
    });

    test('(h) without the orphan DELETEs the NULL check aborts and rolls '
        'back', () {
      expect(
        variantError.toString(),
        contains('normalization-step2: billing_account has NULL authUserId'),
      );
      // Every owner column survives and nothing was retained or deleted.
      expect(afterVariant, [_ownerTables.length, 0, 1]);
    });

    test('(i) step2 leaves NOT NULL keys and no owner or snapshot', () async {
      expect(await balmatchumVersion(), step2Id);
      final rows = await db.execute(
        'SELECT table_name, is_nullable FROM information_schema.columns '
        "WHERE table_schema = current_schema() AND column_name = 'authUserId' "
        'AND table_name IN (${_inList(_ownerTables)}) ORDER BY table_name',
      );
      final nullable = {for (final r in rows) r[0] as String: r[1] as String};
      final dropped = await count(
        'SELECT count(*)::int FROM information_schema.columns WHERE '
        "table_schema = current_schema() AND (column_name = 'owner' OR "
        "(table_name = 'quiz_assignment' AND column_name = 'snapshot'))",
      );
      final guard = await mismatches();
      _log(
        '(i) nullable=$nullable ownerOrSnapshotColumns=$dropped guard=$guard',
      );
      expect(nullable.keys.toSet(), _ownerTables.toSet());
      expect(nullable.values.toSet(), {'NO'});
      expect(dropped, 0);
      expect(guard, isEmpty);
    });

    test('(j) the orphan purchase is retained by the Dart rules', () async {
      final tombstone = await db.execute(
        'SELECT "retainUntil" FROM billing_purchase_tombstone '
        "WHERE \"identityHash\" = 'h-orphan'",
      );
      final records = await db.execute(
        'SELECT store, environment, "productId", kind, "storeTransactionId", '
        '"originalTransactionId", state, "purchasedAt", "expiresAt", '
        '"revokedAt", "recordedAt", "purgeAfter" FROM billing_payment_record',
      );
      final row = StoredPurchase(
        authUserId: UuidValue.fromString(_orphan),
        identityHash: 'h-orphan',
        store: 'apple',
        environment: 'production',
        productId: 'p1',
        kind: 'subscription',
        purchaseReference: 'orig-orphan',
        transactionId: 'tx-orphan',
        state: 'expired',
        sequence: 1,
        observedAt: _orphanObserved,
        purchasedAt: _orphanPurchased,
        expiresAt: _orphanExpires,
        acknowledgementPending: false,
      );
      final retain = identityRetainUntil('subscription', [
        _orphanExpires,
        null,
      ], _orphanObserved);
      final record = paymentRecordOf(row, DateTime.now().toUtc());
      _log('(j) tombstone=$tombstone expected=$retain');
      _log('(j) records=$records expectedPurge=${record.purgeAfter}');
      expect(tombstone, hasLength(1));
      expect(tombstone.first[0], retain);
      expect(records, hasLength(1));
      final r = records.first;
      expect(r.sublist(0, 10), [
        record.store,
        record.environment,
        record.productId,
        record.kind,
        record.storeTransactionId,
        record.originalTransactionId,
        record.state,
        record.purchasedAt,
        record.expiresAt,
        record.revokedAt,
      ]);
      expect(
        (r[10] as DateTime).difference(record.recordedAt).inSeconds.abs(),
        lessThan(120),
      );
      expect(r[11], record.purgeAfter);
    });

    test('(k) only orphans are deleted and late owner rows are kept', () async {
      final after = await tableCounts();
      _log('(k) after counts=$after orphans=$_orphanRows');
      for (final table in _ownerTables) {
        expect(
          after[table],
          before[table]! - (_orphanRows[table] ?? 0),
          reason: table,
        );
      }
      final late = await db.execute(
        'SELECT "authUserId"::text FROM product_request '
        "WHERE \"requestId\" = 'req-between'",
      );
      _log('(k) req-between authUserId=${late.first[0]}');
      expect(late.first[0], _userB);
    });

    test('(l) balances still equal the ledger after step2', () async {
      final rows = await db.execute(
        'SELECT a."authUserId"::text, a.balance, COALESCE((SELECT SUM(amount) '
        'FROM point_entry e WHERE e."authUserId" = a."authUserId" AND '
        'e."policyVersion" IN (${_inList(_balancePolicies)})), 0)::bigint '
        'FROM product_account a ORDER BY 1',
      );
      _log('(l) $rows');
      expect(rows, hasLength(2));
      for (final r in rows) {
        expect(r[1], r[2], reason: r[0] as String);
      }
    });
  });
}
