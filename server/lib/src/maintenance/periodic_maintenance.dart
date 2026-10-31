import 'dart:async';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../auth/login_attempt_cleanup.dart';
import '../billing/billing_retention.dart';
import '../product/product_request_cleanup.dart';

typedef MaintenanceJob = Future<void> Function(Session session);

/// Serverpod Cloud Starter disables future calls, so retention cleanup runs on
/// an in-process timer instead. Each instance runs its own timer; the jobs are
/// idempotent deletes, so overlapping instances only find fewer rows.
const maintenanceInterval = Duration(hours: 1);

const List<MaintenanceJob> retentionJobs = [
  purgeStaleProductRequests,
  deleteStaleLoginAttempts,
  purgeExpiredBillingRetention,
];

void _reportFailure(Object error, StackTrace stackTrace) {
  stderr.writeln('Periodic maintenance job failed: $error\n$stackTrace');
}

class PeriodicMaintenance {
  PeriodicMaintenance._(this._pod, this._ticks, this._jobs, this._onError);

  final Serverpod _pod;
  final Stream<void> _ticks;
  final List<MaintenanceJob> _jobs;
  final void Function(Object error, StackTrace stackTrace) _onError;
  final _completed = StreamController<void>.broadcast(sync: true);
  StreamSubscription<void>? _subscription;
  Future<void>? _running;

  /// Runs every job once, then again on each tick. Production ticks hourly;
  /// tests inject their own ticks and jobs.
  static Future<PeriodicMaintenance> start(
    Serverpod pod, {
    Stream<void>? ticks,
    List<MaintenanceJob> jobs = retentionJobs,
    void Function(Object error, StackTrace stackTrace) onError = _reportFailure,
  }) async {
    final maintenance = PeriodicMaintenance._(
      pod,
      ticks ?? Stream<void>.periodic(maintenanceInterval),
      jobs,
      onError,
    );
    await maintenance._run();
    maintenance._subscription = maintenance._ticks.listen(
      (_) => maintenance._tick(),
    );
    return maintenance;
  }

  /// Emits after each finished run, including runs with failed jobs.
  Stream<void> get completed => _completed.stream;

  /// A tick arriving while a run is still going is skipped: the run in
  /// progress already covers it, and stacking runs would only add DB load.
  void _tick() {
    if (_running != null) return;
    unawaited(_run());
  }

  Future<void> _run() {
    final run = _runJobs().whenComplete(() {
      _running = null;
      _completed.add(null);
    });
    _running = run;
    return run;
  }

  Future<void> _runJobs() async {
    try {
      final session = await _pod.createSession(enableLogging: false);
      try {
        for (final job in _jobs) {
          // A failing job must not block the others; it runs again next tick.
          try {
            await job(session);
          } catch (error, stackTrace) {
            _onError(error, stackTrace);
          }
        }
      } finally {
        await session.close();
      }
    } catch (error, stackTrace) {
      _onError(error, stackTrace);
    }
  }

  /// Stops ticking and waits for a run in progress, so shutdown does not close
  /// the database under it.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _running;
    await _completed.close();
  }
}
