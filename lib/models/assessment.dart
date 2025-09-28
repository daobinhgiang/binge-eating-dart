import 'assessment_question.dart';
import 'assessment_response.dart';

class Assessment {
  final String id;
  final String title;
  final String description;
  final String lessonId;
  final List<AssessmentQuestion> questions;
  final List<AssessmentResponse>? responses; // User's responses if completed
  final DateTime? completedAt;
  final bool isCompleted;

  const Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonId,
    required this.questions,
    this.responses,
    this.completedAt,
    this.isCompleted = false,
  });

  Assessment copyWith({
    String? id,
    String? title,
    String? description,
    String? lessonId,
    List<AssessmentQuestion>? questions,
    List<AssessmentResponse>? responses,
    DateTime? completedAt,
    bool? isCompleted,
  }) {
    return Assessment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lessonId: lessonId ?? this.lessonId,
      questions: questions ?? this.questions,
      responses: responses ?? this.responses,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lessonId': lessonId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'responses': responses?.map((r) => r.toMap()).toList(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      lessonId: map['lessonId'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
          ?.map((q) => AssessmentQuestion.fromMap(q))
          .toList() ?? [],
      responses: (map['responses'] as List<dynamic>?)
          ?.map((r) => AssessmentResponse.fromMap(r))
          .toList(),
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
