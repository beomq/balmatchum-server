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

abstract class DailyQuiz
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DailyQuiz._({
    required this.date,
    required this.questionId,
    required this.question,
    required this.choices,
    this.answerIndex,
    this.correctIndex,
    this.explanation,
    required this.awardedPoints,
    required this.fixtureLabel,
  });

  factory DailyQuiz({
    required String date,
    required String questionId,
    required String question,
    required List<String> choices,
    int? answerIndex,
    int? correctIndex,
    String? explanation,
    required int awardedPoints,
    required String fixtureLabel,
  }) = _DailyQuizImpl;

  factory DailyQuiz.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyQuiz(
      date: jsonSerialization['date'] as String,
      questionId: jsonSerialization['questionId'] as String,
      question: jsonSerialization['question'] as String,
      choices: _iu3f2ih9.Protocol().deserialize<List<String>>(
        jsonSerialization['choices'],
      ),
      answerIndex: jsonSerialization['answerIndex'] as int?,
      correctIndex: jsonSerialization['correctIndex'] as int?,
      explanation: jsonSerialization['explanation'] as String?,
      awardedPoints: jsonSerialization['awardedPoints'] as int,
      fixtureLabel: jsonSerialization['fixtureLabel'] as String,
    );
  }

  String date;

  String questionId;

  String question;

  List<String> choices;

  int? answerIndex;

  int? correctIndex;

  String? explanation;

  int awardedPoints;

  String fixtureLabel;

  /// Returns a shallow copy of this [DailyQuiz]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DailyQuiz copyWith({
    String? date,
    String? questionId,
    String? question,
    List<String>? choices,
    int? answerIndex,
    int? correctIndex,
    String? explanation,
    int? awardedPoints,
    String? fixtureLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyQuiz',
      'date': date,
      'questionId': questionId,
      'question': question,
      'choices': choices.toJson(),
      if (answerIndex != null) 'answerIndex': answerIndex,
      if (correctIndex != null) 'correctIndex': correctIndex,
      if (explanation != null) 'explanation': explanation,
      'awardedPoints': awardedPoints,
      'fixtureLabel': fixtureLabel,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyQuiz',
      'date': date,
      'questionId': questionId,
      'question': question,
      'choices': choices.toJson(),
      if (answerIndex != null) 'answerIndex': answerIndex,
      if (correctIndex != null) 'correctIndex': correctIndex,
      if (explanation != null) 'explanation': explanation,
      'awardedPoints': awardedPoints,
      'fixtureLabel': fixtureLabel,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyQuizImpl extends DailyQuiz {
  _DailyQuizImpl({
    required String date,
    required String questionId,
    required String question,
    required List<String> choices,
    int? answerIndex,
    int? correctIndex,
    String? explanation,
    required int awardedPoints,
    required String fixtureLabel,
  }) : super._(
         date: date,
         questionId: questionId,
         question: question,
         choices: choices,
         answerIndex: answerIndex,
         correctIndex: correctIndex,
         explanation: explanation,
         awardedPoints: awardedPoints,
         fixtureLabel: fixtureLabel,
       );

  /// Returns a shallow copy of this [DailyQuiz]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DailyQuiz copyWith({
    String? date,
    String? questionId,
    String? question,
    List<String>? choices,
    Object? answerIndex = _Undefined,
    Object? correctIndex = _Undefined,
    Object? explanation = _Undefined,
    int? awardedPoints,
    String? fixtureLabel,
  }) {
    return DailyQuiz(
      date: date ?? this.date,
      questionId: questionId ?? this.questionId,
      question: question ?? this.question,
      choices: choices ?? this.choices.map((e0) => e0).toList(),
      answerIndex: answerIndex is int? ? answerIndex : this.answerIndex,
      correctIndex: correctIndex is int? ? correctIndex : this.correctIndex,
      explanation: explanation is String? ? explanation : this.explanation,
      awardedPoints: awardedPoints ?? this.awardedPoints,
      fixtureLabel: fixtureLabel ?? this.fixtureLabel,
    );
  }
}
