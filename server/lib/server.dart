import 'src/generated/serverpod.dart';
import 'src/auth/auth_setup.dart';
import 'src/ads/ad_setup.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);
  configureAuth(pod);

  // Start the server.
  await pod.start();
  try {
    await configureAdMob(pod);
  } catch (_) {
    await pod.shutdown(exitProcess: false);
    rethrow;
  }
}
