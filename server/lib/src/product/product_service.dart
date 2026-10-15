import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// No production economics are configured. These values are disposable fixtures.
const productFixtureLabel = 'development-fixture-v1-not-production';

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

bool touchesDay(GpsRecordInput input, String date) {
  final start = dayStart(date);
  final end = start.add(const Duration(days: 1));
  // Endpoints at midnight are real samples and belong to the new date.
  return input.startedAt.isBefore(end) && !input.endedAt.isBefore(start);
}

/// One owner lock covers money, generations, day deletion, GPS and reads.
/// This intentionally trades per-owner parallelism for a single lock order.
Future<ProductAccount> lockProductAccount(
  Session session,
  String owner,
  Transaction tx,
) async {
  await ProductAccount.db.insert(
    session,
    [ProductAccount(owner: owner)],
    ignoreConflicts: true,
    transaction: tx,
  );
  return (await ProductAccount.db.findFirstRow(
    session,
    where: (t) => t.owner.equals(owner),
    lockMode: LockMode.forUpdate,
    transaction: tx,
  ))!;
}

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
      return action(ProductService(session, owner, tx, account));
    });
  }

  Future<ProductDay> day(String date) async {
    dayStart(date);
    return await ProductDay.db.findFirstRow(
          session,
          where: (t) => t.owner.equals(owner) & t.date.equals(date),
          transaction: tx,
        ) ??
        ProductDay(owner: owner, date: date, windows: []);
  }

  Future<void> saveDay(ProductDay value) async {
    if (value.id == null) {
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
      where: (t) => t.owner.equals(owner) & t.requestId.equals(requestId),
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
        requestId: requestId,
        digest: digest(payload),
        result: jsonEncode(result),
      ),
      transaction: tx,
    );
  }

  Future<int> balance() async {
    final result = await session.db.unsafeQuery(
      'SELECT COALESCE(SUM(amount), 0) FROM point_entry WHERE owner = @owner',
      parameters: QueryParameters.named({'owner': owner}),
      transaction: tx,
    );
    return int.parse(result.single[0].toString());
  }

  Future<WalletView> wallet() async => WalletView(
    balance: await balance(),
    streamGeneration: account.streamGeneration,
    fixtureLabel: productFixturesEnabled(session) ? productFixtureLabel : null,
  );

  int units(ProductDay value) => (value.steps ?? 0) ~/ 1000;

  /// The development fixture grants one point per complete 1000 steps.
  int claimable(ProductDay value) {
    final current = units(value);
    return value.windows.fold(0, (sum, window) {
      if (!clock.now().toUtc().isBefore(window.freeUntil)) return sum;
      return sum +
          max(
            0,
            min(current, window.throughUnits) -
                max(value.grantedUnits, window.fromUnits),
          );
    });
  }

  Future<DailyRecord> view(ProductDay value, {bool routes = true}) async {
    final fixture = productFixturesEnabled(session);
    final entries = await PointEntry.db.find(
      session,
      where: (t) =>
          t.owner.equals(owner) &
          t.date.equals(value.date) &
          t.kind.equals('steps'),
      transaction: tx,
    );
    final available = value.availability == 'confirmed' && value.steps != null;
    final amount = fixture && available && !value.deleted
        ? claimable(value)
        : null;
    final paths = <DayRoute>[];
    if (routes && !value.deleted) {
      final records = await StoredGpsRecord.db.find(
        session,
        where: (t) => t.owner.equals(owner) & t.deleted.equals(false),
        transaction: tx,
      );
      for (final record in records) {
        final input = record.payload!;
        if (!touchesDay(input, value.date)) continue;
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
          : !fixture
          ? 'policyUnconfigured'
          : !available
          ? 'pending'
          : amount! > 0
          ? 'eligible'
          : units(value) > value.grantedUnits
          ? 'expired'
          : 'settled',
      claimablePoints: value.deleted ? 0 : amount,
      grantedPoints: entries.fold(0, (sum, entry) => sum + entry.amount),
      fixtureLabel: fixture ? productFixtureLabel : null,
      routes: paths,
    );
  }

  Future<List<DailyRecord>> listDays(String fromDate, String toDate) async {
    final start = dayStart(fromDate);
    final end = dayStart(toDate);
    final count = end.difference(start).inDays;
    if (count < 0 || count > 92) throw ProductException(code: 'invalidRange');
    return [
      for (var i = 0; i <= count; i++)
        await view(
          await day(localDate(start.add(Duration(days: i)))),
          routes: false,
        ),
    ];
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
          t.owner.equals(owner) &
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
    if (productFixturesEnabled(session) && input.total != null) {
      value.policyVersion ??= productFixtureLabel;
      final confirmed = units(value);
      if (confirmed > value.confirmedUnits) {
        final now = clock.now().toUtc();
        final ordinary = start.add(const Duration(days: 7));
        final delayed = now.add(const Duration(days: 3));
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
      await ProductAccount.db.updateRow(session, account, transaction: tx);
      await saveDay(value);
      await StepRevision.db.deleteWhere(
        session,
        where: (t) => t.owner.equals(owner) & t.date.equals(date),
        transaction: tx,
      );
      final records = await StoredGpsRecord.db.find(
        session,
        where: (t) => t.owner.equals(owner) & t.deleted.equals(false),
        transaction: tx,
      );
      for (final record in records) {
        if (touchesDay(record.payload!, date)) {
          record.payload = null;
          record.deleted = true;
          await StoredGpsRecord.db.updateRow(session, record, transaction: tx);
        }
      }
    }
    // Store no snapshot/route in an idempotency response that could expose deletion.
    await remember(requestId, payload, value.deletionVersion);
    return view(value);
  }

  Future<List<DailyRecord>> deletions(int afterVersion) async {
    if (afterVersion < 0) throw ProductException(code: 'invalidCursor');
    final values = await ProductDay.db.find(
      session,
      where: (t) =>
          t.owner.equals(owner) &
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
    int expectedRevision,
  ) async {
    dayStart(date);
    final payload = ['claimDay', date, expectedRevision];
    final previous = await replay(requestId, payload);
    if (previous != null) {
      return RewardGrant.fromJson(jsonDecode(previous) as Map<String, dynamic>);
    }
    final value = await day(date);
    if (value.deleted) throw ProductException(code: 'dayDeleted');
    requireProductFixtures(session);
    if (value.revision != expectedRevision) {
      throw ProductException(code: 'staleProjection');
    }
    if (value.availability != 'confirmed') {
      throw ProductException(code: 'stepsUnavailable');
    }
    final amount = claimable(value);
    if (amount == 0) throw ProductException(code: 'nothingToClaim');
    final from = value.grantedUnits;
    final through = units(value);
    final entry = await PointEntry.db.insertRow(
      session,
      PointEntry(
        owner: owner,
        entryKey: 'steps:$date:$through',
        kind: 'steps',
        date: date,
        amount: amount,
        fromUnits: from,
        throughUnits: through,
        policyVersion: productFixtureLabel,
        createdAt: clock.now().toUtc(),
      ),
      transaction: tx,
    );
    value.grantedUnits = through;
    await saveDay(value);
    final grant = RewardGrant(
      ledgerId: entry.id!,
      date: date,
      amount: amount,
      fromUnits: from,
      throughUnits: through,
      grantedAt: entry.createdAt,
      fixtureLabel: productFixtureLabel,
    );
    await remember(requestId, payload, grant.toJson());
    return grant;
  }
}
