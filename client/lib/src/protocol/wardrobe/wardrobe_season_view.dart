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

/// A monthly gift window of a set or an item.
abstract class WardrobeSeasonView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WardrobeSeasonView._({
    required this.month,
    required this.releaseAt,
    required this.endsAt,
    required this.open,
    required this.granted,
    required this.resaleOpen,
    this.resaleEndsAt,
  });

  factory WardrobeSeasonView({
    required String month,
    required DateTime releaseAt,
    required DateTime endsAt,
    required bool open,
    required bool granted,
    required bool resaleOpen,
    DateTime? resaleEndsAt,
  }) = _WardrobeSeasonViewImpl;

  factory WardrobeSeasonView.fromJson(Map<String, dynamic> jsonSerialization) {
    return WardrobeSeasonView(
      month: jsonSerialization['month'] as String,
      releaseAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['releaseAt'],
      ),
      endsAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      open: _isc.BoolJsonExtension.fromJson(jsonSerialization['open']),
      granted: _isc.BoolJsonExtension.fromJson(jsonSerialization['granted']),
      resaleOpen: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['resaleOpen'],
      ),
      resaleEndsAt: jsonSerialization['resaleEndsAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resaleEndsAt'],
            ),
    );
  }

  /// KST month of the gift, yyyy-MM.
  String month;

  DateTime releaseAt;

  DateTime endsAt;

  /// Now inside [releaseAt, endsAt].
  bool open;

  /// The user received this gift as a paying member.
  bool granted;

  /// A limited-time point sale of this past gift is open now.
  bool resaleOpen;

  DateTime? resaleEndsAt;

  /// Returns a shallow copy of this [WardrobeSeasonView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WardrobeSeasonView copyWith({
    String? month,
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
      'month': month,
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
      'month': month,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WardrobeSeasonViewImpl extends WardrobeSeasonView {
  _WardrobeSeasonViewImpl({
    required String month,
    required DateTime releaseAt,
    required DateTime endsAt,
    required bool open,
    required bool granted,
    required bool resaleOpen,
    DateTime? resaleEndsAt,
  }) : super._(
         month: month,
         releaseAt: releaseAt,
         endsAt: endsAt,
         open: open,
         granted: granted,
         resaleOpen: resaleOpen,
         resaleEndsAt: resaleEndsAt,
       );

  /// Returns a shallow copy of this [WardrobeSeasonView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WardrobeSeasonView copyWith({
    String? month,
    DateTime? releaseAt,
    DateTime? endsAt,
    bool? open,
    bool? granted,
    bool? resaleOpen,
    Object? resaleEndsAt = _Undefined,
  }) {
    return WardrobeSeasonView(
      month: month ?? this.month,
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
