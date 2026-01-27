import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // API Base URL - Update setelah deploy ke cPanel
  // Untuk testing lokal, gunakan: http://localhost/api atau http://10.0.2.2/api (Android Emulator)
  static const String baseUrl = 'https://kilimanjaro.iixcp.rumahweb.net/api';

  static const Duration timeout = Duration(seconds: 30);

  // ==================== USERS API ====================

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users.php?action=register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users.php?action=login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      final result = jsonDecode(response.body);

      // Save user data to SharedPreferences if login successful
      if (result['success'] == true && result['data'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(result['data']));
        if (result['token'] != null) {
          await prefs.setString('auth_token', result['token']);
        }
        await prefs.setBool('is_logged_in', true);
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ==================== UPLOAD API ====================

  static Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload.php'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.setBool('is_logged_in', false);
  }

  // ==================== HOTELS API ====================

  static Future<Map<String, dynamic>> getHotels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hotels.php'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHotelDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hotels.php?action=detail&id=$id'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> searchHotels({
    String? city,
    String? roomType,
    double? minPrice,
    double? maxPrice,
    String? keyword,
  }) async {
    try {
      final params = <String, String>{};
      if (city != null) params['city'] = city;
      if (roomType != null) params['room_type'] = roomType;
      if (minPrice != null) params['min_price'] = minPrice.toString();
      if (maxPrice != null) params['max_price'] = maxPrice.toString();
      if (keyword != null) params['keyword'] = keyword;

      final uri = Uri.parse('$baseUrl/hotels.php?action=search')
          .replace(queryParameters: params);

      final response = await http.get(uri).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ==================== RESERVATIONS API ====================

  static Future<Map<String, dynamic>> createReservation({
    required int userId,
    required int hotelId,
    required String checkInDate,
    required String checkOutDate,
    int guestCount = 1,
    String? specialRequest,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations.php?action=create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'hotel_id': hotelId,
          'check_in_date': checkInDate,
          'check_out_date': checkOutDate,
          'guest_count': guestCount,
          'special_request': specialRequest,
        }),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserReservations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations.php?action=user&user_id=$userId'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> cancelReservation(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations.php?action=cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ==================== ARTICLES API ====================

  static Future<Map<String, dynamic>> getArticles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/articles.php'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getArticleDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/articles.php?action=detail&id=$id'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getArticlesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/articles.php?action=category&category=$category'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ==================== FOOD MENU API ====================

  static Future<Map<String, dynamic>> getFoodMenu() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food.php'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFeaturedFood() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food.php?action=featured'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFoodByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food.php?action=category&category=$category'),
      ).timeout(timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
