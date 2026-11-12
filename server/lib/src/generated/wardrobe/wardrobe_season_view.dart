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

abstract class WardrobeSeasonView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WardrobeSeasonView._({
    required this.releaseAt,
    required this.endsAt,
    required this.open,
    required this.granted,
    required this.resaleOpen,
    this.resaleEndsAt,
  });

  factory WardrobeSeasonView({
    required DateTime releaseAt,
    required DateTime endsAt,
    required bool open,
    required bool granted,
    required bool resaleOpen,
    DateTime? resaleEndsAt,
  }) = _WardrobeSeasonViewImpl;

  factory WardrobeSeasonView.fromJson(Map<String, dynamic> jsonSerialization) {
    return WardrobeSeasonView(
      releaseAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['releaseAt'],
      ),
      endsAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      open: _is.BoolJsonExtension.fromJson(jsonSerialization['open']),
      granted: _is.BoolJsonExtension.fromJson(jsonSerialization['granted']),
      resaleOpen: _is.BoolJsonExtension.fromJson(
        jsonSerialization['resaleOpen'],
      ),
      resaleEndsAt: jsonSerialization['resaleEndsAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['resaleEndsAt'],
            ),
    );
  }

  DateTime releaseAt;

  DateTime endsAt;

  /// Now inside [releaseAt, endsAt].
  bool open;

  /// The user received this set as a subscriber.
  bool granted;

  /// A limited-time point sale of this past set is open now.
  bool resaleOpen;

  DateTime? resaleEndsAt;

  /// Returns a shallow copy of this [WardrobeSeasonView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WardrobeSeasonView copyWith({
    DateTime? releaseAt,
    DateTime? endsAt,
    bool? open,
    bool? granted,
    bool? resaleOpen,
    DateTime? resaleEndsAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WardrobeSeasonView',
      'releaseAt': releaseAt.toJson(),
      'endsAt': endsAt.toJson(),
      'open': open,
      'granted': granted,
      'resaleOpen': resaleOpen,
      if (resaleEndsAt != null) 'resaleEndsAt': resaleEndsAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WardrobeSeasonView',
      'releaseAt': releaseAt.toJson(),
      'endsAt': endsAt.toJson(),
      'open': open,
      'granted': granted,
      'resaleOpen': resaleOpen,
      if (resaleEndsAt != null) 'resaleEndsAt': resaleEndsAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WardrobeSeasonViewImpl extends WardrobeSeasonView {
  _WardrobeSeasonViewImpl({
    required DateTime releaseAt,
    required DateTime endsAt,
    required bool open,
    required bool granted,
    required bool resaleOpen,
    DateTime? resaleEndsAt,
  }) : super._(
         releaseAt: releaseAt,
         endsAt: endsAt,
         open: open,
         granted: granted,
         resaleOpen: resaleOpen,
         resaleEndsAt: resaleEndsAt,
       );

  /// Returns a shallow copy of this [WardrobeSeasonView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WardrobeSeasonView copyWith({
    DateTime? releaseAt,
    DateTime? endsAt,
    bool? open,
    bool? granted,
    bool? resaleOpen,
    Object? resaleEndsAt = _Undefined,
  }) {
    return WardrobeSeasonView(
      releaseAt: releaseAt ?? this.releaseAt,
      endsAt: endsAt ?? this.endsAt,
      open: open ?? this.open,
      granted: granted ?? this.granted,
      resaleOpen: resaleOpen ?? this.resaleOpen,
      resaleEndsAt: resaleEndsAt is DateTime?
          ? resaleEndsAt
          : this.resaleEndsAt,
    );
  }
}
