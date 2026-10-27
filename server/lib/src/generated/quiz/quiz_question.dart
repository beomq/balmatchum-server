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

abstract class QuizQuestion
    implements _is.SerializableModel, _is.ProtocolSerialization {
  QuizQuestion._({
    required this.assignmentId,
    required this.date,
    required this.slot,
    required this.questionId,
    required this.version,
    required this.question,
    required this.choices,
    required this.conditions,
    required this.reviewedAt,
    required this.reviewedBy,
    this.answerIndex,
    this.correctIndex,
    this.explanation,
    this.source,
    this.answeredAt,
    required this.awardedPoints,
    required this.policyVersion,
    this.fixtureLabel,
  });

  factory QuizQuestion({
    required int assignmentId,
    required String date,
    required String slot,
    required String questionId,
    required int version,
    required String question,
    required List<String> choices,
    required String conditions,
    required String reviewedAt,
    required String reviewedBy,
    int? answerIndex,
    int? correctIndex,
    String? explanation,
    String? source,
    DateTime? answeredAt,
    required int awardedPoints,
    required String policyVersion,
    String? fixtureLabel,
  }) = _QuizQuestionImpl;

  factory QuizQuestion.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuizQuestion(
      assignmentId: jsonSerialization['assignmentId'] as int,
      date: jsonSerialization['date'] as String,
      slot: jsonSerialization['slot'] as String,
      questionId: jsonSerialization['questionId'] as String,
      version: jsonSerialization['version'] as int,
      question: jsonSerialization['question'] as String,
      choices: _iu3f2ih9.Protocol().deserialize<List<String>>(
        jsonSerialization['choices'],
      ),
      conditions: jsonSerialization['conditions'] as String,
      reviewedAt: jsonSerialization['reviewedAt'] as String,
      reviewedBy: jsonSerialization['reviewedBy'] as String,
      answerIndex: jsonSerialization['answerIndex'] as int?,
      correctIndex: jsonSerialization['correctIndex'] as int?,
      explanation: jsonSerialization['explanation'] as String?,
      source: jsonSerialization['source'] as String?,
      answeredAt: jsonSerialization['answeredAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['answeredAt']),
      awardedPoints: jsonSerialization['awardedPoints'] as int,
      policyVersion: jsonSerialization['policyVersion'] as String,
      fixtureLabel: jsonSerialization['fixtureLabel'] as String?,
    );
  }

  int assignmentId;

  String date;

  String slot;

  String questionId;

  int version;

  String question;

  List<String> choices;

  String conditions;

  String reviewedAt;

  String reviewedBy;

  int? answerIndex;

  int? correctIndex;

  String? explanation;

  String? source;

  DateTime? answeredAt;

  int awardedPoints;

  String policyVersion;

  String? fixtureLabel;

  /// Returns a shallow copy of this [QuizQuestion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  QuizQuestion copyWith({
    int? assignmentId,
    String? date,
    String? slot,
    String? questionId,
    int? version,
    String? question,
    List<String>? choices,
    String? conditions,
    String? reviewedAt,
    String? reviewedBy,
    int? answerIndex,
    int? correctIndex,
    String? explanation,
    String? source,
    DateTime? answeredAt,
    int? awardedPoints,
    String? policyVersion,
    String? fixtureLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuizQuestion',
      'assignmentId': assignmentId,
      'date': date,
      'slot': slot,
      'questionId': questionId,
      'version': version,
      'question': question,
      'choices': choices.toJson(),
      'conditions': conditions,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
      if (answerIndex != null) 'answerIndex': answerIndex,
      if (correctIndex != null) 'correctIndex': correctIndex,
      if (explanation != null) 'explanation': explanation,
      if (source != null) 'source': source,
      if (answeredAt != null) 'answeredAt': answeredAt?.toJson(),
      'awardedPoints': awardedPoints,
      'policyVersion': policyVersion,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'QuizQuestion',
      'assignmentId': assignmentId,
      'date': date,
      'slot': slot,
      'questionId': questionId,
      'version': version,
      'question': question,
      'choices': choices.toJson(),
      'conditions': conditions,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
      if (answerIndex != null) 'answerIndex': answerIndex,
      if (correctIndex != null) 'correctIndex': correctIndex,
      if (explanation != null) 'explanation': explanation,
      if (source != null) 'source': source,
      if (answeredAt != null) 'answeredAt': answeredAt?.toJson(),
      'awardedPoints': awardedPoints,
      'policyVersion': policyVersion,
      if (fixtureLabel != null) 'fixtureLabel': fixtureLabel,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuizQuestionImpl extends QuizQuestion {
  _QuizQuestionImpl({
    required int assignmentId,
    required String date,
    required String slot,
    required String questionId,
    required int version,
    required String question,
    required List<String> choices,
    required String conditions,
    required String reviewedAt,
    required String reviewedBy,
    int? answerIndex,
    int? correctIndex,
    String? explanation,
    String? source,
    DateTime? answeredAt,
    required int awardedPoints,
    required String policyVersion,
    String? fixtureLabel,
  }) : super._(
         assignmentId: assignmentId,
         date: date,
         slot: slot,
         questionId: questionId,
         version: version,
         question: question,
         choices: choices,
         conditions: conditions,
         reviewedAt: reviewedAt,
         reviewedBy: reviewedBy,
         answerIndex: answerIndex,
         correctIndex: correctIndex,
         explanation: explanation,
         source: source,
         answeredAt: answeredAt,
         awardedPoints: awardedPoints,
         policyVersion: policyVersion,
         fixtureLabel: fixtureLabel,
       );

  /// Returns a shallow copy of this [QuizQuestion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  QuizQuestion copyWith({
    int? assignmentId,
    String? date,
    String? slot,
    String? questionId,
    int? version,
    String? question,
    List<String>? choices,
    String? conditions,
    String? reviewedAt,
    String? reviewedBy,
    Object? answerIndex = _Undefined,
    Object? correctIndex = _Undefined,
    Object? explanation = _Undefined,
    Object? source = _Undefined,
    Object? answeredAt = _Undefined,
    int? awardedPoints,
    String? policyVersion,
    Object? fixtureLabel = _Undefined,
  }) {
    return QuizQuestion(
      assignmentId: assignmentId ?? this.assignmentId,
      date: date ?? this.date,
      slot: slot ?? this.slot,
      questionId: questionId ?? this.questionId,
      version: version ?? this.version,
      question: question ?? this.question,
      choices: choices ?? this.choices.map((e0) => e0).toList(),
      conditions: conditions ?? this.conditions,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      answerIndex: answerIndex is int? ? answerIndex : this.answerIndex,
      correctIndex: correctIndex is int? ? correctIndex : this.correctIndex,
      explanation: explanation is String? ? explanation : this.explanation,
      source: source is String? ? source : this.source,
      answeredAt: answeredAt is DateTime? ? answeredAt : this.answeredAt,
      awardedPoints: awardedPoints ?? this.awardedPoints,
      policyVersion: policyVersion ?? this.policyVersion,
      fixtureLabel: fixtureLabel is String? ? fixtureLabel : this.fixtureLabel,
    );
  }
}
