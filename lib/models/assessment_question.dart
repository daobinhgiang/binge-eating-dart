class AssessmentQuestion {
  final String id;
  final String questionText;
  final String questionType; // 'multiple_choice', 'scale', 'text', 'yes_no'
  final List<String>? options; // For multiple choice questions
  final int? minValue; // For scale questions
  final int? maxValue; // For scale questions
  final String? scaleLabel; // For scale questions (e.g., "Not at all" to "Extremely")
  final bool isRequired;

  const AssessmentQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    this.options,
    this.minValue,
    this.maxValue,
    this.scaleLabel,
    this.isRequired = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'questionType': questionType,
      'options': options,
      'minValue': minValue,
      'maxValue': maxValue,
      'scaleLabel': scaleLabel,
      'isRequired': isRequired,
    };
  }

  factory AssessmentQuestion.fromMap(Map<String, dynamic> map) {
    return AssessmentQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      questionType: map['questionType'] ?? '',
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      minValue: map['minValue'],
      maxValue: map['maxValue'],
      scaleLabel: map['scaleLabel'],
      isRequired: map['isRequired'] ?? true,
    );
  }
}
