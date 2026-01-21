class Booking {
  final int? id;
  final int userId;
  final int hotelId;
  final String? hotelName;
  final DateTime? checkin;
  final DateTime? checkout;
  final double totalPrice;
  final String status;
  final String? qrCode; // Mocking QR Code data
  final DateTime? createdAt;

  Booking({
    this.id,
    required this.userId,
    required this.hotelId,
    this.hotelName,
    this.checkin,
    this.checkout,
    this.totalPrice = 0.0,
    this.status = 'pending',
    this.qrCode,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      hotelId: json['hotel_id'] is int ? json['hotel_id'] : int.parse(json['hotel_id'].toString()),
      hotelName: json['hotel_name'] ?? json['hotel'],
      checkin: json['check_in'] != null ? DateTime.parse(json['check_in']) : (json['checkin'] != null ? DateTime.parse(json['checkin']) : null),
      checkout: json['check_out'] != null ? DateTime.parse(json['check_out']) : (json['checkout'] != null ? DateTime.parse(json['checkout']) : null),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? (double.tryParse(json['price'].toString()) ?? 0.0),
      status: json['status'] ?? 'pending',
      qrCode: json['qr_code'] ?? 'HEI-${json['id'] ?? 'TMP'}-XYZ',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'hotel_name': hotelName,
      'check_in': checkin?.toIso8601String(),
      'check_out': checkout?.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'qr_code': qrCode,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
