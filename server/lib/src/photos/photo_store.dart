import 'package:clock/clock.dart';
import 'package:http/http.dart' as http;

import '../config_password.dart';
import 's3_presigner.dart';
import 'package:serverpod/serverpod.dart';

/// What S3 reports for an uploaded object.
typedef StoredObject = ({int byteSize, String contentType});

/// The object storage behind photos. The S3 implementation is
/// [S3PhotoStore]; tests install an in-memory one through [PhotoStore.current].
abstract interface class PhotoObjectStore {
  /// A PUT URL that accepts exactly [byteSize] bytes of [contentType].
  ({String url, Map<String, String> headers}) presignUpload(
    String key, {
    required String contentType,
    required int byteSize,
    required Duration expires,
  });

  String presignDownload(String key, {required Duration expires});

  /// Null when the object does not exist.
  Future<StoredObject?> head(String key);

  /// Succeeds when the object is already gone.
  Future<void> delete(String key);

  /// Every key under [prefix].
  Future<List<String>> list(String prefix);
}

/// Thrown when S3 answers a server call with an unexpected status.
class PhotoStoreException implements Exception {
  PhotoStoreException(this.operation, this.status);
  final String operation;
  final int status;
  @override
  String toString() => 'S3 $operation failed with HTTP $status';
}

/// The configured store; null means photo storage is not configured.
abstract final class PhotoStore {
  static PhotoObjectStore? current;
}

/// The four Serverpod passwords photo storage reads. All absent disables
/// photos; a partial group is a startup error, like every other group.
class PhotoStorageConfig {
  PhotoStorageConfig._(
    this.accessKeyId,
    this.secretAccessKey,
    this.region,
    this.bucket,
  );

  final String accessKeyId;
  final String secretAccessKey;
  final String region;
  final String bucket;

  static const keys = [
    'awsAccessKeyId',
    'awsSecretAccessKey',
    'awsRegion',
    'photosBucket',
  ];

  static final _accessKey = RegExp(r'^[A-Z0-9]{16,128}$');
  static final _region = RegExp(r'^[a-z]{2}(-[a-z]+)+-[0-9]$');
  // Virtual-hosted TLS needs a bucket name without dots.
  static final _bucket = RegExp(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$');

  static PhotoStorageConfig? fromPasswords(
    String? Function(String) password,
  ) {
    final values = {
      for (final key in keys) key: password(key)?.trim() ?? '',
    };
    final missing = [
      for (final MapEntry(:key, :value) in values.entries)
        if (value.isEmpty) key,
    ];
    if (missing.length == keys.length) return null;
    if (missing.isNotEmpty) {
      throw StateError(
        'Invalid photo storage configuration: missing ${missing.join(', ')}',
      );
    }
    if (!_accessKey.hasMatch(values['awsAccessKeyId']!)) {
      throw StateError(
        'Invalid photo storage configuration: awsAccessKeyId format',
      );
    }
    if (!_region.hasMatch(values['awsRegion']!)) {
      throw StateError('Invalid photo storage configuration: awsRegion format');
    }
    if (!_bucket.hasMatch(values['photosBucket']!)) {
      throw StateError(
        'Invalid photo storage configuration: photosBucket format',
      );
    }
    return PhotoStorageConfig._(
      values['awsAccessKeyId']!,
      values['awsSecretAccessKey']!,
      values['awsRegion']!,
      values['photosBucket']!,
    );
  }
}

/// Installs the S3 store when the passwords are set. Called before
/// `pod.start()` so the first request already sees it.
void configurePhotoStorage(Serverpod pod) {
  final config = PhotoStorageConfig.fromPasswords(pod.configPassword);
  PhotoStore.current = config == null ? null : S3PhotoStore(config);
}

/// S3 over presigned URLs, so server calls and app URLs share one signer.
class S3PhotoStore implements PhotoObjectStore {
  S3PhotoStore(
    PhotoStorageConfig config, {
    http.Client? client,
    this.clock = const Clock(),
  }) : _client = client ?? http.Client(),
       signer = S3Presigner(
         accessKeyId: config.accessKeyId,
         secretAccessKey: config.secretAccessKey,
         region: config.region,
         bucket: config.bucket,
       );

  final S3Presigner signer;
  final http.Client _client;
  final Clock clock;

  /// Server-side calls are sent at once; a minute covers clock skew only.
  static const _callExpiry = Duration(minutes: 1);

  @override
  ({String url, Map<String, String> headers}) presignUpload(
    String key, {
    required String contentType,
    required int byteSize,
    required Duration expires,
  }) {
    final headers = {
      'Content-Type': contentType,
      'Content-Length': '$byteSize',
    };
    return (
      url: signer.presign(
        'PUT',
        key,
        now: clock.now(),
        expires: expires,
        headers: headers,
      ),
      headers: headers,
    );
  }

  @override
  String presignDownload(String key, {required Duration expires}) =>
      signer.presign('GET', key, now: clock.now(), expires: expires);

  String _call(String method, String key, [Map<String, String>? query]) =>
      signer.presign(
        method,
        key,
        now: clock.now(),
        expires: _callExpiry,
        query: query ?? const {},
      );

  @override
  Future<StoredObject?> head(String key) async {
    final response = await _client.head(Uri.parse(_call('HEAD', key)));
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw PhotoStoreException('HEAD', response.statusCode);
    }
    return (
      byteSize: int.parse(response.headers['content-length'] ?? '-1'),
      contentType: response.headers['content-type'] ?? '',
    );
  }

  @override
  Future<void> delete(String key) async {
    final response = await _client.delete(Uri.parse(_call('DELETE', key)));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw PhotoStoreException('DELETE', response.statusCode);
    }
  }

  static final _keyTag = RegExp(r'<Key>([^<]*)</Key>');
  static final _nextToken = RegExp(
    r'<NextContinuationToken>([^<]*)</NextContinuationToken>',
  );

  @override
  Future<List<String>> list(String prefix) async {
    final keys = <String>[];
    String? token;
    do {
      final response = await _client.get(
        Uri.parse(
          _call('GET', '', {
            'list-type': '2',
            'prefix': prefix,
            'continuation-token': ?token,
          }),
        ),
      );
      if (response.statusCode != 200) {
        throw PhotoStoreException('LIST', response.statusCode);
      }
      keys.addAll(
        _keyTag.allMatches(response.body).map((m) => _unescape(m[1]!)),
      );
      token = response.body.contains('<IsTruncated>true</IsTruncated>')
          ? _unescape(_nextToken.firstMatch(response.body)![1]!)
          : null;
    } while (token != null);
    return keys;
  }

  static String _unescape(String xml) => xml
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');
}
