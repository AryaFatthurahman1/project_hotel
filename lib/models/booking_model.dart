class Booking {
  int id;
  int userId;
  int roomId;
  DateTime checkIn;
  DateTime checkOut;
  int totalNights;
  double totalPrice;
  String status;
  String? paymentMethod;
  String paymentStatus;
  DateTime? createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.roomId,
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
      id: json['id'],
      userId: json['user_id'],
      roomId: json['room_id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      totalNights: json['total_nights'],
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': roomId,
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
