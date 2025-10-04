import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../models/chat_message.dart';
import '../../core/services/openai_service.dart';
import '../../widgets/comforting_background.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final OpenAIService _openAIService = OpenAIService();

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: "Hello! I'm here to support you on your recovery journey. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Check if OpenAI is configured
      if (!_openAIService.isConfigured) {
        throw Exception('OpenAI service is not configured. Please check your API key.');
      }

      // Prepare conversation history for context
      final conversationHistory = _messages
          .where((msg) => !msg.isTyping)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.content,
              })
          .toList();

      // Get AI response
      final response = await _openAIService.sendMessage(
        message,
        conversationHistory: conversationHistory,
      );

      // Parse JSON response if it contains structured data
      Map<String, dynamic>? parsedResponse;
      String displayText = response;
      
      try {
        // Look for JSON in the response - more strict parsing
        final jsonStart = response.indexOf('{');
        final jsonEnd = response.lastIndexOf('}');
        
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          final jsonString = response.substring(jsonStart, jsonEnd + 1);
          parsedResponse = jsonDecode(jsonString) as Map<String, dynamic>;
          
          // Validate required fields
          if (parsedResponse.containsKey('response') && 
              parsedResponse.containsKey('recommendations') &&
              parsedResponse['recommendations'] is List) {
            displayText = parsedResponse['response'] as String? ?? response;
          } else {
            // Invalid JSON structure, use original response
            parsedResponse = null;
            displayText = response;
          }
        }
      } catch (e) {
        // If JSON parsing fails, use the original response
        parsedResponse = null;
        displayText = response;
      }

      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: displayText,
        isUser: false,
        timestamp: DateTime.now(),
        recommendations: parsedResponse,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: "I'm sorry, I'm having trouble connecting right now. Please try again later or contact support if the issue persists.",
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Support Chat'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4CAF50).withValues(alpha: 0.15),
                const Color(0xFF66BB6A).withValues(alpha: 0.12),
                const Color(0xFF43A047).withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Start new conversation',
          ),
        ],
      ),
      body: ComfortingBackground(
        child: Column(
          children: [
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            
            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // Check if this AI message has recommendations
    final hasRecommendations = !message.isUser && message.recommendations != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  if (hasRecommendations) ...[
                    const SizedBox(height: 12),
                    _buildInlineRecommendations(message.recommendations!),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[400]?.withValues(alpha: 0.3 + (0.7 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildInlineRecommendations(Map<String, dynamic> recommendationsData) {
    final recommendations = recommendationsData['recommendations'] as List<dynamic>? ?? [];
    final nextSteps = recommendationsData['nextSteps'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: const Color(0xFF4CAF50),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Recommendations
          ...recommendations.map((rec) => _buildInlineRecommendationItem(rec)),
          
          if (nextSteps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Steps',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nextSteps,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineRecommendationItem(dynamic recommendation) {
    final type = recommendation['type'] as String? ?? '';
    final title = recommendation['title'] as String? ?? '';
    final description = recommendation['description'] as String? ?? '';
    final priority = recommendation['priority'] as String? ?? 'medium';

    Color priorityColor;
    IconData priorityIcon;
    
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.remove;
        break;
      case 'low':
        priorityColor = Colors.green;
        priorityIcon = Icons.keyboard_arrow_down;
        break;
      default:
        priorityColor = Colors.grey;
        priorityIcon = Icons.remove;
    }

    IconData typeIcon;
    Color typeColor;
    
    switch (type) {
      case 'lesson':
        typeIcon = Icons.school;
        typeColor = Colors.blue;
        break;
      case 'tool':
        typeIcon = Icons.build;
        typeColor = Colors.green;
        break;
      case 'journal':
        typeIcon = Icons.edit_note;
        typeColor = Colors.purple;
        break;
      case 'assessment':
        typeIcon = Icons.quiz;
        typeColor = Colors.orange;
        break;
      default:
        typeIcon = Icons.help;
        typeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToFeature(type, recommendation['id'] as String? ?? ''),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(typeIcon, color: typeColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(priorityIcon, color: priorityColor, size: 12),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: typeColor,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _navigateToFeature(String type, String id) {
    switch (type) {
      case 'lesson':
        _navigateToLesson(id);
        break;
      case 'tool':
        _navigateToTool(id);
        break;
      case 'journal':
        _navigateToJournal(id);
        break;
      case 'assessment':
        _navigateToAssessment(id);
        break;
      default:
        _showFeatureNotAvailable();
    }
  }

  void _navigateToLesson(String lessonId) {
    // Navigate to specific lesson based on lesson ID
    // Store the chat route so we can return to it
    switch (lessonId) {
      // Stage 1 lessons
      case 'lesson_1_1':
        context.push('/lesson/1_1');
        break;
      case 'lesson_1_2':
        context.push('/lesson/1_2');
        break;
      case 'lesson_1_2_1':
        context.push('/lesson/1_2_1');
        break;
      case 'lesson_1_3':
        context.push('/lesson/1_3');
        break;
      case 'lesson_2_1':
        context.push('/lesson/2_1');
        break;
      case 'lesson_2_2':
        context.push('/lesson/2_2');
        break;
      case 'lesson_2_3':
        context.push('/lesson/2_3');
        break;
      case 'lesson_3_1':
        context.push('/lesson/3_1');
        break;
      case 'lesson_3_2':
        context.push('/lesson/3_2');
        break;
      case 'lesson_3_3':
        context.push('/lesson/3_3');
        break;
      case 'lesson_3_4':
        context.push('/lesson/3_4');
        break;
      case 'lesson_3_5':
        context.push('/lesson/3_5');
        break;
      case 'lesson_3_6':
        context.push('/lesson/3_6');
        break;
      case 'lesson_3_7':
        context.push('/lesson/3_7');
        break;
      case 'lesson_3_8':
        context.push('/lesson/3_8');
        break;
      case 'lesson_3_9':
        context.push('/lesson/3_9');
        break;
      case 'lesson_3_10':
        context.push('/lesson/3_10');
        break;
      
      // Stage 2 lessons
      case 'lesson_s2_0_1':
        context.push('/lesson/s2_0_1');
        break;
      case 'lesson_s2_0_2':
        context.push('/lesson/s2_0_2');
        break;
      case 'lesson_s2_0_3':
        context.push('/lesson/s2_0_3');
        break;
      case 'lesson_s2_0_4':
        context.push('/lesson/s2_0_4');
        break;
      case 'lesson_s2_0_5':
        context.push('/lesson/s2_0_5');
        break;
      case 'lesson_s2_0_6':
        context.push('/lesson/s2_0_6');
        break;
      case 'lesson_s2_1_1':
        context.push('/lesson/s2_1_1');
        break;
      case 'lesson_s2_1_2':
        context.push('/lesson/s2_1_2');
        break;
      case 'lesson_s2_1_3':
        context.push('/lesson/s2_1_3');
        break;
      case 'lesson_s2_2_1':
        context.push('/lesson/s2_2_1');
        break;
      case 'lesson_s2_2_2':
        context.push('/lesson/s2_2_2');
        break;
      case 'lesson_s2_2_3':
        context.push('/lesson/s2_2_3');
        break;
      case 'lesson_s2_2_4':
        context.push('/lesson/s2_2_4');
        break;
      case 'lesson_s2_2_5':
        context.push('/lesson/s2_2_5');
        break;
      case 'lesson_s2_2_5_1':
        context.push('/lesson/s2_2_5_1');
        break;
      case 'lesson_s2_2_7':
        context.push('/lesson/s2_2_7');
        break;
      case 'lesson_s2_3_1':
        context.push('/lesson/s2_3_1');
        break;
      case 'lesson_s2_3_2':
        context.push('/lesson/s2_3_2');
        break;
      case 'lesson_s2_3_2_1':
        context.push('/lesson/s2_3_2_1');
        break;
      case 'lesson_s2_3_3':
        context.push('/lesson/s2_3_3');
        break;
      case 'lesson_s2_3_4':
        context.push('/lesson/s2_3_4');
        break;
      case 'lesson_s2_3_5':
        context.push('/lesson/s2_3_5');
        break;
      case 'lesson_s2_4_1':
        context.push('/lesson/s2_4_1');
        break;
      case 'lesson_s2_4_2':
        context.push('/lesson/s2_4_2');
        break;
      case 'lesson_s2_4_2_1':
        context.push('/lesson/s2_4_2_1');
        break;
      case 'lesson_s2_4_3':
        context.push('/lesson/s2_4_3');
        break;
      case 'lesson_s2_5_1':
        context.push('/lesson/s2_5_1');
        break;
      case 'lesson_s2_5_2':
        context.push('/lesson/s2_5_2');
        break;
      case 'lesson_s2_6_1':
        context.push('/lesson/s2_6_1');
        break;
      case 'lesson_s2_6_2':
        context.push('/lesson/s2_6_2');
        break;
      case 'lesson_s2_6_3':
        context.push('/lesson/s2_6_3');
        break;
      case 'lesson_s2_7_1':
        context.push('/lesson/s2_7_1');
        break;
      case 'lesson_s2_7_1_1':
        context.push('/lesson/s2_7_1_1');
        break;
      case 'lesson_s2_7_2':
        context.push('/lesson/s2_7_2');
        break;
      case 'lesson_s2_7_3':
        context.push('/lesson/s2_7_3');
        break;
      case 'lesson_s2_7_4':
        context.push('/lesson/s2_7_4');
        break;
      case 'lesson_s2_7_5':
        context.push('/lesson/s2_7_5');
        break;
      case 'lesson_s2_7_6':
        context.push('/lesson/s2_7_6');
        break;
      case 'lesson_s2_7_7':
        context.push('/lesson/s2_7_7');
        break;
      case 'lesson_s2_7_8':
        context.push('/lesson/s2_7_8');
        break;
      case 'lesson_s2_7_2_1':
        context.push('/lesson/s2_7_2_1');
        break;
      
      // Stage 3 lessons
      case 'lesson_s3_0_1':
        context.push('/lesson/s3_0_1');
        break;
      case 'lesson_s3_0_2':
        context.push('/lesson/s3_0_2');
        break;
      case 'lesson_s3_0_2_1':
        context.push('/lesson/s3_0_2_1');
        break;
      default:
        _showLessonNotAvailable(lessonId);
    }
  }

  void _navigateToTool(String toolName) {
    switch (toolName.toLowerCase()) {
      case 'problem solving':
        context.push('/tools/problem-solving');
        break;
      case 'meal planning':
        context.push('/tools/meal-planning');
        break;
      case 'urge surfing activities':
        context.push('/tools/urge-surfing');
        break;
      case 'addressing overconcern':
        context.push('/tools/addressing-overconcern');
        break;
      case 'addressing setbacks':
        context.push('/tools/addressing-setbacks');
        break;
      default:
        _showToolNotAvailable(toolName);
    }
  }

  void _navigateToJournal(String journalType) {
    switch (journalType.toLowerCase()) {
      case 'food diary':
        context.push('/journal/food-diary');
        break;
      case 'weight diary':
        context.push('/journal/weight-diary');
        break;
      case 'body image diary':
        context.push('/journal/body-image-diary');
        break;
      default:
        context.push('/journal');
    }
  }

  void _navigateToAssessment(String assessmentName) {
    switch (assessmentName.toLowerCase()) {
      case 'ede-q':
        context.push('/lesson/2_1'); // EDE-Q assessment
        break;
      case 'cia':
        context.push('/lesson/2_2'); // CIA assessment
        break;
      case 'general psychiatric':
        context.push('/lesson/2_3'); // General psychiatric assessment
        break;
      default:
        _showAssessmentNotAvailable(assessmentName);
    }
  }

  void _showFeatureNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showLessonNotAvailable(String lessonId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson $lessonId is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showToolNotAvailable(String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tool "$toolName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAssessmentNotAvailable(String assessmentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assessment "$assessmentName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
