import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../core/services/chatbot_service.dart';

/// Provider that manages the chatbot state
class ChatbotNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final String userId;
  final ChatbotService _chatbotService = ChatbotService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatbotNotifier({required this.userId}) : super(const AsyncValue.loading()) {
    _loadChatHistory();
  }

  /// Load chat history from Firestore
  Future<void> _loadChatHistory() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .orderBy('timestamp', descending: false)
          .get();

      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();

      state = AsyncValue.data(messages);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Send a message to the chatbot and get a response
  Future<void> sendMessage(String message) async {
    try {
      // Don't allow empty messages
      if (message.trim().isEmpty) return;

      // Get current chat messages
      final currentMessages = state.value ?? [];

      // Create user message
      final userMessage = ChatMessage.user(content: message);

      // Update state with user message
      state = AsyncValue.data([...currentMessages, userMessage]);

      // Save user message to Firestore
      await _saveMessage(userMessage);

      // Show typing indicator
      state = AsyncValue.data([...state.value!, ChatMessage.assistant(content: '...')]);

      // Get response from chatbot
      final botResponse = await _chatbotService.getResponse(message, currentMessages);

      // Update state with bot response
      state = AsyncValue.data([...state.value!.sublist(0, state.value!.length - 1), botResponse]);

      // Save bot response to Firestore
      await _saveMessage(botResponse);
    } catch (error) {
      // If there was an error, show an error message
      final currentMessages = state.value ?? [];
      final errorMessage = ChatMessage.assistant(
        content: 'Sorry, I encountered an error. Please try again later.',
      );
      
      state = AsyncValue.data([...currentMessages, errorMessage]);
      await _saveMessage(errorMessage);
    }
  }

  /// Save a message to Firestore
  Future<void> _saveMessage(ChatMessage message) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      // Handle error silently - the message will still be displayed in the UI
      print('Error saving chat message: $e');
    }
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    try {
      final batch = _firestore.batch();
      
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      state = const AsyncValue.data([]);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

/// Provider for chatbot messages
final chatbotProvider = StateNotifierProvider.family<ChatbotNotifier, AsyncValue<List<ChatMessage>>, String>(
  (ref, userId) => ChatbotNotifier(userId: userId),
);
