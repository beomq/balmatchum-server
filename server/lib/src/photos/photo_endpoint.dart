import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../maintenance/schema_guard.dart';
import '../product/product_service.dart' show authUserIdOf;
import 'photo_store.dart';

/// Only the app's compressed JPEG is accepted.
const photoContentType = 'image/jpeg';

/// The app sends at most 1600 px at JPEG ~80, far below this cap.
const photoMaxBytes = 5 * 1024 * 1024;

/// Upload tickets are short-lived (5 min); a pending row older than
/// [photoPendingRetention] is swept with its object.
const photoUploadExpiry = Duration(minutes: 5);
const photoDownloadExpiry = Duration(minutes: 10);
const photoPendingRetention = Duration(hours: 1);

/// Unconfirmed uploads one account may hold at once.
const photoMaxPending = 5;

/// Confirmed photos one account may keep.
const photoMaxStored = 500;

/// What a photo is: the picked photo, or the saved picture made from it.
const photoKinds = {'original', 'composite'};

/// Upper bound for the app-reported pixel size.
const photoMaxDimension = 10000;

/// `photos/<authUserId>/<photoId>.jpg`: one prefix per account, so account
/// deletion removes every object, confirmed or not, with one listing.
String photoObjectKey(UuidValue authUserId, UuidValue photoId) =>
    'photos/${authUserId.uuid}/${photoId.uuid}.jpg';

String photoUserPrefix(UuidValue authUserId) => 'photos/${authUserId.uuid}/';

class PhotoEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Reserves a photo and returns where to PUT its bytes. S3 itself rejects a
  /// body of another length or content type because both headers are signed.
  ///
  /// [kind] is `original` (default) or `composite`; a composite may name the
  /// caller's own [originalId] it was made from. Both count toward the same
  /// limits.
  Future<PhotoUploadTicket> createUpload(
    Session session,
    String contentType,
    int byteSize, {
    String? kind,
    UuidValue? originalId,
  }) async {
    final (owner, store) = _context(session);
    final photoKind = kind ?? 'original';
    if (!photoKinds.contains(photoKind)) {
      throw PhotoException(code: 'invalidKind');
    }
    if (contentType != photoContentType) {
      throw PhotoException(code: 'unsupportedType');
    }
    if (byteSize <= 0 || byteSize > photoMaxBytes) {
      throw PhotoException(code: 'invalidSize');
    }
    if (originalId != null) {
      if (photoKind != 'composite') {
        throw PhotoException(code: 'invalidOriginal');
      }
      // Another account's photo is reported as missing, never as present.
      final original = await _owned(session, owner, originalId);
      if (original.kind != 'original' || original.status != 'ready') {
        throw PhotoException(code: 'invalidOriginal');
      }
    }
    final now = clock.now().toUtc();
    final photoId = const Uuid().v7obj();
    final key = photoObjectKey(owner, photoId);
    await session.db.transaction((tx) async {
      // Serializes this account's quota checks against concurrent tickets.
      await session.db.unsafeExecute(
        'SELECT pg_advisory_xact_lock(hashtext(@k))',
        parameters: QueryParameters.named({'k': 'photo:${owner.uuid}'}),
        transaction: tx,
      );
      final pending = await StoredPhoto.db.count(
        session,
        where: (t) =>
            t.authUserId.equals(owner) &
            t.status.equals('pending') &
            (t.createdAt > now.subtract(photoUploadExpiry)),
        transaction: tx,
      );
      if (pending >= photoMaxPending) {
        throw PhotoException(code: 'tooManyPending');
      }
      final stored = await StoredPhoto.db.count(
        session,
        where: (t) => t.authUserId.equals(owner) & t.status.equals('ready'),
        transaction: tx,
      );
      if (stored >= photoMaxStored) {
        throw PhotoException(code: 'quotaExceeded');
      }
      await StoredPhoto.db.insertRow(
        session,
        StoredPhoto(
          id: photoId,
          authUserId: owner,
          objectKey: key,
          contentType: contentType,
          byteSize: byteSize,
          kind: photoKind,
          originalId: originalId,
          status: 'pending',
          createdAt: now,
        ),
        transaction: tx,
      );
    });
    final upload = store.presignUpload(
      key,
      contentType: contentType,
      byteSize: byteSize,
      expires: photoUploadExpiry,
    );
    return PhotoUploadTicket(
      photoId: photoId,
      uploadUrl: upload.url,
      method: 'PUT',
      headers: upload.headers,
      expiresAt: now.add(photoUploadExpiry),
    );
  }

  /// Marks the photo ready once S3 holds exactly the reserved object.
  /// Repeating it for a ready photo returns the same photo.
  Future<PhotoView> confirmUpload(
    Session session,
    UuidValue photoId,
    int? width,
    int? height,
  ) async {
    final (owner, store) = _context(session);
    for (final value in [width, height]) {
      if (value != null && (value <= 0 || value > photoMaxDimension)) {
        throw PhotoException(code: 'invalidDimensions');
      }
    }
    final photo = await _owned(session, owner, photoId);
    if (photo.status == 'ready') return _view(store, photo);
    final object = await _storage(
      session,
      () => store.head(photo.objectKey),
    );
    if (object == null) throw PhotoException(code: 'notUploaded');
    if (object.byteSize != photo.byteSize ||
        object.contentType != photo.contentType) {
      // Unreachable through the signed URL; never keep what was not reserved.
      await _storage(session, () => store.delete(photo.objectKey));
      await StoredPhoto.db.deleteRow(session, photo);
      throw PhotoException(code: 'invalidUpload');
    }
    final ready = await StoredPhoto.db.updateRow(
      session,
      photo.copyWith(
        status: 'ready',
        width: width,
        height: height,
        confirmedAt: clock.now().toUtc(),
      ),
    );
    return _view(store, ready);
  }

  /// Confirmed photos, newest first, each with a fresh short-lived GET URL.
  Future<List<PhotoView>> listMine(Session session) async {
    final (owner, store) = _context(session);
    final photos = await StoredPhoto.db.find(
      session,
      where: (t) => t.authUserId.equals(owner) & t.status.equals('ready'),
      // v7 ids are time-ordered, so this is newest first with no tie.
      orderBy: (t) => t.id.desc(),
      limit: photoMaxStored,
    );
    return [for (final photo in photos) _view(store, photo)];
  }

  /// Removes the object first: a row is never deleted while its object may
  /// remain, so a failed call can simply be retried. Composites made from a
  /// deleted original stay, unlinked.
  Future<void> deletePhoto(Session session, UuidValue photoId) async {
    final (owner, store) = _context(session);
    final photo = await _owned(session, owner, photoId);
    await _storage(session, () => store.delete(photo.objectKey));
    await session.db.transaction((tx) async {
      final linked = await StoredPhoto.db.find(
        session,
        where: (t) =>
            t.authUserId.equals(owner) & t.originalId.equals(photo.id),
        transaction: tx,
      );
      await StoredPhoto.db.update(
        session,
        [for (final c in linked) c.copyWith(originalId: null)],
        transaction: tx,
      );
      await StoredPhoto.db.deleteRow(session, photo, transaction: tx);
    });
  }

  (UuidValue, PhotoObjectStore) _context(Session session) {
    SchemaGuard.require();
    final owner = authUserIdOf(session.authenticated!.userIdentifier);
    final store = PhotoStore.current;
    if (store == null) throw PhotoException(code: 'notConfigured');
    return (owner, store);
  }

  Future<StoredPhoto> _owned(
    Session session,
    UuidValue owner,
    UuidValue photoId,
  ) async {
    final photo = await StoredPhoto.db.findFirstRow(
      session,
      where: (t) => t.id.equals(photoId) & t.authUserId.equals(owner),
    );
    if (photo == null) throw PhotoException(code: 'notFound');
    return photo;
  }

  PhotoView _view(PhotoObjectStore store, StoredPhoto photo) => PhotoView(
    photoId: photo.id!,
    kind: photo.kind,
    originalId: photo.originalId,
    contentType: photo.contentType,
    byteSize: photo.byteSize,
    width: photo.width,
    height: photo.height,
    createdAt: photo.createdAt,
    url: store.presignDownload(photo.objectKey, expires: photoDownloadExpiry),
    urlExpiresAt: clock.now().toUtc().add(photoDownloadExpiry),
  );
}

/// Storage failures reach the app as one retryable code, never as S3 detail.
/// The log names the failure kind only: HTTP client errors carry the signed
/// URL, which must not reach logs.
Future<T> _storage<T>(Session session, Future<T> Function() call) async {
  try {
    return await call();
  } on Exception catch (error) {
    session.log(
      'Photo storage call failed: '
      '${error is PhotoStoreException ? error : error.runtimeType}',
      level: LogLevel.warning,
    );
    throw PhotoException(code: 'storageUnavailable');
  }
}

/// Deletes every object under the account's prefix and its photo rows,
/// inside the account deletion transaction: if S3 fails the deletion rolls
/// back and can be retried, so no object outlives its account.
Future<void> deleteAccountPhotos(
  Session session,
  UuidValue authUserId,
  Transaction tx,
) async {
  final store = PhotoStore.current;
  if (store == null) {
    final rows = await StoredPhoto.db.count(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
    );
    if (rows > 0) {
      throw StateError('Photo storage is not configured; photos remain');
    }
  } else {
    for (final key in await store.list(photoUserPrefix(authUserId))) {
      await store.delete(key);
    }
  }
  await StoredPhoto.db.deleteWhere(
    session,
    where: (t) => t.authUserId.equals(authUserId),
    transaction: tx,
  );
}

/// Removes uploads never confirmed within [photoPendingRetention], objects
/// first. Without storage nothing can be deleted, so the rows stay.
Future<int> sweepPendingPhotos(
  Session session, {
  Clock clock = const Clock(),
  int batchSize = 100,
}) async {
  final store = PhotoStore.current;
  if (store == null) return 0;
  final cutoff = clock.now().toUtc().subtract(photoPendingRetention);
  final stale = await StoredPhoto.db.find(
    session,
    where: (t) => t.status.equals('pending') & (t.createdAt < cutoff),
    orderBy: (t) => t.createdAt,
    limit: batchSize,
  );
  for (final photo in stale) {
    await store.delete(photo.objectKey);
    await StoredPhoto.db.deleteRow(session, photo);
  }
  return stale.length;
}
