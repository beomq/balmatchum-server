import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import '../wardrobe/season_grants.dart';
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
  ) => _granting(
    session,
    BillingService.run(session, (s, db) => s.verify(db, input)),
  );

  Future<EntitlementView> restorePurchase(
    Session session,
    PurchaseInput input,
  ) => _granting(
    session,
    BillingService.run(session, (s, db) => s.verify(db, input)),
  );

  Future<EntitlementView> getEntitlement(Session session) => _granting(
    session,
    BillingService.run(session, (s, db) => s.entitlement(db)),
  );

  /// A subscription seen active while a season window is open receives that
  /// season set (once). Late subscribers get nothing: the window is closed.
  Future<EntitlementView> _granting(
    Session session,
    Future<EntitlementView> lookup,
  ) async {
    final view = await lookup;
    if (view.active) {
      await ProductService.run(
        session,
        (s) => s.grantOpenSeasonSets('subscribe'),
      );
    }
    return view;
  }
}
