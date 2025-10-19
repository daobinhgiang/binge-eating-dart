import 'package:cloud_firestore/cloud_firestore.dart';

class ExpLedger {
  final String id;
  final String userId;
  final String? quizId; // Made optional for journal entries
  final String? entryType; // 'quiz', 'food_diary', 'weight_diary', 'body_image_diary', 'money_diary'
  final int expAwarded;
  final int score; // For quizzes, this is correct count
  final int? totalQuestions; // Made optional, only for quizzes
  final int oldLevel;
  final int newLevel;
  final DateTime createdAt;

  const ExpLedger({
    required this.id,
    required this.userId,
    this.quizId,
    this.entryType,
    required this.expAwarded,
    required this.score,
    this.totalQuestions,
    required this.oldLevel,
    required this.newLevel,
    required this.createdAt,
  });

  factory ExpLedger.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpLedger(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'],
      entryType: data['entryType'],
      expAwarded: data['expAwarded'] ?? 0,
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'],
      oldLevel: data['oldLevel'] ?? 1,
      newLevel: data['newLevel'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (quizId != null) 'quizId': quizId,
      if (entryType != null) 'entryType': entryType,
      'expAwarded': expAwarded,
      'score': score,
      if (totalQuestions != null) 'totalQuestions': totalQuestions,
      'oldLevel': oldLevel,
      'newLevel': newLevel,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get scorePercentage => totalQuestions != null && totalQuestions! > 0 ? (score / totalQuestions!) * 100 : 0;

  bool get leveledUp => newLevel > oldLevel;

  @override
  String toString() {
    if (quizId != null) {
      return 'ExpLedger(id: $id, quizId: $quizId, score: $score/$totalQuestions, expAwarded: $expAwarded, $oldLevel→$newLevel)';
    } else {
      return 'ExpLedger(id: $id, entryType: $entryType, expAwarded: $expAwarded, $oldLevel→$newLevel)';
    }
  }
}


