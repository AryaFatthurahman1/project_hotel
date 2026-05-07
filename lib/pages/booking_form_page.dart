import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class BookingFormPage extends StatefulWidget {
  final Hotel hotel;
  final User user;

  const BookingFormPage({super.key, required this.hotel, required this.user});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));
  bool _isLoading = false;

  int get _nights => _checkOut.difference(_checkIn).inDays;
  double get _totalPrice => widget.hotel.price * (_nights > 0 ? _nights : 1);

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF1B3022),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut.isBefore(_checkIn)) {
            _checkOut = _checkIn.add(const Duration(days: 1));
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    setState(() => _isLoading = true);
    
    final bookingData = {
      "user_id": widget.user.id.toString(),
      "hotel_id": widget.hotel.id.toString(),
      "check_in": DateFormat('yyyy-MM-dd').format(_checkIn),
      "check_out": DateFormat('yyyy-MM-dd').format(_checkOut),
      "total_price": _totalPrice.toString(),
      "status": "confirmed",
      "token": widget.user.apiToken,
    };

    final res = await ApiService.insertBooking(bookingData);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (res['status'] == true || res['status'] == 'success') {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal membuat pesanan')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3022),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 60),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PESANAN BERHASIL!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Terima kasih telah memilih ${widget.hotel.name}. E-ticket telah dibuat.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to detail
                Navigator.pop(context); // Back to home
              },
              child: const Text('KEMBALI KE BERANDA', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B14),
      appBar: AppBar(
        title: const Text('KONFIRMASI PEMESANAN', style: TextStyle(fontSize: 14, letterSpacing: 2)),
        backgroundColor: const Color(0xFF1B3022),
        foregroundColor: const Color(0xFFD4AF37),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.hotel.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.hotel.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(width: 80, height: 80, color: Colors.grey),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hotel.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(widget.hotel.location, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text('DETAIL MENGINAP', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 20),

            // Check-in Date Picker
            _buildDatePickerTile('CHECK-IN', _checkIn, () => _selectDate(context, true)),
            const SizedBox(height: 15),
            // Check-out Date Picker
            _buildDatePickerTile('CHECK-OUT', _checkOut, () => _selectDate(context, false)),

            const SizedBox(height: 40),
            const Text('RINCIAN PEMBAYARAN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 20),

            _buildPriceRow('Harga Per Malam', widget.hotel.price),
            _buildPriceRow('Durasi', '${_nights > 0 ? _nights : 1} Malam'),
            const Divider(color: Colors.white10, height: 30),
            _buildPriceRow('TOTAL PEMBAYARAN', _totalPrice, isTotal: true),

            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('KONFIRMASI & BAYAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 5),
                Text(DateFormat('dd MMMM yyyy').format(date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.white : Colors.white60, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            value is double ? 'Rp ${value.toStringAsFixed(0)}' : value.toString(),
            style: TextStyle(
              color: isTotal ? const Color(0xFFD4AF37) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
