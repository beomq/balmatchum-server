import 'dart:io';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'ad_config.dart';
import 'ad_service.dart';
import 'ad_verifier.dart';
import 'raw_query_server.dart';

/// Called after pod.start; absent config means no SSV listener or intent API.
Future<RawQueryServer?> configureAdMob(
  Serverpod pod, {
  AdConfig? config,
  AdVerifier? verifier,
  Clock clock = const Clock(),
}) async {
  config ??= AdConfig.fromPasswords(pod.getPassword);
  if (config == null) return null;
  final service = AdService(
    config,
    verifier ?? AdVerifier(clock: clock),
    clock: clock,
  );
  final listener = await RawQueryServer.bind(
    address: InternetAddress.loopbackIPv4,
    port: config.port,
    callback: (query) async {
      final session = await pod.createSession(enableLogging: false);
      try {
        await service.callback(session, query);
        return 200;
      } on AdKeysUnavailable {
        return 503;
      } on FormatException {
        return 400;
      } on AdException {
        return 409;
      } on NotAuthorizedException {
        return 410;
      } finally {
        await session.close();
      }
    },
  );
  AdService.instances[pod] = service;
  pod.experimental.shutdownTasks.addTask('admob-ssv', () async {
    AdService.instances[pod] = null;
    await listener.close();
  });
  return listener;
}
