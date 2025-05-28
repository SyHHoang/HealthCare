class News {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String coverImage;
  final int viewCount;
  final String createdAt;

  News({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.coverImage,
    required this.viewCount,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      coverImage: json['coverImage'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
} 