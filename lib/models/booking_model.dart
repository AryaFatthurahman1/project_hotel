class Booking {
  final int? id;
  final int userId;
  final int hotelId;
  final String? hotelName;
  String? hotelImageUrl;
  String? hotelLocation;
  final DateTime checkIn;
  final DateTime checkOut;
  final int totalNights;
  final double totalPrice;
  final String status;
  final String? paymentMethod;
  final String paymentStatus;
  final DateTime? createdAt;

  DateTime get checkin => checkIn;
  DateTime get checkout => checkOut;

  Booking({
    this.id,
    required this.userId,
    required this.hotelId,
    this.hotelName,
    this.hotelImageUrl,
    this.hotelLocation,
    required this.checkIn,
    required this.checkOut,
    required this.totalNights,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      hotelId: json['hotel_id'] is int
          ? json['hotel_id']
          : (json['room_id'] is int
                ? json['room_id']
                : int.parse(
                    (json['hotel_id'] ?? json['room_id'] ?? '0').toString(),
                  )),
      hotelName: json['hotel_name'] ?? json['hotel'],
      hotelImageUrl: json['hotel_image'],
      hotelLocation: json['hotel_location'],
      checkIn: DateTime.parse(
        json['check_in'] ??
            json['checkin'] ??
            json['check_in_date'] ??
            DateTime.now().toIso8601String(),
      ),
      checkOut: DateTime.parse(
        json['check_out'] ??
            json['checkout'] ??
            json['check_out_date'] ??
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      ),
      totalNights: json['total_nights'] is int
          ? json['total_nights']
          : int.tryParse(json['total_nights'].toString()) ?? 1,
      totalPrice:
          double.tryParse(json['total_price'].toString()) ??
          (double.tryParse(json['price'].toString()) ?? 0.0),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'hotel_name': hotelName,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'total_nights': totalNights,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
