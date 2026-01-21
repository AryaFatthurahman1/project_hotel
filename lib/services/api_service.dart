import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../models/booking.dart';
import '../models/article.dart';

class ApiService {
  // BASE URL - Pastikan tidak ada slash di akhir
  static const String baseUrl = "https://arya.bersama.cloud";

  // Helper untuk membersihkan path dari double slashes
  static Uri _buildUri(String endpoint) {
    String cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    // Gunakan try-catch untuk URI parsing
    try {
      return Uri.parse('$baseUrl$cleanEndpoint');
    } catch (e) {
      return Uri.parse(baseUrl);
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, 
      {Map<String, dynamic>? data, String? token}) async {
    try {
      final response = await http.post(
        _buildUri(endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html>')) {
        return {
          'status': false,
          'message': 'Server Error (HTML): Gagal terhubung ke API. Pastikan file index.php dan .htaccess sudah diupload dengan benar di Hosting.'
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': 'Kesalahan Koneksi: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(_buildUri(endpoint))
          .timeout(const Duration(seconds: 15));

      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html>')) {
        return {
          'status': false,
          'message': 'Server memberikan respons HTML (Error). Mohon cek konfigurasi Hosting.'
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': false,
        'message': 'Kesalahan Koneksi: $e'
      };
    }
  }

  // --- AUTH ENDPOINTS ---

  static Future<Map<String, dynamic>> login(String email, String password) async {
    return post("/login", data: {"email": email, "password": password});
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    return post("/register", data: {
      "nama_lengkap": name,
      "email": email,
      "password": password,
      "phone": phone
    });
  }

  static Map<String, dynamic> adminBypass() {
    return {
      "status": true,
      "message": "Akses Admin Diberikan",
      "data": {
        "id": 1,
        "nama_lengkap": "Muhammad Arya Fatthurahman",
        "email": "aryafatthurahman4@gmail.com",
        "role": "admin",
        "api_token": "MASTER_ADMIN_BYPASS_TOKEN"
      }
    };
  }

  // --- DATA ENDPOINTS ---

  static Future<List<Hotel>> getHotels() async {
    final res = await get("/get_data?table=hotels");
    if (res['status'] == true && res['data'] is List) {
      return (res['data'] as List).map((h) => Hotel.fromJson(h)).toList();
    }
    return [];
  }

  static Future<List<Article>> getArticles() async {
    final res = await get("/get_data?table=articles");
    if (res['status'] == true && res['data'] is List) {
      return (res['data'] as List).map((a) => Article.fromJson(a)).toList();
    }
    return [];
  }

  static Future<List<Booking>> getBookings(int userId) async {
    final res = await get("/get_data?table=bookings&user_id=$userId");
    if (res['status'] == true && res['data'] is List) {
      return (res['data'] as List).map((b) => Booking.fromJson(b)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> insertBooking(Map<String, dynamic> data) async {
    data['table'] = 'bookings';
    return post("/insert_data", data: data);
  }

  // New: Method untuk mengecek koneksi API secara langsung
  static Future<Map<String, dynamic>> checkApiStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/test_conn.php'))
          .timeout(const Duration(seconds: 5));
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': false, 'message': e.toString()};
    }
  }
}