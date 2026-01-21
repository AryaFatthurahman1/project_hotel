// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
// import 'api_service.dart'; // unused import removed
class AuthService with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  static const String _baseUrl = 'http://localhost:8080/api';
  final SharedPreferences _prefs;
  AuthService(this._prefs) {
    _loadUserFromPrefs();
  }
  Future<void> _loadUserFromPrefs() async {
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
      _token = _prefs.getString('token');
      notifyListeners();
    }
  }
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/test_login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // accept both boolean true or string 'success'
        final ok = (data['status'] == true) || (data['status'] == 'success') || (data['status'] == 'ok');
        if (ok) {
          final userJson = data['data'] ?? {};
          _user = User.fromJson(userJson);
          _token = userJson['api_token'] ?? userJson['token'] ?? data['token'] ?? '';

          // Save to shared preferences
          await _prefs.setString('user', json.encode(_user!.toJson()));
          if (_token != null && _token!.isNotEmpty) await _prefs.setString('token', _token!);

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8081/test_register_fixed.php'),
        body: {
          'nama_lengkap': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
        },
      );
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final ok = (data['status'] == true) || (data['status'] == 'success');
        if (ok) {
          // Auto login after registration
          return await login(email, password);
        }
        throw Exception(data['message'] ?? 'Registration failed');
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<void> logout() async {
    await _prefs.remove('user');
    await _prefs.remove('token');
    _user = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }
  // Add this method to check if user is logged in
  Future<bool> checkAuth() async {
    if (_user != null && _token != null) return true;
    
    await _loadUserFromPrefs();
    return _user != null && _token != null;
  }
}