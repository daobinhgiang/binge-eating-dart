class AssessmentResponse {
  final String id;
  final String questionId;
  final String responseValue; // The actual answer
  final String responseType; // 'multiple_choice', 'scale', 'text', 'yes_no'
  final DateTime answeredAt;

  const AssessmentResponse({
    required this.id,
    required this.questionId,
    required this.responseValue,
    required this.responseType,
    required this.answeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'responseValue': responseValue,
      'responseType': responseType,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory AssessmentResponse.fromMap(Map<String, dynamic> map) {
    return AssessmentResponse(
      id: map['id'] ?? '',
      questionId: map['questionId'] ?? '',
      responseValue: map['responseValue'] ?? '',
      responseType: map['responseType'] ?? '',
      answeredAt: DateTime.parse(map['answeredAt']),
    );
  }
}
