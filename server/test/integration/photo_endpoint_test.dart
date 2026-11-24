import 'package:balmatchum_server/src/generated/protocol.dart';
import 'package:balmatchum_server/src/photos/photo_endpoint.dart';
import 'package:balmatchum_server/src/photos/photo_store.dart';
import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../test_utils/memory_photo_store.dart';
import 'test_tools/serverpod_test_tools.dart';

Matcher photoError(String code) =>
    throwsA(isA<PhotoException>().having((e) => e.code, 'code', code));

void main() {
  withServerpod('Photo upload', (builder, endpoints) {
    late MemoryPhotoStore store;
    final a = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    final b = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        const Uuid().v4(),
        {},
      ),
    );
    UuidValue idOf(TestSessionBuilder owner) =>
        UuidValue.fromString(owner.build().authenticated!.userIdentifier);

    setUp(() async {
      store = MemoryPhotoStore();
      PhotoStore.current = store;
      for (final owner in [a, b]) {
        await AuthUser.db.insertRow(
          owner.build(),
          AuthUser(id: idOf(owner), scopeNames: {}),
        );
      }
    });
    tearDown(() => PhotoStore.current = null);

    Future<PhotoView> upload(
      TestSessionBuilder owner, {
      int size = 2048,
    }) async {
      final ticket = await endpoints.photo.createUpload(
        owner,
        'image/jpeg',
        size,
      );
      store.put(store.presigned.last, byteSize: size);
      return endpoints.photo.confirmUpload(owner, ticket.photoId, 1600, 1200);
    }

    test('every method rejects anonymous requests', () async {
      final id = const Uuid().v7obj();
      for (final call in [
        endpoints.photo.createUpload(builder, 'image/jpeg', 1),
        endpoints.photo.confirmUpload(builder, id, null, null),
        endpoints.photo.listMine(builder),
        endpoints.photo.deletePhoto(builder, id),
      ]) {
        await expectLater(
          call,
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      }
    });

    test('a ticket reserves photos/<user>/<photo>.jpg for 5 minutes', () async {
      final ticket = await endpoints.photo.createUpload(a, 'image/jpeg', 1000);
      final key = photoObjectKey(idOf(a), ticket.photoId);
      expect(store.presigned, [key]);
      expect(ticket.uploadUrl, contains('$key?op=put&expires=300'));
      expect(ticket.method, 'PUT');
      expect(ticket.headers, {
        'Content-Type': 'image/jpeg',
        'Content-Length': '1000',
      });
      expect(
        ticket.expiresAt.difference(DateTime.now().toUtc()).inSeconds,
        inInclusiveRange(290, 300),
      );
      final row = (await StoredPhoto.db.findById(a.build(), ticket.photoId))!;
      expect(row.status, 'pending');
      expect(row.objectKey, key);
      expect(row.authUserId, idOf(a));
    });

    test(
      'type and size limits are enforced before anything is stored',
      () async {
        for (final (type, size, code) in [
          ('image/png', 10, 'unsupportedType'),
          ('image/jpeg; charset=x', 10, 'unsupportedType'),
          ('', 10, 'unsupportedType'),
          ('image/jpeg', 0, 'invalidSize'),
          ('image/jpeg', -1, 'invalidSize'),
          ('image/jpeg', photoMaxBytes + 1, 'invalidSize'),
        ]) {
          await expectLater(
            endpoints.photo.createUpload(a, type, size),
            photoError(code),
            reason: '$type $size',
          );
        }
        expect(await StoredPhoto.db.count(a.build()), 0);
        expect(store.presigned, isEmpty);
        // The cap itself is allowed.
        await endpoints.photo.createUpload(a, 'image/jpeg', photoMaxBytes);
      },
    );

    test('confirm waits for the object, then lists it with a GET', () async {
      final ticket = await endpoints.photo.createUpload(a, 'image/jpeg', 2048);
      await expectLater(
        endpoints.photo.confirmUpload(a, ticket.photoId, 10, 10),
        photoError('notUploaded'),
      );
      expect(await endpoints.photo.listMine(a), isEmpty);
      store.put(store.presigned.single, byteSize: 2048);
      final view = await endpoints.photo.confirmUpload(
        a,
        ticket.photoId,
        1600,
        1200,
      );
      expect(view.photoId, ticket.photoId);
      expect((view.width, view.height, view.byteSize), (1600, 1200, 2048));
      expect(view.url, endsWith('?op=get&expires=600'));
      // Confirming again returns the same photo.
      final again = await endpoints.photo.confirmUpload(
        a,
        ticket.photoId,
        null,
        null,
      );
      expect(again.width, 1600);
      final listed = await endpoints.photo.listMine(a);
      expect(listed.map((p) => p.photoId), [ticket.photoId]);
    });

    test('an object of another size or type is deleted, not kept', () async {
      final ticket = await endpoints.photo.createUpload(a, 'image/jpeg', 2048);
      final key = store.presigned.single;
      store.put(key, byteSize: 9999);
      await expectLater(
        endpoints.photo.confirmUpload(a, ticket.photoId, null, null),
        photoError('invalidUpload'),
      );
      expect(store.objects, isEmpty);
      expect(await StoredPhoto.db.count(a.build()), 0);
    });

    test('dimensions out of range are rejected', () async {
      final ticket = await endpoints.photo.createUpload(a, 'image/jpeg', 10);
      for (final (w, h) in [(0, 10), (10, -1), (photoMaxDimension + 1, 10)]) {
        await expectLater(
          endpoints.photo.confirmUpload(a, ticket.photoId, w, h),
          photoError('invalidDimensions'),
        );
      }
    });

    test('other accounts can neither see, confirm nor delete it', () async {
      final photo = await upload(a);
      expect(await endpoints.photo.listMine(b), isEmpty);
      await expectLater(
        endpoints.photo.confirmUpload(b, photo.photoId, null, null),
        photoError('notFound'),
      );
      await expectLater(
        endpoints.photo.deletePhoto(b, photo.photoId),
        photoError('notFound'),
      );
      expect(store.objects, hasLength(1));
      expect(await endpoints.photo.listMine(a), hasLength(1));
    });

    test('delete removes the object and then the row', () async {
      final keep = await upload(a);
      final gone = await upload(a);
      await endpoints.photo.deletePhoto(a, gone.photoId);
      expect(store.objects.keys, [
        photoObjectKey(idOf(a), keep.photoId),
      ]);
      expect(
        (await endpoints.photo.listMine(a)).map((p) => p.photoId),
        [keep.photoId],
      );
      // A storage failure keeps the row so the delete can be retried.
      store.failing = true;
      await expectLater(
        endpoints.photo.deletePhoto(a, keep.photoId),
        photoError('storageUnavailable'),
      );
      store.failing = false;
      expect(await StoredPhoto.db.count(a.build()), 1);
      await endpoints.photo.deletePhoto(a, keep.photoId);
      expect(store.objects, isEmpty);
    });

    test('lists newest first', () async {
      final first = await upload(a);
      final second = await upload(a);
      expect(
        (await endpoints.photo.listMine(a)).map((p) => p.photoId),
        [second.photoId, first.photoId],
      );
    });

    test('at most five live unconfirmed uploads per account', () async {
      for (var i = 0; i < photoMaxPending; i++) {
        await endpoints.photo.createUpload(a, 'image/jpeg', 10);
      }
      await expectLater(
        endpoints.photo.createUpload(a, 'image/jpeg', 10),
        photoError('tooManyPending'),
      );
      // Another account is unaffected.
      await endpoints.photo.createUpload(b, 'image/jpeg', 10);
    });

    test('without storage passwords every call says notConfigured', () async {
      PhotoStore.current = null;
      await expectLater(
        endpoints.photo.createUpload(a, 'image/jpeg', 10),
        photoError('notConfigured'),
      );
      await expectLater(
        endpoints.photo.listMine(a),
        photoError('notConfigured'),
      );
    });

    Future<PhotoView> composite(
      TestSessionBuilder owner, {
      UuidValue? originalId,
      int size = 4096,
    }) async {
      final ticket = await endpoints.photo.createUpload(
        owner,
        'image/jpeg',
        size,
        kind: 'composite',
        originalId: originalId,
      );
      store.put(store.presigned.last, byteSize: size);
      return endpoints.photo.confirmUpload(owner, ticket.photoId, 1600, 1200);
    }

    test('photos are originals unless they say composite', () async {
      final original = await upload(a);
      expect(original.kind, 'original');
      expect(original.originalId, isNull);
      for (final kind in ['', 'thumbnail', 'Composite']) {
        await expectLater(
          endpoints.photo.createUpload(a, 'image/jpeg', 10, kind: kind),
          photoError('invalidKind'),
          reason: kind,
        );
      }
      // An original never links to another photo.
      await expectLater(
        endpoints.photo.createUpload(
          a,
          'image/jpeg',
          10,
          kind: 'original',
          originalId: original.photoId,
        ),
        photoError('invalidOriginal'),
      );
    });

    test('a composite links to its own original and lists with it', () async {
      final original = await upload(a);
      final saved = await composite(a, originalId: original.photoId);
      expect(saved.kind, 'composite');
      expect(saved.originalId, original.photoId);
      final row = (await StoredPhoto.db.findById(a.build(), saved.photoId))!;
      expect(row.objectKey, photoObjectKey(idOf(a), saved.photoId));
      final listed = await endpoints.photo.listMine(a);
      expect(
        listed.map((p) => (p.kind, p.originalId)),
        [('composite', original.photoId), ('original', null)],
      );
      // Without an uploaded original it stands alone.
      final alone = await composite(a);
      expect(alone.originalId, isNull);
    });

    test(
      'a composite cannot link to another account or another composite',
      () async {
        final theirs = await upload(b);
        await expectLater(
          endpoints.photo.createUpload(
            a,
            'image/jpeg',
            10,
            kind: 'composite',
            originalId: theirs.photoId,
          ),
          photoError('notFound'),
        );
        final mine = await upload(a);
        final saved = await composite(a, originalId: mine.photoId);
        await expectLater(
          endpoints.photo.createUpload(
            a,
            'image/jpeg',
            10,
            kind: 'composite',
            originalId: saved.photoId,
          ),
          photoError('invalidOriginal'),
        );
        // An original still waiting for its upload cannot be linked either.
        final pending = await endpoints.photo.createUpload(a, 'image/jpeg', 10);
        await expectLater(
          endpoints.photo.createUpload(
            a,
            'image/jpeg',
            10,
            kind: 'composite',
            originalId: pending.photoId,
          ),
          photoError('invalidOriginal'),
        );
        // Nothing was reserved for the rejected links.
        expect(
          await StoredPhoto.db.count(
            a.build(),
            where: (t) => t.authUserId.equals(idOf(a)),
          ),
          3,
        );
      },
    );

    test(
      'composites share the size limit and the stored-photo quota',
      () async {
        await expectLater(
          endpoints.photo.createUpload(
            a,
            'image/jpeg',
            photoMaxBytes + 1,
            kind: 'composite',
          ),
          photoError('invalidSize'),
        );
        final original = await upload(a);
        await composite(a, originalId: original.photoId);
        // Fill the quota up to the cap with direct rows, both kinds counted.
        final now = DateTime.now().toUtc();
        await StoredPhoto.db.insert(a.build(), [
          for (var i = 0; i < photoMaxStored - 2; i++)
            StoredPhoto(
              authUserId: idOf(a),
              objectKey: 'photos/${idOf(a).uuid}/fill-$i.jpg',
              contentType: 'image/jpeg',
              byteSize: 1,
              kind: 'original',
              status: 'ready',
              createdAt: now,
            ),
        ]);
        await expectLater(
          endpoints.photo.createUpload(a, 'image/jpeg', 10, kind: 'composite'),
          photoError('quotaExceeded'),
        );
      },
    );

    test('deleting an original keeps its composite, unlinked', () async {
      final original = await upload(a);
      final saved = await composite(a, originalId: original.photoId);
      await endpoints.photo.deletePhoto(a, original.photoId);
      final listed = await endpoints.photo.listMine(a);
      expect(listed.map((p) => p.photoId), [saved.photoId]);
      expect(listed.single.originalId, isNull);
      expect(store.objects.keys, [photoObjectKey(idOf(a), saved.photoId)]);
    });

    test(
      'the sweep removes stale unconfirmed uploads with their objects',
      () async {
        final stale = await endpoints.photo.createUpload(a, 'image/jpeg', 10);
        store.put(store.presigned.last, byteSize: 10);
        final ready = await upload(a);
        final fresh = await endpoints.photo.createUpload(a, 'image/jpeg', 10);
        final later = clock.now().add(
          photoPendingRetention + const Duration(minutes: 1),
        );
        // Only rows created before the cutoff are stale: move one back.
        final row = (await StoredPhoto.db.findById(a.build(), stale.photoId))!;
        await StoredPhoto.db.updateRow(
          a.build(),
          row.copyWith(createdAt: later.subtract(const Duration(hours: 2))),
        );
        final freshRow = (await StoredPhoto.db.findById(
          a.build(),
          fresh.photoId,
        ))!;
        await StoredPhoto.db.updateRow(
          a.build(),
          freshRow.copyWith(
            createdAt: later.subtract(const Duration(minutes: 5)),
          ),
        );
        final removed = await sweepPendingPhotos(
          a.build(),
          clock: Clock.fixed(later),
        );
        expect(removed, 1);
        expect(await StoredPhoto.db.findById(a.build(), stale.photoId), isNull);
        expect(store.objects.keys, [photoObjectKey(idOf(a), ready.photoId)]);
        expect(
          await StoredPhoto.db.findById(a.build(), fresh.photoId),
          isNotNull,
        );
      },
    );
  });
}
