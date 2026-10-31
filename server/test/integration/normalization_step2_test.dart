@Timeout(Duration(minutes: 3))
library;

import 'package:balmatchum_server/src/billing/billing_retention.dart';
import 'package:balmatchum_server/src/generated/protocol.dart'
    show StoredPurchase;
import 'package:postgres/postgres.dart' as pg;
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import 'support/scratch_database.dart';

// Runs only step2's self-verifying prelude on a step-1 schema, so its
// backfill, billing retention and orphan rules are checked row by row.
const _scratch = 'balmatchum_step2_prelude';
const _tag = 'step2-prelude';

const _user = '0190b000-0000-7000-8000-00000000000a';
const _orphan = '0190b000-0000-7000-8000-0000000000cc';

void _log(String line) => scratchLog(_tag, line);

String _ts(DateTime? t) => t == null ? 'NULL' : "'${t.toIso8601String()}'";

DateTime _d(int month, int day, [int year = 2026]) =>
    DateTime.utc(year, month, day, 12);

class _Purchase {
  const _Purchase(
    this.hash,
    this.store,
    this.kind, {
    required this.observedAt,
    this.purchasedAt,
    this.expiresAt,
    this.graceExpiresAt,
    this.revokedAt,
    this.tombstone,
    this.hasTombstone = false,
  });

  final String hash;
  final String store;
  final String kind;
  final DateTime observedAt;
  final DateTime? purchasedAt;
  final DateTime? expiresAt;
  final DateTime? graceExpiresAt;
  final DateTime? revokedAt;

  /// An identity tombstone that already exists before the migration.
  final DateTime? tombstone;
  final bool hasTombstone;

  StoredPurchase get row => StoredPurchase(
    authUserId: UuidValue.fromString(_orphan),
    identityHash: hash,
    store: store,
    environment: 'production',
    productId: 'product-$hash',
    kind: kind,
    purchaseReference: 'reference-$hash',
    transactionId: 'transaction-$hash',
    state: 'expired',
    sequence: 1,
    observedAt: observedAt,
    purchasedAt: purchasedAt,
    expiresAt: expiresAt,
    graceExpiresAt: graceExpiresAt,
    revokedAt: revokedAt,
    acknowledgementPending: false,
  );

  /// Mirrors retainPurchaseIdentity: NULL (keep forever) wins, otherwise the
  /// later date is kept.
  DateTime? get expectedRetainUntil {
    final wanted = identityRetainUntil(kind, [
      expiresAt,
      graceExpiresAt,
    ], observedAt);
    if (!hasTombstone) return wanted;
    final current = tombstone;
    if (current == null || wanted == null) return null;
    return wanted.isAfter(current) ? wanted : current;
  }
}

final _purchases = [
  // Expired subscription: expiresAt before observedAt, no grace period.
  _Purchase(
    'expired-sub',
    'apple',
    'subscription',
    observedAt: _d(10, 1),
    purchasedAt: _d(1, 1),
    expiresAt: _d(9, 1),
  ),
  // Only a grace expiry was reported.
  _Purchase(
    'grace-only',
    'google',
    'subscription',
    observedAt: _d(10, 1),
    purchasedAt: _d(2, 1),
    graceExpiresAt: _d(10, 20),
  ),
  // No expiry at all: observedAt stands in.
  _Purchase(
    'no-expiry',
    'apple',
    'subscription',
    observedAt: _d(10, 2),
  ),
  // Only a revocation.
  _Purchase(
    'revoked-only',
    'google',
    'subscription',
    observedAt: _d(8, 1),
    revokedAt: _d(8, 15),
  ),
  _Purchase(
    'lifetime-apple',
    'apple',
    'lifetime',
    observedAt: _d(10, 3),
    purchasedAt: _d(3, 3),
  ),
  _Purchase(
    'lifetime-revoked',
    'google',
    'lifetime',
    observedAt: _d(10, 4),
    revokedAt: _d(10, 10),
  ),
  // Future expiry, grace later than expiry.
  _Purchase(
    'grace-later',
    'apple',
    'subscription',
    observedAt: _d(10, 5),
    purchasedAt: _d(9, 5),
    expiresAt: _d(11, 5),
    graceExpiresAt: _d(11, 20),
  ),
  // Future expiry later than the grace expiry.
  _Purchase(
    'expiry-later',
    'google',
    'subscription',
    observedAt: _d(10, 6),
    purchasedAt: _d(9, 6),
    expiresAt: _d(12, 6),
    graceExpiresAt: _d(11, 6),
  ),
  // Expired with grace and a revocation after the last observation.
  _Purchase(
    'expired-revoked',
    'apple',
    'subscription',
    observedAt: _d(10, 7),
    purchasedAt: _d(1, 7),
    expiresAt: _d(9, 7),
    graceExpiresAt: _d(9, 21),
    revokedAt: _d(10, 25),
  ),
  _Purchase(
    'lifetime-no-dates',
    'apple',
    'lifetime',
    observedAt: _d(10, 8),
  ),
  // Existing tombstones: NULL stays NULL, the later date wins, lifetime wins.
  _Purchase(
    'tomb-null',
    'google',
    'subscription',
    observedAt: _d(10, 9),
    expiresAt: _d(9, 9),
    hasTombstone: true,
  ),
  _Purchase(
    'tomb-earlier',
    'apple',
    'subscription',
    observedAt: _d(10, 10),
    expiresAt: _d(11, 10),
    hasTombstone: true,
    tombstone: _d(1, 1, 2027),
  ),
  _Purchase(
    'tomb-later',
    'google',
    'subscription',
    observedAt: _d(10, 11),
    expiresAt: _d(9, 11),
    hasTombstone: true,
    tombstone: _d(6, 1, 2030),
  ),
  _Purchase(
    'tomb-lifetime',
    'apple',
    'lifetime',
    observedAt: _d(10, 12),
    hasTombstone: true,
    tombstone: _d(6, 1, 2030),
  ),
];

String _fixtureSql() {
  final b = StringBuffer()
    ..writeln(
      'INSERT INTO "serverpod_auth_core_user" ("id", "createdAt", '
      '"scopeNames", "blocked") VALUES (\'$_user\', now(), \'[]\', false);',
    )
    // (i) authUserId NULL although the AuthUser exists: must be backfilled.
    ..writeln(
      'INSERT INTO "product_account" ("owner") VALUES (\'$_user\');\n'
      'INSERT INTO "billing_account" ("owner", "binding") '
      "VALUES ('$_user', 'b-user');\n"
      'INSERT INTO "billing_purchase" ("owner", "identityHash", "store", '
      '"environment", "productId", "kind", "purchaseReference", "state", '
      '"sequence", "observedAt", "acknowledgementPending") VALUES '
      "('$_user', 'user-purchase', 'apple', 'production', 'p', "
      "'subscription', 'r', 'active', 1, now(), false);",
    )
    // (ii) orphans whose AuthUser is gone: must be deleted.
    ..writeln(
      'INSERT INTO "product_account" ("owner") VALUES (\'$_orphan\');\n'
      'INSERT INTO "dog_profile" ("owner", "breedId", "name", "sex", '
      '"dailyGoal", "firstMetAt") VALUES '
      "('$_orphan', 'maltese', 'Bori', 'female', 5000, now());\n"
      'INSERT INTO "billing_account" ("owner", "binding") '
      "VALUES ('$_orphan', 'b-orphan');",
    );
  for (final p in _purchases) {
    b.writeln(
      'INSERT INTO "billing_purchase" ("owner", "identityHash", "store", '
      '"environment", "productId", "kind", "purchaseReference", '
      '"transactionId", "state", "sequence", "observedAt", "purchasedAt", '
      '"expiresAt", "graceExpiresAt", "revokedAt", "acknowledgementPending") '
      "VALUES ('$_orphan', '${p.hash}', '${p.store}', 'production', "
      "'product-${p.hash}', '${p.kind}', 'reference-${p.hash}', "
      "'transaction-${p.hash}', 'expired', 1, ${_ts(p.observedAt)}, "
      '${_ts(p.purchasedAt)}, ${_ts(p.expiresAt)}, '
      '${_ts(p.graceExpiresAt)}, ${_ts(p.revokedAt)}, false);',
    );
    if (p.hasTombstone) {
      b.writeln(
        'INSERT INTO "billing_purchase_tombstone" ("identityHash", '
        "\"retainUntil\") VALUES ('${p.hash}', ${_ts(p.tombstone)});",
      );
    }
  }
  return b.toString();
}

void main() {
  late ScratchDatabase scratch;
  late pg.Connection db;
  late Object variantError;
  late Map<String, int> afterVariant;
  late DateTime ranAt;

  Future<int> count(String sql) => scratch.count(sql);

  Future<Map<String, int>> state() async => {
    'orphanProductAccounts': await count(
      'SELECT count(*)::int FROM product_account WHERE owner = '
      "'$_orphan'",
    ),
    'orphanPurchases': await count(
      'SELECT count(*)::int FROM billing_purchase WHERE owner = '
      "'$_orphan'",
    ),
    'tombstones': await count(
      'SELECT count(*)::int FROM billing_purchase_tombstone',
    ),
    'paymentRecords': await count(
      'SELECT count(*)::int FROM billing_payment_record',
    ),
    'userNulls': await count(
      'SELECT count(*)::int FROM product_account WHERE owner = '
      "'$_user' AND \"authUserId\" IS NULL",
    ),
  };

  setUpAll(() async {
    scratch = await ScratchDatabase.create(_scratch, _tag);
    db = scratch.db;
    await scratch.runFile(step1DefinitionSql);
    await scratch.runSql(_fixtureSql());
    _log('fixture state=${await state()}');

    final withoutDeletes = step2Prelude()
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('DELETE FROM'))
        .join('\n');
    try {
      await scratch.runSql('BEGIN;\n$withoutDeletes\nCOMMIT;');
      fail('the prelude without DELETEs must abort');
    } on pg.ServerException catch (e) {
      variantError = e;
    }
    await db.execute('ROLLBACK');
    afterVariant = await state();
    _log('variant aborted: $variantError; state=$afterVariant');

    ranAt = DateTime.now().toUtc();
    await scratch.runSql('BEGIN;\n${step2Prelude()}\nCOMMIT;');
    _log('prelude applied; state=${await state()}');
  });

  tearDownAll(() => scratch.dispose(_tag));

  test('without the DELETEs the NULL check raises and nothing changes', () {
    expect(variantError, isA<pg.ServerException>());
    expect(
      variantError.toString(),
      contains('normalization-step2: billing_account has NULL authUserId'),
    );
    expect(afterVariant, {
      'orphanProductAccounts': 1,
      'orphanPurchases': _purchases.length,
      'tombstones': _purchases.where((p) => p.hasTombstone).length,
      'paymentRecords': 0,
      'userNulls': 1,
    });
  });

  test(
    '(i) rows of an existing AuthUser are backfilled, not deleted',
    () async {
      for (final table in ['product_account', 'billing_account']) {
        final rows = await db.execute(
          'SELECT "authUserId"::text FROM "$table" WHERE owner = \'$_user\'',
        );
        _log('(i) $table authUserId=${rows.map((r) => r[0]).toList()}');
        expect(rows.map((r) => r[0]), [_user], reason: table);
      }
      final purchase = await db.execute(
        'SELECT "authUserId"::text FROM billing_purchase '
        "WHERE \"identityHash\" = 'user-purchase'",
      );
      expect(purchase.single[0], _user);
      // Only orphan purchases are retained.
      expect(
        await count(
          'SELECT count(*)::int FROM billing_purchase_tombstone '
          "WHERE \"identityHash\" = 'user-purchase'",
        ),
        0,
      );
    },
  );

  test('(ii) orphans are deleted and no NULL authUserId remains', () async {
    final remaining = await state();
    _log('(ii) state=$remaining');
    expect(remaining['orphanProductAccounts'], 0);
    expect(remaining['orphanPurchases'], 0);
    expect(
      await count(
        'SELECT count(*)::int FROM dog_profile WHERE owner = '
        "'$_orphan'",
      ),
      0,
    );
    for (final table in [
      'product_account',
      'billing_account',
      'billing_purchase',
      'dog_profile',
    ]) {
      expect(
        await count(
          'SELECT count(*)::int FROM "$table" WHERE "authUserId" IS NULL',
        ),
        0,
        reason: table,
      );
    }
  });

  test(
    '(iii) tombstones follow identityRetainUntil and the merge rule',
    () async {
      final rows = await db.execute(
        'SELECT "identityHash", "retainUntil" FROM billing_purchase_tombstone',
      );
      final byHash = {for (final r in rows) r[0] as String: r[1]};
      expect(byHash.keys.toSet(), _purchases.map((p) => p.hash).toSet());
      for (final p in _purchases) {
        _log(
          '(iii) ${p.hash} sql=${byHash[p.hash]} '
          'dart=${p.expectedRetainUntil}',
        );
        expect(byHash[p.hash], p.expectedRetainUntil, reason: p.hash);
      }
    },
  );

  test(
    '(iii) payment records equal paymentRecordOf for every orphan',
    () async {
      final rows = await db.execute(
        'SELECT store, environment, "productId", kind, "storeTransactionId", '
        '"originalTransactionId", state, "purchasedAt", "expiresAt", '
        '"revokedAt", "recordedAt", "purgeAfter" FROM billing_payment_record',
      );
      expect(rows, hasLength(_purchases.length));
      final byTransaction = {for (final r in rows) r[4] as String: r};
      for (final p in _purchases) {
        final expected = paymentRecordOf(p.row, ranAt);
        final r = byTransaction['transaction-${p.hash}']!;
        _log(
          '(iii) ${p.hash} purgeAfter sql=${r[11]} '
          'dart=${expected.purgeAfter} original=${r[5]}',
        );
        expect(r.sublist(0, 10), [
          expected.store,
          expected.environment,
          expected.productId,
          expected.kind,
          expected.storeTransactionId,
          expected.originalTransactionId,
          expected.state,
          expected.purchasedAt,
          expected.expiresAt,
          expected.revokedAt,
        ], reason: p.hash);
        expect(
          (r[10] as DateTime).difference(expected.recordedAt).inSeconds.abs(),
          lessThan(120),
          reason: '${p.hash} recordedAt',
        );
        expect(r[11], expected.purgeAfter, reason: '${p.hash} purgeAfter');
      }
    },
  );
}
