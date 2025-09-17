import 'lesson_slide.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final int chapterNumber;
  final int lessonNumber;
  final List<LessonSlide> slides;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.chapterNumber,
    required this.lessonNumber,
    required this.slides,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    return Lesson(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      chapterNumber: map['chapterNumber'] ?? 0,
      lessonNumber: map['lessonNumber'] ?? 0,
      slides: (map['slides'] as List<dynamic>?)
          ?.map((slide) => LessonSlide.fromMap(slide, slide['id'] ?? ''))
          .toList() ?? [],
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'chapterNumber': chapterNumber,
      'lessonNumber': lessonNumber,
      'slides': slides.map((slide) => slide.toMap()).toList(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    int? chapterNumber,
    int? lessonNumber,
    List<LessonSlide>? slides,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      slides: slides ?? this.slides,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
