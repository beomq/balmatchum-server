import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/product/product_service.dart';
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

    group('KST day-number predicate', () {
      GpsRecordInput span(DateTime start, DateTime end) =>
          record().copyWith(startedAt: start, endedAt: end);

      Future<Map<UuidValue, GpsRecordInput>> saveAll(
        TestSessionBuilder user,
        Iterable<GpsRecordInput> inputs,
      ) async => {
        for (final input in inputs)
          (await endpoints.records.saveConfirmed(user, input)).recordId: input,
      };

      Future<void> expectRoutesMatchTouchesDay(
        Map<UuidValue, GpsRecordInput> live,
        List<String> dates,
      ) async {
        for (final date in dates) {
          final routes = (await endpoints.product.getDay(owner, date)).routes;
          expect(
            routes.map((route) => route.recordId).toSet(),
            {
              for (final entry in live.entries)
                if (touchesDay(entry.value, date)) entry.key,
            },
            reason: date,
          );
        }
      }

      test('localDayNumber equals the migration backfill expression', () async {
        final session = owner.build();
        for (final instant in [
          DateTime.utc(1969, 12, 31, 14, 59, 59, 999, 999),
          DateTime.utc(1969, 12, 31, 15),
          DateTime.utc(2026, 10, 9, 14, 59, 59, 999, 999),
          DateTime.utc(2026, 10, 9, 15),
          DateTime.utc(2026, 12, 31, 14, 59, 59, 999),
          DateTime.utc(2026, 12, 31, 15),
          DateTime.utc(2028, 2, 28, 15),
          DateTime.utc(2028, 2, 29, 14, 59, 59, 999, 999),
        ]) {
          final rows = await session.db.unsafeQuery(
            'SELECT floor((extract(epoch from CAST(@ts AS timestamptz)) '
            '+ 32400) / 86400)::int',
            parameters: QueryParameters.named({
              'ts': instant.toIso8601String(),
            }),
          );
          expect(
            localDayNumber(instant),
            rows.single.single,
            reason: '$instant',
          );
        }
        expect(localDayNumber(dayStart('1970-01-01')), 0);
        expect(localDayNumber(dayStart('1969-12-31')), -1);
        expect(
          localDayNumber(dayStart('2028-03-01')) -
              localDayNumber(dayStart('2028-02-28')),
          2,
        );
      });

      test(
        'getDay returns exactly the touchesDay set across KST midnights',
        () async {
          final live = await saveAll(owner, [
            // KST 23:59:59.999999 -> 00:00: belongs to both dates.
            span(
              DateTime.utc(2026, 10, 9, 14, 59, 59, 999, 999),
              DateTime.utc(2026, 10, 9, 15),
            ),
            // Ends at KST 23:59:59.999: only the earlier date.
            span(
              DateTime.utc(2026, 10, 9, 14),
              DateTime.utc(2026, 10, 9, 14, 59, 59, 999),
            ),
            // Instant exactly at KST midnight: only the new date.
            span(DateTime.utc(2026, 10, 9, 15), DateTime.utc(2026, 10, 9, 15)),
            // Midnight to next midnight: two dates.
            span(
              DateTime.utc(2026, 10, 10, 15),
              DateTime.utc(2026, 10, 11, 15),
            ),
            // Three-plus days: middle dates included.
            span(
              DateTime.utc(2026, 10, 12, 14),
              DateTime.utc(2026, 10, 14, 16),
            ),
            // Month end.
            span(
              DateTime.utc(2026, 10, 31, 14, 30),
              DateTime.utc(2026, 10, 31, 15, 30),
            ),
            // Year end.
            span(
              DateTime.utc(2026, 12, 31, 14, 59, 59, 999),
              DateTime.utc(2026, 12, 31, 15),
            ),
            // Leap day.
            span(DateTime.utc(2028, 2, 28, 15), DateTime.utc(2028, 2, 29, 15)),
          ]);
          // Another owner's overlapping record must never appear.
          await saveAll(other, [
            span(DateTime.utc(2026, 10, 9), DateTime.utc(2026, 10, 15)),
          ]);
          final dates = [
            for (var day = 8; day <= 16; day++)
              '2026-10-${day.toString().padLeft(2, '0')}',
            '2026-10-31',
            '2026-11-01',
            '2026-12-31',
            '2027-01-01',
            '2028-02-28',
            '2028-02-29',
            '2028-03-01',
          ];
          await expectRoutesMatchTouchesDay(live, dates);
          // Guard against a vacuous match on the midnight edges.
          final ids = live.keys.toList();
          Future<Set<UuidValue>> on(String date) async => {
            for (final route in (await endpoints.product.getDay(
              owner,
              date,
            )).routes)
              route.recordId,
          };
          expect(await on('2026-10-09'), {ids[0], ids[1]});
          expect(await on('2026-10-10'), {ids[0], ids[2]});
          expect(await on('2026-10-12'), {ids[3], ids[4]});
          expect(await on('2026-10-13'), {ids[4]});
          expect(await on('2027-01-01'), {ids[6]});
          expect(await on('2028-02-29'), {ids[7]});
          expect(await on('2028-03-01'), {ids[7]});

          final unmatched = await owner.build().db.unsafeQuery(
            'SELECT count(*) FROM gps_record WHERE '
            '"firstLocalDay" IS DISTINCT FROM floor((extract(epoch from '
            '(payload->>\'startedAt\')::timestamptz) + 32400) / 86400)::int '
            'OR "lastLocalDay" IS DISTINCT FROM floor((extract(epoch from '
            '(payload->>\'endedAt\')::timestamptz) + 32400) / 86400)::int',
          );
          expect(unmatched.single.single, 0);
        },
      );

      test(
        'deleteDay tombstones only that KST day and keeps blocking resends',
        () async {
          final crossing = span(
            DateTime.utc(2026, 10, 12, 14),
            DateTime.utc(2026, 10, 14, 16),
          );
          final live = await saveAll(owner, [
            crossing,
            span(
              DateTime.utc(2026, 10, 12, 14),
              DateTime.utc(2026, 10, 12, 14, 59, 59, 999, 999),
            ),
            span(
              DateTime.utc(2026, 10, 13, 15),
              DateTime.utc(2026, 10, 13, 16),
            ),
          ]);
          final otherIds = await saveAll(other, [
            span(DateTime.utc(2026, 10, 13, 1), DateTime.utc(2026, 10, 13, 2)),
          ]);
          final crossingId = live.keys.first;

          await endpoints.product.deleteDay(owner, '2026-10-13', 'delete-13');

          final session = owner.build();
          final tombstone = await StoredGpsRecord.db.findById(
            session,
            crossingId,
          );
          expect(tombstone!.deleted, isTrue);
          expect(tombstone.payload, isNull);
          expect(tombstone.firstLocalDay, isNull);
          expect(tombstone.lastLocalDay, isNull);
          for (final id in [...live.keys.skip(1), ...otherIds.keys]) {
            final kept = await StoredGpsRecord.db.findById(session, id);
            expect(kept!.deleted, isFalse);
            expect(kept.firstLocalDay, isNotNull);
          }
          live.remove(crossingId);
          await expectRoutesMatchTouchesDay(live, [
            '2026-10-12',
            '2026-10-13',
            '2026-10-14',
          ]);

          // Same clientRecordId stays deleted; a midnight end touches the day.
          for (final input in [
            crossing,
            span(
              DateTime.utc(2026, 10, 12, 14, 30),
              DateTime.utc(2026, 10, 12, 15),
            ),
          ]) {
            await expectLater(
              endpoints.records.saveConfirmed(owner, input),
              failsWith('dayDeleted'),
            );
          }
          // Neighbouring instants and other owners are not blocked.
          for (final input in [
            span(
              DateTime.utc(2026, 10, 12, 14, 30),
              DateTime.utc(2026, 10, 12, 14, 59, 59, 999, 999),
            ),
            span(
              DateTime.utc(2026, 10, 13, 15),
              DateTime.utc(2026, 10, 13, 15),
            ),
          ]) {
            await endpoints.records.saveConfirmed(owner, input);
          }
          await endpoints.records.saveConfirmed(
            other,
            span(DateTime.utc(2026, 10, 13, 3), DateTime.utc(2026, 10, 13, 4)),
          );
        },
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

  // The lock holder needs its own committed transaction beside the reader.
  withServerpod('Lock-free record reads', (builder, endpoints) {
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
    test('getMine completes while the account lock is held', () async {
      final receipt = await endpoints.records.saveConfirmed(owner, record());
      final locked = Completer<void>();
      final release = Completer<void>();
      final holder = owner.build().db.transaction((tx) async {
        await lockProductAccount(
          owner.build(),
          owner.build().authenticated!.userIdentifier,
          tx,
        );
        locked.complete();
        await release.future;
      });
      try {
        await locked.future;
        final saved = await endpoints.records
            .getMine(owner, receipt.recordId)
            .timeout(const Duration(seconds: 10));
        expect(saved.receipt.toJson(), receipt.toJson());
      } finally {
        release.complete();
        await holder;
      }
    });
  }, rollbackDatabase: RollbackDatabase.disabled);
}
