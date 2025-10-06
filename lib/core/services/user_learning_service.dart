import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLearningService {
  static final UserLearningService _instance = UserLearningService._internal();
  factory UserLearningService() => _instance;
  UserLearningService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveLastLesson(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'lastLessonId': lessonId,
        'lastLessonUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Intentionally swallow to avoid UX interruption
    }
  }

  Stream<String?> lastLessonStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      return data != null ? data['lastLessonId'] as String? : null;
    });
  }
}


