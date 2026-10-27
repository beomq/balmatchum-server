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
import 'package:serverpod/serverpod.dart' as _is;

abstract class PurchaseView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PurchaseView._({
    required this.store,
    required this.productId,
    required this.kind,
    required this.state,
    required this.active,
    required this.observedAt,
    this.expiresAt,
    this.graceExpiresAt,
    required this.acknowledgementPending,
  });

  factory PurchaseView({
    required String store,
    required String productId,
    required String kind,
    required String state,
    required bool active,
    required DateTime observedAt,
    DateTime? expiresAt,
    DateTime? graceExpiresAt,
    required bool acknowledgementPending,
  }) = _PurchaseViewImpl;

  factory PurchaseView.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseView(
      store: jsonSerialization['store'] as String,
      productId: jsonSerialization['productId'] as String,
      kind: jsonSerialization['kind'] as String,
      state: jsonSerialization['state'] as String,
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      observedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['observedAt'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      graceExpiresAt: jsonSerialization['graceExpiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['graceExpiresAt'],
            ),
      acknowledgementPending: _is.BoolJsonExtension.fromJson(
        jsonSerialization['acknowledgementPending'],
      ),
    );
  }

  String store;

  String productId;

  String kind;

  String state;

  bool active;

  DateTime observedAt;

  DateTime? expiresAt;

  DateTime? graceExpiresAt;

  bool acknowledgementPending;

  /// Returns a shallow copy of this [PurchaseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PurchaseView copyWith({
    String? store,
    String? productId,
    String? kind,
    String? state,
    bool? active,
    DateTime? observedAt,
    DateTime? expiresAt,
    DateTime? graceExpiresAt,
    bool? acknowledgementPending,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseView',
      'store': store,
      'productId': productId,
      'kind': kind,
      'state': state,
      'active': active,
      'observedAt': observedAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (graceExpiresAt != null) 'graceExpiresAt': graceExpiresAt?.toJson(),
      'acknowledgementPending': acknowledgementPending,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PurchaseView',
      'store': store,
      'productId': productId,
      'kind': kind,
      'state': state,
      'active': active,
      'observedAt': observedAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (graceExpiresAt != null) 'graceExpiresAt': graceExpiresAt?.toJson(),
      'acknowledgementPending': acknowledgementPending,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseViewImpl extends PurchaseView {
  _PurchaseViewImpl({
    required String store,
    required String productId,
    required String kind,
    required String state,
    required bool active,
    required DateTime observedAt,
    DateTime? expiresAt,
    DateTime? graceExpiresAt,
    required bool acknowledgementPending,
  }) : super._(
         store: store,
         productId: productId,
         kind: kind,
         state: state,
         active: active,
         observedAt: observedAt,
         expiresAt: expiresAt,
         graceExpiresAt: graceExpiresAt,
         acknowledgementPending: acknowledgementPending,
       );

  /// Returns a shallow copy of this [PurchaseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PurchaseView copyWith({
    String? store,
    String? productId,
    String? kind,
    String? state,
    bool? active,
    DateTime? observedAt,
    Object? expiresAt = _Undefined,
    Object? graceExpiresAt = _Undefined,
    bool? acknowledgementPending,
  }) {
    return PurchaseView(
      store: store ?? this.store,
      productId: productId ?? this.productId,
      kind: kind ?? this.kind,
      state: state ?? this.state,
      active: active ?? this.active,
      observedAt: observedAt ?? this.observedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      graceExpiresAt: graceExpiresAt is DateTime?
          ? graceExpiresAt
          : this.graceExpiresAt,
      acknowledgementPending:
          acknowledgementPending ?? this.acknowledgementPending,
    );
  }
}
