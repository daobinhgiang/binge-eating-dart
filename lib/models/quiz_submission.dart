import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus {
  pending,
  validated,
  failed,
}

extension SubmissionStatusExtension on SubmissionStatus {
  String get name {
    switch (this) {
      case SubmissionStatus.pending:
        return 'pending';
      case SubmissionStatus.validated:
        return 'validated';
      case SubmissionStatus.failed:
        return 'failed';
    }
  }

  static SubmissionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return SubmissionStatus.pending;
      case 'validated':
        return SubmissionStatus.validated;
      case 'failed':
        return SubmissionStatus.failed;
      default:
        return SubmissionStatus.pending;
    }
  }
}

class QuizSubmission {
  final String id;
  final String userId;
  final String quizId;
  final Map<String, int> answers; // questionId -> selected option index
  final DateTime submittedAt;
  final SubmissionStatus status;
  final DateTime? validatedAt;
  final int? score;
  final int? expAwarded;

  const QuizSubmission({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.answers,
    required this.submittedAt,
    required this.status,
    this.validatedAt,
    this.score,
    this.expAwarded,
  });

  factory QuizSubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizSubmission(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      answers: Map<String, int>.from(data['answers'] ?? {}),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      status: SubmissionStatusExtension.fromString(data['status'] ?? 'pending'),
      validatedAt: data['validatedAt'] != null
          ? (data['validatedAt'] as Timestamp).toDate()
          : null,
      score: data['score'],
      expAwarded: data['expAwarded'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'answers': answers,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'status': status.name,
      if (validatedAt != null) 'validatedAt': Timestamp.fromDate(validatedAt!),
      if (score != null) 'score': score,
      if (expAwarded != null) 'expAwarded': expAwarded,
    };
  }

  QuizSubmission copyWith({
    String? id,
    String? userId,
    String? quizId,
    Map<String, int>? answers,
    DateTime? submittedAt,
    SubmissionStatus? status,
    DateTime? validatedAt,
    int? score,
    int? expAwarded,
  }) {
    return QuizSubmission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      answers: answers ?? this.answers,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      validatedAt: validatedAt ?? this.validatedAt,
      score: score ?? this.score,
      expAwarded: expAwarded ?? this.expAwarded,
    );
  }

  @override
  String toString() {
    return 'QuizSubmission(id: $id, quizId: $quizId, status: ${status.name}, score: $score, expAwarded: $expAwarded)';
  }
}


