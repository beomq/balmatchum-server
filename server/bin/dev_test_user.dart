import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/auth/dev_test_user.dart';
import 'package:balmatchum_server/src/config_password.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart';

Future<void> main(List<String> args) async {
  Serverpod? pod;
  Session? session;
  Directory? output;
  try {
    // Accept no arbitrary Serverpod options (including migrations/repair).
    if (args.length != 1 ||
        args.single != '--mode=development' ||
        (Platform.environment['SERVERPOD_RUN_MODE'] != null &&
            Platform.environment['SERVERPOD_RUN_MODE'] != 'development')) {
      throw StateError('Explicit development mode required.');
    }
    pod = Serverpod(args);
    requireDevTestDatabase(pod.config);
    final pepper = pod.configPassword('serverSideSessionKeyHashPepper');
    if (pepper == null || pepper.isEmpty) {
      throw StateError('Session pepper required.');
    }
    configureAuth(pod);
    // No pod.start(): the SDK lazily opens the DB pool; no listening servers,
    // future calls, migrations or HTTP response carrying secrets are created.
    session = await pod.createSession(enableLogging: false);
    output = await prepareDevTestOutput();
    final success = await bootstrapDevTestUser(session);
    final file = File('${output.path}/session.json');
    await file.writeAsString(jsonEncode(success.toJson()), flush: true);
    stdout.writeln('Dev test session saved to ${file.absolute.path}');
  } catch (_) {
    // Exceptions may contain secret material. Never echo them or stack traces.
    if (output != null) await output.delete(recursive: true);
    stderr.writeln(
      'Dev test bootstrap refused or failed. Check mode, isolated DB, '
      'migrations, pepper and local output permissions.',
    );
    exitCode = 1;
  } finally {
    await session?.close();
    await pod?.shutdown(exitProcess: false);
  }
}

/// Creates an ignored, private directory and an empty 0600 file before secrets.
Future<Directory> prepareDevTestOutput() async {
  if (!Platform.isLinux && !Platform.isMacOS) {
    throw UnsupportedError('POSIX permissions required.');
  }
  final parent = Directory('.dart_tool');
  await parent.create();
  final directory = await parent.createTemp('dev-test-user-');
  try {
    final ignored = await Process.run('git', [
      'check-ignore',
      '--quiet',
      '${directory.path}/session.json',
    ]);
    if (ignored.exitCode != 0) throw StateError('Output must be ignored.');
    final privateDirectory = await Process.run('chmod', [
      '700',
      directory.path,
    ]);
    if (privateDirectory.exitCode != 0) throw StateError('chmod failed.');
    final file = await File('${directory.path}/session.json').create();
    final privateFile = await Process.run('chmod', ['600', file.path]);
    if (privateFile.exitCode != 0) throw StateError('chmod failed.');
    return directory;
  } catch (_) {
    await directory.delete(recursive: true);
    rethrow;
  }
}
