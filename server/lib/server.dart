import 'src/generated/serverpod.dart';
import 'src/auth/auth_setup.dart';
import 'src/ads/ad_setup.dart';
import 'src/quiz/quiz_bank.dart';
import 'src/billing/billing_retention.dart';
import 'src/billing/billing_service.dart';
import 'src/maintenance/periodic_maintenance.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);
  configureAuth(pod);
  BillingService.configure(pod);

  // Start the server.
  await pod.start();
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
