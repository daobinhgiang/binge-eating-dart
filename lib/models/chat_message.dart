import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the role of a chat message sender
enum ChatRole {
  user,
  assistant,
}

/// Model class for a chat message
class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final List<ResourceRecommendation>? recommendations;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.recommendations,
  });

  /// Create a new user message
  factory ChatMessage.user({
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Create a new assistant message
  factory ChatMessage.assistant({
    required String content,
    List<ResourceRecommendation>? recommendations,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      recommendations: recommendations,
    );
  }

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toString().split('.').last,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'recommendations': recommendations?.map((r) => r.toJson()).toList(),
    };
  }

  /// Create from JSON Map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      role: json['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
      content: json['content'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      recommendations: json['recommendations'] != null
          ? (json['recommendations'] as List)
              .map((r) => ResourceRecommendation.fromJson(r))
              .toList()
          : null,
    );
  }
}

/// Model class for a resource recommendation in chat responses
class ResourceRecommendation {
  final String id;
  final String title;
  final String description;
  final ResourceType type;

  ResourceRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
    };
  }

  /// Create from JSON Map
  factory ResourceRecommendation.fromJson(Map<String, dynamic> json) {
    return ResourceRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: _parseResourceType(json['type']),
    );
  }

  /// Parse resource type from string
  static ResourceType _parseResourceType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'tool':
      case 'exercise':
        return ResourceType.tool;
      case 'lesson':
        return ResourceType.lesson;
      default:
        return ResourceType.other;
    }
  }
}

/// Types of resources that can be recommended
enum ResourceType {
  lesson,
  tool,
  other,
}
