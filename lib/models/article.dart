class Article {
  final int? id;
  final String title;
  final String? category;
  final String? content;
  final String? imageUrl;
  final DateTime? createdAt;

  Article({
    this.id,
    required this.title,
    this.category,
    this.content,
    this.imageUrl,
    this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      title: json['title'] ?? '',
      category: json['category'] ?? 'Travel',
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
