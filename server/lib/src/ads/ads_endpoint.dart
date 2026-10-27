import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'ad_service.dart';

class AdsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  AdService _service(Session session) {
    final service = AdService.instances[session.server.serverpod];
    if (service == null) throw AdException(code: 'configurationMissing');
    return service;
  }

  Future<AdIntent> createIntent(
    Session session,
    String purpose,
    String targetDate,
    int targetRevision,
  ) => ProductService.run(
    session,
    (s) => _service(session).create(s, purpose, targetDate, targetRevision),
  );

  Future<AdIntent> getIntent(Session session, String intentId) =>
      ProductService.run(session, (s) => _service(session).get(s, intentId));
}
