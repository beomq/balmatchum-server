import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/records/records_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

GpsRecordInput record() => GpsRecordInput(
  schemaVersion: 1,
  clientRecordId: const Uuid().v4obj(),
  startedAt: DateTime.utc(2026, 10, 9, 10),
  endedAt: DateTime.utc(2026, 10, 9, 10, 1),
  source: 'watch',
  routePoints: [],
);

GpsRecordInput locatedRecord() => record().copyWith(
  routePoints: [
    RoutePoint(
      recordedAt: DateTime.utc(2026, 10, 9, 10),
      latitude: 37.5,
      longitude: 127,
      horizontalAccuracyMeters: 0,
    ),
    RoutePoint(
      recordedAt: DateTime.utc(2026, 10, 9, 10, 1),
      latitude: 37.6,
      longitude: 127.1,
    ),
  ],
);

Matcher failsWith(String code) => throwsA(
  isA<RecordException>().having((error) => error.code, 'code', code),
);

void main() {
  withServerpod('Owner-scoped GPS records', (builder, endpoints) {
    final owner = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    final other = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );

    setUp(() async {
      for (final user in [owner, other]) {
        final session = user.build();
        await AuthUser.db.insertRow(
          session,
          AuthUser(
            id: UuidValue.fromString(session.authenticated!.userIdentifier),
            scopeNames: {},
          ),
        );
      }
    });

    test('requires authentication for both endpoints', () async {
      await expectLater(
        endpoints.records.saveConfirmed(builder, record()),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
      await expectLater(
        endpoints.records.getMine(builder, const Uuid().v4obj()),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test(
      'persists location-free metadata and returns stable receipt',
      () async {
        final input = record();
        final first = await endpoints.records.saveConfirmed(owner, input);
        final again = await endpoints.records.saveConfirmed(owner, input);
        expect(again.toJson(), first.toJson());
        final saved = await endpoints.records.getMine(owner, first.recordId);
        expect(saved.payload.toJson(), input.toJson());
        expect(saved.receipt.toJson(), first.toJson());
        expect(first.schemaVersion, 1);
        expect(first.clientRecordId, input.clientRecordId);
        expect(first.persistedAt.isUtc, isTrue);
        expect(await StoredGpsRecord.db.count(owner.build()), 1);
      },
    );

    test(
      'Watch location fixture is rejected without persistence',
      () async {
        final fixture =
            jsonDecode(
                  File(
                    'test/integration/fixtures/watch_v1.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        final wire = fixture['record'] as Map<String, dynamic>;
        final input = GpsRecordInput(
          schemaVersion: wire['schemaVersion'] as int,
          clientRecordId: UuidValue.fromString(wire['recordId'] as String),
          startedAt: DateTime.parse(wire['startedAt'] as String),
          endedAt: DateTime.parse(wire['endedAt'] as String),
          source: 'watch',
          routePoints: (wire['payload']['points'] as List)
              .map(
                (point) => RoutePoint(
                  recordedAt: DateTime.parse(point['recordedAt'] as String),
                  latitude: (point['latitude'] as num).toDouble(),
                  longitude: (point['longitude'] as num).toDouble(),
                  horizontalAccuracyMeters:
                      (point['horizontalAccuracyMeters'] as num).toDouble(),
                ),
              )
              .toList(),
        );
        await expectLater(
          endpoints.records.saveConfirmed(owner, input),
          failsWith('invalidRoute'),
        );
        expect(await StoredGpsRecord.db.count(owner.build()), 0);
      },
    );

    test('different payload conflicts without replacing original', () async {
      final input = record();
      final receipt = await endpoints.records.saveConfirmed(owner, input);
      await expectLater(
        endpoints.records.saveConfirmed(owner, input.copyWith(source: 'phone')),
        failsWith('conflict'),
      );
      final saved = await endpoints.records.getMine(owner, receipt.recordId);
      expect(saved.payload.toJson(), input.toJson());
      expect(await StoredGpsRecord.db.count(owner.build()), 1);
    });

    test('owners cannot query each other and keys are owner scoped', () async {
      final input = record();
      final first = await endpoints.records.saveConfirmed(owner, input);
      await expectLater(
        endpoints.records.getMine(other, first.recordId),
        failsWith('notFound'),
      );
      final second = await endpoints.records.saveConfirmed(other, input);
      expect(second.recordId, isNot(first.recordId));
      await expectLater(
        endpoints.records.getMine(owner, second.recordId),
        failsWith('notFound'),
      );
      await expectLater(
        endpoints.records.getMine(owner, const Uuid().v4obj()),
        failsWith('notFound'),
      );
    });

    test('rejects unsupported schema and invalid metadata', () async {
      final input = record();
      await expectLater(
        endpoints.records.saveConfirmed(
          owner,
          input.copyWith(schemaVersion: 2),
        ),
        failsWith('unsupportedSchemaVersion'),
      );
      for (final invalid in [
        input.copyWith(source: 'unknown'),
        input.copyWith(
          endedAt: input.startedAt.subtract(const Duration(seconds: 1)),
        ),
      ]) {
        await expectLater(
          endpoints.records.saveConfirmed(owner, invalid),
          failsWith('invalidRecord'),
        );
      }
      expect(await StoredGpsRecord.db.count(owner.build()), 0);
    });

    test('rejects invalid route without partial persistence', () async {
      final input = locatedRecord();
      final point = input.routePoints.last;
      for (final invalid in [
        point.copyWith(latitude: 90.1),
        point.copyWith(longitude: -180.1),
        point.copyWith(horizontalAccuracyMeters: -1),
        point.copyWith(
          recordedAt: input.endedAt.add(const Duration(seconds: 1)),
        ),
        point.copyWith(
          recordedAt: input.startedAt.subtract(const Duration(seconds: 1)),
        ),
      ]) {
        await expectLater(
          endpoints.records.saveConfirmed(
            owner,
            input.copyWith(routePoints: [input.routePoints.first, invalid]),
          ),
          failsWith('invalidRoute'),
        );
      }
      await expectLater(
        endpoints.records.saveConfirmed(
          owner,
          input.copyWith(routePoints: input.routePoints.reversed.toList()),
        ),
        failsWith('invalidRoute'),
      );
      expect(await StoredGpsRecord.db.count(owner.build()), 0);
    });

    test(
      'validates values before protocol normalization or JSON encoding',
      () async {
        // The generated helper normalizes DateTime to UTC and JSON rejects NaN.
        // Exercise the endpoint boundary directly for these in-process values.
        final endpoint = RecordsEndpoint();
        final session = owner.build();
        final input = locatedRecord();
        await expectLater(
          endpoint.saveConfirmed(
            session,
            input.copyWith(startedAt: DateTime(2026, 10, 9, 10)),
          ),
          failsWith('invalidRecord'),
        );
        for (final point in [
          input.routePoints.first.copyWith(latitude: double.nan),
          input.routePoints.first.copyWith(longitude: double.infinity),
          input.routePoints.first.copyWith(
            horizontalAccuracyMeters: double.infinity,
          ),
        ]) {
          await expectLater(
            endpoint.saveConfirmed(
              session,
              input.copyWith(routePoints: [point]),
            ),
            failsWith('invalidRoute'),
          );
        }
        expect(await StoredGpsRecord.db.count(session), 0);
      },
    );

    test(
      'rejects valid and boundary coordinates without storing location',
      () async {
        // Given: even valid coordinates must never cross the storage boundary.
        final input = locatedRecord();
        for (final points in [
          input.routePoints,
          [
            input.routePoints.first.copyWith(latitude: -90, longitude: 180),
            input.routePoints.first.copyWith(latitude: 90, longitude: -180),
          ],
        ]) {
          // When.
          await expectLater(
            endpoints.records.saveConfirmed(
              owner,
              input.copyWith(routePoints: points),
            ),
            failsWith('invalidRoute'),
          );
        }
        // Then.
        expect(await StoredGpsRecord.db.count(owner.build()), 0);
      },
    );

    test('accepts an empty route with unchanged receipt protocol', () async {
      // Given.
      final empty = record();
      // When.
      final receipt = await endpoints.records.saveConfirmed(owner, empty);
      // Then.
      expect(
        (await endpoints.records.getMine(
          owner,
          receipt.recordId,
        )).payload.routePoints,
        isEmpty,
      );
    });
  });

  // Real independent transactions are essential for the unique-key race.
  withServerpod('Concurrent record commits', (builder, endpoints) {
    final owner = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    setUp(() async {
      final session = owner.build();
      await AuthUser.db.insertRow(
        session,
        AuthUser(
          id: UuidValue.fromString(session.authenticated!.userIdentifier),
          scopeNames: {},
        ),
      );
    });
    test('concurrent retries commit exactly one full record', () async {
      final input = record();
      final receipts = await Future.wait([
        endpoints.records.saveConfirmed(owner, input),
        endpoints.records.saveConfirmed(owner, input),
      ]);
      expect(receipts.first.toJson(), receipts.last.toJson());
      final session = owner.build();
      expect(await StoredGpsRecord.db.count(session), 1);
      final saved = await endpoints.records.getMine(
        owner,
        receipts.first.recordId,
      );
      expect(saved.payload.toJson(), input.toJson());
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
