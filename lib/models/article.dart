class Article {
  final String id;
  final String title;
  final String content;
  final String category;
  final String author;
  final DateTime publishedAt;
  final String? imageUrl;
  final List<String> tags;
  final int readTimeMinutes;
  final bool isFeatured;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.publishedAt,
    this.imageUrl,
    required this.tags,
    required this.readTimeMinutes,
    this.isFeatured = false,
  });

  factory Article.fromMap(Map<String, dynamic> map, String id) {
    return Article(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      author: map['author'] ?? '',
      publishedAt: DateTime.fromMillisecondsSinceEpoch(map['publishedAt'] ?? 0),
      imageUrl: map['imageUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      readTimeMinutes: map['readTimeMinutes'] ?? 5,
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'author': author,
      'publishedAt': publishedAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'tags': tags,
      'readTimeMinutes': readTimeMinutes,
      'isFeatured': isFeatured,
    };
  }
}

enum ArticleCategory {
  understandingBed('Understanding BED'),
  copingStrategies('Coping Strategies'),
  nutrition('Nutrition & Eating'),
  mentalHealth('Mental Health'),
  recovery('Recovery Journey'),
  support('Support & Resources');

  const ArticleCategory(this.displayName);
  final String displayName;
}

