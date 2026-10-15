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

abstract class RewardWindow
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RewardWindow._({
    required this.fromUnits,
    required this.throughUnits,
    required this.confirmedAt,
    required this.freeUntil,
  });

  factory RewardWindow({
    required int fromUnits,
    required int throughUnits,
    required DateTime confirmedAt,
    required DateTime freeUntil,
  }) = _RewardWindowImpl;

  factory RewardWindow.fromJson(Map<String, dynamic> jsonSerialization) {
    return RewardWindow(
      fromUnits: jsonSerialization['fromUnits'] as int,
      throughUnits: jsonSerialization['throughUnits'] as int,
      confirmedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['confirmedAt'],
      ),
      freeUntil: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['freeUntil'],
      ),
    );
  }

  int fromUnits;

  int throughUnits;

  DateTime confirmedAt;

  DateTime freeUntil;

  /// Returns a shallow copy of this [RewardWindow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RewardWindow copyWith({
    int? fromUnits,
    int? throughUnits,
    DateTime? confirmedAt,
    DateTime? freeUntil,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RewardWindow',
      'fromUnits': fromUnits,
      'throughUnits': throughUnits,
      'confirmedAt': confirmedAt.toJson(),
      'freeUntil': freeUntil.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RewardWindowImpl extends RewardWindow {
  _RewardWindowImpl({
    required int fromUnits,
    required int throughUnits,
    required DateTime confirmedAt,
    required DateTime freeUntil,
  }) : super._(
         fromUnits: fromUnits,
         throughUnits: throughUnits,
         confirmedAt: confirmedAt,
         freeUntil: freeUntil,
       );

  /// Returns a shallow copy of this [RewardWindow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RewardWindow copyWith({
    int? fromUnits,
    int? throughUnits,
    DateTime? confirmedAt,
    DateTime? freeUntil,
  }) {
    return RewardWindow(
      fromUnits: fromUnits ?? this.fromUnits,
      throughUnits: throughUnits ?? this.throughUnits,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      freeUntil: freeUntil ?? this.freeUntil,
    );
  }
}
