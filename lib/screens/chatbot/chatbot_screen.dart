import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/chat_message.dart';
import '../../providers/chatbot_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/navigation_service.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final NavigationService _navigationService = NavigationService();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to the bottom of the chat
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

  // Send a message to the chatbot
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final user = ref.read(authNotifierProvider).value;
      if (user != null) {
        ref.read(chatbotProvider(user.id).notifier).sendMessage(message);
        _messageController.clear();
        _scrollToBottom();
      }
    }
  }

  // Handle resource recommendation navigation
  void _navigateToResource(ResourceRecommendation resource) {
    switch (resource.type) {
      case ResourceType.other:
        // Lessons are no longer available
        _showErrorSnackbar('This resource is not available at this time');
        break;
        
      case ResourceType.tool:
        // Map tool IDs to routes
        String? route;
        switch (resource.id) {
          case 'problem_solving':
            route = '/tools/problem-solving';
            break;
          case 'meal_planning':
            route = '/tools/meal-planning';
            break;
          case 'urge_surfing':
            route = '/tools/urge-surfing';
            break;
          case 'addressing_overconcern':
            route = '/tools/addressing-overconcern';
            break;
          case 'addressing_setbacks':
            route = '/tools/addressing-setbacks';
            break;
        }
        
        if (route != null) {
          context.push(route);
        } else {
          _showErrorSnackbar('Tool not found');
        }
        break;
        
      case ResourceType.other:
      default:
        _showErrorSnackbar('Resource type not supported');
        break;
    }
  }

  // Show error message
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inquiries'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat History'),
                  content: const Text('Are you sure you want to clear all chat history? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final user = ref.read(authNotifierProvider).value;
                        if (user != null) {
                          ref.read(chatbotProvider(user.id).notifier).clearChatHistory();
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear chat history',
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            // User not logged in
            return const Center(
              child: Text('Please log in to use the chatbot'),
            );
          }
          
          // User is logged in, show chat interface
          final chatbotState = ref.watch(chatbotProvider(user.id));
          
          return Column(
            children: [
              // Welcome card
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'How can I help you?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ask me about resources in the app that can help with your specific needs. I can recommend lessons and tools that might be useful.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Chat messages
              Expanded(
                child: chatbotState.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a conversation by typing below',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    _scrollToBottom();
                    
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildChatBubble(context, message);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading chat: $error',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.refresh(chatbotProvider(user.id));
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Message input
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      elevation: 2,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => const Center(
          child: Text('Error loading user data'),
        ),
      ),
    );
  }

  // Build a chat bubble for a message
  Widget _buildChatBubble(BuildContext context, ChatMessage message) {
    final isUser = message.role == ChatRole.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message content
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            
            // Resource recommendations
            if (!isUser && message.recommendations != null && message.recommendations!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    'Recommended Resources:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...message.recommendations!.map(
                    (resource) => _buildResourceButton(resource),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Build a button for a resource recommendation
  Widget _buildResourceButton(ResourceRecommendation resource) {
    final Color buttonColor = resource.type == ResourceType.other
        ? Colors.grey
        : Colors.teal;

    final IconData iconData = resource.type == ResourceType.other
        ? Icons.help_outline
        : Icons.fitness_center;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: OutlinedButton.icon(
        onPressed: () => _navigateToResource(resource),
        icon: Icon(iconData, color: buttonColor, size: 16),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.title,
              style: TextStyle(
                color: buttonColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              resource.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(color: buttonColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
