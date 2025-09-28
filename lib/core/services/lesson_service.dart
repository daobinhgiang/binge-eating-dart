import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mark lesson as completed (for Stage system lessons)
  Future<void> markLessonCompleted(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('user_progress')
          .doc(user.uid)
          .collection('completed_lessons')
          .doc(lessonId)
          .set({
        'lessonId': lessonId,
        'completedAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });
    } catch (e) {
      print('Error marking lesson as completed: $e');
    }
  }

  // Check if lesson is unlocked (for Stage system lessons)
  Future<bool> isLessonUnlocked(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // For now, all Stage 1, 2, and 3 lessons are unlocked
      // This can be expanded later with proper unlock logic
      if (lessonId.startsWith('lesson_1_') || lessonId.startsWith('lesson_2_') || lessonId.startsWith('lesson_3_') || 
          lessonId.startsWith('lesson_s2_') || lessonId.startsWith('lesson_s3_')) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking lesson unlock status: $e');
      return false;
    }
  }

  // Get completed lessons for user
  Future<Set<String>> getCompletedLessons() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(user.uid)
          .collection('completed_lessons')
          .get();

      return snapshot.docs.map((doc) => doc.data()['lessonId'] as String).toSet();
    } catch (e) {
      print('Error getting completed lessons: $e');
      return {};
    }
  }
}
