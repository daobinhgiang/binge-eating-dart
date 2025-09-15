class OnboardingAnswer {
  final int questionNumber;
  final String question;
  final int selectedOption;
  final String selectedText;
  final DateTime answeredAt;

  const OnboardingAnswer({
    required this.questionNumber,
    required this.question,
    required this.selectedOption,
    required this.selectedText,
    required this.answeredAt,
  });

  factory OnboardingAnswer.fromMap(Map<String, dynamic> map) {
    // Handle both Timestamp and int for answeredAt
    DateTime answeredAt;
    final answeredAtValue = map['answeredAt'];
    if (answeredAtValue == null) {
      answeredAt = DateTime.now();
    } else if (answeredAtValue is int) {
      answeredAt = DateTime.fromMillisecondsSinceEpoch(answeredAtValue);
    } else {
      // Handle Firestore Timestamp
      answeredAt = answeredAtValue.toDate();
    }

    return OnboardingAnswer(
      questionNumber: map['questionNumber'] ?? 0,
      question: map['question'] ?? '',
      selectedOption: map['selectedOption'] ?? 0,
      selectedText: map['selectedText'] ?? '',
      answeredAt: answeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionNumber': questionNumber,
      'question': question,
      'selectedOption': selectedOption,
      'selectedText': selectedText,
      'answeredAt': answeredAt.millisecondsSinceEpoch,
    };
  }

  OnboardingAnswer copyWith({
    int? questionNumber,
    String? question,
    int? selectedOption,
    String? selectedText,
    DateTime? answeredAt,
  }) {
    return OnboardingAnswer(
      questionNumber: questionNumber ?? this.questionNumber,
      question: question ?? this.question,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedText: selectedText ?? this.selectedText,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingAnswer &&
        other.questionNumber == questionNumber &&
        other.question == question &&
        other.selectedOption == selectedOption &&
        other.selectedText == selectedText &&
        other.answeredAt == answeredAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      questionNumber,
      question,
      selectedOption,
      selectedText,
      answeredAt,
    );
  }

  @override
  String toString() {
    return 'OnboardingAnswer(questionNumber: $questionNumber, question: $question, selectedOption: $selectedOption, selectedText: $selectedText, answeredAt: $answeredAt)';
  }
}
