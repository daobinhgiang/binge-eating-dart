import 'onboarding_answer.dart';

class OnboardingData {
  final String userId;
  final List<OnboardingAnswer> answers;
  final DateTime completedAt;
  final int totalScore;

  const OnboardingData({
    required this.userId,
    required this.answers,
    required this.completedAt,
    required this.totalScore,
  });

  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    final answersList = map['answers'] as List<dynamic>? ?? [];
    final answers = answersList
        .map((answer) => OnboardingAnswer.fromMap(answer as Map<String, dynamic>))
        .toList();

    // Handle both Timestamp and int for completedAt
    DateTime completedAt;
    final completedAtValue = map['completedAt'];
    if (completedAtValue == null) {
      completedAt = DateTime.now();
    } else if (completedAtValue is int) {
      completedAt = DateTime.fromMillisecondsSinceEpoch(completedAtValue);
    } else {
      // Handle Firestore Timestamp
      completedAt = completedAtValue.toDate();
    }

    return OnboardingData(
      userId: map['userId'] ?? '',
      answers: answers,
      completedAt: completedAt,
      totalScore: map['totalScore'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'answers': answers.map((answer) => answer.toMap()).toList(),
      'completedAt': completedAt.millisecondsSinceEpoch,
      'totalScore': totalScore,
    };
  }

  OnboardingData copyWith({
    String? userId,
    List<OnboardingAnswer>? answers,
    DateTime? completedAt,
    int? totalScore,
  }) {
    return OnboardingData(
      userId: userId ?? this.userId,
      answers: answers ?? this.answers,
      completedAt: completedAt ?? this.completedAt,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  // Calculate total score from all answers
  int calculateTotalScore() {
    return answers.fold(0, (sum, answer) => sum + answer.selectedOption);
  }

  // Check if all 16 questions are answered
  bool get isComplete => answers.length == 16;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingData &&
        other.userId == userId &&
        other.answers == answers &&
        other.completedAt == completedAt &&
        other.totalScore == totalScore;
  }

  @override
  int get hashCode {
    return Object.hash(userId, answers, completedAt, totalScore);
  }

  @override
  String toString() {
    return 'OnboardingData(userId: $userId, answers: ${answers.length}, completedAt: $completedAt, totalScore: $totalScore)';
  }
}
