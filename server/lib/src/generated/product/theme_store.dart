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
import 'package:balmatchum_server/src/generated/protocol.dart' as _iu3f2ih9;
import 'package:serverpod/serverpod.dart' as _is;
import '../product/theme_item.dart' as _ikrazf1q;

abstract class ThemeStore
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ThemeStore._({
    required this.items,
    required this.equippedTheme,
    required this.balance,
    this.fixtureLabel,
  });

  factory ThemeStore({
    required List<_ikrazf1q.ThemeItem> items,
    required String equippedTheme,
    required int balance,
    String? fixtureLabel,
  }) = _ThemeStoreImpl;

  factory ThemeStore.fromJson(Map<String, dynamic> jsonSerialization) {
    return ThemeStore(
      items: _iu3f2ih9.Protocol().deserialize<List<_ikrazf1q.ThemeItem>>(
        jsonSerialization['items'],
      ),
      equippedTheme: jsonSerialization['equippedTheme'] as String,
      balance: jsonSerialization['balance'] as int,
      fixtureLabel: jsonSerialization['fixtureLabel'] as String?,
    );
  }

  List<_ikrazf1q.ThemeItem> items;

  String equippedTheme;

  int balance;

  String? fixtureLabel;

  /// Returns a shallow copy of this [ThemeStore]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ThemeStore copyWith({
    List<_ikrazf1q.ThemeItem>? items,
    String? equippedTheme,
    int? balance,
    String? fixtureLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ThemeStore',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      'equippedTheme': equippedTheme,
      'balance': balance,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ThemeStore',
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'equippedTheme': equippedTheme,
      'balance': balance,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ThemeStoreImpl extends ThemeStore {
  _ThemeStoreImpl({
    required List<_ikrazf1q.ThemeItem> items,
    required String equippedTheme,
    required int balance,
    String? fixtureLabel,
  }) : super._(
         items: items,
         equippedTheme: equippedTheme,
         balance: balance,
         fixtureLabel: fixtureLabel,
       );

  /// Returns a shallow copy of this [ThemeStore]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ThemeStore copyWith({
    List<_ikrazf1q.ThemeItem>? items,
    String? equippedTheme,
    int? balance,
    Object? fixtureLabel = _Undefined,
  }) {
    return ThemeStore(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      equippedTheme: equippedTheme ?? this.equippedTheme,
      balance: balance ?? this.balance,
      fixtureLabel: fixtureLabel is String? ? fixtureLabel : this.fixtureLabel,
    );
  }
}
