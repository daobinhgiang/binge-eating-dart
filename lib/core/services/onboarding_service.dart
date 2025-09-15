import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/onboarding_data.dart';
import '../../models/onboarding_answer.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save onboarding data to Firestore
  Future<void> saveOnboardingData(OnboardingData onboardingData) async {
    try {
      await _firestore
          .collection('onboarding')
          .doc(onboardingData.userId)
          .set(onboardingData.toMap());
    } catch (e) {
      throw 'Failed to save onboarding data: $e';
    }
  }

  // Get onboarding data for a user
  Future<OnboardingData?> getOnboardingData(String userId) async {
    try {
      final doc = await _firestore
          .collection('onboarding')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return OnboardingData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to get onboarding data: $e';
    }
  }

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final onboardingData = await getOnboardingData(userId);
      return onboardingData?.isComplete ?? false;
    } catch (e) {
      return false;
    }
  }

  // Save a single answer (for progressive saving)
  Future<void> saveAnswer(String userId, OnboardingAnswer answer) async {
    try {
      final docRef = _firestore.collection('onboarding').doc(userId);
      
      await docRef.set({
        'userId': userId,
        'answers': FieldValue.arrayUnion([answer.toMap()]),
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save answer: $e';
    }
  }

  // Update total score when onboarding is completed
  Future<void> completeOnboarding(String userId, int totalScore) async {
    try {
      await _firestore
          .collection('onboarding')
          .doc(userId)
          .update({
        'totalScore': totalScore,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to complete onboarding: $e';
    }
  }
}
