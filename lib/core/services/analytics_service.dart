import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/openai_service.dart';
import '../services/recommendation_service.dart';
import '../../models/food_diary.dart';
import '../../models/weight_diary.dart';
import '../../models/body_image_diary.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OpenAIService _openAIService = OpenAIService();
  final RecommendationService _recommendationService = RecommendationService();

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

  // Generate analysis using OpenAI
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

      // Prepare context for OpenAI
      final analysisContext = _prepareAnalysisContext(weekData);
      
      // Call OpenAI for analysis
      final openAIResponse = await _callOpenAIForAnalysis(analysisContext);
      
      // Add metadata
      openAIResponse['weekNumber'] = mostRecentWeek;
      openAIResponse['generatedAt'] = DateTime.now().toIso8601String();
      openAIResponse['entriesAnalyzed'] = weekData['totalEntries'];
      
      return openAIResponse;
    } catch (e) {
      throw 'Failed to generate journal analysis: $e';
    }
  }

  // Generate analysis and add AI-recommended todo items
  Future<Map<String, dynamic>> generateJournalAnalysisWithRecommendations(String userId) async {
    try {
      // First generate the regular analysis
      final analysis = await generateJournalAnalysis(userId);
      
      // If analysis contains useful insights and patterns, generate recommendations
      if (analysis['insights'] != null && 
          analysis['patterns'] != null &&
          (analysis['insights'] as List).isNotEmpty &&
          analysis['entriesAnalyzed'] != null &&
          analysis['entriesAnalyzed'] > 0) {
        
        try {
          // Generate AI recommendations based on the analysis
          final recommendedTodos = await _recommendationService.generateRecommendationsFromAnalytics(
            userId,
            analysis,
          );
          
          // Add information about generated recommendations to the analysis
          analysis['recommendedTodos'] = recommendedTodos.length;
          analysis['todosGenerated'] = true;
        } catch (recommendationError) {
          // If recommendations fail, still return the analysis without todos
          analysis['recommendedTodos'] = 0;
          analysis['todosGenerated'] = false;
          analysis['recommendationError'] = recommendationError.toString();
        }
      } else {
        analysis['recommendedTodos'] = 0;
        analysis['todosGenerated'] = false;
      }
      
      return analysis;
    } catch (e) {
      throw 'Failed to generate journal analysis with recommendations: $e';
    }
  }

  // Prepare context for OpenAI analysis
  String _prepareAnalysisContext(Map<String, dynamic> weekData) {
    final foodDiaries = weekData['foodDiaries'] as List<FoodDiary>;
    final weightDiaries = weekData['weightDiaries'] as List<WeightDiary>;
    final bodyImageDiaries = weekData['bodyImageDiaries'] as List<BodyImageDiary>;
    final weekNumber = weekData['weekNumber'];

    final buffer = StringBuffer();
    buffer.writeln('Journal Data Analysis for Week $weekNumber:');
    buffer.writeln();

    // Food diary analysis
    if (foodDiaries.isNotEmpty) {
      buffer.writeln('FOOD DIARY ENTRIES (${foodDiaries.length} entries):');
      for (final entry in foodDiaries) {
        buffer.writeln('- Date/Time: ${entry.mealTime}');
        buffer.writeln('  Food: ${entry.foodAndDrinks}');
        buffer.writeln('  Location: ${entry.displayLocation}');
        buffer.writeln('  Binge Episode: ${entry.isBinge ? "Yes" : "No"}');
        if (entry.purgeMethod != 'none') {
          buffer.writeln('  Purge Method: ${entry.purgeMethod}');
        }
        buffer.writeln('  Context: ${entry.contextAndComments}');
        buffer.writeln();
      }
    }

    // Weight diary analysis
    if (weightDiaries.isNotEmpty) {
      buffer.writeln('WEIGHT DIARY ENTRIES (${weightDiaries.length} entries):');
      for (final entry in weightDiaries) {
        buffer.writeln('- Date: ${entry.createdAt}');
        buffer.writeln('  Weight: ${entry.weight} ${entry.unit}');
        buffer.writeln();
      }
    }

    // Body image diary analysis
    if (bodyImageDiaries.isNotEmpty) {
      buffer.writeln('BODY IMAGE DIARY ENTRIES (${bodyImageDiaries.length} entries):');
      for (final entry in bodyImageDiaries) {
        buffer.writeln('- Date/Time: ${entry.checkTime}');
        buffer.writeln('  How Checked: ${entry.displayHowChecked}');
        buffer.writeln('  Where Checked: ${entry.displayWhereChecked}');
        buffer.writeln('  Context & Feelings: ${entry.contextAndFeelings}');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  // Call OpenAI for analysis
  Future<Map<String, dynamic>> _callOpenAIForAnalysis(String context) async {
    try {
      final prompt = """
Analyze the following journal data from a user with binge eating disorder. Please provide a comprehensive analysis that includes:

1. Key insights about eating patterns, behaviors, and triggers
2. Patterns or trends you notice in the data
3. Recommendations for improvement based on the data
4. Overall progress assessment

$context

Please return your analysis in the following JSON format:
{
  "analysis": "A comprehensive overview of the user's week in 2-3 paragraphs",
  "insights": [
    "Key insight 1",
    "Key insight 2", 
    "Key insight 3"
  ],
  "patterns": [
    "Pattern or trend 1",
    "Pattern or trend 2"
  ],
  "recommendations": [
    "Specific recommendation 1",
    "Specific recommendation 2",
    "Specific recommendation 3"
  ]
}

Focus on being:
- Supportive and non-judgmental
- Specific to the data provided
- Constructive in recommendations
- Encouraging about progress made
- Professional but empathetic
""";

      // Use OpenAI service to get analysis
      final response = await _openAIService.getAnalysis(prompt);
      return response;
    } catch (e) {
      throw 'Failed to get analysis from OpenAI: $e';
    }
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
