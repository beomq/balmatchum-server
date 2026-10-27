import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';

class RecordsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<RecordReceipt> saveConfirmed(
    Session session,
    GpsRecordInput input,
  ) async {
    final owner = session.authenticated!.userIdentifier;
    _validate(input);

    // The ordered route and metadata occupy one row: neither can commit alone.
    // ON CONFLICT waits for a concurrent insert before the following lookup.
    return session.db.transaction((transaction) async {
      await lockProductAccount(session, owner, transaction);
      final tombstones = await ProductDay.db.find(
        session,
        where: (t) => t.owner.equals(owner) & t.deleted.equals(true),
        transaction: transaction,
      );
      if (tombstones.any((day) => touchesDay(input, day.date))) {
        throw RecordException(code: 'dayDeleted');
      }
      final inserted = await StoredGpsRecord.db.insert(
        session,
        [
          StoredGpsRecord(
            owner: owner,
            clientRecordId: input.clientRecordId,
            persistedAt: DateTime.now().toUtc(),
            payload: input,
          ),
        ],
        ignoreConflicts: true,
        transaction: transaction,
      );
      final stored = inserted.isNotEmpty
          ? inserted.single
          : (await StoredGpsRecord.db.findFirstRow(
              session,
              where: (t) =>
                  t.owner.equals(owner) &
                  t.clientRecordId.equals(input.clientRecordId),
              transaction: transaction,
            ))!;
      if (stored.deleted) throw RecordException(code: 'dayDeleted');
      if (jsonEncode(stored.payload!.toJson()) != jsonEncode(input.toJson())) {
        throw RecordException(code: 'conflict');
      }
      return _receipt(stored);
    });
  }

  Future<GpsRecord> getMine(Session session, UuidValue recordId) async {
    final owner = session.authenticated!.userIdentifier;
    return session.db.transaction((transaction) async {
      await lockProductAccount(session, owner, transaction);
      final stored = await StoredGpsRecord.db.findFirstRow(
        session,
        where: (t) => t.id.equals(recordId) & t.owner.equals(owner),
        transaction: transaction,
      );
      if (stored == null) throw RecordException(code: 'notFound');
      if (stored.deleted) throw RecordException(code: 'dayDeleted');
      return GpsRecord(receipt: _receipt(stored), payload: stored.payload!);
    });
  }

  RecordReceipt _receipt(StoredGpsRecord stored) => RecordReceipt(
    clientRecordId: stored.clientRecordId,
    recordId: stored.id!,
    persistedAt: stored.persistedAt,
    schemaVersion: stored.payload!.schemaVersion,
  );

  void _validate(GpsRecordInput input) {
    if (input.schemaVersion != 1) {
      throw RecordException(code: 'unsupportedSchemaVersion');
    }
    if (!{'watch', 'phone'}.contains(input.source) ||
        !input.startedAt.isUtc ||
        !input.endedAt.isUtc ||
        input.endedAt.isBefore(input.startedAt)) {
      throw RecordException(code: 'invalidRecord');
    }
    if (input.routePoints.isNotEmpty) {
      throw RecordException(code: 'invalidRoute');
    }
  }
}
