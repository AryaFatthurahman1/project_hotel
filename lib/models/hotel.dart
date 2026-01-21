class Hotel {
  final int id;
  final String name;
  final String location;
  final double price;
  final String? imageUrl;
  final String? description;
  final DateTime? createdAt;

  Hotel({
    required this.id, 
    required this.name, 
    required this.location, 
    required this.price, 
    this.imageUrl, 
    this.description,
    this.createdAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'],
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
