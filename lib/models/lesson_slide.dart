class LessonSlide {
  final String id;
  final String title;
  final String content;
  final int slideNumber;
  final List<String> bulletPoints;
  final String? additionalInfo;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const LessonSlide({
    required this.id,
    required this.title,
    required this.content,
    required this.slideNumber,
    this.bulletPoints = const [],
    this.additionalInfo,
    this.imageUrl,
    this.metadata,
  });

  factory LessonSlide.fromMap(Map<String, dynamic> map, String id) {
    return LessonSlide(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      slideNumber: map['slideNumber'] ?? 0,
      bulletPoints: List<String>.from(map['bulletPoints'] ?? []),
      additionalInfo: map['additionalInfo'],
      imageUrl: map['imageUrl'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'slideNumber': slideNumber,
      'bulletPoints': bulletPoints,
      'additionalInfo': additionalInfo,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  LessonSlide copyWith({
    String? id,
    String? title,
    String? content,
    int? slideNumber,
    List<String>? bulletPoints,
    String? additionalInfo,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return LessonSlide(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      slideNumber: slideNumber ?? this.slideNumber,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}