import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/regular_eating.dart';

class RegularEatingService {
  static final RegularEatingService _instance = RegularEatingService._internal();
  factory RegularEatingService() => _instance;
  RegularEatingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'Regular Eating';

  // Get user's regular eating settings
  Future<RegularEating?> getUserRegularEatingSettings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return RegularEating.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw 'Failed to get regular eating settings: $e';
    }
  }

  // Create or update regular eating settings
  Future<RegularEating> saveRegularEatingSettings({
    required String userId,
    required double mealIntervalHours,
    required int firstMealHour,
    required int firstMealMinute,
    required int mealCount,
    String? existingId,
  }) async {
    try {
      final now = DateTime.now();
      
      // Create temporary settings to generate meal times
      final tempSettings = RegularEating(
        id: existingId ?? '',
        userId: userId,
        mealIntervalHours: mealIntervalHours,
        firstMealHour: firstMealHour,
        firstMealMinute: firstMealMinute,
        mealCount: mealCount,
        mealTimes: <String>[],
        createdAt: existingId != null ? await _getCreatedAt(userId, existingId) : now,
        updatedAt: now,
      );
      
      // Generate meal times based on settings
      final generatedMealTimes = tempSettings.generateMealTimes();
      
      final regularEating = tempSettings.copyWith(mealTimes: generatedMealTimes);

      DocumentReference docRef;
      if (existingId != null) {
        // Update existing
        docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection(_collectionName)
            .doc(existingId);
        
        await docRef.update(regularEating.toFirestore());
      } else {
        // Create new
        docRef = await _firestore
            .collection('users')
            .doc(userId)
            .collection(_collectionName)
            .add(regularEating.toFirestore());
      }

      final savedRegularEating = regularEating.copyWith(id: docRef.id);
      
      
      return savedRegularEating;
    } catch (e) {
      throw 'Failed to save regular eating settings: $e';
    }
  }

  // Helper method to get created date for existing document
  Future<DateTime> _getCreatedAt(String userId, String settingsId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .doc(settingsId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  // Delete regular eating settings
  Future<void> deleteRegularEatingSettings(String userId, String settingsId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .doc(settingsId)
          .delete();
      
    } catch (e) {
      throw 'Failed to delete regular eating settings: $e';
    }
  }

  // Get all regular eating settings history for a user
  Future<List<RegularEating>> getRegularEatingHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RegularEating.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get regular eating history: $e';
    }
  }

}
