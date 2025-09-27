import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/chat_message.dart';
import './app_content_service.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  // OpenAI API key - loaded from environment variables
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  String get _endpoint => dotenv.env['OPENAI_API_ENDPOINT'] ?? 'https://api.openai.com/v1/chat/completions';
  final AppContentService _appContentService = AppContentService();

  // System prompt for the chatbot
  final String _systemPrompt = '''
You are a helpful assistant in a binge eating disorder recovery app. Your primary role is to help users find relevant resources within the app.

When the user asks a question or expresses a need:
1. Provide a thoughtful, empathetic response addressing their immediate question or concern
2. Recommend specific app resources (lessons or tools) that would help them with their specific situation
3. For EVERY recommendation, include the exact resource ID and type so they can be displayed as clickable buttons

IMPORTANT: Always format your recommendations using this JSON-like syntax within your response:
[RESOURCE{type:"lesson",id:"lesson_6_1",title:"Body Image and Self-Compassion",description:"Learn to develop a healthier relationship with your body"}]

You can include multiple resource recommendations in one reply, each in its own [RESOURCE{...}] block.

Remember that you're not a substitute for professional help, so encourage users to seek professional support when appropriate.
''';

  // Get app content context for the chatbot
  Future<String> _getAppContentContext() async {
    return await _appContentService.getAppContentContext();
  }

  // Process a user message and get a chatbot response
  Future<ChatMessage> getResponse(String userMessage, List<ChatMessage> chatHistory) async {
    try {
      // Get app content context
      final appContentContext = await _getAppContentContext();

      // Prepare messages for API request
      List<Map<String, String>> messages = [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'system', 'content': 'App content resources:\n$appContentContext'},
      ];

      // Add chat history (limit to last 10 messages to save tokens)
      final recentHistory = chatHistory.length > 10 
          ? chatHistory.sublist(chatHistory.length - 10)
          : chatHistory;

      for (final message in recentHistory) {
        messages.add({
          'role': message.role == ChatRole.user ? 'user' : 'assistant',
          'content': message.content,
        });
      }

      // Add the current user message
      messages.add({'role': 'user', 'content': userMessage});

      // Prepare headers for API request
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      // Construct the request body
      final body = jsonEncode({
        'model': 'gpt-4-turbo', // Using GPT-4 Turbo
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 2000,
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
        
        // Extract resource recommendations from content
        final recommendations = _extractResourceRecommendations(content);
        
        // Clean up content by removing resource tags
        final cleanContent = _cleanContent(content);

        // Create chat message with recommendations
        return ChatMessage.assistant(
          content: cleanContent,
          recommendations: recommendations,
        );
      } else {
        throw 'OpenAI API request failed with status code ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      // Return error message
      return ChatMessage.assistant(
        content: 'I apologize, but I encountered an error while processing your request. Please try again later.',
      );
    }
  }

  // Extract resource recommendations from content
  List<ResourceRecommendation> _extractResourceRecommendations(String content) {
    final recommendations = <ResourceRecommendation>[];
    
    // Match pattern [RESOURCE{type:"...",id:"...",title:"...",description:"..."}]
    final regex = RegExp(r'\[RESOURCE\{type:"([^"]+)",id:"([^"]+)",title:"([^"]+)",description:"([^"]+)"\}\]');
    
    // Find all matches
    final matches = regex.allMatches(content);
    
    for (final match in matches) {
      if (match.groupCount >= 4) {
        final type = match.group(1)!;
        final id = match.group(2)!;
        final title = match.group(3)!;
        final description = match.group(4)!;
        
        // Create resource recommendation
        recommendations.add(
          ResourceRecommendation(
            type: _parseResourceType(type),
            id: id,
            title: title,
            description: description,
          ),
        );
      }
    }
    
    return recommendations;
  }

  // Clean up content by removing resource tags
  String _cleanContent(String content) {
    final regex = RegExp(r'\[RESOURCE\{type:"([^"]+)",id:"([^"]+)",title:"([^"]+)",description:"([^"]+)"\}\]');
    return content.replaceAll(regex, '');
  }

  // Parse resource type from string
  ResourceType _parseResourceType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'tool':
      case 'exercise':
        return ResourceType.tool;
      case 'lesson':
        return ResourceType.other;
      default:
        return ResourceType.other;
    }
  }
}
