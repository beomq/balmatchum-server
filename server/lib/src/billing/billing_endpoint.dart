import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import '../wardrobe/gift_grants.dart';
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

  Future<EntitlementView> _granting(
    Session session,
    Future<EntitlementView> lookup,
  ) => withSeasonGift(
    session,
    lookup,
    () => ProductService.run(
      session,
      (s) => s.grantCurrentGift('subscribe'),
    ),
  );
}

/// A member seen active during a month receives that month's gift (once);
/// late members do not get past months. The gift is a separate write: if it fails, the verified
/// entitlement is still returned and the hourly release sweep
/// ([grantMonthlyGifts]) gives the set later.
Future<EntitlementView> withSeasonGift(
  Session session,
  Future<EntitlementView> lookup,
  Future<void> Function() gift,
) async {
  final view = await lookup;
  if (!view.active) return view;
  try {
    await gift();
  } catch (error) {
    session.log(
      'Season-set gift failed; the release sweep retries it: '
      '${error.runtimeType}',
      level: LogLevel.warning,
    );
  }
  return view;
}
