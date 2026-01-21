import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../models/booking.dart';
import '../models/article.dart';

class ApiService {
  // Use production URL for live cloud testing
  static const String baseUrl = "https://arya.bersama.cloud";
  // For local development, use: http://localhost:8000

  static Future<Map<String, dynamic>> post(String endpoint, 
      {Map<String, dynamic>? data, String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      
      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html>')) {
        return {
          'status': false,
          'message': 'Server Error (HTML): Pastikan URL $baseUrl$endpoint benar dan file .htaccess sudah diupload.'
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
  
  static Future<Map<String, dynamic>> get(String endpoint, 
      {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html>')) {
        return {
          'status': false,
          'message': 'Server Error (HTML): Gagal mengambil data dari $endpoint'
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

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return post("/login", data: {"email": email, "password": password});
  }

  // Register
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    return post("/register", data: {
      "nama_lengkap": name,
      "email": email,
      "password": password,
      "password_confirmation": password,
    });
  }

  // Force Admin Bypass (requested by user)
  static Map<String, dynamic> adminBypass() {
    return {
      "status": true,
      "message": "Akses Admin Diberikan",
      "data": {
        "id": 1,
        "name": "Muhammad Arya Fatthurahman",
        "email": "aryafatthurahman4@gmail.com",
        "role": "admin",
        "token": "MASTER_ADMIN_BYPASS_TOKEN"
      }
    };
  }

  // Auth Check
  static Future<Map<String, dynamic>> authCheck(String token) async {
    return post("/auth", token: token);
  }

  // Get Hotels
  static Future<List<Hotel>> getHotels() async {
    final response = await http.get(Uri.parse("$baseUrl/get_data?table=hotels"));
    final result = jsonDecode(response.body);
    
    final ok = result['status'] == 'success' || result['status'] == true;
    if (ok) {
      return (result['data'] as List).map((item) => Hotel.fromJson(item)).toList();
    }
    return [];
  }

  // Get Articles
  static Future<List<Article>> getArticles() async {
    final response = await http.get(Uri.parse("$baseUrl/get_data?table=articles"));
    final result = jsonDecode(response.body);
    final ok = result['status'] == 'success' || result['status'] == true;
    if (ok) {
      return (result['data'] as List).map((item) => Article.fromJson(item)).toList();
    }
    return [];
  }

  // Get Bookings by User
  static Future<List<Booking>> getBookings(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/get_data?table=bookings&user_id=$userId"));
    final result = jsonDecode(response.body);
    final ok = result['status'] == 'success' || result['status'] == true;
    if (ok) {
      return (result['data'] as List).map((item) => Booking.fromJson(item)).toList();
    }
    return [];
  }

  // Insert Booking
  static Future<Map<String, dynamic>> insertBooking(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/insert_data"),
      body: bookingData,
    );
    return jsonDecode(response.body);
  }

  // Update Data
  static Future<Map<String, dynamic>> updateData(String table, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_data"),
      body: {"table": table, ...data},
    );
    return jsonDecode(response.body);
  }

  // Delete Data
  static Future<Map<String, dynamic>> deleteData(String table, int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_data"),
      body: {"table": table, "id": id.toString()},
    );
    return jsonDecode(response.body);
  }
}