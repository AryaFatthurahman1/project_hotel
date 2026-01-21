class Booking {
  final int? id;
  final int userId;
  final int hotelId;
  final String? hotelName;
  final DateTime? checkin;
  final DateTime? checkout;
  final String status;
  final DateTime? createdAt;

  Booking({
    this.id,
    required this.userId,
    required this.hotelId,
    this.hotelName,
    this.checkin,
    this.checkout,
    this.status = 'pending',
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      hotelId: json['hotel_id'] as int,
      hotelName: json['hotel_name'] as String?,
      checkin: json['checkin'] != null ? DateTime.parse(json['checkin']) : null,
      checkout: json['checkout'] != null ? DateTime.parse(json['checkout']) : null,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'hotel_name': hotelName,
      'checkin': checkin?.toIso8601String(),
      'checkout': checkout?.toIso8601String(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
