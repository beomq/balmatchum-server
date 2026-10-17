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

abstract class ProfileView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ProfileView._({
    required this.breedId,
    required this.name,
    required this.sex,
    required this.dailyGoal,
    required this.firstMetAt,
    required this.revision,
  });

  factory ProfileView({
    required String breedId,
    required String name,
    required String sex,
    required int dailyGoal,
    required DateTime firstMetAt,
    required int revision,
  }) = _ProfileViewImpl;

  factory ProfileView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileView(
      breedId: jsonSerialization['breedId'] as String,
      name: jsonSerialization['name'] as String,
      sex: jsonSerialization['sex'] as String,
      dailyGoal: jsonSerialization['dailyGoal'] as int,
      firstMetAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['firstMetAt'],
      ),
      revision: jsonSerialization['revision'] as int,
    );
  }

  String breedId;

  String name;

  String sex;

  int dailyGoal;

  DateTime firstMetAt;

  int revision;

  /// Returns a shallow copy of this [ProfileView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProfileView copyWith({
    String? breedId,
    String? name,
    String? sex,
    int? dailyGoal,
    DateTime? firstMetAt,
    int? revision,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileView',
      'breedId': breedId,
      'name': name,
      'sex': sex,
      'dailyGoal': dailyGoal,
      'firstMetAt': firstMetAt.toJson(),
      'revision': revision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileView',
      'breedId': breedId,
      'name': name,
      'sex': sex,
      'dailyGoal': dailyGoal,
      'firstMetAt': firstMetAt.toJson(),
      'revision': revision,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ProfileViewImpl extends ProfileView {
  _ProfileViewImpl({
    required String breedId,
    required String name,
    required String sex,
    required int dailyGoal,
    required DateTime firstMetAt,
    required int revision,
  }) : super._(
         breedId: breedId,
         name: name,
         sex: sex,
         dailyGoal: dailyGoal,
         firstMetAt: firstMetAt,
         revision: revision,
       );

  /// Returns a shallow copy of this [ProfileView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProfileView copyWith({
    String? breedId,
    String? name,
    String? sex,
    int? dailyGoal,
    DateTime? firstMetAt,
    int? revision,
  }) {
    return ProfileView(
      breedId: breedId ?? this.breedId,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      firstMetAt: firstMetAt ?? this.firstMetAt,
      revision: revision ?? this.revision,
    );
  }
}
