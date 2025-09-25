import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  // OpenAI API key - loaded from environment variables
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  String get _endpoint => dotenv.env['OPENAI_API_ENDPOINT'] ?? 'https://api.openai.com/v1/chat/completions';

  // Method to call OpenAI API for recommendations based on onboarding answers
  Future<Map<String, dynamic>> getRecommendations({
    required List<Map<String, dynamic>> userAnswers,
    required String appContentContext,
  }) async {
    try {
      // Prepare headers for API request
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      // Prepare the prompt to send to OpenAI
      final String prompt = """
Based on the following user survey responses:
${jsonEncode(userAnswers)}

And considering the available lessons, tools, and exercises in the app:
$appContentContext

Please provide a personalized list of recommended lessons, tools, and exercises for this user. 

IMPORTANT INSTRUCTIONS:
- FOR LESSONS: Only recommend the FIRST LESSON from relevant chapters that match the user's needs. Find the most relevant chapters based on their survey responses, then recommend the first lesson from those chapters using the "First Lesson ID" provided.
- Provide a mix of lessons, tools, and exercises (not just lessons)
- Tools and exercises are interactive activities that help users practice recovery skills
- Include at least 2-3 tools/exercises in your recommendations
- Consider the user's specific challenges from their survey responses
- Recommend tools that directly address their reported difficulties

Return the response in the following strict JSON format:
{
  "recommendations": [
    {
      "type": "lesson", 
      "id": "lesson_1_1", 
      "title": "Start Chapter 1: Introduction to Binge Eating Recovery",
      "description": "Begin with foundational understanding of binge eating recovery based on your survey responses",
      "dueDate": "YYYY-MM-DD"
    },
    {
      "type": "tool", 
      "id": "tool_id", 
      "title": "Tool Title",
      "description": "Brief description of why this tool is recommended based on survey responses",
      "dueDate": "YYYY-MM-DD"
    },
    {
      "type": "exercise", 
      "id": "exercise_id", 
      "title": "Exercise Title",
      "description": "Brief description of why this exercise is recommended based on survey responses",
      "dueDate": "YYYY-MM-DD"
    }
  ]
}

Note: 
- For lessons, use the "First Lesson ID" from the most relevant chapters (e.g., lesson_1_1, lesson_4_1, lesson_6_1)
- For tools and exercises, use the exact IDs from the content library above
- The "type" field should be exactly "lesson", "tool", or "exercise"
      """;

      // Construct the request body
      final body = jsonEncode({
        'model': 'gpt-4-turbo', // Using GPT-4 Turbo
        'messages': [
          {'role': 'system', 'content': 'You are a specialized AI assistant for a binge eating disorder treatment app. Your role is to analyze survey responses and recommend a balanced mix of lessons, tools, and exercises from the app\'s content library. Always include interactive tools and exercises, not just educational lessons. Focus on practical activities that help users develop recovery skills.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.5, // Lower temperature for more consistent output
        'max_tokens': 2000, // Adjust based on expected response size
      });

      // Make the API call
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices'][0]['message']['content'];
        
        // Parse the JSON response
        try {
          final recommendations = jsonDecode(content);
          return recommendations;
        } catch (e) {
          throw 'Failed to parse OpenAI response: $e';
        }
      } else {
        throw 'OpenAI API request failed with status code ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      throw 'Failed to get recommendations from OpenAI: $e';
    }
  }

  // Method to call OpenAI API for journal analysis
  Future<Map<String, dynamic>> getAnalysis(String prompt) async {
    try {
      // Prepare headers for API request
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      // Construct the request body
      final body = jsonEncode({
        'model': 'gpt-4-turbo', // Using GPT-4 Turbo
        'messages': [
          {'role': 'system', 'content': 'You are a specialized AI assistant for analyzing journal data from users with binge eating disorder. Your role is to provide supportive, insightful analysis of eating patterns, behaviors, and emotional states. Always be empathetic, non-judgmental, and constructive in your analysis. Focus on identifying patterns, triggers, and providing actionable recommendations for recovery.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3, // Lower temperature for more consistent analysis
        'max_tokens': 2500, // Allow more space for detailed analysis
      });

      // Make the API call
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices'][0]['message']['content'];
        
        // Parse the JSON response
        try {
          final analysis = jsonDecode(content);
          return analysis;
        } catch (e) {
          // If JSON parsing fails, return the raw content
          return {
            'analysis': content,
            'insights': [],
            'patterns': [],
            'recommendations': [],
          };
        }
      } else {
        throw 'OpenAI API request failed with status code ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      throw 'Failed to get analysis from OpenAI: $e';
    }
  }

  // Method to call OpenAI API for analytics-based recommendations
  Future<Map<String, dynamic>> getRecommendationsFromAnalytics({
    required Map<String, dynamic> analyticsData,
    required String appContentContext,
  }) async {
    try {
      // Prepare headers for API request
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      // Prepare the prompt to send to OpenAI
      final String prompt = """
Based on the following weekly analytics from a user's journal entries, provide personalized lesson and exercise recommendations:

WEEKLY ANALYTICS:
Week Number: ${analyticsData['weekNumber']}
Entries Analyzed: ${analyticsData['entriesAnalyzed']}

Analysis Overview:
${analyticsData['analysisOverview']}

Key Insights:
${(analyticsData['insights'] as List).map((insight) => '- $insight').join('\n')}

Patterns Identified:
${(analyticsData['patterns'] as List).map((pattern) => '- $pattern').join('\n')}

Existing General Recommendations:
${(analyticsData['existingRecommendations'] as List).map((rec) => '- $rec').join('\n')}

And considering the available lessons, tools, and exercises in the app:
$appContentContext

Please provide SPECIFIC lesson and exercise recommendations that directly address the insights and patterns identified in this user's data.

IMPORTANT INSTRUCTIONS:
- FOR LESSONS: Only recommend the FIRST LESSON from relevant chapters that match the user's specific patterns and insights. Use the "First Lesson ID" provided.
- Recommend 2-3 items maximum to avoid overwhelming the user
- Prioritize tools and exercises over lessons if they directly address identified patterns
- Focus on actionable items that address the specific insights and patterns found
- Consider what the user most needs based on their actual journal data patterns
- Each recommendation should clearly relate to the analytics findings

CRITICAL: Return ONLY the JSON response below, with no additional text, explanations, or formatting:

{
  "recommendations": [
    {
      "type": "lesson", 
      "id": "lesson_X_X", 
      "title": "Start: [Chapter Title]",
      "description": "Based on your [specific pattern/insight], this chapter will help you [specific benefit]",
      "dueDate": "YYYY-MM-DD"
    },
    {
      "type": "tool", 
      "id": "tool_id", 
      "title": "Tool Title",
      "description": "Your analytics show [specific finding] - this tool will help you [specific solution]",
      "dueDate": "YYYY-MM-DD"
    },
    {
      "type": "exercise", 
      "id": "exercise_id", 
      "title": "Exercise Title",
      "description": "Given your pattern of [specific pattern], this exercise will help you [specific outcome]",
      "dueDate": "YYYY-MM-DD"
    }
  ]
}

Note: 
- For lessons, use the "First Lesson ID" from the most relevant chapters
- For tools and exercises, use the exact IDs from the content library above
- The "type" field should be exactly "lesson", "tool", or "exercise"
- Make descriptions specific to the user's actual analytics data, not generic
- Set due dates within 3-5 days for timely action
      """;

      // Construct the request body
      final body = jsonEncode({
        'model': 'gpt-4-turbo', // Using GPT-4 Turbo
        'messages': [
          {'role': 'system', 'content': 'You are a specialized AI assistant for a binge eating disorder treatment app. Your role is to analyze weekly journal analytics and recommend specific lessons, tools, and exercises that directly address the user\'s identified patterns and insights. Always connect recommendations to specific findings in the analytics data. Be precise and actionable. CRITICAL: Always respond with valid JSON only, no additional text or explanations.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3, // Lower temperature for more consistent recommendations
        'max_tokens': 1500, // Focused recommendations
      });

      // Make the API call
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices'][0]['message']['content'];
        
        // Debug: Print the raw content to help with troubleshooting
        // Remove this in production
        print('OpenAI Raw Response: $content');
        
        // Parse the JSON response with better error handling
        try {
          // Try to extract JSON from the response if it's wrapped in text
          String jsonContent = content.trim();
          
          // Look for JSON block markers
          final jsonStart = jsonContent.indexOf('{');
          final jsonEnd = jsonContent.lastIndexOf('}');
          
          if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
            jsonContent = jsonContent.substring(jsonStart, jsonEnd + 1);
          }
          
          final recommendations = jsonDecode(jsonContent);
          return recommendations;
        } catch (e) {
          // If JSON parsing fails, return a structured fallback response
          return {
            'recommendations': [
              {
                'type': 'lesson',
                'id': 'lesson_1_1',
                'title': 'Start: Introduction to Binge Eating Recovery',
                'description': 'Based on your journal analysis, this chapter will help you understand the fundamentals of recovery',
                'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String().split('T')[0],
              },
            ],
          };
        }
      } else {
        throw 'OpenAI API request failed with status code ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      throw 'Failed to get analytics-based recommendations from OpenAI: $e';
    }
  }
}
