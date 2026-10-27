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
import '../billing/purchase_view.dart' as _ifbold7p;

abstract class EntitlementView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  EntitlementView._({
    required this.active,
    required this.purchases,
  });

  factory EntitlementView({
    required bool active,
    required List<_ifbold7p.PurchaseView> purchases,
  }) = _EntitlementViewImpl;

  factory EntitlementView.fromJson(Map<String, dynamic> jsonSerialization) {
    return EntitlementView(
      active: _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      purchases: _iu3f2ih9.Protocol().deserialize<List<_ifbold7p.PurchaseView>>(
        jsonSerialization['purchases'],
      ),
    );
  }

  bool active;

  List<_ifbold7p.PurchaseView> purchases;

  /// Returns a shallow copy of this [EntitlementView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EntitlementView copyWith({
    bool? active,
    List<_ifbold7p.PurchaseView>? purchases,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EntitlementView',
      'active': active,
      'purchases': purchases.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EntitlementView',
      'active': active,
      'purchases': purchases.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _EntitlementViewImpl extends EntitlementView {
  _EntitlementViewImpl({
    required bool active,
    required List<_ifbold7p.PurchaseView> purchases,
  }) : super._(
         active: active,
         purchases: purchases,
       );

  /// Returns a shallow copy of this [EntitlementView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EntitlementView copyWith({
    bool? active,
    List<_ifbold7p.PurchaseView>? purchases,
  }) {
    return EntitlementView(
      active: active ?? this.active,
      purchases:
          purchases ?? this.purchases.map((e0) => e0.copyWith()).toList(),
    );
  }
}
