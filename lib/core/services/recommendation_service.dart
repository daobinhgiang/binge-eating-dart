import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';
import '../../models/onboarding_answer.dart';
import './openai_service.dart';
import './app_content_service.dart';
import './todo_service.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final OpenAIService _openAiService = OpenAIService();
  final AppContentService _appContentService = AppContentService();
  final TodoService _todoService = TodoService();

  // Generate personalized recommendations based on onboarding answers
  Future<List<TodoItem>> generateRecommendationsFromOnboarding(
    String userId,
    List<OnboardingAnswer> answers,
  ) async {
    try {
      // Prepare survey answers for the OpenAI API
      final answersFormatted = answers.map((answer) => {
        'question': answer.question,
        'answer': answer.selectedText,
        'questionNumber': answer.questionNumber,
      }).toList();
      
      // Clear cache to ensure we get updated chapter-based content
      _appContentService.clearCache();
      
      // Get app content for context
      final appContentContext = await _appContentService.getAppContentContext();
      
      // Call OpenAI API to get recommendations
      final recommendations = await _openAiService.getRecommendations(
        userAnswers: answersFormatted,
        appContentContext: appContentContext,
      );
      
      // Check if recommendations were successfully retrieved
      if (!recommendations.containsKey('recommendations') || 
          recommendations['recommendations'] == null ||
          recommendations['recommendations'] is! List) {
        throw 'Invalid recommendations format received from OpenAI';
      }
      
      // Create todo items from recommendations
      final todoItems = <TodoItem>[];
      final now = DateTime.now();
      
      for (final recommendation in recommendations['recommendations']) {
        // Validate recommendation format
        if (!_isValidRecommendation(recommendation)) {
          continue;
        }
        
        // Parse recommendation type
        final TodoType todoType = _parseTodoType(recommendation['type']);
        
        // Parse due date with fallback to 7 days from now
        final DateTime dueDate = _parseDueDate(recommendation['dueDate']) ?? 
            now.add(const Duration(days: 7));
        
        // Create and save todo item
        final todoItem = await _todoService.createTodo(
          userId: userId,
          title: recommendation['title'],
          description: recommendation['description'],
          type: todoType,
          activityId: recommendation['id'],
          activityData: {
            'source': 'ai_recommendation',
            'recommendedAt': Timestamp.fromDate(now),
          },
          dueDate: dueDate,
        );
        
        todoItems.add(todoItem);
      }
      
      return todoItems;
    } catch (e) {
      throw 'Failed to generate recommendations: $e';
    }
  }

  // Generate personalized recommendations based on analytics insights and patterns
  Future<List<TodoItem>> generateRecommendationsFromAnalytics(
    String userId,
    Map<String, dynamic> analysis,
  ) async {
    try {
      // Extract insights and patterns from analysis
      final insights = (analysis['insights'] as List?)?.cast<String>() ?? [];
      final patterns = (analysis['patterns'] as List?)?.cast<String>() ?? [];
      final recommendations = (analysis['recommendations'] as List?)?.cast<String>() ?? [];
      final analysisText = analysis['analysis'] as String? ?? '';
      final weekNumber = analysis['weekNumber'] as int? ?? 1;
      
      // Check if we have enough data to generate meaningful recommendations
      if (insights.isEmpty && patterns.isEmpty && analysisText.isEmpty) {
        throw 'Insufficient analytics data to generate recommendations';
      }
      
      // Prepare analytics data for the OpenAI API
      final analyticsFormatted = {
        'weekNumber': weekNumber,
        'analysisOverview': analysisText,
        'insights': insights,
        'patterns': patterns,
        'existingRecommendations': recommendations,
        'entriesAnalyzed': analysis['entriesAnalyzed'] ?? 0,
      };
      
      // Clear cache to ensure we get updated chapter-based content
      _appContentService.clearCache();
      
      // Get app content for context
      final appContentContext = await _appContentService.getAppContentContext();
      
      // Call OpenAI API to get lesson and exercise recommendations
      final aiRecommendations = await _openAiService.getRecommendationsFromAnalytics(
        analyticsData: analyticsFormatted,
        appContentContext: appContentContext,
      );
      
      // Check if recommendations were successfully retrieved
      if (!aiRecommendations.containsKey('recommendations') || 
          aiRecommendations['recommendations'] == null ||
          aiRecommendations['recommendations'] is! List) {
        throw 'Invalid recommendations format received from OpenAI';
      }
      
      // Create todo items from recommendations
      final todoItems = <TodoItem>[];
      final now = DateTime.now();
      
      for (final recommendation in aiRecommendations['recommendations']) {
        
        if (!_isValidRecommendation(recommendation)) {
          continue;
        }
        
        // Parse recommendation type
        final TodoType todoType = _parseTodoType(recommendation['type']);
        
        // Parse due date with fallback to 3 days from now (shorter than onboarding)
        final DateTime dueDate = _parseDueDate(recommendation['dueDate']) ?? 
            now.add(const Duration(days: 3));
        
        // Create and save todo item
        final todoItem = await _todoService.createTodo(
          userId: userId,
          title: recommendation['title'],
          description: recommendation['description'],
          type: todoType,
          activityId: recommendation['id'],
          activityData: {
            'source': 'analytics_recommendation',
            'weekNumber': weekNumber,
            'recommendedAt': Timestamp.fromDate(now),
            'basedOnInsights': insights,
            'basedOnPatterns': patterns,
          },
          dueDate: dueDate,
        );
        
        todoItems.add(todoItem);
      }
      
      return todoItems;
    } catch (e) {
      throw 'Failed to generate analytics-based recommendations: $e';
    }
  }
  
  // Helper to validate recommendation format
  bool _isValidRecommendation(dynamic recommendation) {
    return recommendation is Map &&
        recommendation.containsKey('type') &&
        recommendation.containsKey('id') &&
        recommendation.containsKey('title') &&
        recommendation.containsKey('description');
  }
  
  // Helper to parse todo type from string
  TodoType _parseTodoType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'tool':
      case 'exercise': // Treat exercises as tools since they're interactive activities
        return TodoType.tool;
      case 'journal':
        return TodoType.journal;
      case 'lesson':
      default:
        return TodoType.lesson;
    }
  }
  
  // Helper to parse due date from string
  DateTime? _parseDueDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return null;
    }
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
