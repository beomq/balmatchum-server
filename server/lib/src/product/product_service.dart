import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../ads/ad_service.dart';
import '../billing/billing_service.dart';
import '../quiz/quiz_bank.dart';

/// Legacy quiz/theme fixtures remain isolated from production step balances.
const productFixtureLabel = 'development-fixture-v1-not-production';
const stepPolicyVersion = 'steps-v1-20261019';
const themePurchasePolicyVersion = 'theme-purchase-v1-20261027';
const outfitPurchasePolicyVersion = 'outfit-purchase-v1-20261027';
const stepsPerPoint = 100;
const dailyBaseCap = 100;

/// User-scoped queries and dual writes share the same AuthUser identity.
UuidValue authUserIdOf(String owner) {
  try {
    return UuidValue.withValidation(owner);
  } on FormatException {
    throw NotAuthorizedException(
      reason: AuthenticationFailureReason.unauthenticated,
    );
  }
}

bool productFixturesEnabled(Session session) {
  final config = session.server.serverpod.config;
  final database = config.database;
  return config.runMode == ServerpodRunMode.development &&
      database is PostgresDatabaseConfig &&
      {'localhost', '127.0.0.1', '::1'}.contains(database.host) &&
      database.name == 'balmatchum_dev_test';
}

void requireProductFixtures(Session session) {
  if (!productFixturesEnabled(session)) {
    throw ProductException(code: 'policyUnconfigured');
  }
}

DateTime dayStart(String date) {
  final parsed = DateTime.tryParse('${date}T00:00:00Z');
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
      parsed == null ||
      parsed.toIso8601String().substring(0, 10) != date) {
    throw ProductException(code: 'invalidDate');
  }
  return parsed.subtract(const Duration(hours: 9));
}

String localDate(DateTime instant) => instant
    .toUtc()
    .add(const Duration(hours: 9))
    .toIso8601String()
    .substring(0, 10);

const _kstOffsetMicros = 9 * Duration.microsecondsPerHour;

/// KST calendar day as days since 1970-01-01. Mirrors the migration backfill:
/// floor((epoch + 9h) / 1 day), floored (not truncated) before the epoch.
int localDayNumber(DateTime instant) {
  final shifted = instant.toUtc().microsecondsSinceEpoch + _kstOffsetMicros;
  const day = Duration.microsecondsPerDay;
  return (shifted - shifted % day) ~/ day;
}

/// Reference semantics for the indexed day predicate; kept for tests.
bool touchesDay(GpsRecordInput input, String date) {
  final start = dayStart(date);
  final end = start.add(const Duration(days: 1));
  // Endpoints at midnight are real samples and belong to the new date.
  return input.startedAt.isBefore(end) && !input.endedAt.isBefore(start);
}

/// Lock the existing auth user BEFORE creating or locking product state.
/// A request authenticated before account deletion must recheck existence here.
/// FOR UPDATE waits for deletion to commit, then returns no row; conversely a
/// mutation holding this lock must commit before deletion can purge its writes.
Future<ProductAccount> lockProductAccount(
  Session session,
  String owner,
  Transaction tx,
) async {
  final user = await AuthUser.db.findFirstRow(
    session,
    where: (t) => t.id.equals(authUserIdOf(owner)),
    lockMode: LockMode.forUpdate,
    transaction: tx,
  );
  if (user == null) {
    throw NotAuthorizedException(
      reason: AuthenticationFailureReason.unauthenticated,
    );
  }
  await ProductAccount.db.insert(
    session,
    [ProductAccount(owner: owner, authUserId: authUserIdOf(owner))],
    ignoreConflicts: true,
    transaction: tx,
  );
  return (await ProductAccount.db.findFirstRow(
    session,
    where: (t) => t.authUserId.equals(authUserIdOf(owner)),
    lockMode: LockMode.forUpdate,
    transaction: tx,
  ))!;
}

/// Compare both materialized balances with the ledger in one DB snapshot.
/// The ledger remains authoritative; this reports drift without repairing it.
Future<List<List<dynamic>>> reconcilePointBalances(Session session) =>
    session.db.unsafeQuery(
      '''
      WITH ledger AS (
        SELECT owner,
          COALESCE(SUM(ledger_entry.amount) FILTER (WHERE "policyVersion" IN
            (@steps, @quiz, @theme, @outfit)), 0) AS balance,
          COALESCE(SUM(ledger_entry.amount) FILTER (WHERE "policyVersion" = @fixture), 0)
            AS fixture_balance
        FROM point_entry ledger_entry GROUP BY owner
      )
      SELECT COALESCE(a.owner, l.owner), a.balance,
        COALESCE(l.balance, 0)::bigint, a."fixtureBalance",
        COALESCE(l.fixture_balance, 0)::bigint
      FROM product_account a FULL OUTER JOIN ledger l ON l.owner = a.owner
      WHERE a.id IS NULL OR a.balance <> COALESCE(l.balance, 0)
        OR a."fixtureBalance" <> COALESCE(l.fixture_balance, 0)
      ''',
      parameters: QueryParameters.named({
        'steps': stepPolicyVersion,
        'quiz': quizPolicyVersion,
        'theme': themePurchasePolicyVersion,
        'outfit': outfitPurchasePolicyVersion,
        'fixture': productFixtureLabel,
      }),
    );

class ProductService {
  ProductService(this.session, this.owner, this.tx, this.account);
  final Session session;
  final String owner;
  final Transaction tx;
  final ProductAccount account;

  static Future<T> run<T>(
    Session session,
    Future<T> Function(ProductService) action,
  ) {
    final owner = session.authenticated?.userIdentifier;
    if (owner == null) throw ProductException(code: 'unauthenticated');
    return session.db.transaction((tx) async {
      final account = await lockProductAccount(session, owner, tx);
      // One eligibility instant after the lock prevents deadline crossings
      // between the quoted amount, consumed proof and recorded tranche slices.
      return withClock(
        Clock.fixed(clock.now()),
        () => action(ProductService(session, owner, tx, account)),
      );
    });
  }

  /// Reads take no row locks, so one user's parallel reads overlap instead of
  /// queueing behind each other. One repeatable-read snapshot keeps a view's
  /// day, grants and balance consistent; every write still goes through [run].
  static Future<T> read<T>(
    Session session,
    Future<T> Function(ProductService) action,
  ) async {
    final owner = session.authenticated?.userIdentifier;
    if (owner == null) throw ProductException(code: 'unauthenticated');
    final result = await session.db.transaction(
      (tx) async {
        final account =
            await ProductAccount.db.findFirstRow(
              session,
              where: (t) => t.authUserId.equals(authUserIdOf(owner)),
              transaction: tx,
            ) ??
            ProductAccount(owner: owner);
        return withClock(
          Clock.fixed(clock.now()),
          () => action(ProductService(session, owner, tx, account)),
        );
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );
    // The snapshot cannot see a deletion committed after it began, so recheck
    // outside the transaction without taking a lock; reads stay read-only.
    final user = await AuthUser.db.findById(
      session,
      authUserIdOf(owner),
    );
    if (user == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
      );
    }
    return result;
  }

  Future<ProductDay> day(String date) async {
    dayStart(date);
    return await ProductDay.db.findFirstRow(
          session,
          where: (t) =>
              t.authUserId.equals(authUserIdOf(owner)) & t.date.equals(date),
          transaction: tx,
        ) ??
        ProductDay(
          owner: owner,
          date: date,
          windows: [],
          policyVersion: stepPolicyVersion,
        );
  }

  Future<void> saveDay(ProductDay value) async {
    if (value.id == null) {
      value.authUserId = authUserIdOf(owner);
      await ProductDay.db.insertRow(session, value, transaction: tx);
    } else {
      await ProductDay.db.updateRow(session, value, transaction: tx);
    }
  }

  String digest(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();

  Future<String?> replay(String requestId, Object payload) async {
    if (requestId.isEmpty || requestId.length > 128) {
      throw ProductException(code: 'invalidRequestId');
    }
    final request = await ProductRequest.db.findFirstRow(
      session,
      where: (t) =>
          t.authUserId.equals(authUserIdOf(owner)) &
          t.requestId.equals(requestId),
      transaction: tx,
    );
    if (request == null) return null;
    if (request.digest != digest(payload)) {
      throw ProductException(code: 'idempotencyConflict');
    }
    return request.result;
  }

  Future<void> remember(String requestId, Object payload, Object result) async {
    await ProductRequest.db.insertRow(
      session,
      ProductRequest(
        owner: owner,
        authUserId: authUserIdOf(owner),
        requestId: requestId,
        digest: digest(payload),
        result: jsonEncode(result),
      ),
      transaction: tx,
    );
  }

  /// Call only while holding [lockProductAccount] in [tx].
  Future<PointEntry> appendPointEntry(
    PointEntry entry, {
    // Test-only failure injection at the boundary between the two writes.
    Future<void> Function()? afterInsert,
  }) async {
    entry.authUserId = authUserIdOf(owner);
    final inserted = await PointEntry.db.insertRow(
      session,
      entry,
      transaction: tx,
    );
    await afterInsert?.call();
    if ({
      stepPolicyVersion,
      quizPolicyVersion,
      themePurchasePolicyVersion,
      outfitPurchasePolicyVersion,
    }.contains(entry.policyVersion)) {
      account.balance += entry.amount;
    } else if (entry.policyVersion == productFixtureLabel) {
      account.fixtureBalance += entry.amount;
    }
    await ProductAccount.db.updateRow(session, account, transaction: tx);
    return inserted;
  }

  Future<int> balance({bool fixture = false}) async =>
      fixture ? account.fixtureBalance : account.balance;

  Future<WalletView> wallet() async => WalletView(
    balance: await balance(),
    streamGeneration: account.streamGeneration,
    policyVersion: stepPolicyVersion,
  );

  int units(ProductDay value) =>
      min(dailyBaseCap, (value.steps ?? 0) ~/ stepsPerPoint);

  int claimable(ProductDay value, {bool withAd = false}) {
    if (value.policyVersion != stepPolicyVersion ||
        value.deleted ||
        value.availability != 'confirmed' ||
        value.date.compareTo(localDate(clock.now())) > 0) {
      return 0;
    }
    final current = units(value);
    return value.windows.fold(0, (sum, window) {
      if (!withAd &&
          (window.freeUntil == null ||
              !clock.now().toUtc().isBefore(window.freeUntil!))) {
        return sum;
      }
      return sum +
          max(
            0,
            min(current, window.throughUnits) -
                max(window.grantedThroughUnits, window.fromUnits),
          );
    });
  }

  Future<ProductDay> claimTarget(
    String date,
    int expectedRevision, {
    bool withAd = false,
  }) async {
    dayStart(date);
    if (date.compareTo(localDate(clock.now())) > 0) {
      throw ProductException(code: 'futureDate');
    }
    final value = await day(date);
    if (value.deleted) throw ProductException(code: 'dayDeleted');
    if (value.revision != expectedRevision) {
      throw ProductException(code: 'staleProjection');
    }
    if (value.policyVersion != stepPolicyVersion) {
      throw ProductException(code: 'legacyPolicyExcluded');
    }
    if (value.availability != 'confirmed') {
      throw ProductException(code: 'stepsUnavailable');
    }
    if (claimable(value, withAd: withAd) == 0) {
      throw ProductException(
        code: !withAd && claimable(value, withAd: true) > 0
            ? 'adRequired'
            : 'nothingToClaim',
      );
    }
    return value;
  }

  Future<List<PointEntry>> stepEntries(String fromDate, String toDate) =>
      PointEntry.db.find(
        session,
        where: (t) =>
            t.authUserId.equals(authUserIdOf(owner)) &
            (t.date >= fromDate) &
            (t.date <= toDate) &
            t.kind.equals('steps') &
            t.policyVersion.equals(stepPolicyVersion),
        transaction: tx,
      );

  Future<DailyRecord> view(
    ProductDay value, {
    bool routes = true,
    List<PointEntry>? entries,
  }) async {
    final production = value.policyVersion == stepPolicyVersion;
    entries ??= await stepEntries(value.date, value.date);
    final available = value.availability == 'confirmed' && value.steps != null;
    final amount = production && available && !value.deleted
        ? claimable(value)
        : null;
    final adBase = production && available && !value.deleted
        ? claimable(value, withAd: true)
        : null;
    final paths = <DayRoute>[];
    if (routes && !value.deleted) {
      final records = await gpsRecordsOnDay(value.date);
      for (final record in records) {
        final input = record.payload!;
        paths.add(
          DayRoute(
            recordId: record.id!,
            source: input.source,
            points: input.routePoints
                .where((p) => localDate(p.recordedAt) == value.date)
                .toList(),
          ),
        );
      }
    }
    return DailyRecord(
      date: value.date,
      revision: value.revision,
      deleted: value.deleted,
      deletionVersion: value.deletionVersion,
      steps: value.deleted ? null : value.steps,
      availability: value.deleted ? 'deleted' : value.availability,
      streamGeneration: value.streamGeneration,
      stepRevision: value.stepRevision,
      rewardStatus: value.deleted
          ? 'canceled'
          : value.date.compareTo(localDate(clock.now())) > 0
          ? 'futureDate'
          : !production
          ? 'legacyPolicyExcluded'
          : !available
          ? 'pending'
          : amount! > 0
          ? 'eligible'
          : adBase! > 0
          ? 'adRequired'
          : 'settled',
      claimablePoints: value.deleted ? 0 : amount,
      grantedPoints: entries.fold(0, (sum, entry) => sum + entry.amount),
      fixtureLabel: value.policyVersion == productFixtureLabel
          ? productFixtureLabel
          : null,
      policyVersion: value.policyVersion,
      gracePolicyStatus: 'active',
      basePoints: production && available && !value.deleted
          ? units(value)
          : null,
      dailyBaseCap: dailyBaseCap,
      stepsPerPoint: stepsPerPoint,
      adClaimablePoints: value.deleted
          ? 0
          : adBase == null
          ? null
          : adBase * 2,
      routes: paths,
    );
  }

  Future<List<DailyRecord>> listDays(String fromDate, String toDate) async {
    final start = dayStart(fromDate);
    final end = dayStart(toDate);
    final count = end.difference(start).inDays;
    if (count < 0 || count > 92) throw ProductException(code: 'invalidRange');
    // Two range reads instead of two reads per day: the range is grouped here.
    final stored = {
      for (final value in await ProductDay.db.find(
        session,
        where: (t) =>
            t.authUserId.equals(authUserIdOf(owner)) &
            (t.date >= fromDate) &
            (t.date <= toDate),
        transaction: tx,
      ))
        value.date: value,
    };
    final entries = <String, List<PointEntry>>{};
    for (final entry in await stepEntries(fromDate, toDate)) {
      entries.putIfAbsent(entry.date!, () => []).add(entry);
    }
    final days = <DailyRecord>[];
    for (var i = 0; i <= count; i++) {
      final date = localDate(start.add(Duration(days: i)));
      days.add(
        await view(
          stored[date] ??
              ProductDay(
                owner: owner,
                date: date,
                windows: [],
                policyVersion: stepPolicyVersion,
              ),
          routes: false,
          entries: entries[date] ?? const [],
        ),
      );
    }
    return days;
  }

  Future<int> registerStream(String requestId, int expectedGeneration) async {
    final payload = ['registerStream', expectedGeneration];
    final previous = await replay(requestId, payload);
    if (previous != null) return jsonDecode(previous) as int;
    if (account.streamGeneration != expectedGeneration) {
      throw ProductException(code: 'staleGeneration');
    }
    account.streamGeneration++;
    await ProductAccount.db.updateRow(session, account, transaction: tx);
    await remember(requestId, payload, account.streamGeneration);
    return account.streamGeneration;
  }

  Future<DailyRecord> submitSteps(DailyStepInput input) async {
    final start = dayStart(input.date);
    if (!input.windowStart.isUtc ||
        !input.windowEnd.isUtc ||
        !input.observedAt.isUtc ||
        input.windowStart != start ||
        input.windowEnd != start.add(const Duration(days: 1)) ||
        input.revision < 1 ||
        input.streamGeneration < 1 ||
        !{
          'confirmed',
          'unknown',
          'permissionUnavailable',
          'pendingSync',
          'queryFailed',
        }.contains(input.availability) ||
        (input.availability == 'confirmed'
            ? input.total == null || input.total! < 0
            : input.total != null) ||
        input.date.compareTo(localDate(clock.now())) > 0) {
      throw ProductException(code: 'invalidSnapshot');
    }
    final value = await day(input.date);
    if (value.deleted) throw ProductException(code: 'dayDeleted');
    if (input.streamGeneration != account.streamGeneration) {
      throw ProductException(code: 'staleGeneration');
    }
    final hash = digest(input.toJson());
    final previous = await StepRevision.db.findFirstRow(
      session,
      where: (t) =>
          t.authUserId.equals(authUserIdOf(owner)) &
          t.date.equals(input.date) &
          t.generation.equals(input.streamGeneration) &
          t.revision.equals(input.revision),
      transaction: tx,
    );
    if (previous != null) {
      if (previous.digest != hash) {
        throw ProductException(code: 'snapshotConflict');
      }
      return view(value);
    }
    await StepRevision.db.insertRow(
      session,
      StepRevision(
        owner: owner,
        authUserId: authUserIdOf(owner),
        date: input.date,
        generation: input.streamGeneration,
        revision: input.revision,
        digest: hash,
      ),
      transaction: tx,
    );
    if (value.streamGeneration == input.streamGeneration &&
        input.revision < value.stepRevision) {
      return view(value);
    }
    value.streamGeneration = input.streamGeneration;
    value.stepRevision = input.revision;
    value.steps = input.total;
    value.availability = input.availability;
    value.revision++;
    if (value.policyVersion == stepPolicyVersion && input.total != null) {
      final confirmed = units(value);
      if (confirmed > value.confirmedUnits) {
        final now = clock.now().toUtc();
        final ordinary = start.add(const Duration(days: 8));
        final delayed = now.add(const Duration(hours: 72));
        value.windows.add(
          RewardWindow(
            fromUnits: value.confirmedUnits,
            throughUnits: confirmed,
            confirmedAt: now,
            freeUntil: ordinary.isAfter(delayed) ? ordinary : delayed,
          ),
        );
        value.confirmedUnits = confirmed;
      }
    }
    await saveDay(value);
    return view(value);
  }

  Future<DailyRecord> deleteDay(String date, String requestId) async {
    dayStart(date);
    final payload = ['deleteDay', date];
    final previous = await replay(requestId, payload);
    if (previous != null) return view(await day(date));
    final value = await day(date);
    if (!value.deleted) {
      account.deletionVersion++;
      value.deleted = true;
      value.deletionVersion = account.deletionVersion;
      value.revision++;
      value.steps = null;
      value.availability = 'deleted';
      value.windows = [];
      value.grantedUnits = 0;
      value.confirmedUnits = 0;
      await ProductAccount.db.updateRow(session, account, transaction: tx);
      await saveDay(value);
      await StepRevision.db.deleteWhere(
        session,
        where: (t) =>
            t.authUserId.equals(authUserIdOf(owner)) & t.date.equals(date),
        transaction: tx,
      );
      await PointEntry.db.updateWhere(
        session,
        columnValues: (t) => [
          t.fromUnits(null),
          t.throughUnits(null),
          t.slices(null),
        ],
        where: (t) =>
            t.authUserId.equals(authUserIdOf(owner)) & t.date.equals(date),
        transaction: tx,
      );
      // Retry receipts duplicate the same units. Preserve their key, digest,
      // ledger identity and paid amount, but not the deleted step detail.
      await session.db.unsafeExecute(
        'UPDATE product_request SET result = '
        '((result::jsonb - \'slices\' - \'basePoints\') || '
        '\'{"fromUnits":0,"throughUnits":0}\'::jsonb)::text '
        'WHERE "authUserId" = CAST(@id AS uuid) '
        'AND result::jsonb ->> \'date\' = @date '
        'AND result::jsonb ? \'ledgerId\'',
        parameters: QueryParameters.named({
          'id': owner,
          'date': date,
        }),
        transaction: tx,
      );
      for (final record in await gpsRecordsOnDay(date)) {
        record.payload = null;
        record.deleted = true;
        record.firstLocalDay = null;
        record.lastLocalDay = null;
        await StoredGpsRecord.db.updateRow(session, record, transaction: tx);
      }
    }
    // Store no snapshot/route in an idempotency response that could expose deletion.
    await remember(requestId, payload, value.deletionVersion);
    return view(value);
  }

  /// Live records whose [first, last] KST day range contains [date]; the same
  /// set as [touchesDay] (an end exactly at midnight belongs to the new day).
  Future<List<StoredGpsRecord>> gpsRecordsOnDay(String date) {
    final target = localDayNumber(dayStart(date));
    return StoredGpsRecord.db.find(
      session,
      where: (t) =>
          t.authUserId.equals(authUserIdOf(owner)) &
          t.deleted.equals(false) &
          (t.firstLocalDay <= target) &
          (t.lastLocalDay >= target),
      transaction: tx,
    );
  }

  Future<List<DailyRecord>> deletions(int afterVersion) async {
    if (afterVersion < 0) throw ProductException(code: 'invalidCursor');
    final values = await ProductDay.db.find(
      session,
      where: (t) =>
          t.authUserId.equals(authUserIdOf(owner)) &
          t.deleted.equals(true) &
          (t.deletionVersion > afterVersion),
      orderBy: (t) => t.deletionVersion,
      limit: 100,
      transaction: tx,
    );
    return [for (final value in values) await view(value, routes: false)];
  }

  Future<RewardGrant> claim(
    String date,
    String requestId,
    int expectedRevision, {
    String? intentId,
    BillingBenefit? premium,
  }) async {
    dayStart(date);
    final payload = premium != null
        ? ['claimDayWithPremium', date, expectedRevision]
        : intentId == null
        ? ['claimDay', date, expectedRevision]
        : ['claimDayWithAd', date, expectedRevision, intentId];
    final previous = await replay(requestId, payload);
    if (previous != null) {
      return RewardGrant.fromJson(jsonDecode(previous) as Map<String, dynamic>);
    }
    if (premium != null) await premium.requireActive(this);
    final boosted = intentId != null || premium != null;
    final value = await claimTarget(
      date,
      expectedRevision,
      withAd: boosted,
    );
    final base = claimable(value, withAd: boosted);
    final multiplier = boosted ? 2 : 1;
    if (intentId != null) {
      final ads = AdService.instances[session.server.serverpod];
      if (ads == null) throw AdException(code: 'configurationMissing');
      await ads.consume(
        session,
        tx,
        owner: owner,
        intentId: intentId,
        purpose: 'dailyReward',
        targetDate: date,
        targetRevision: expectedRevision,
      );
    }
    final amount = base * multiplier;
    final slices = <RewardSlice>[];
    for (final window in value.windows) {
      if (!boosted &&
          (window.freeUntil == null ||
              !clock.now().toUtc().isBefore(window.freeUntil!))) {
        continue;
      }
      final from = max(window.fromUnits, window.grantedThroughUnits);
      final through = min(units(value), window.throughUnits);
      if (through <= from) continue;
      slices.add(
        RewardSlice(
          fromUnits: from,
          throughUnits: through,
          basePoints: through - from,
          multiplier: multiplier,
        ),
      );
      window.grantedThroughUnits = through;
    }
    final from = slices.first.fromUnits;
    final through = slices.last.throughUnits;
    final entry = await appendPointEntry(
      PointEntry(
        owner: owner,
        entryKey: '$stepPolicyVersion:steps:$date:${value.revision}',
        kind: 'steps',
        date: date,
        amount: amount,
        fromUnits: from,
        throughUnits: through,
        policyVersion: stepPolicyVersion,
        createdAt: clock.now().toUtc(),
        slices: slices,
      ),
    );
    value.grantedUnits = max(value.grantedUnits, through);
    value.revision++;
    await saveDay(value);
    final grant = RewardGrant(
      ledgerId: entry.id!,
      date: date,
      amount: amount,
      fromUnits: from,
      throughUnits: through,
      grantedAt: entry.createdAt,
      policyVersion: stepPolicyVersion,
      basePoints: base,
      multiplier: multiplier,
      slices: slices,
    );
    await remember(requestId, payload, grant.toJson());
    return grant;
  }
}
