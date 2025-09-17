class UserProgress {
  final String id;
  final String userId;
  final String lessonId;
  final int chapterNumber;
  final int lessonNumber;
  final bool isCompleted;
  final int? completedAt;
  final int createdAt;
  final int updatedAt;

  UserProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map, String id) {
    return UserProgress(
      id: id,
      userId: map['userId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      chapterNumber: map['chapterNumber'] ?? 0,
      lessonNumber: map['lessonNumber'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'],
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'chapterNumber': chapterNumber,
      'lessonNumber': lessonNumber,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserProgress copyWith({
    String? id,
    String? userId,
    String? lessonId,
    int? chapterNumber,
    int? lessonNumber,
    bool? isCompleted,
    int? completedAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
