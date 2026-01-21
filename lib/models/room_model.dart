class Room {
  int id;
  String roomNumber;
  String roomType;
  String? description;
  double pricePerNight;
  int capacity;
  String? facilities;
  String? imageUrl;
  bool isAvailable;
  DateTime? createdAt;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.isAvailable,
    this.description,
    this.facilities,
    this.imageUrl,
    this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      roomNumber: json['room_number'],
      roomType: json['room_type'],
      description: json['description'],
      pricePerNight: double.parse(json['price_per_night'].toString()),
      capacity: json['capacity'],
      facilities: json['facilities'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] == 1,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'room_type': roomType,
      'description': description,
      'price_per_night': pricePerNight,
      'capacity': capacity,
      'facilities': facilities,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
