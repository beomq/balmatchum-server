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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A confirmed photo. [url] is a short-lived signed GET; cache the bytes by
/// [photoId], not by URL, and list again after [urlExpiresAt].
abstract class PhotoView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PhotoView._({
    required this.photoId,
    required this.kind,
    this.originalId,
    required this.contentType,
    required this.byteSize,
    this.width,
    this.height,
    required this.createdAt,
    required this.url,
    required this.urlExpiresAt,
  });

  factory PhotoView({
    required _isc.UuidValue photoId,
    required String kind,
    _isc.UuidValue? originalId,
    required String contentType,
    required int byteSize,
    int? width,
    int? height,
    required DateTime createdAt,
    required String url,
    required DateTime urlExpiresAt,
  }) = _PhotoViewImpl;

  factory PhotoView.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhotoView(
      photoId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['photoId'],
      ),
      kind: jsonSerialization['kind'] as String,
      originalId: jsonSerialization['originalId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['originalId'],
            ),
      contentType: jsonSerialization['contentType'] as String,
      byteSize: jsonSerialization['byteSize'] as int,
      width: jsonSerialization['width'] as int?,
      height: jsonSerialization['height'] as int?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      url: jsonSerialization['url'] as String,
      urlExpiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['urlExpiresAt'],
      ),
    );
  }

  _isc.UuidValue photoId;

  /// original or composite.
  String kind;

  /// For a composite, the original it was made from (null if unknown or
  /// since deleted).
  _isc.UuidValue? originalId;

  String contentType;

  int byteSize;

  int? width;

  int? height;

  DateTime createdAt;

  String url;

  DateTime urlExpiresAt;

  /// Returns a shallow copy of this [PhotoView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PhotoView copyWith({
    _isc.UuidValue? photoId,
    String? kind,
    _isc.UuidValue? originalId,
    String? contentType,
    int? byteSize,
    int? width,
    int? height,
    DateTime? createdAt,
    String? url,
    DateTime? urlExpiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PhotoView',
      'photoId': photoId.toJson(),
      'kind': kind,
      if (originalId != null) 'originalId': originalId?.toJson(),
      'contentType': contentType,
      'byteSize': byteSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'createdAt': createdAt.toJson(),
      'url': url,
      'urlExpiresAt': urlExpiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PhotoView',
      'photoId': photoId.toJson(),
      'kind': kind,
      if (originalId != null) 'originalId': originalId?.toJson(),
      'contentType': contentType,
      'byteSize': byteSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'createdAt': createdAt.toJson(),
      'url': url,
      'urlExpiresAt': urlExpiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhotoViewImpl extends PhotoView {
  _PhotoViewImpl({
    required _isc.UuidValue photoId,
    required String kind,
    _isc.UuidValue? originalId,
    required String contentType,
    required int byteSize,
    int? width,
    int? height,
    required DateTime createdAt,
    required String url,
    required DateTime urlExpiresAt,
  }) : super._(
         photoId: photoId,
         kind: kind,
         originalId: originalId,
         contentType: contentType,
         byteSize: byteSize,
         width: width,
         height: height,
         createdAt: createdAt,
         url: url,
         urlExpiresAt: urlExpiresAt,
       );

  /// Returns a shallow copy of this [PhotoView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PhotoView copyWith({
    _isc.UuidValue? photoId,
    String? kind,
    Object? originalId = _Undefined,
    String? contentType,
    int? byteSize,
    Object? width = _Undefined,
    Object? height = _Undefined,
    DateTime? createdAt,
    String? url,
    DateTime? urlExpiresAt,
  }) {
    return PhotoView(
      photoId: photoId ?? this.photoId,
      kind: kind ?? this.kind,
      originalId: originalId is _isc.UuidValue? ? originalId : this.originalId,
      contentType: contentType ?? this.contentType,
      byteSize: byteSize ?? this.byteSize,
      width: width is int? ? width : this.width,
      height: height is int? ? height : this.height,
      createdAt: createdAt ?? this.createdAt,
      url: url ?? this.url,
      urlExpiresAt: urlExpiresAt ?? this.urlExpiresAt,
    );
  }
}
