import 'lesson.dart';

class Chapter {
  final int chapterNumber;
  final String title;
  final List<Lesson> lessons;

  const Chapter({
    required this.chapterNumber,
    required this.title,
    required this.lessons,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      chapterNumber: map['chapterNumber'] ?? 0,
      title: map['title'] ?? '',
      lessons: (map['lessons'] as List<dynamic>?)
          ?.map((lesson) => Lesson.fromMap(lesson, lesson['id'] ?? ''))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterNumber': chapterNumber,
      'title': title,
      'lessons': lessons.map((lesson) => lesson.toMap()).toList(),
    };
  }

  Chapter copyWith({
    int? chapterNumber,
    String? title,
    List<Lesson>? lessons,
  }) {
    return Chapter(
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      lessons: lessons ?? this.lessons,
    );
  }
}
