import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'billing_service.dart';

class BillingEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<PurchaseConfiguration> getPurchaseConfiguration(
    Session session,
    String store,
  ) => BillingService.run(session, (s, db) => s.configuration(db, store));

  Future<EntitlementView> verifyPurchase(
    Session session,
    PurchaseInput input,
  ) => BillingService.run(session, (s, db) => s.verify(db, input));

  Future<EntitlementView> restorePurchase(
    Session session,
    PurchaseInput input,
  ) => BillingService.run(session, (s, db) => s.verify(db, input));

  Future<EntitlementView> getEntitlement(Session session) =>
      BillingService.run(session, (s, db) => s.entitlement(db));
}
