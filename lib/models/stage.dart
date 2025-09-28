import 'chapter.dart';

class Stage {
  final int stageNumber;
  final String title;
  final List<Chapter> chapters;

  const Stage({
    required this.stageNumber,
    required this.title,
    required this.chapters,
  });

  factory Stage.fromMap(Map<String, dynamic> map) {
    return Stage(
      stageNumber: map['stageNumber'] ?? 0,
      title: map['title'] ?? '',
      chapters: (map['chapters'] as List<dynamic>?)
          ?.map((chapter) => Chapter.fromMap(chapter))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stageNumber': stageNumber,
      'title': title,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
    };
  }

  Stage copyWith({
    int? stageNumber,
    String? title,
    List<Chapter>? chapters,
  }) {
    return Stage(
      stageNumber: stageNumber ?? this.stageNumber,
      title: title ?? this.title,
      chapters: chapters ?? this.chapters,
    );
  }
}
