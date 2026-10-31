import 'dart:convert';

import 'package:characters/characters.dart';
import 'package:clock/clock.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';

// Keep aligned with the app's FirstMeetingCatalog, not display labels.
const _breedIds = {
  'pekingese',
  'bulldog',
  'shih-tzu',
  'pug',
  'maltese',
  'chihuahua',
  'french-bulldog',
  'dachshund',
  'miniature-schnauzer',
  'bichon-frise',
  'yorkshire-terrier',
  'west-highland-white-terrier',
  'norwich-terrier',
  'jindo',
  'shiba-inu',
  'alaskan-malamute',
  'german-shepherd',
  'pembroke-welsh-corgi',
  'pomeranian',
  'miniature-pinscher',
  'boston-terrier',
  'siberian-husky',
  'dalmatian',
  'beagle',
  'golden-retriever',
  'labrador-retriever',
  'border-collie',
  'samoyed',
  'toy-poodle',
  'cocker-spaniel',
};

String _name(String input) {
  final name = input.trim();
  if (name.isEmpty ||
      name.characters.length > 12 ||
      !name.runes.every(
        (rune) =>
            rune == 32 ||
            (rune >= 48 && rune <= 57) ||
            (rune >= 65 && rune <= 90) ||
            (rune >= 97 && rune <= 122) ||
            (rune >= 0xac00 && rune <= 0xd7a3) ||
            (rune >= 0x3131 && rune <= 0x3163) ||
            (rune >= 0x1100 && rune <= 0x11ff) ||
            (rune >= 0xa960 && rune <= 0xa97f) ||
            (rune >= 0xd7b0 && rune <= 0xd7ff),
      )) {
    throw ProfileException(code: 'invalidName');
  }
  return name;
}

ProfileView _view(DogProfile value) => ProfileView(
  breedId: value.breedId,
  name: value.name,
  sex: value.sex,
  dailyGoal: value.dailyGoal,
  firstMetAt: value.firstMetAt,
  revision: value.revision,
);

extension ProfileService on ProductService {
  Future<DogProfile?> _profile() => DogProfile.db.findFirstRow(
    session,
    where: (t) => t.owner.equals(owner),
    transaction: tx,
  );

  Future<ProfileView?> getProfile() async {
    final value = await _profile();
    return value == null ? null : _view(value);
  }

  // Reuse the shared owner/request-id namespace and payload digest exactly.
  Future<ProfileView?> _replayProfile(String requestId, Object payload) async {
    try {
      final previous = await replay(requestId, payload);
      return previous == null
          ? null
          : ProfileView.fromJson(jsonDecode(previous) as Map<String, dynamic>);
    } on ProductException catch (error) {
      throw ProfileException(code: error.code);
    }
  }

  Future<ProfileView> createProfile(
    ProfileInput input,
    String requestId,
  ) async {
    final payload = ['createProfile', input.toJson()];
    final previous = await _replayProfile(requestId, payload);
    if (previous != null) return previous;
    final name = _name(input.name);
    if (!_breedIds.contains(input.breedId)) {
      throw ProfileException(code: 'invalidBreed');
    }
    if (!{'male', 'female'}.contains(input.sex)) {
      throw ProfileException(code: 'invalidSex');
    }
    if (input.dailyGoal <= 0) throw ProfileException(code: 'invalidGoal');
    if (await _profile() != null) {
      throw ProfileException(code: 'alreadyExists');
    }
    final value = await DogProfile.db.insertRow(
      session,
      DogProfile(
        owner: owner,
        breedId: input.breedId,
        name: name,
        sex: input.sex,
        dailyGoal: input.dailyGoal,
        firstMetAt: clock.now().toUtc(),
      ),
      transaction: tx,
    );
    final result = _view(value);
    await remember(requestId, payload, result.toJson());
    return result;
  }

  Future<ProfileView> renameDog(
    String name,
    String requestId,
    int expectedRevision,
  ) async {
    final payload = ['renameDog', name, expectedRevision];
    final previous = await _replayProfile(requestId, payload);
    if (previous != null) return previous;
    final normalized = _name(name);
    final value = await _editable(expectedRevision);
    value.name = normalized;
    return _saveProfile(value, requestId, payload);
  }

  Future<ProfileView> updateGoal(
    int goal,
    String requestId,
    int expectedRevision,
  ) async {
    final payload = ['updateGoal', goal, expectedRevision];
    final previous = await _replayProfile(requestId, payload);
    if (previous != null) return previous;
    if (goal <= 0) throw ProfileException(code: 'invalidGoal');
    final value = await _editable(expectedRevision);
    value.dailyGoal = goal;
    return _saveProfile(value, requestId, payload);
  }

  Future<DogProfile> _editable(int expectedRevision) async {
    final value = await _profile();
    if (value == null) throw ProfileException(code: 'notFound');
    if (value.revision != expectedRevision) {
      throw ProfileException(code: 'staleRevision');
    }
    return value;
  }

  Future<ProfileView> _saveProfile(
    DogProfile value,
    String requestId,
    Object payload,
  ) async {
    value.revision++;
    await DogProfile.db.updateRow(session, value, transaction: tx);
    final result = _view(value);
    await remember(requestId, payload, result.toJson());
    return result;
  }
}
