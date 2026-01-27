import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'current_user';

  // REGISTER
  Future<bool> register(User newUser) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing users
    List<User> users = [];
    String? usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      List<dynamic> usersList = jsonDecode(usersJson);
      users = usersList.map((e) => User.fromMap(e)).toList();
    }

    // Check if email already exists
    if (users.any((u) => u.email == newUser.email)) {
      return false; // Email already taken
    }

    // Add new user
    users.add(newUser);
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toMap()).toList()));
    return true;
  }

  // LOGIN
  Future<User?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    String? usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      List<dynamic> usersList = jsonDecode(usersJson);
      List<User> users = usersList.map((e) => User.fromMap(e)).toList();

      try {
        User user = users.firstWhere(
          (u) => u.email == email && u.password == password,
        );
        
        // Save session
        await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
        return user;
      } catch (e) {
        return null; // User not found or wrong password
      }
    }
    return null;
  }

  // GET CURRENT SESSION
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_currentUserKey);
    if (userJson != null) {
      return User.fromMap(jsonDecode(userJson));
    }
    return null;
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
