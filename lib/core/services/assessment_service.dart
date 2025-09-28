import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/assessment_response.dart';

class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save assessment responses to Firestore
  Future<bool> saveAssessmentResponses(String lessonId, List<AssessmentResponse> responses) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final batch = _firestore.batch();
      
      // Create a document for this assessment completion
      final assessmentDocRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .doc(lessonId);

      // Save the assessment completion data
      batch.set(assessmentDocRef, {
        'lessonId': lessonId,
        'completedAt': FieldValue.serverTimestamp(),
        'isCompleted': true,
        'userId': user.uid,
      });

      // Save individual responses
      for (final response in responses) {
        final responseDocRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('assessments')
            .doc(lessonId)
            .collection('responses')
            .doc(response.id);

        batch.set(responseDocRef, response.toMap());
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error saving assessment responses: $e');
      return false;
    }
  }

  // Get assessment responses for a specific lesson
  Future<List<AssessmentResponse>> getAssessmentResponses(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .doc(lessonId)
          .collection('responses')
          .get();

      return querySnapshot.docs
          .map((doc) => AssessmentResponse.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting assessment responses: $e');
      return [];
    }
  }

  // Check if assessment is completed
  Future<bool> isAssessmentCompleted(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .doc(lessonId)
          .get();

      return doc.exists && (doc.data()?['isCompleted'] ?? false);
    } catch (e) {
      print('Error checking assessment completion: $e');
      return false;
    }
  }

  // Get assessment completion date
  Future<DateTime?> getAssessmentCompletionDate(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .doc(lessonId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data?['completedAt'] != null) {
          return (data!['completedAt'] as Timestamp).toDate();
        }
      }
      return null;
    } catch (e) {
      print('Error getting assessment completion date: $e');
      return null;
    }
  }

  // Delete assessment responses (if user wants to retake)
  Future<bool> deleteAssessmentResponses(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final batch = _firestore.batch();
      
      // Delete the main assessment document
      final assessmentDocRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .doc(lessonId);
      
      batch.delete(assessmentDocRef);

      // Delete all response documents
      final responsesQuery = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .doc(lessonId)
          .collection('responses')
          .get();

      for (final doc in responsesQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting assessment responses: $e');
      return false;
    }
  }
}
