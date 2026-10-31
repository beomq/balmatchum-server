import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart' as generated;
import 'package:balmatchum_server/src/maintenance/periodic_maintenance.dart';
import 'package:balmatchum_server/src/product/product_request_cleanup.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late generated.Serverpod pod;
  late Session admin;
  // Synchronous delivery: a tick reaches the runner inside `add`, so tests
  // control exactly which ticks land during a run without waiting on time.
  late StreamController<void> ticks;
  final started = <PeriodicMaintenance>[];

  Future<PeriodicMaintenance> start(
    List<MaintenanceJob> jobs, {
    void Function(Object, StackTrace)? onError,
  }) async {
    final maintenance = await PeriodicMaintenance.start(
      pod,
      ticks: ticks.stream,
      jobs: jobs,
      onError: onError ?? (error, stackTrace) => fail('job failed: $error'),
    );
    started.add(maintenance);
    return maintenance;
  }

  Future<void> tick(PeriodicMaintenance maintenance) {
    final done = maintenance.completed.first;
    ticks.add(null);
    return done;
  }

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('maintenance-');
    pod = generated.Serverpod(
      ['--mode=test', '--apply-migrations'],
      configOverride: (config) => config.copyWith(
        database: PostgresDatabaseConfig.embedded(
          dataPath: '${directory.path}/pgdata',
          name: 'maintenance_test',
          maxConnectionCount: 10,
        ),
        // Serverpod Cloud Starter: future calls are disabled.
        futureCall: const FutureCallConfig(enabled: false),
      ),
    );
    await pod.start(runInGuardedZone: false);
    admin = await pod.createSession(enableLogging: false);
  });

  tearDownAll(() async {
    await admin.close();
    await pod.shutdown(exitProcess: false);
    await directory.delete(recursive: true);
  });

  // Broadcast: closing completes even when a test never started a runner.
  setUp(() => ticks = StreamController<void>.broadcast(sync: true));

  tearDown(() async {
    for (final maintenance in started) {
      await maintenance.stop();
    }
    started.clear();
    await ticks.close();
  });

  test(
    '(a) with future calls disabled, startup plus two ticks runs each job three times',
    () async {
      expect(pod.config.futureCall.enabled, isFalse);
      final counts = [0, 0];
      final maintenance = await start([
        (_) async => counts[0]++,
        (_) async => counts[1]++,
      ]);
      expect(counts, [1, 1]);
      await tick(maintenance);
      await tick(maintenance);
      expect(counts, [3, 3]);
    },
  );

  test('a tick arriving during a run is skipped, not stacked', () async {
    var calls = 0;
    var block = false;
    final gate = Completer<void>();
    final maintenance = await start([
      (_) async {
        calls++;
        if (block) await gate.future;
      },
    ]);
    block = true;
    final done = maintenance.completed.first;
    ticks.add(null);
    ticks.add(null);
    gate.complete();
    await done;
    expect(calls, 2);
    await tick(maintenance);
    expect(calls, 3);
  });

  test(
    '(b) a throwing job does not stop the others and is retried next tick',
    () async {
      var flaky = 0;
      var steady = 0;
      final errors = <Object>[];
      final maintenance = await start(
        [
          (_) async {
            flaky++;
            if (flaky == 1) throw StateError('transient');
          },
          (_) async => steady++,
        ],
        onError: (error, _) => errors.add(error),
      );
      expect((flaky, steady), (1, 1));
      expect(errors, [isA<StateError>()]);
      await tick(maintenance);
      expect((flaky, steady), (2, 2));
      expect(errors, hasLength(1));
    },
  );

  test('stop cancels the ticks so no run follows', () async {
    var calls = 0;
    final maintenance = await start([(_) async => calls++]);
    await tick(maintenance);
    expect(calls, 2);
    await maintenance.stop();
    started.remove(maintenance);
    expect(ticks.hasListener, isFalse);
    ticks.add(null);
    expect(calls, 2);
  });

  test(
    '(c) one tick of the retention jobs deletes the three expired rows only',
    () async {
      final maintenance = await start(retentionJobs);
      final now = DateTime.now().toUtc();
      const owner = 'maintenance-owner';
      final payload = ['equipTheme', 'forest'];
      final digest = sha256
          .convert(utf8.encode(jsonEncode(payload)))
          .toString();
      ProductRequest request(String id, Duration age) => ProductRequest(
        owner: owner,
        requestId: id,
        digest: digest,
        result: '$id-result',
        createdAt: now.subtract(age),
      );
      final stale = await ProductRequest.db.insertRow(
        admin,
        request('stale', const Duration(days: 31)),
      );
      final fresh = await ProductRequest.db.insertRow(
        admin,
        request('fresh', const Duration(days: 1)),
      );
      final attempt = await LoginAttempt.db.insertRow(
        admin,
        LoginAttempt(
          nonceHash: 'maintenance',
          expiresAt: now.subtract(const Duration(days: 2)),
        ),
      );
      final tombstone = await PurchaseTombstone.db.insertRow(
        admin,
        PurchaseTombstone(
          identityHash: 'maintenance-expired',
          retainUntil: now.subtract(const Duration(days: 1)),
        ),
      );

      await tick(maintenance);

      expect(await ProductRequest.db.findById(admin, stale.id!), isNull);
      expect(await ProductRequest.db.findById(admin, fresh.id!), isNotNull);
      expect(await LoginAttempt.db.findById(admin, attempt.id!), isNull);
      expect(await PurchaseTombstone.db.findById(admin, tombstone.id!), isNull);
      await admin.db.transaction((tx) async {
        final service = ProductService(
          admin,
          owner,
          tx,
          ProductAccount(owner: owner),
        );
        expect(await service.replay('fresh', payload), 'fresh-result');
        expect(await service.replay('stale', payload), isNull);
      });
    },
  );

  test(
    'product request purge drains a backlog beyond one 500-row batch',
    () async {
      final now = DateTime.now().toUtc();
      await ProductRequest.db.insert(admin, [
        for (var i = 0; i < 1201; i++)
          ProductRequest(
            owner: 'backlog',
            requestId: 'stale-$i',
            digest: 'digest',
            result: 'result',
            createdAt: now.subtract(const Duration(days: 40)),
          ),
        ProductRequest(
          owner: 'backlog',
          requestId: 'kept',
          digest: 'digest',
          result: 'result',
          createdAt: now,
        ),
      ]);
      expect(await purgeStaleProductRequests(admin), 1201);
      final left = await ProductRequest.db.find(
        admin,
        where: (t) => t.owner.equals('backlog'),
      );
      expect(left.map((r) => r.requestId), ['kept']);
      expect(await purgeStaleProductRequests(admin), 0);
    },
  );
}
