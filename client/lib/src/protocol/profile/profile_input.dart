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

abstract class ProfileInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ProfileInput._({
    required this.breedId,
    required this.name,
    required this.sex,
    required this.dailyGoal,
  });

  factory ProfileInput({
    required String breedId,
    required String name,
    required String sex,
    required int dailyGoal,
  }) = _ProfileInputImpl;

  factory ProfileInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileInput(
      breedId: jsonSerialization['breedId'] as String,
      name: jsonSerialization['name'] as String,
      sex: jsonSerialization['sex'] as String,
      dailyGoal: jsonSerialization['dailyGoal'] as int,
    );
  }

  String breedId;

  String name;

  String sex;

  int dailyGoal;

  /// Returns a shallow copy of this [ProfileInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProfileInput copyWith({
    String? breedId,
    String? name,
    String? sex,
    int? dailyGoal,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileInput',
      'breedId': breedId,
      'name': name,
      'sex': sex,
      'dailyGoal': dailyGoal,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileInput',
      'breedId': breedId,
      'name': name,
      'sex': sex,
      'dailyGoal': dailyGoal,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ProfileInputImpl extends ProfileInput {
  _ProfileInputImpl({
    required String breedId,
    required String name,
    required String sex,
    required int dailyGoal,
  }) : super._(
         breedId: breedId,
         name: name,
         sex: sex,
         dailyGoal: dailyGoal,
       );

  /// Returns a shallow copy of this [ProfileInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProfileInput copyWith({
    String? breedId,
    String? name,
    String? sex,
    int? dailyGoal,
  }) {
    return ProfileInput(
      breedId: breedId ?? this.breedId,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}
