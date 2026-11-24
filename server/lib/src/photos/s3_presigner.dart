import 'dart:convert';

import 'package:crypto/crypto.dart';

/// AWS Signature Version 4 query-string signing for S3
/// (https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html).
///
/// Every S3 call the server makes, and every URL it hands to the app, is a
/// presigned URL: the secret key never leaves the server and no SDK is
/// needed. Headers passed to [presign] are signed, so S3 rejects a request
/// whose value differs (for an upload: its exact length and content type).
class S3Presigner {
  S3Presigner({
    required this.accessKeyId,
    required String secretAccessKey,
    required this.region,
    required this.bucket,
    String? host,
  }) : _secret = secretAccessKey,
       host = host ?? '$bucket.s3.$region.amazonaws.com';

  final String accessKeyId;
  final String _secret;
  final String region;
  final String bucket;

  /// Virtual-hosted-style bucket host.
  final String host;

  /// AWS caps a SigV4 presigned URL at seven days.
  static const maxExpiry = Duration(days: 7);

  /// The signed `https` URL for [method] on object [key] (`''` for the
  /// bucket itself, as ListObjectsV2 uses).
  String presign(
    String method,
    String key, {
    required DateTime now,
    required Duration expires,
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
  }) {
    if (expires <= Duration.zero || expires > maxExpiry) {
      throw ArgumentError.value(expires, 'expires', 'must be 1s..7d');
    }
    final time = now.toUtc();
    final date = _date(time);
    final amzDate =
        '${date}T${_two(time.hour)}${_two(time.minute)}'
        '${_two(time.second)}Z';
    final scope = '$date/$region/s3/aws4_request';
    final signedHeaders = <String, String>{
      for (final MapEntry(:key, :value) in headers.entries)
        key.toLowerCase(): value.trim(),
      'host': host,
    };
    final headerNames = signedHeaders.keys.toList()..sort();
    final params = <String, String>{
      ...query,
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Credential': '$accessKeyId/$scope',
      'X-Amz-Date': amzDate,
      'X-Amz-Expires': '${expires.inSeconds}',
      'X-Amz-SignedHeaders': headerNames.join(';'),
    };
    final canonicalQuery = canonicalQueryString(params);
    final path = canonicalPath(key);
    final canonicalRequest = [
      method,
      path,
      canonicalQuery,
      for (final name in headerNames) '$name:${signedHeaders[name]}',
      '',
      headerNames.join(';'),
      'UNSIGNED-PAYLOAD',
    ].join('\n');
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      scope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');
    List<int> signingKey = utf8.encode('AWS4$_secret');
    for (final part in [date, region, 's3', 'aws4_request']) {
      signingKey = Hmac(sha256, signingKey).convert(utf8.encode(part)).bytes;
    }
    final signature = Hmac(
      sha256,
      signingKey,
    ).convert(utf8.encode(stringToSign)).toString();
    return 'https://$host$path?$canonicalQuery&X-Amz-Signature=$signature';
  }

  /// `/` followed by each key segment URI-encoded; slashes stay literal.
  static String canonicalPath(String key) =>
      '/${key.split('/').map(uriEncode).join('/')}';

  static String canonicalQueryString(Map<String, String> params) {
    final encoded =
        [
          for (final MapEntry(:key, :value) in params.entries)
            (uriEncode(key), uriEncode(value)),
        ]..sort((a, b) {
          final byKey = a.$1.compareTo(b.$1);
          return byKey != 0 ? byKey : a.$2.compareTo(b.$2);
        });
    return encoded.map((p) => '${p.$1}=${p.$2}').join('&');
  }

  /// RFC 3986 encoding as SigV4 requires: unreserved characters stay, every
  /// other UTF-8 byte becomes `%XX` with upper-case hex.
  static String uriEncode(String value) {
    final out = StringBuffer();
    for (final byte in utf8.encode(value)) {
      final unreserved =
          (byte >= 0x41 && byte <= 0x5a) ||
          (byte >= 0x61 && byte <= 0x7a) ||
          (byte >= 0x30 && byte <= 0x39) ||
          byte == 0x2d ||
          byte == 0x2e ||
          byte == 0x5f ||
          byte == 0x7e;
      if (unreserved) {
        out.writeCharCode(byte);
      } else {
        out.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    return out.toString();
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _date(DateTime time) =>
      '${time.year.toString().padLeft(4, '0')}${_two(time.month)}'
      '${_two(time.day)}';
}
