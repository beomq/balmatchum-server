import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// A product request is replayed only for client retries of the same call,
/// which arrive within seconds; after this window a reused requestId runs as a
/// new request.
const productRequestRetention = Duration(days: 30);

/// Deletes in id-ordered batches so one run never loads the whole backlog;
/// concurrent runs on other instances only delete rows already gone.
Future<int> purgeStaleProductRequests(
  Session session, {
  Clock clock = const Clock(),
  int batchSize = 500,
}) async {
  final cutoff = clock.now().toUtc().subtract(productRequestRetention);
  var deleted = 0;
  while (true) {
    final ids = {
      for (final row in await ProductRequest.db.find(
        session,
        where: (t) => t.createdAt < cutoff,
        orderBy: (t) => t.id,
        limit: batchSize,
      ))
        row.id!,
    };
    if (ids.isEmpty) break;
    deleted += (await ProductRequest.db.deleteWhere(
      session,
      where: (t) => t.id.inSet(ids),
    )).length;
    if (ids.length < batchSize) break;
  }
  return deleted;
}
