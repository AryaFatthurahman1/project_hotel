class Hotel {
  final int id;
  final String name;
  final String location;
  final double price;
  final double stars;
  final List<String> facilities;
  final String? imageUrl;
  final String? description;
  final DateTime? createdAt;

  Hotel({
    required this.id, 
    required this.name, 
    required this.location, 
    required this.price, 
    this.stars = 4.0,
    this.facilities = const ['WiFi', 'AC', 'TV'],
    this.imageUrl, 
    this.description,
    this.createdAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    var facil = json['facilities'];
    List<String> facilList = [];
    if (facil is String) {
      facilList = facil.split(',').map((e) => e.trim()).toList();
    } else if (facil is List) {
      facilList = facil.map((e) => e.toString()).toList();
    }

    return Hotel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      location: (json['location'] ?? json['alamat']) ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stars: double.tryParse(json['stars'].toString()) ?? 4.0,
      facilities: facilList.isEmpty ? ['WiFi', 'AC', 'TV'] : facilList,
      imageUrl: json['image_url'] ?? json['foto'],
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
      'stars': stars,
      'facilities': facilities.join(','),
      'image_url': imageUrl,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
