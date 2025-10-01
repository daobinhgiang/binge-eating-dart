import 'package:cloud_firestore/cloud_firestore.dart';
// OpenAI and AI-based recommendation services removed
import '../../models/food_diary.dart';
import '../../models/weight_diary.dart';
import '../../models/body_image_diary.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // AI services removed

  // Get the most recent week number for a user
  Future<int> getMostRecentWeekNumber(String userId) async {
    try {
      final weeksQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .get();

      if (weeksQuery.docs.isEmpty) {
        return 1; // Default to week 1 if no weeks exist
      }

      // Extract week numbers and find the maximum
      int maxWeekNumber = 1;
      for (final doc in weeksQuery.docs) {
        final weekNumber = int.tryParse(doc.id.replaceFirst('week_', '')) ?? 1;
        if (weekNumber > maxWeekNumber) {
          maxWeekNumber = weekNumber;
        }
      }
      
      return maxWeekNumber;
    } catch (e) {
      throw 'Failed to get most recent week number: $e';
    }
  }

  // Get all journal data for a specific week
  Future<Map<String, dynamic>> getWeekJournalData(String userId, int weekNumber) async {
    try {
      final weekDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber');

      // Get all food diary entries (without orderBy to avoid index issues)
      final foodDiariesQuery = await weekDocRef
          .collection('foodDiaries')
          .get();

      // Get all weight diary entries (without orderBy to avoid index issues)
      final weightDiariesQuery = await weekDocRef
          .collection('weightDiaries')
          .get();

      // Get all body image diary entries (without orderBy to avoid index issues)
      final bodyImageDiariesQuery = await weekDocRef
          .collection('bodyImageDiaries')
          .get();

      // Parse data and sort manually to avoid index issues
      final foodDiaries = foodDiariesQuery.docs
          .map((doc) => FoodDiary.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.mealTime.compareTo(b.mealTime));

      final weightDiaries = weightDiariesQuery.docs
          .map((doc) => WeightDiary.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final bodyImageDiaries = bodyImageDiariesQuery.docs
          .map((doc) => BodyImageDiary.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.checkTime.compareTo(b.checkTime));

      return {
        'weekNumber': weekNumber,
        'foodDiaries': foodDiaries,
        'weightDiaries': weightDiaries,
        'bodyImageDiaries': bodyImageDiaries,
        'totalEntries': foodDiaries.length + weightDiaries.length + bodyImageDiaries.length,
      };
    } catch (e) {
      throw 'Failed to get week journal data: $e';
    }
  }

  // Generate a simple local analysis without AI
  Future<Map<String, dynamic>> generateJournalAnalysis(String userId) async {
    try {
      // Get the most recent week number
      final mostRecentWeek = await getMostRecentWeekNumber(userId);
      
      // Get all journal data for the most recent week
      final weekData = await getWeekJournalData(userId, mostRecentWeek);
      
      // Check if there's enough data to analyze
      if (weekData['totalEntries'] == 0) {
        return {
          'analysis': 'No journal entries found for analysis. Please add some food diary, weight diary, or body image diary entries to generate insights.',
          'insights': [],
          'patterns': [],
          'recommendations': [],
          'weekNumber': mostRecentWeek,
          'generatedAt': DateTime.now().toIso8601String(),
        };
      }

      // Build basic heuristic analysis locally
      final localAnalysis = _buildLocalAnalysis(weekData);
      localAnalysis['weekNumber'] = mostRecentWeek;
      localAnalysis['generatedAt'] = DateTime.now().toIso8601String();
      localAnalysis['entriesAnalyzed'] = weekData['totalEntries'];
      return localAnalysis;
    } catch (e) {
      throw 'Failed to generate journal analysis: $e';
    }
  }

  // Generate analysis only (AI recommendations removed)
  Future<Map<String, dynamic>> generateJournalAnalysisWithRecommendations(String userId) async {
    try {
      // First generate the regular analysis
      final analysis = await generateJournalAnalysis(userId);
      
      // Recommendations removed; only analysis is returned
      analysis['recommendedTodos'] = 0;
      analysis['todosGenerated'] = false;
      
      return analysis;
    } catch (e) {
      throw 'Failed to generate journal analysis with recommendations: $e';
    }
  }

  // Build a simple local analysis based on available journal data
  Map<String, dynamic> _buildLocalAnalysis(Map<String, dynamic> weekData) {
    final foodDiaries = weekData['foodDiaries'] as List<FoodDiary>;
    final weightDiaries = weekData['weightDiaries'] as List<WeightDiary>;
    final bodyImageDiaries = weekData['bodyImageDiaries'] as List<BodyImageDiary>;

    final insights = <String>[];
    final patterns = <String>[];
    final recommendations = <String>[];

    // Basic insights
    if (foodDiaries.isNotEmpty) {
      final bingeCount = foodDiaries.where((e) => e.isBinge).length;
      insights.add('Logged ${foodDiaries.length} meals; ${bingeCount} marked as binge episodes.');
      if (bingeCount > 0) {
        recommendations.add('Review coping tools such as Urge Surfing when urges arise.');
      }
    } else {
      insights.add('No food diary entries this week. Adding entries improves insights.');
      recommendations.add('Try logging a few meals next week to spot patterns.');
    }

    if (weightDiaries.isNotEmpty) {
      final first = weightDiaries.first.weight;
      final last = weightDiaries.last.weight;
      final delta = (last - first).toStringAsFixed(1);
      patterns.add('Weight changed ${delta} ${weightDiaries.first.unit} across the week.');
    }

    if (bodyImageDiaries.isNotEmpty) {
      insights.add('You reflected on body image ${bodyImageDiaries.length} times this week.');
      recommendations.add('Consider scheduling supportive activities on challenging days.');
    }

    final analysisText = insights.isEmpty
        ? 'No sufficient data to analyze this week.'
        : 'Here is a brief overview based on your recent entries.';

    return {
      'analysis': analysisText,
      'insights': insights,
      'patterns': patterns,
      'recommendations': recommendations,
    };
  }

  // Store analysis in Firestore for caching
  Future<void> storeAnalysis(String userId, Map<String, dynamic> analysis) async {
    try {
      final weekNumber = analysis['weekNumber'] as int;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('analytics')
          .doc('latest_analysis')
          .set({
        ...analysis,
        'storedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to store analysis: $e';
    }
  }

  // Get latest stored analysis
  Future<Map<String, dynamic>?> getLatestAnalysis(String userId) async {
    try {
      // Get the most recent week number first
      final mostRecentWeek = await getMostRecentWeekNumber(userId);
      
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$mostRecentWeek')
          .collection('analytics')
          .doc('latest_analysis')
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      
      // Check if analysis is recent (within 24 hours)
      final storedAt = data['storedAt'] as Timestamp?;
      if (storedAt != null) {
        final storedTime = storedAt.toDate();
        final now = DateTime.now();
        final difference = now.difference(storedTime).inHours;
        
        // Return cached analysis if it's less than 24 hours old
        if (difference < 24) {
          return data;
        }
      }

      return null; // Analysis is too old
    } catch (e) {
      throw 'Failed to get latest analysis: $e';
    }
  }

  // Get historical analytics for all weeks
  Future<Map<int, Map<String, dynamic>>> getAllAnalytics(String userId) async {
    try {
      final weeksQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .get();

      final Map<int, Map<String, dynamic>> allAnalytics = {};

      for (final weekDoc in weeksQuery.docs) {
        final weekNumber = int.tryParse(weekDoc.id.replaceFirst('week_', ''));
        if (weekNumber == null) continue;

        final analyticsDoc = await weekDoc.reference
            .collection('analytics')
            .doc('latest_analysis')
            .get();

        if (analyticsDoc.exists) {
          final data = analyticsDoc.data() as Map<String, dynamic>;
          allAnalytics[weekNumber] = data;
        }
      }

      return allAnalytics;
    } catch (e) {
      throw 'Failed to get all analytics: $e';
    }
  }

  // Delete old analytics (cleanup method)
  Future<void> deleteAnalyticsForWeek(String userId, int weekNumber) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeks')
          .doc('week_$weekNumber')
          .collection('analytics')
          .doc('latest_analysis')
          .delete();
    } catch (e) {
      throw 'Failed to delete analytics for week $weekNumber: $e';
    }
  }
}
