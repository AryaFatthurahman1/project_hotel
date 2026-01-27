class Article {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String imageUrl;
  final String author;
  final String category;
  final int views;
  final String createdAt;
  final String createdAtFormatted;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.imageUrl,
    required this.author,
    required this.category,
    required this.views,
    required this.createdAt,
    required this.createdAtFormatted,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'] ?? '',
      imageUrl: json['image_url'] ?? '',
      author: json['author'] ?? 'Admin',
      category: json['category'] ?? 'news',
      views: int.tryParse(json['views'].toString()) ?? 0,
      createdAt: json['created_at'] ?? '',
      createdAtFormatted: json['created_at_formatted'] ?? '',
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'promo':
        return 'Promo';
      case 'tips':
        return 'Tips';
      case 'event':
        return 'Event';
      case 'news':
      default:
        return 'Berita';
    }
  }
}
