import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_message.dart';
import '../../core/services/openai_service.dart';
import '../../core/services/user_context_service.dart';
import '../../widgets/comforting_background.dart';
import '../../providers/auth_provider.dart';

class AccountabilityPartnerScreen extends ConsumerStatefulWidget {
  const AccountabilityPartnerScreen({super.key});

  @override
  ConsumerState<AccountabilityPartnerScreen> createState() => _AccountabilityPartnerScreenState();
}

class _AccountabilityPartnerScreenState extends ConsumerState<AccountabilityPartnerScreen> {
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
                  content: "Hi $firstName! I'm your accountability partner, here to support you on your recovery journey. I'll help you stay committed to your goals, check in on your progress, and provide gentle accountability when you need it. What would you like to work on together today?",
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
      String welcomeMessage = "I'm your accountability partner, here to support you on your recovery journey. I'll help you stay committed to your goals, check in on your progress, and provide gentle accountability when you need it. What would you like to work on together today?";
      
      // Personalize welcome message if user context is available
      if (_userContext != null) {
        final user = _userContext!['user'] as Map<String, dynamic>?;
        if (user != null) {
          final firstName = user['firstName'] as String?;
          if (firstName != null && firstName.isNotEmpty) {
            welcomeMessage = "Hi $firstName! I'm your accountability partner, here to support you on your recovery journey. I'll help you stay committed to your goals, check in on your progress, and provide gentle accountability when you need it. What would you like to work on together today?";
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

      // Get AI response for accountability with user context
      final response = await _openAIService.sendAccountabilityMessage(
        message,
        conversationHistory: conversationHistory,
        userContext: _userContext,
      );

      // Add AI response
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
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Sorry, I encountered an error: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
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
        title: const Text('Accountability Partner'),
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
                const Color(0xFF4CAF50).withOpacity(0.15),
                const Color(0xFF66BB6A).withOpacity(0.12),
                const Color(0xFF388E3C).withOpacity(0.08),
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
            tooltip: 'Start new conversation',
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
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Loading your accountability context...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4CAF50),
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
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your accountability partner is here to help you stay committed to your recovery goals',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4CAF50),
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
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF4CAF50).withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your accountability partner is thinking...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4CAF50).withOpacity(0.7),
                        fontStyle: FontStyle.italic,
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Share your goals, progress, or challenges...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1,
                          ),
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
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.support_agent,
                color: Color(0xFF4CAF50),
                size: 16,
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
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.grey[800],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4CAF50),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
