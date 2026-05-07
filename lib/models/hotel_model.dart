class Hotel {
  final int id;
  final String name;
  final String description;
  final String address;
  final String city;
  final double pricePerNight;
  final String priceFormatted;
  final double rating;
  final String imageUrl;
  final String facilities;
  final List<String> facilitiesList;
  final String roomType;
  final bool isAvailable;
  final int totalRooms;
  bool isFavorite;

  String get location => city;
  double get price => pricePerNight;
  double get stars => rating;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.pricePerNight,
    required this.priceFormatted,
    required this.rating,
    required this.imageUrl,
    required this.facilities,
    required this.facilitiesList,
    required this.roomType,
    required this.isAvailable,
    required this.totalRooms,
    this.isFavorite = false,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    List<String> parseFacilities(dynamic facilities) {
      if (facilities is List) {
        return facilities.map((e) => e.toString()).toList();
      } else if (facilities is String) {
        return facilities.split(', ');
      }
      return [];
    }

    return Hotel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pricePerNight: double.tryParse(json['price_per_night'].toString()) ?? 0,
      priceFormatted: json['price_formatted'] ?? 'Rp 0',
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      imageUrl: json['image_url'] ?? '',
      facilities: json['facilities'] ?? '',
      facilitiesList: parseFacilities(json['facilities_list'] ?? json['facilities']),
      roomType: json['room_type'] ?? 'standard',
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      totalRooms: int.tryParse(json['total_rooms'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'price_per_night': pricePerNight,
      'price_formatted': priceFormatted,
      'rating': rating,
      'image_url': imageUrl,
      'facilities': facilities,
      'room_type': roomType,
      'is_available': isAvailable,
      'total_rooms': totalRooms,
    };
  }
}
