/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:balmatchum_client/src/protocol/protocol.dart' as _i5u3fx7i;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A one-time S3 upload: PUT the JPEG bytes to [uploadUrl] with exactly
/// [headers] before [expiresAt], then call confirmUpload with [photoId].
abstract class PhotoUploadTicket
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PhotoUploadTicket._({
    required this.photoId,
    required this.uploadUrl,
    required this.method,
    required this.headers,
    required this.expiresAt,
  });

  factory PhotoUploadTicket({
    required _isc.UuidValue photoId,
    required String uploadUrl,
    required String method,
    required Map<String, String> headers,
    required DateTime expiresAt,
  }) = _PhotoUploadTicketImpl;

  factory PhotoUploadTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoUploadTicket(
      photoId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['photoId'],
      ),
      uploadUrl: jsonSerialization['uploadUrl'] as String,
      method: jsonSerialization['method'] as String,
      headers: _i5u3fx7i.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['headers'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  _isc.UuidValue photoId;

  String uploadUrl;

  String method;

  Map<String, String> headers;

  DateTime expiresAt;

  /// Returns a shallow copy of this [PhotoUploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PhotoUploadTicket copyWith({
    _isc.UuidValue? photoId,
    String? uploadUrl,
    String? method,
    Map<String, String>? headers,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PhotoUploadTicket',
      'photoId': photoId.toJson(),
      'uploadUrl': uploadUrl,
      'method': method,
      'headers': headers.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PhotoUploadTicket',
      'photoId': photoId.toJson(),
      'uploadUrl': uploadUrl,
      'method': method,
      'headers': headers.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PhotoUploadTicketImpl extends PhotoUploadTicket {
  _PhotoUploadTicketImpl({
    required _isc.UuidValue photoId,
    required String uploadUrl,
    required String method,
    required Map<String, String> headers,
    required DateTime expiresAt,
  }) : super._(
         photoId: photoId,
         uploadUrl: uploadUrl,
         method: method,
         headers: headers,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [PhotoUploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PhotoUploadTicket copyWith({
    _isc.UuidValue? photoId,
    String? uploadUrl,
    String? method,
    Map<String, String>? headers,
    DateTime? expiresAt,
  }) {
    return PhotoUploadTicket(
      photoId: photoId ?? this.photoId,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      method: method ?? this.method,
      headers:
          headers ??
          this.headers.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
