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
import '../product/daily_record.dart' as _irm9m2mf;
import '../product/outfit_store.dart' as _iobmgmk3;
import '../product/theme_store.dart' as _ifhmh1w9;
import '../product/wallet_view.dart' as _ic5lo3sd;
import '../profile/profile_view.dart' as _ih0yc01p;

abstract class HomeSnapshot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  HomeSnapshot._({
    required this.date,
    this.profile,
    required this.day,
    required this.wallet,
    required this.themes,
    required this.outfits,
    required this.recentDays,
  });

  factory HomeSnapshot({
    required String date,
    _ih0yc01p.ProfileView? profile,
    required _irm9m2mf.DailyRecord day,
    required _ic5lo3sd.WalletView wallet,
    required _ifhmh1w9.ThemeStore themes,
    required _iobmgmk3.OutfitStore outfits,
    required List<_irm9m2mf.DailyRecord> recentDays,
  }) = _HomeSnapshotImpl;

  factory HomeSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return HomeSnapshot(
      date: jsonSerialization['date'] as String,
      profile: jsonSerialization['profile'] == null
          ? null
          : _i5u3fx7i.Protocol().deserialize<_ih0yc01p.ProfileView>(
              jsonSerialization['profile'],
            ),
      day: _i5u3fx7i.Protocol().deserialize<_irm9m2mf.DailyRecord>(
        jsonSerialization['day'],
      ),
      wallet: _i5u3fx7i.Protocol().deserialize<_ic5lo3sd.WalletView>(
        jsonSerialization['wallet'],
      ),
      themes: _i5u3fx7i.Protocol().deserialize<_ifhmh1w9.ThemeStore>(
        jsonSerialization['themes'],
      ),
      outfits: _i5u3fx7i.Protocol().deserialize<_iobmgmk3.OutfitStore>(
        jsonSerialization['outfits'],
      ),
      recentDays: _i5u3fx7i.Protocol().deserialize<List<_irm9m2mf.DailyRecord>>(
        jsonSerialization['recentDays'],
      ),
    );
  }

  String date;

  _ih0yc01p.ProfileView? profile;

  _irm9m2mf.DailyRecord day;

  _ic5lo3sd.WalletView wallet;

  _ifhmh1w9.ThemeStore themes;

  _iobmgmk3.OutfitStore outfits;

  List<_irm9m2mf.DailyRecord> recentDays;

  /// Returns a shallow copy of this [HomeSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  HomeSnapshot copyWith({
    String? date,
    _ih0yc01p.ProfileView? profile,
    _irm9m2mf.DailyRecord? day,
    _ic5lo3sd.WalletView? wallet,
    _ifhmh1w9.ThemeStore? themes,
    _iobmgmk3.OutfitStore? outfits,
    List<_irm9m2mf.DailyRecord>? recentDays,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HomeSnapshot',
      'date': date,
      if (profile != null) 'profile': profile?.toJson(),
      'day': day.toJson(),
      'wallet': wallet.toJson(),
      'themes': themes.toJson(),
      'outfits': outfits.toJson(),
      'recentDays': recentDays.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HomeSnapshot',
      'date': date,
      if (profile != null) 'profile': profile?.toJsonForProtocol(),
      'day': day.toJsonForProtocol(),
      'wallet': wallet.toJsonForProtocol(),
      'themes': themes.toJsonForProtocol(),
      'outfits': outfits.toJsonForProtocol(),
      'recentDays': recentDays.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HomeSnapshotImpl extends HomeSnapshot {
  _HomeSnapshotImpl({
    required String date,
    _ih0yc01p.ProfileView? profile,
    required _irm9m2mf.DailyRecord day,
    required _ic5lo3sd.WalletView wallet,
    required _ifhmh1w9.ThemeStore themes,
    required _iobmgmk3.OutfitStore outfits,
    required List<_irm9m2mf.DailyRecord> recentDays,
  }) : super._(
         date: date,
         profile: profile,
         day: day,
         wallet: wallet,
         themes: themes,
         outfits: outfits,
         recentDays: recentDays,
       );

  /// Returns a shallow copy of this [HomeSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  HomeSnapshot copyWith({
    String? date,
    Object? profile = _Undefined,
    _irm9m2mf.DailyRecord? day,
    _ic5lo3sd.WalletView? wallet,
    _ifhmh1w9.ThemeStore? themes,
    _iobmgmk3.OutfitStore? outfits,
    List<_irm9m2mf.DailyRecord>? recentDays,
  }) {
    return HomeSnapshot(
      date: date ?? this.date,
      profile: profile is _ih0yc01p.ProfileView?
          ? profile
          : this.profile?.copyWith(),
      day: day ?? this.day.copyWith(),
      wallet: wallet ?? this.wallet.copyWith(),
      themes: themes ?? this.themes.copyWith(),
      outfits: outfits ?? this.outfits.copyWith(),
      recentDays:
          recentDays ?? this.recentDays.map((e0) => e0.copyWith()).toList(),
    );
  }
}
