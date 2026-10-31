import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Tables whose AuthUser foreign key normalization-step2 makes NOT NULL.
const normalizedTables = [
  'ad_intent',
  'billing_account',
  'billing_purchase',
  'dog_profile',
  'gps_record',
  'outfit_ownership',
  'point_entry',
  'product_account',
  'product_day',
  'product_request',
  'quiz_assignment',
  'quiz_state',
  'step_revision',
  'theme_ownership',
];

/// Every column the guard inspects, in the schema the server is connected to.
final schemaGuardQuery =
    '''
SELECT table_name::text, column_name::text, is_nullable::text
FROM information_schema.columns
WHERE table_schema = current_schema()
  AND ((column_name = 'authUserId' AND table_name IN ($_quoted))
    OR (table_name = 'product_account' AND column_name = 'owner')
    OR (table_name = 'quiz_assignment' AND column_name = 'snapshot'))
''';

final _quoted = normalizedTables.map((t) => "'$t'").join(', ');

/// Compares [rows] of [schemaGuardQuery] with the post-step2 schema. Kept
/// separate from the query so a raw connection can check the same rules.
List<String> schemaMismatchesFrom(Iterable<List<Object?>> rows) {
  final nullable = <String, String>{};
  final extra = <String>{};
  for (final [table, column, isNullable] in rows) {
    if (column == 'authUserId') {
      nullable[table as String] = isNullable as String;
    } else {
      extra.add('$table.$column');
    }
  }
  return [
    for (final table in normalizedTables)
      if (nullable[table] == null)
        '$table.authUserId is missing'
      else if (nullable[table] != 'NO')
        '$table.authUserId is nullable',
    if (extra.contains('product_account.owner'))
      'product_account.owner still exists',
    if (extra.contains('quiz_assignment.snapshot'))
      'quiz_assignment.snapshot still exists',
  ];
}

/// Serverpod keeps starting after a failed migration outside development, so
/// the server checks the schema it actually got right after [Serverpod.start].
Future<List<String>> schemaMismatches(Session session) async =>
    schemaMismatchesFrom(await session.db.unsafeQuery(schemaGuardQuery));

/// Rejects requests until the startup check has passed. [ready] starts true so
/// test pods that never run `server.dart` are unaffected; `run()` closes the
/// gate before starting the pod and opens it only after the check.
abstract final class SchemaGuard {
  static bool ready = true;

  static void require() {
    if (!ready) throw ProductException(code: 'serverStarting');
  }

  static void requireLogin() {
    if (!ready) throw LoginException(code: 'serverStarting');
  }
}
