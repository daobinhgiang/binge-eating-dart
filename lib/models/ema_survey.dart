import 'package:cloud_firestore/cloud_firestore.dart';

class EMASurvey {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final List<EMASurveyAnswer> answers;
  final DateTime surveyDate; // The date this survey is for

  const EMASurvey({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.completedAt,
    this.isCompleted = false,
    this.answers = const [],
    required this.surveyDate,
  });

  factory EMASurvey.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final answersList = data['answers'] as List<dynamic>? ?? [];
    final answers = answersList
        .map((answer) => EMASurveyAnswer.fromMap(answer as Map<String, dynamic>))
        .toList();

    return EMASurvey(
      id: doc.id,
      userId: data['userId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      completedAt: data['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completedAt'])
          : null,
      isCompleted: data['isCompleted'] ?? false,
      answers: answers,
      surveyDate: DateTime.fromMillisecondsSinceEpoch(data['surveyDate'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'answers': answers.map((answer) => answer.toMap()).toList(),
      'surveyDate': surveyDate.millisecondsSinceEpoch,
    };
  }

  EMASurvey copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isCompleted,
    List<EMASurveyAnswer>? answers,
    DateTime? surveyDate,
  }) {
    return EMASurvey(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      answers: answers ?? this.answers,
      surveyDate: surveyDate ?? this.surveyDate,
    );
  }

  // Check if all required questions are answered
  bool get isComplete => answers.length >= 11; // Based on the 11 main questions

  // Get completion percentage
  double get completionPercentage => answers.length / 11.0;

  @override
  String toString() {
    return 'EMASurvey(id: $id, userId: $userId, isCompleted: $isCompleted, answers: ${answers.length})';
  }
}

class EMASurveyAnswer {
  final String questionId;
  final String questionText;
  final dynamic answer; // Can be String, int, double, List<String>, etc.
  final String answerType; // 'single', 'multiple', 'slider', 'text'
  final DateTime answeredAt;

  const EMASurveyAnswer({
    required this.questionId,
    required this.questionText,
    required this.answer,
    required this.answerType,
    required this.answeredAt,
  });

  factory EMASurveyAnswer.fromMap(Map<String, dynamic> map) {
    DateTime answeredAt;
    final answeredAtValue = map['answeredAt'];
    if (answeredAtValue == null) {
      answeredAt = DateTime.now();
    } else if (answeredAtValue is int) {
      answeredAt = DateTime.fromMillisecondsSinceEpoch(answeredAtValue);
    } else {
      answeredAt = answeredAtValue.toDate();
    }

    return EMASurveyAnswer(
      questionId: map['questionId'] ?? '',
      questionText: map['questionText'] ?? '',
      answer: map['answer'],
      answerType: map['answerType'] ?? 'single',
      answeredAt: answeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'answer': answer,
      'answerType': answerType,
      'answeredAt': answeredAt.millisecondsSinceEpoch,
    };
  }

  EMASurveyAnswer copyWith({
    String? questionId,
    String? questionText,
    dynamic answer,
    String? answerType,
    DateTime? answeredAt,
  }) {
    return EMASurveyAnswer(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      answer: answer ?? this.answer,
      answerType: answerType ?? this.answerType,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  String toString() {
    return 'EMASurveyAnswer(questionId: $questionId, answer: $answer, answerType: $answerType)';
  }
}

// Enum for question types
enum EMAQuestionType {
  singleChoice,
  multipleChoice,
  slider,
  multiSlider,
  text,
}

// Enum for specific question IDs
enum EMAQuestionId {
  location,
  companions,
  ateSinceLastPrompt,
  eatingContext,
  hungerBefore,
  fullnessAfter,
  urgeToBinge,
  emotions,
  bodyThoughts,
  eatingThoughts,
  triggers,
  coping,
  copingHelpfulness,
  confidence,
  bingedSinceLastPrompt,
}

// Question data structure
class EMAQuestion {
  final EMAQuestionId id;
  final String text;
  final EMAQuestionType type;
  final List<String>? options;
  final int? minValue;
  final int? maxValue;
  final String? hintText;
  final bool isRequired;
  final List<EMAQuestion>? subQuestions;

  const EMAQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.minValue,
    this.maxValue,
    this.hintText,
    this.isRequired = true,
    this.subQuestions,
  });
}
