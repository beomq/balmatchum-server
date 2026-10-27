import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_shared/log.dart' as shared;
import '../config_password.dart';
import '../generated/protocol.dart';
import 'ad_config.dart';
import 'ad_service.dart';
import 'ad_verifier.dart';

/// Public API server path that receives Google AdMob SSV callbacks.
const admobSsvPath = '/admob/ssv';

/// Called after pod.start; absent config means no SSV route or intent API.
/// The callback is served on the public API server (the only port Serverpod
/// Cloud exposes besides web/insights), so no extra listener is opened.
Future<AdService?> configureAdMob(
  Serverpod pod, {
  AdConfig? config,
  AdVerifier? verifier,
  Clock clock = const Clock(),
}) async {
  config ??= AdConfig.fromPasswords(pod.configPassword);
  if (config == null) return null;
  final service = AdService(
    config,
    verifier ?? AdVerifier(clock: clock),
    clock: clock,
  );
  AdService.instances[pod] = service;
  pod.server.addMiddleware(
    (next) => (request) async {
      final active = AdService.instances[pod];
      if (request.url.path != admobSsvPath || active == null) {
        return next(request);
      }
      if (request.method != Method.get) return Response(405);
      final ping = await active.verifier.ping(request.url.query);
      if (ping != null) {
        // Framework logger: no Session, database acquisition or DB log writes.
        shared.log.info(
          'AdMob SSV reward-less request acknowledged: ${ping.name}',
          metadata: {'kind': ping.name},
        );
        return Response(200);
      }
      return Response(await _callback(pod, active, request.url.query));
    },
  );
  pod.experimental.shutdownTasks.addTask('admob-ssv', () async {
    AdService.instances[pod] = null;
  });
  return service;
}

/// dart:io parses the request target through Uri, which normalizes percent
/// escapes; Google's canonical encoding is unchanged by that normalization,
/// and any other encoding fails signature verification (fail closed).
Future<int> _callback(Serverpod pod, AdService service, String query) async {
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
  } on Exception {
    // Transient DB/unexpected failure: Google retries non-2xx responses.
    return 503;
  } finally {
    await session.close();
  }
}
