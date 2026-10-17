import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import 'profile_service.dart';

class ProfileEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ProfileView?> getProfile(Session session) =>
      ProductService.run(session, (s) => s.getProfile());

  Future<ProfileView> createProfile(
    Session session,
    ProfileInput input,
    String requestId,
  ) => ProductService.run(session, (s) => s.createProfile(input, requestId));

  Future<ProfileView> renameDog(
    Session session,
    String name,
    String requestId,
    int expectedRevision,
  ) => ProductService.run(
    session,
    (s) => s.renameDog(name, requestId, expectedRevision),
  );

  Future<ProfileView> updateGoal(
    Session session,
    int goal,
    String requestId,
    int expectedRevision,
  ) => ProductService.run(
    session,
    (s) => s.updateGoal(goal, requestId, expectedRevision),
  );
}
