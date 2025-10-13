import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_message.dart';
import '../../core/services/openai_service.dart';
import '../../core/services/user_context_service.dart';
import '../../widgets/comforting_background.dart';
import '../../providers/auth_provider.dart';

class RealtimeJournalingScreen extends ConsumerStatefulWidget {
  const RealtimeJournalingScreen({super.key});

  @override
  ConsumerState<RealtimeJournalingScreen> createState() => _RealtimeJournalingScreenState();
}

class _RealtimeJournalingScreenState extends ConsumerState<RealtimeJournalingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final OpenAIService _openAIService = OpenAIService();
  final UserContextService _userContextService = UserContextService();
  Map<String, dynamic>? _userContext;
  bool _isLoadingContext = false;

  @override
  void initState() {
    super.initState();
    _loadUserContext();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserContext() async {
    setState(() {
      _isLoadingContext = true;
    });

    try {
      // Get current user ID
      final authState = ref.read(authNotifierProvider);
      final user = authState.valueOrNull;
      
      if (user != null) {
        final context = await _userContextService.getUserContext(user.id);
        setState(() {
          _userContext = context;
          _isLoadingContext = false;
        });
        
        // Update welcome message with personalized greeting
        if (_messages.isNotEmpty && !_messages.first.isUser) {
          final user = context['user'] as Map<String, dynamic>?;
          if (user != null) {
            final firstName = user['firstName'] as String?;
            if (firstName != null && firstName.isNotEmpty) {
              setState(() {
                _messages[0] = ChatMessage(
                  id: _messages[0].id,
                  content: "Welcome to your reflection space, $firstName. I'm here to help you explore your thoughts and feelings. How are you doing today?",
                  isUser: false,
                  timestamp: _messages[0].timestamp,
                );
              });
            }
          }
        }
      } else {
        setState(() {
          _isLoadingContext = false;
        });
      }
    } catch (e) {
      print('Error loading user context: $e');
      setState(() {
        _isLoadingContext = false;
      });
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      String welcomeMessage = "Welcome to your reflection space. I'm here to help you explore your thoughts and feelings. How are you doing today?";
      
      // Personalize welcome message if user context is available
      if (_userContext != null) {
        final user = _userContext!['user'] as Map<String, dynamic>?;
        if (user != null) {
          final firstName = user['firstName'] as String?;
          if (firstName != null && firstName.isNotEmpty) {
            welcomeMessage = "Welcome to your reflection space, $firstName. I'm here to help you explore your thoughts and feelings. How are you doing today?";
          }
        }
      }
      
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: welcomeMessage,
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

      // Get AI response for journaling with user context
      final response = await _openAIService.sendJournalingMessage(
        message,
        conversationHistory: conversationHistory,
        userContext: _userContext,
      );

      // Add AI response (journaling doesn't use structured JSON)
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Add error message to chat
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: "I'm having trouble connecting right now. Please try again in a moment.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
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
        title: const Text('Realtime Journaling'),
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
                const Color(0xFF9C27B0).withValues(alpha: 0.15),
                const Color(0xFFBA68C8).withValues(alpha: 0.12),
                const Color(0xFF8E24AA).withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _loadUserContext();
              _addWelcomeMessage();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Start new journal entry',
          ),
        ],
      ),
      body: ComfortingBackground(
        child: Column(
          children: [
            // Loading context indicator
            if (_isLoadingContext)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Loading your journaling context...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: const Color(0xFF9C27B0),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is your safe space to reflect and express yourself',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9C27B0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            
            // Loading indicator
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reflecting...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Message input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFF9C27B0),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9C27B0),
                            Color(0xFFBA68C8),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFFBA68C8),
                  ],
                )
              : null,
          color: message.isUser ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser 
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

