import 'package:cloud_firestore/cloud_firestore.dart';

class ExpLedger {
  final String id;
  final String userId;
  final String quizId;
  final int expAwarded;
  final int score;
  final int totalQuestions;
  final int oldLevel;
  final int newLevel;
  final DateTime createdAt;

  const ExpLedger({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.expAwarded,
    required this.score,
    required this.totalQuestions,
    required this.oldLevel,
    required this.newLevel,
    required this.createdAt,
  });

  factory ExpLedger.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpLedger(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      expAwarded: data['expAwarded'] ?? 0,
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      oldLevel: data['oldLevel'] ?? 1,
      newLevel: data['newLevel'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'expAwarded': expAwarded,
      'score': score,
      'totalQuestions': totalQuestions,
      'oldLevel': oldLevel,
      'newLevel': newLevel,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get scorePercentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  bool get leveledUp => newLevel > oldLevel;

  @override
  String toString() {
    return 'ExpLedger(id: $id, quizId: $quizId, score: $score/$totalQuestions, expAwarded: $expAwarded, ${oldLevel}→${newLevel})';
  }
}


