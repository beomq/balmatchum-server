import 'package:balmatchum_server/src/photos/photo_endpoint.dart';
import 'package:balmatchum_server/src/photos/photo_store.dart';
import 'package:balmatchum_server/src/photos/s3_presigner.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('SigV4 query signing', () {
    // The worked example in AWS "Authenticating Requests: Using Query
    // Parameters (AWS Signature Version 4)".
    test('matches the AWS documented GET example signature', () {
      final signer = S3Presigner(
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
        region: 'us-east-1',
        bucket: 'examplebucket',
        host: 'examplebucket.s3.amazonaws.com',
      );
      final url = signer.presign(
        'GET',
        'test.txt',
        now: DateTime.utc(2013, 5, 24),
        expires: const Duration(days: 1),
      );
      expect(
        url,
        'https://examplebucket.s3.amazonaws.com/test.txt'
        '?X-Amz-Algorithm=AWS4-HMAC-SHA256'
        '&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3'
        '%2Faws4_request'
        '&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400'
        '&X-Amz-SignedHeaders=host'
        '&X-Amz-Signature='
        'aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404',
      );
    });

    test('an upload URL signs its exact length and type for 5 minutes', () {
      final signer = S3Presigner(
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'secret',
        region: 'ap-southeast-2',
        bucket: 'balmatchum-photos-dev',
      );
      String put(int length, String type) => signer.presign(
        'PUT',
        'photos/u/p.jpg',
        now: DateTime.utc(2026, 11, 12, 8, 30),
        expires: photoUploadExpiry,
        headers: {'Content-Type': type, 'Content-Length': '$length'},
      );
      final url = Uri.parse(put(1000, 'image/jpeg'));
      expect(url.host, 'balmatchum-photos-dev.s3.ap-southeast-2.amazonaws.com');
      expect(url.path, '/photos/u/p.jpg');
      expect(url.queryParameters['X-Amz-Expires'], '300');
      expect(
        url.queryParameters['X-Amz-SignedHeaders'],
        'content-length;content-type;host',
      );
      // A different length or type is a different signature.
      final signature = url.queryParameters['X-Amz-Signature'];
      expect(
        Uri.parse(put(1001, 'image/jpeg')).queryParameters['X-Amz-Signature'],
        isNot(signature),
      );
      expect(
        Uri.parse(put(1000, 'image/png')).queryParameters['X-Amz-Signature'],
        isNot(signature),
      );
    });

    test('encodes keys per RFC 3986 and keeps slashes', () {
      expect(S3Presigner.canonicalPath('a b/c+d~.jpg'), '/a%20b/c%2Bd~.jpg');
      expect(S3Presigner.uriEncode('한'), '%ED%95%9C');
      expect(
        S3Presigner.canonicalQueryString({'prefix': 'photos/x/', 'a': '1'}),
        'a=1&prefix=photos%2Fx%2F',
      );
    });

    test('rejects expiries S3 would refuse', () {
      final signer = S3Presigner(
        accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
        secretAccessKey: 'secret',
        region: 'ap-southeast-2',
        bucket: 'b-1',
      );
      for (final expires in [Duration.zero, const Duration(days: 8)]) {
        expect(
          () => signer.presign(
            'GET',
            'k',
            now: DateTime.utc(2026),
            expires: expires,
          ),
          throwsArgumentError,
        );
      }
    });
  });

  test('object keys are photos/<authUserId>/<photoId>.jpg', () {
    final user = UuidValue.fromString('0190a1b2-c3d4-7e5f-8a9b-0c1d2e3f4a5b');
    final photo = UuidValue.fromString('019a2b3c-4d5e-7f60-8172-839405a6b7c8');
    expect(
      photoObjectKey(user, photo),
      'photos/0190a1b2-c3d4-7e5f-8a9b-0c1d2e3f4a5b/'
      '019a2b3c-4d5e-7f60-8172-839405a6b7c8.jpg',
    );
    expect(photoObjectKey(user, photo), startsWith(photoUserPrefix(user)));
  });

  group('photo storage passwords', () {
    const valid = {
      'awsAccessKeyId': 'AKIAIOSFODNN7EXAMPLE',
      'awsSecretAccessKey': 'public-test-secret',
      'awsRegion': 'ap-southeast-2',
      'photosBucket': 'balmatchum-photos-dev',
    };

    test('all absent disables photos', () {
      expect(PhotoStorageConfig.fromPasswords((_) => null), isNull);
      expect(PhotoStorageConfig.fromPasswords((_) => ' '), isNull);
    });

    test('a complete group configures the bucket', () {
      final config = PhotoStorageConfig.fromPasswords((k) => valid[k])!;
      expect(config.bucket, 'balmatchum-photos-dev');
      expect(config.region, 'ap-southeast-2');
    });

    for (final key in valid.keys) {
      test('a group missing $key fails startup', () {
        expect(
          () => PhotoStorageConfig.fromPasswords(
            (k) => k == key ? null : valid[k],
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains(key),
            ),
          ),
        );
      });
    }

    for (final (key, value) in [
      ('awsAccessKeyId', 'lowercase-key'),
      ('awsRegion', 'Sydney'),
      ('photosBucket', 'dotted.bucket'),
      ('photosBucket', 'Upper'),
    ]) {
      test('rejects $key=$value', () {
        expect(
          () => PhotoStorageConfig.fromPasswords(
            (k) => k == key ? value : valid[k],
          ),
          throwsStateError,
        );
      });
    }
  });
}
