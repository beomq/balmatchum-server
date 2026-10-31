import 'dart:io';

import 'src/generated/serverpod.dart';
import 'src/auth/auth_setup.dart';
import 'src/ads/ad_setup.dart';
import 'src/quiz/quiz_bank.dart';
import 'src/billing/billing_retention.dart';
import 'src/billing/billing_service.dart';
import 'src/maintenance/periodic_maintenance.dart';
import 'src/maintenance/schema_guard.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Closed until the schema check below passes: the port opens inside start().
  SchemaGuard.ready = false;
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);
  configureAuth(pod);
  BillingService.configure(pod);

  // Start the server. Pending migrations are applied inside start(); outside
  // development a failed migration is logged and startup continues.
  await pod.start();
  final guard = await pod.createSession(enableLogging: false);
  final List<String> mismatches;
  try {
    mismatches = await schemaMismatches(guard);
  } finally {
    await guard.close();
  }
  if (mismatches.isNotEmpty) {
    stderr.writeln(
      'schema guard: database schema does not match this release; exiting.\n'
      '${mismatches.map((m) => '  - $m').join('\n')}',
    );
    await stderr.flush();
    // pod.shutdown(exitProcess: true) exits 0 when no error was recorded.
    exit(1);
  }
  SchemaGuard.ready = true;
  stdout.writeln('Schema check passed: requests are accepted.');
  try {
    await configureQuizBank(pod);
    await configureAdMob(pod);
    // Keeps the daily cron where future calls are enabled; the hourly runner
    // repeats the same idempotent purge, so running both is harmless.
    await startBillingRetention(pod);
    await PeriodicMaintenance.start(pod);
  } catch (_) {
    await pod.shutdown(exitProcess: false);
    rethrow;
  }
}
