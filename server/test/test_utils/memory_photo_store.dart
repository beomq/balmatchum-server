import 'package:balmatchum_server/src/photos/photo_store.dart';

/// An in-memory bucket. Presigned URLs are opaque strings naming the key, so
/// tests can "upload" with [put] and see which keys were handed out.
class MemoryPhotoStore implements PhotoObjectStore {
  final objects = <String, StoredObject>{};
  final presigned = <String>[];

  /// When set, every server-side call fails like an S3 outage.
  bool failing = false;

  void put(String key, {required int byteSize, String type = 'image/jpeg'}) =>
      objects[key] = (byteSize: byteSize, contentType: type);

  @override
  ({String url, Map<String, String> headers}) presignUpload(
    String key, {
    required String contentType,
    required int byteSize,
    required Duration expires,
  }) {
    presigned.add(key);
    return (
      url: 'https://bucket.test/$key?op=put&expires=${expires.inSeconds}',
      headers: {'Content-Type': contentType, 'Content-Length': '$byteSize'},
    );
  }

  @override
  String presignDownload(String key, {required Duration expires}) =>
      'https://bucket.test/$key?op=get&expires=${expires.inSeconds}';

  void _check(String operation) {
    if (failing) throw PhotoStoreException(operation, 503);
  }

  @override
  Future<StoredObject?> head(String key) async {
    _check('HEAD');
    return objects[key];
  }

  @override
  Future<void> delete(String key) async {
    _check('DELETE');
    objects.remove(key);
  }

  @override
  Future<List<String>> list(String prefix) async {
    _check('LIST');
    return [
      for (final key in objects.keys)
        if (key.startsWith(prefix)) key,
    ];
  }
}
