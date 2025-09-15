import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ema_survey.dart';

class EMASurveyService {
  static final EMASurveyService _instance = EMASurveyService._internal();
  factory EMASurveyService() => _instance;
  EMASurveyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new EMA survey for today
  Future<EMASurvey> createTodaySurvey(String userId) async {
    try {
      final today = DateTime.now();
      final surveyDate = DateTime(today.year, today.month, today.day);
      
      // Check if survey already exists for today
      final existingSurvey = await getTodaySurvey(userId);
      if (existingSurvey != null) {
        return existingSurvey;
      }

      final survey = EMASurvey(
        id: '', // Will be set by Firestore
        userId: userId,
        createdAt: DateTime.now(),
        surveyDate: surveyDate,
      );

      final docRef = await _firestore
          .collection('ema_surveys')
          .add(survey.toFirestore());
      
      return survey.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to create EMA survey: $e';
    }
  }

  // Get today's survey for a user
  Future<EMASurvey?> getTodaySurvey(String userId) async {
    try {
      final today = DateTime.now();
      final surveyDate = DateTime(today.year, today.month, today.day);
      
      final querySnapshot = await _firestore
          .collection('ema_surveys')
          .where('userId', isEqualTo: userId)
          .where('surveyDate', isEqualTo: surveyDate.millisecondsSinceEpoch)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return EMASurvey.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Failed to get today\'s EMA survey: $e';
    }
  }

  // Get all surveys for a user
  Future<List<EMASurvey>> getUserSurveys(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ema_surveys')
          .where('userId', isEqualTo: userId)
          .orderBy('surveyDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EMASurvey.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get user surveys: $e';
    }
  }

  // Save an answer to a survey
  Future<void> saveAnswer(String surveyId, EMASurveyAnswer answer) async {
    try {
      final surveyRef = _firestore.collection('ema_surveys').doc(surveyId);
      
      // Get current survey
      final surveyDoc = await surveyRef.get();
      if (!surveyDoc.exists) {
        throw 'Survey not found';
      }

      final survey = EMASurvey.fromFirestore(surveyDoc);
      final updatedAnswers = List<EMASurveyAnswer>.from(survey.answers);
      
      // Remove existing answer for this question if it exists
      updatedAnswers.removeWhere((a) => a.questionId == answer.questionId);
      
      // Add new answer
      updatedAnswers.add(answer);
      
      // Update survey
      await surveyRef.update({
        'answers': updatedAnswers.map((a) => a.toMap()).toList(),
        'isCompleted': updatedAnswers.length >= 11,
        'completedAt': updatedAnswers.length >= 11 
            ? DateTime.now().millisecondsSinceEpoch 
            : null,
      });
    } catch (e) {
      throw 'Failed to save answer: $e';
    }
  }

  // Complete a survey
  Future<void> completeSurvey(String surveyId) async {
    try {
      await _firestore.collection('ema_surveys').doc(surveyId).update({
        'isCompleted': true,
        'completedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to complete survey: $e';
    }
  }

  // Delete a survey
  Future<void> deleteSurvey(String surveyId) async {
    try {
      await _firestore.collection('ema_surveys').doc(surveyId).delete();
    } catch (e) {
      throw 'Failed to delete survey: $e';
    }
  }

  // Get survey by ID
  Future<EMASurvey?> getSurveyById(String surveyId) async {
    try {
      final doc = await _firestore.collection('ema_surveys').doc(surveyId).get();
      if (doc.exists) {
        return EMASurvey.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get survey: $e';
    }
  }

  // Stream of user's surveys
  Stream<List<EMASurvey>> getUserSurveysStream(String userId) {
    return _firestore
        .collection('ema_surveys')
        .where('userId', isEqualTo: userId)
        .orderBy('surveyDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EMASurvey.fromFirestore(doc))
            .toList());
  }

  // Stream of today's survey
  Stream<EMASurvey?> getTodaySurveyStream(String userId) {
    final today = DateTime.now();
    final surveyDate = DateTime(today.year, today.month, today.day);
    
    return _firestore
        .collection('ema_surveys')
        .where('userId', isEqualTo: userId)
        .where('surveyDate', isEqualTo: surveyDate.millisecondsSinceEpoch)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return EMASurvey.fromFirestore(snapshot.docs.first);
          }
          return null;
        });
  }
}
