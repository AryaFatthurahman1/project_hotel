class Reservation {
  final int id;
  final int userId;
  final int hotelId;
  final String checkInDate;
  final String checkOutDate;
  final int totalNights;
  final double totalPrice;
  final String totalPriceFormatted;
  final int guestCount;
  final String? specialRequest;
  final String status;
  final String paymentStatus;
  final String createdAt;
  
  // Joined data
  final String? hotelName;
  final String? hotelImageUrl;
  final String? hotelAddress;
  final String? guestName;
  final String? guestEmail;

  Reservation({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.totalPrice,
    required this.totalPriceFormatted,
    required this.guestCount,
    this.specialRequest,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.hotelName,
    this.hotelImageUrl,
    this.hotelAddress,
    this.guestName,
    this.guestEmail,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      hotelId: int.tryParse(json['hotel_id'].toString()) ?? 0,
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      totalNights: int.tryParse(json['total_nights'].toString()) ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      totalPriceFormatted: json['total_price_formatted'] ?? 'Rp 0',
      guestCount: int.tryParse(json['guest_count'].toString()) ?? 1,
      specialRequest: json['special_request'],
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      createdAt: json['created_at'] ?? '',
      hotelName: json['hotel_name'],
      hotelImageUrl: json['image_url'],
      hotelAddress: json['address'],
      guestName: json['full_name'],
      guestEmail: json['email'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'checked_in':
        return 'Check-In';
      case 'checked_out':
        return 'Check-Out';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get paymentLabel {
    switch (paymentStatus) {
      case 'unpaid':
        return 'Belum Bayar';
      case 'paid':
        return 'Sudah Bayar';
      case 'refunded':
        return 'Refund';
      default:
        return paymentStatus;
    }
  }
}
