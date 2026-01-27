class FoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String priceFormatted;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final bool isFeatured;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceFormatted,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.isFeatured,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      priceFormatted: json['price_formatted'] ?? 'Rp 0',
      category: json['category'] ?? 'main_course',
      imageUrl: json['image_url'] ?? '',
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'appetizer':
        return 'Appetizer';
      case 'main_course':
        return 'Hidangan Utama';
      case 'dessert':
        return 'Dessert';
      case 'beverage':
        return 'Minuman';
      case 'snack':
        return 'Snack';
      default:
        return category;
    }
  }
}
