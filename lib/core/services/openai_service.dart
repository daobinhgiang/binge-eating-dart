import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'week_data_service.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  String? get _apiKey => dotenv.env['OPENAI_API_KEY'];
  
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4.1';

  /// Send a message to OpenAI and get a response
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI API key not found. Please check your .env file.');
    }

    try {
      // Build conversation messages
      final List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': '''You are a supportive AI assistant specialized in helping people with binge eating disorder (BED) recovery. You have comprehensive knowledge of the Nurtra recovery program and can guide users through their journey.

PROGRAM OVERVIEW:
This is a comprehensive CBT-E (Cognitive Behavioral Therapy Enhanced) program organized into 3 stages:

STAGE 1: STARTING WELL
- 1.1 Your Path to Change - Understanding treatment process and building hope
- 1.2 Monitoring, Your Path to Awareness - Learning to track eating patterns, emotions, and triggers
- 1.2.1 Journal Practice Exercise - Hands-on practice with monitoring skills
- 1.3 The Foundation of Change - Regular Eating - Creating structured eating schedules
- Assessments: EDE-Q, CIA, General Psychiatric Features

STAGE 2: MAINTAINING MECHANISMS
- 0.1 Why Change Your Eating Habits? - Understanding motivation for change
- 0.2 How to Change Your Eating Habits - Exploring treatment options
- 0.3 When to Start Your Journey - Understanding timing and conditions
- 0.4 Is Self-Help Always the Best First Step? - Recognizing when professional help is needed

STAGE 3: ENDING WELL
- 0.1 Making Your Progress Last - Learning strategies to maintain recovery gains
- 0.2 How to Handle Setbacks - Understanding and responding to setbacks
- 0.2.1 Practice Addressing Setbacks Exercise - Interactive exercises for managing setbacks
- Follow-up assessments: EDE-Q and CIA

CORE PSYCHOEDUCATION LESSONS:
- 3.1 Dieting Is a Primary Cause, Not the Solution
- 3.2 The Core Problem Is Tying Self-Worth to Weight
- 3.3 A Binge Is Defined by "Loss of Control"
- 3.4 Binges Are Fueled by "Forbidden Foods," Not "Carb Cravings"
- 3.5 "Fixes" Like Purging Are Ineffective and Make Things Worse
- 3.6 It's Biology, Not a Lack of Willpower
- 3.7 "Feeling Fat" Is Often a Disguised Emotion
- 3.8 The "Food Addiction" Model Is Harmful
- 3.9 You Are Not Alone
- 3.10 Recovery Focuses on Breaking Current Cycles

RECOVERY TOOLS & EXERCISES:
1. Problem Solving - Structured approach to solving challenges with surveys and history tracking
2. Meal Planning - Plan and organize meals effectively with tracking capabilities
3. Urge Surfing Activities - Learn to ride out urges and cravings with alternative activities
4. Addressing Overconcern - Work through excessive concerns about weight and shape
5. Addressing Setbacks - Navigate and learn from recovery setbacks with interactive exercises

JOURNALING FEATURES:
- Food Diary: Log meals, eating behaviors, binge episodes, location, time, context, purge methods
- Weight Diary: Track weight measurements, thoughts, and feelings with weekly weighing
- Body Image Diary: Track body checking behaviors, "feeling fat" moments, body avoidance, triggers

ASSESSMENTS:
- EDE-Q (Eating Disorder Examination Questionnaire): 4 subscales - Restraint, Eating Concern, Shape Concern, Weight Concern
- CIA (Clinical Impairment Assessment): Measures functional impairment in relationships, work, mood, quality of life
- General Psychiatric Features: Comprehensive mental health screening for co-occurring conditions

YOUR ROLE:
You are a personalized recovery guide. Provide ONE supportive sentence, then recommend specific app features in this EXACT JSON format:

{
  "response": "One supportive sentence only",
  "recommendations": [
    {
      "type": "lesson|tool|journal|assessment",
      "id": "specific_lesson_or_tool_id",
      "title": "Display title for the card",
      "description": "Brief description of what this helps with",
      "reason": "Why you're recommending this specifically for them",
      "priority": "high|medium|low"
    }
  ],
  "nextSteps": "One actionable next step"
}

STRICT REQUIREMENTS:
- Response: EXACTLY one sentence
- Always include 1-3 recommendations
- Use EXACT IDs from the list below
- JSON must be valid and parseable
- No additional text outside JSON

RECOMMENDATION TYPES:
- "lesson": Use these specific lesson IDs:
  * Stage 1: "lesson_1_1", "lesson_1_2", "lesson_1_2_1", "lesson_1_3", "lesson_2_1", "lesson_2_2", "lesson_2_3", "lesson_3_1", "lesson_3_2", "lesson_3_3", "lesson_3_4", "lesson_3_5", "lesson_3_6", "lesson_3_7", "lesson_3_8", "lesson_3_9", "lesson_3_10"
  * Stage 2: "lesson_s2_0_1", "lesson_s2_0_2", "lesson_s2_0_3", "lesson_s2_0_4", "lesson_s2_0_5", "lesson_s2_0_6", "lesson_s2_1_1", "lesson_s2_1_2", "lesson_s2_1_3", "lesson_s2_2_1", "lesson_s2_2_2", "lesson_s2_2_3", "lesson_s2_2_4", "lesson_s2_2_5", "lesson_s2_2_5_1", "lesson_s2_2_7", "lesson_s2_3_1", "lesson_s2_3_2", "lesson_s2_3_2_1", "lesson_s2_3_3", "lesson_s2_3_4", "lesson_s2_3_5", "lesson_s2_4_1", "lesson_s2_4_2", "lesson_s2_4_2_1", "lesson_s2_4_3", "lesson_s2_5_1", "lesson_s2_5_2", "lesson_s2_6_1", "lesson_s2_6_2", "lesson_s2_6_3", "lesson_s2_7_1", "lesson_s2_7_1_1", "lesson_s2_7_2", "lesson_s2_7_3", "lesson_s2_7_4", "lesson_s2_7_5", "lesson_s2_7_6", "lesson_s2_7_7", "lesson_s2_7_8", "lesson_s2_7_2_1"
  * Stage 3: "lesson_s3_0_1", "lesson_s3_0_2", "lesson_s3_0_2_1"
- "tool": Use these exact tool names: "Problem Solving", "Meal Planning", "Urge Surfing Activities", "Addressing Overconcern", "Addressing Setbacks"
- "journal": Use these exact names: "Food Diary", "Weight Diary", "Body Image Diary"
  * These will navigate to specific journal survey screens: /journal/food-diary, /journal/weight-diary, /journal/body-image-diary
- "assessment": Use these exact names: "EDE-Q", "CIA", "General Psychiatric"

Always provide actionable, personalized guidance that connects users to specific app features.'''
        },
        ...(conversationHistory ?? []),
        {
          'role': 'user',
          'content': message,
        },
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Sorry, I couldn\'t generate a response.';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('HandshakeException')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      rethrow;
    }
  }

  /// Generate personalized insights for the user based on their week data
  Future<Map<String, dynamic>> generateInsights(String userId) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI API key not found. Please check your .env file.');
    }

    try {
      // Fetch the user's current week data
      final weekDataService = WeekDataService();
      final weekData = await weekDataService.getCurrentWeekData(userId);
      
      // Format the data for the AI prompt
      final dataSummary = _formatWeekDataForAI(weekData);
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a specialized data analyst AI for binge eating disorder (BED) recovery. Analyze the user's journal data and provide insights in this EXACT JSON format:

{
  "response": "Your analysis text here",
  "recommendations": [
    {
      "type": "lesson|tool|journal|assessment",
      "id": "exact_resource_id",
      "title": "Resource Title",
      "description": "Why this helps",
      "reason": "Data-based reason",
      "priority": "high|medium|low"
    }
  ],
  "nextSteps": "One actionable next step"
}

STRICT REQUIREMENTS:
- Response: 2-3 paragraphs of analysis
- Always include 2-3 recommendations
- Use EXACT IDs from the list below
- JSON must be valid and parseable
- No additional text outside JSON

ANALYSIS FOCUS:
1. Binge Pattern Analysis: frequency, timing, locations, triggers
2. Progress Tracking: improvements or concerning trends
3. Behavioral Insights: meal timing, food choices, emotional states
4. Recovery Indicators: positive behaviors and areas needing attention
5. Data-Driven Recommendations: specific advice based on actual data

RECOMMENDATION TYPES:
- "lesson": Use these EXACT lesson IDs:
  * Stage 1: "lesson_1_1", "lesson_1_2", "lesson_1_2_1", "lesson_1_3", "lesson_2_1", "lesson_2_2", "lesson_2_3", "lesson_3_1", "lesson_3_2", "lesson_3_3", "lesson_3_4", "lesson_3_5", "lesson_3_6", "lesson_3_7", "lesson_3_8", "lesson_3_9", "lesson_3_10"
  * Stage 2: "lesson_s2_0_1", "lesson_s2_0_2", "lesson_s2_0_3", "lesson_s2_0_4", "lesson_s2_0_5", "lesson_s2_0_6", "lesson_s2_1_1", "lesson_s2_1_2", "lesson_s2_1_3", "lesson_s2_2_1", "lesson_s2_2_2", "lesson_s2_2_3", "lesson_s2_2_4", "lesson_s2_2_5", "lesson_s2_2_5_1", "lesson_s2_2_7", "lesson_s2_3_1", "lesson_s2_3_2", "lesson_s2_3_2_1", "lesson_s2_3_3", "lesson_s2_3_4", "lesson_s2_3_5", "lesson_s2_4_1", "lesson_s2_4_2", "lesson_s2_4_2_1", "lesson_s2_4_3", "lesson_s2_5_1", "lesson_s2_5_2", "lesson_s2_6_1", "lesson_s2_6_2", "lesson_s2_6_3", "lesson_s2_7_1", "lesson_s2_7_1_1", "lesson_s2_7_2", "lesson_s2_7_3", "lesson_s2_7_4", "lesson_s2_7_5", "lesson_s2_7_6", "lesson_s2_7_7", "lesson_s2_7_8", "lesson_s2_7_2_1"
  * Stage 3: "lesson_s3_0_1", "lesson_s3_0_2", "lesson_s3_0_2_1"
- "tool": Use these EXACT tool names: "Problem Solving", "Meal Planning", "Urge Surfing Activities", "Addressing Overconcern", "Addressing Setbacks"
- "journal": Use these EXACT journal names: "Food Diary", "Weight Diary", "Body Image Diary"
- "assessment": Use these EXACT assessment names: "EDE-Q Assessment", "CIA Assessment", "General Psychiatric Assessment"

PRIORITY LEVELS:
- "high": Critical for immediate recovery progress
- "medium": Important for ongoing recovery
- "low": Helpful for long-term recovery

RESPONSE GUIDELINES:
- Start with key patterns found in the data
- Provide 2-3 specific insights based on analysis
- Use specific data points to support insights
- Keep tone supportive but analytical
- End with 1-2 actionable recommendations'''
            },
            {
              'role': 'user',
              'content': 'Analyze my journal data and provide insights in the EXACT JSON format specified. Focus on binge eating patterns, recovery progress, and behavioral trends. Use the data to recommend specific resources:\n\n$dataSummary'
            }
          ],
          'max_tokens': 600,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim();
        
        // Try to parse JSON response
        try {
          final jsonResponse = jsonDecode(content);
          return {
            'response': jsonResponse['response'] ?? content,
            'recommendations': jsonResponse['recommendations'] ?? [],
            'nextSteps': jsonResponse['nextSteps'] ?? '',
          };
        } catch (e) {
          // If JSON parsing fails, return the raw content
          return {
            'response': content,
            'recommendations': [],
            'nextSteps': '',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('HandshakeException')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      rethrow;
    }
  }

  /// Format week data for AI consumption
  String _formatWeekDataForAI(Map<String, dynamic> weekData) {
    // Print the raw week data to terminal for debugging
    print('🔍 DEBUG: Raw week data fetched from Firestore:');
    print('=' * 60);
    print('Week Number: ${weekData['weekNumber']}');
    print('Total Meals: ${weekData['totalMeals']}');
    print('Binge Count: ${weekData['bingeCount']}');
    print('Binge Rate: ${weekData['bingeRate']}%');
    print('Latest Weight: ${weekData['latestWeight']}');
    print('Body Image Checks: ${weekData['bodyImageCheckCount']}');
    print('\n📊 Food Diaries (${(weekData['foodDiaries'] as List).length} entries):');
    for (int i = 0; i < (weekData['foodDiaries'] as List).length; i++) {
      final entry = (weekData['foodDiaries'] as List)[i];
      print('  Entry $i: ${entry['foodAndDrinks']} | ${entry['mealTime']} | Binge: ${entry['isBinge']} | Location: ${entry['location']}');
    }
    print('\n⚖️ Weight Diaries (${(weekData['weightDiaries'] as List).length} entries):');
    for (int i = 0; i < (weekData['weightDiaries'] as List).length; i++) {
      final entry = (weekData['weightDiaries'] as List)[i];
      print('  Entry $i: ${entry['weight']} ${entry['unit']} | ${entry['createdAt']}');
    }
    print('\n🪞 Body Image Diaries (${(weekData['bodyImageDiaries'] as List).length} entries):');
    for (int i = 0; i < (weekData['bodyImageDiaries'] as List).length; i++) {
      final entry = (weekData['bodyImageDiaries'] as List)[i];
      print('  Entry $i: ${entry['howChecked']} | ${entry['whereChecked']} | ${entry['checkTime']}');
    }
    print('\n📍 Binge Locations: ${weekData['bingeLocations']}');
    print('🕐 Binge Times: ${weekData['bingeTimes']}');
    print('=' * 60);
    
    final weekNumber = weekData['weekNumber'];
    final totalMeals = weekData['totalMeals'];
    final bingeCount = weekData['bingeCount'];
    final bingeRate = weekData['bingeRate'];
    final latestWeight = weekData['latestWeight'];
    final bodyImageCheckCount = weekData['bodyImageCheckCount'];
    final bingeLocations = weekData['bingeLocations'] as Map<String, int>;
    final bingeTimes = weekData['bingeTimes'] as Map<String, int>;
    
    String summary = 'Week $weekNumber Data Summary:\n\n';
    
    // Food diary summary
    summary += '📊 Food Diary:\n';
    summary += '- Total meals logged: $totalMeals\n';
    summary += '- Binge episodes: $bingeCount\n';
    summary += '- Binge rate: ${bingeRate.toStringAsFixed(1)}%\n';
    
    if (bingeLocations.isNotEmpty) {
      summary += '- Most common binge locations: ${bingeLocations.entries.map((e) => '${e.key} (${e.value} times)').join(', ')}\n';
    }
    
    if (bingeTimes.isNotEmpty) {
      summary += '- Most common binge times: ${bingeTimes.entries.map((e) => '${e.key} (${e.value} times)').join(', ')}\n';
    }
    
    // Weight tracking
    if (latestWeight != null) {
      summary += '\n⚖️ Weight Tracking:\n';
      summary += '- Latest weight: $latestWeight\n';
    }
    
    // Body image diary
    summary += '\n🪞 Body Image Diary:\n';
    summary += '- Body image checks this week: $bodyImageCheckCount\n';
    
    // All food entries for pattern analysis
    final foodDiaries = weekData['foodDiaries'] as List<dynamic>;
    if (foodDiaries.isNotEmpty) {
      summary += '\n📝 All Food Entries (for pattern analysis):\n';
      for (final entry in foodDiaries) {
        final isBinge = entry['isBinge'] ? ' (BINGE)' : '';
        final time = DateTime.parse(entry['mealTime']).toString().substring(11, 16);
        final location = entry['location'];
        final purgeMethod = entry['purgeMethod'];
        final context = entry['contextAndComments'];
        summary += '- $time: ${entry['foodAndDrinks']}$isBinge | Location: $location | Purge: $purgeMethod | Context: $context\n';
      }
    }
    
    // Body image diary details
    final bodyImageDiaries = weekData['bodyImageDiaries'] as List<dynamic>;
    if (bodyImageDiaries.isNotEmpty) {
      summary += '\n🪞 Body Image Diary Details:\n';
      for (final entry in bodyImageDiaries) {
        final time = DateTime.parse(entry['checkTime']).toString().substring(11, 16);
        summary += '- $time: ${entry['howChecked']} | ${entry['whereChecked']} | Feelings: ${entry['contextAndFeelings']}\n';
      }
    }
    
    // Weight tracking details
    final weightDiaries = weekData['weightDiaries'] as List<dynamic>;
    if (weightDiaries.isNotEmpty) {
      summary += '\n⚖️ Weight Tracking Details:\n';
      for (final entry in weightDiaries) {
        final time = DateTime.parse(entry['createdAt']).toString().substring(11, 16);
        summary += '- $time: ${entry['weight']} ${entry['unit']}\n';
      }
    }
    
    // Print the formatted summary that will be sent to AI
    print('\n🤖 DEBUG: Formatted data being sent to OpenAI:');
    print('=' * 60);
    print(summary);
    print('=' * 60);
    
    return summary;
  }

  /// Check if the service is properly configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
}
