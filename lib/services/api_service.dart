import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../models/booking.dart';
import '../models/article.dart';

class ApiService {
  // During development use local PHP server to avoid CORS issues. Change to production URL when deployed.
  static const String baseUrl = "https://arya.bersama.cloud";

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
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Koneksi gagal: $e'
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
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Koneksi gagal: $e'
      };
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return post("/login.php", data: {"email": email, "password": password});
  }

  // Register
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    return post("/register.php", data: {
      "nama_lengkap": name,
      "email": email,
      "password": password,
      "password_confirmation": password,
    });
  }

  // Auth Check
  static Future<Map<String, dynamic>> authCheck(String token) async {
    return post("/auth.php", token: token);
  }

  // Get Hotels
  static Future<List<Hotel>> getHotels() async {
    final response = await http.get(Uri.parse("$baseUrl/get_data.php?table=hotels"));
    final result = jsonDecode(response.body);
    
    final ok = result['status'] == 'success' || result['status'] == true;
    if (ok) {
      return (result['data'] as List).map((item) => Hotel.fromJson(item)).toList();
    }
    return [];
  }

  // Get Articles
  static Future<List<Article>> getArticles() async {
    final response = await http.get(Uri.parse("$baseUrl/get_data.php?table=articles"));
    final result = jsonDecode(response.body);
    final ok = result['status'] == 'success' || result['status'] == true;
    if (ok) {
      return (result['data'] as List).map((item) => Article.fromJson(item)).toList();
    }
    return [];
  }

  // Get Bookings by User
  static Future<List<Booking>> getBookings(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/get_data.php?table=bookings&user_id=$userId"));
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
      Uri.parse("$baseUrl/insert_data.php"),
      body: bookingData,
    );
    return jsonDecode(response.body);
  }

  // Update Data
  static Future<Map<String, dynamic>> updateData(String table, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_data.php"),
      body: {"table": table, ...data},
    );
    return jsonDecode(response.body);
  }

  // Delete Data
  static Future<Map<String, dynamic>> deleteData(String table, int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_data.php"),
      body: {"table": table, "id": id.toString()},
    );
    return jsonDecode(response.body);
  }
}