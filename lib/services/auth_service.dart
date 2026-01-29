// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  final SharedPreferences? _prefs;

  // Make constructor flexible or use a factory/static method if needed
  AuthService([this._prefs]) {
    if (_prefs != null) {
      _loadUserFromPrefs();
    }
  }

  Future<void> _loadUserFromPrefs() async {
    if (_prefs == null) return;
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      try {
        _user = User.fromJson(json.decode(userJson));
        _token = _prefs.getString('token');
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading user from prefs: $e');
      }
    }
  }

  // Compatibility method for screens that use 'getCurrentUser'
  Future<User?> getCurrentUser() async {
    if (_user != null) return _user;
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
      return _user;
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.login(email, password);

      final ok =
          (res['status'] == true) ||
          (res['status'] == 'success') ||
          (res['status'] == 'ok');
      if (ok) {
        final userData = res['data'] ?? {};
        _user = User.fromJson(userData);
        _token =
            userData['api_token'] ?? userData['token'] ?? res['token'] ?? '';

        // Save to shared preferences
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(_user!.toJson()));
        if (_token != null && _token!.isNotEmpty) {
          await prefs.setString('token', _token!);
        }
        if (userData['id'] != null) {
          await prefs.setString('user_id', userData['id'].toString());
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
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
      final res = await ApiService.register(name, email, password, phone);

      final ok = (res['status'] == true) || (res['status'] == 'success');
      if (ok) {
        return await login(email, password);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('role');

    _user = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    if (_user != null && _token != null) return true;
    await _loadUserFromPrefs();
    return _user != null && _token != null;
  }
}
