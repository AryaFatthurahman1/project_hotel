class Article {
  final int? id;
  final String title;
  final String? content;
  final String? imageUrl;
  final DateTime? createdAt;

  Article({
    this.id,
    required this.title,
    this.content,
    this.imageUrl,
    this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
