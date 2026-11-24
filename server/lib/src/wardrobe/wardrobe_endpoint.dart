import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'wardrobe_service.dart';

/// Wardrobe: items per colour, sets, backgrounds and what is worn.
/// Every write takes a requestId and replays its first result.
class WardrobeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<WardrobeStore> getWardrobe(Session session) =>
      ProductService.read(session, (s) => s.wardrobe());

  Future<WardrobeStore> purchaseItem(
    Session session,
    String itemId,
    String colourId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.purchaseItem(itemId, colourId, requestId),
  );

  Future<WardrobeStore> purchaseSet(
    Session session,
    String setId,
    String colourId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.purchaseSet(setId, colourId, requestId),
  );

  Future<WardrobeStore> purchaseBackground(
    Session session,
    String backgroundId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.purchaseBackground(backgroundId, requestId),
  );

  Future<WardrobeStore> equipItem(
    Session session,
    String itemId,
    String colourId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.equipItem(itemId, colourId, requestId),
  );

  Future<WardrobeStore> unequipSlot(
    Session session,
    String slot,
    String requestId,
  ) => ProductService.run(session, (s) => s.unequipSlot(slot, requestId));

  Future<WardrobeStore> equipBackground(
    Session session,
    String backgroundId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.equipBackground(backgroundId, requestId),
  );

  Future<WardrobeStore> equipSet(
    Session session,
    String setId,
    String colourId,
    String requestId,
  ) => ProductService.run(
    session,
    (s) => s.equipSet(setId, colourId, requestId),
  );

  Future<WardrobeStore> unequipSet(
    Session session,
    String setId,
    String requestId,
  ) => ProductService.run(session, (s) => s.unequipSet(setId, requestId));
}
