import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Keep expired attempts for one day for diagnosis; no scheduler is enabled.
const expiredAttemptRetention = Duration(days: 1);

Future<int> deleteStaleLoginAttempts(
  Session session, {
  Clock clock = const Clock(),
}) async {
  final cutoff = clock.now().toUtc().subtract(expiredAttemptRetention);
  final deleted = await LoginAttempt.db.deleteWhere(
    session,
    where: (t) => t.expiresAt < cutoff,
  );
  final naverDeleted = await NaverLoginAttempt.db.deleteWhere(
    session,
    where: (t) => t.expiresAt < cutoff,
  );
  return deleted.length + naverDeleted.length;
}
