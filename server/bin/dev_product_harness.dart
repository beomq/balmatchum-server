import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/auth/auth_setup.dart';
import 'package:balmatchum_server/src/auth/dev_test_user.dart';
import 'package:balmatchum_server/src/generated/serverpod.dart';

import 'dev_test_user.dart' show prepareDevTestOutput;

/// Disposable loopback server for the mobile integration harness.
Future<void> main(List<String> args) async {
  if (args.length != 1 || args.single != '--mode=development') {
    stderr.writeln('Explicit development mode required.');
    exitCode = 1;
    return;
  }
  final directory = await Directory.systemTemp.createTemp(
    'balmatchum-product-',
  );
  final pod = Serverpod(
    ['--mode=test', '--apply-migrations'],
    configOverride: (config) => config.copyWith(
      runMode: 'development',
      apiServer: ServerConfig(
        port: 18080,
        publicHost: 'localhost',
        publicPort: 18080,
        publicScheme: 'http',
      ),
      database: PostgresDatabaseConfig(
        host: '127.0.0.1',
        port: 0,
        user: 'postgres',
        password: 'local-disposable-test-only',
        dataPath: '${directory.path}/pgdata',
        name: devTestDatabaseName,
      ),
    ),
  );
  configureAuth(pod, sessionPepper: 'local-disposable-product-harness');
  Session? session;
  Directory? output;
  try {
    await pod.start(runInGuardedZone: false);
    session = await pod.createSession(enableLogging: false);
    output = await prepareDevTestOutput();
    final auth = await bootstrapDevTestUser(session);
    await File('${output.path}/session.json').writeAsString(
      jsonEncode(auth.toJson()),
      flush: true,
    );
    stdout.writeln(
      'PRODUCT_HARNESS_READY ${output.absolute.path}/session.json',
    );
  } catch (_) {
    await session?.close();
    session = null;
    try {
      await pod.shutdown(exitProcess: false);
    } finally {
      if (output != null) await output.delete(recursive: true);
      await directory.delete(recursive: true);
    }
    stderr.writeln('Product harness startup failed.');
    exitCode = 1;
  } finally {
    await session?.close();
  }
  // The monitor owns this process tree. Its teardown also stops the embedded DB.
}
