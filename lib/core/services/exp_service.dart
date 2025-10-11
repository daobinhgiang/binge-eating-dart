import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/quiz_submission.dart';
import '../../models/exp_ledger.dart';

class ExpService {
  static final ExpService _instance = ExpService._internal();
  factory ExpService() => _instance;
  ExpService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Base EXP configuration (client-side reference, actual calculation is server-side)
  static const Map<String, int> _baseExpMap = {
    // Stage 1 quizzes
    'quiz_1_chapter_1': 50,
    'quiz_3_chapter_3': 50,
    // Stage 2 quizzes
    'quiz_0_chapter_0': 75,
    'quiz_1_stage_2': 100,
    'quiz_2_stage_2': 100,
    'quiz_3_stage_2': 100,
    'quiz_4_stage_2': 100,
    'quiz_5_stage_2': 150,
    'quiz_6_stage_2': 150,
    'quiz_7_stage_2': 150,
  };

  // Level thresholds (cumulative EXP required)
  static const Map<int, int> _levelThresholds = {
    1: 0,
    2: 500,
    3: 1500,   // 500 + 1000
    4: 3500,   // 500 + 1000 + 2000
    5: 7500,   // 500 + 1000 + 2000 + 4000
  };

  /// Submit quiz for validation
  /// Returns the submission document reference to listen for results
  Future<DocumentReference?> submitQuizForValidation(
    String quizId,
    Map<String, int> answers,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Check if quiz already completed
      final alreadyCompleted = await isQuizCompleted(quizId);
      if (alreadyCompleted) {
        print('Quiz $quizId already completed');
        return null;
      }

      // Create submission document
      final submissionRef = _firestore.collection('quiz_submissions').doc();
      
      final submission = QuizSubmission(
        id: submissionRef.id,
        userId: user.uid,
        quizId: quizId,
        answers: answers,
        submittedAt: DateTime.now(),
        status: SubmissionStatus.pending,
      );

      await submissionRef.set(submission.toFirestore());
      
      print('Quiz submission created: ${submissionRef.id}');
      return submissionRef;
    } catch (e) {
      print('Error submitting quiz: $e');
      return null;
    }
  }

  /// Listen to submission result
  Stream<QuizSubmission> listenToSubmissionResult(String submissionId) {
    return _firestore
        .collection('quiz_submissions')
        .doc(submissionId)
        .snapshots()
        .map((doc) => QuizSubmission.fromFirestore(doc));
  }

  /// Check if quiz is already completed
  Future<bool> isQuizCompleted(String quizId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final querySnapshot = await _firestore
          .collection('exp_ledger')
          .where('userId', isEqualTo: user.uid)
          .where('quizId', isEqualTo: quizId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking quiz completion: $e');
      return false;
    }
  }

  /// Get EXP history for current user
  Future<List<ExpLedger>> getExpHistory({int limit = 10}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('exp_ledger')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ExpLedger.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching EXP history: $e');
      return [];
    }
  }

  /// Stream EXP history for current user
  Stream<List<ExpLedger>> streamExpHistory({int limit = 10}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('exp_ledger')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpLedger.fromFirestore(doc))
            .toList());
  }

  /// Get count of completed quizzes
  Future<int> getCompletedQuizzesCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('exp_ledger')
          .where('userId', isEqualTo: user.uid)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching completed quizzes count: $e');
      return 0;
    }
  }

  /// Get base EXP for a quiz (for UI display)
  int getBaseExpForQuiz(String quizId) {
    return _baseExpMap[quizId] ?? 0;
  }

  /// Get EXP required for a specific level
  int getExpRequiredForLevel(int level) {
    if (level <= 1 || level > 5) return 0;
    
    // Calculate EXP needed to advance from (level-1) to level
    final previousLevelTotal = _levelThresholds[level - 1] ?? 0;
    final currentLevelTotal = _levelThresholds[level] ?? 0;
    
    return currentLevelTotal - previousLevelTotal;
  }

  /// Get current level progress (0.0 to 1.0)
  double getCurrentLevelProgress(int currentExp, int currentLevel) {
    if (currentLevel >= 5) return 1.0; // Max level

    final currentLevelTotal = _levelThresholds[currentLevel] ?? 0;
    final nextLevelTotal = _levelThresholds[currentLevel + 1] ?? 0;
    
    if (nextLevelTotal == currentLevelTotal) return 1.0;

    final expIntoCurrentLevel = currentExp - currentLevelTotal;
    final expNeededForNextLevel = nextLevelTotal - currentLevelTotal;

    if (expNeededForNextLevel == 0) return 1.0;
    
    final progress = expIntoCurrentLevel / expNeededForNextLevel;
    return progress.clamp(0.0, 1.0);
  }

  /// Get EXP remaining until next level
  int getExpRemainingForNextLevel(int currentExp, int currentLevel) {
    if (currentLevel >= 5) return 0; // Max level

    final nextLevelTotal = _levelThresholds[currentLevel + 1] ?? 0;
    final remaining = nextLevelTotal - currentExp;
    
    return remaining > 0 ? remaining : 0;
  }

  /// Get total EXP required for a level (cumulative)
  int getTotalExpForLevel(int level) {
    return _levelThresholds[level] ?? 0;
  }
}

