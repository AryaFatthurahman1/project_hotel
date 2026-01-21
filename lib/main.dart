import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      return User(
        id: int.parse(prefs.getString('user_id') ?? '0'),
        name: prefs.getString('name') ?? '',
        email: prefs.getString('email') ?? '',
        role: prefs.getString('role') ?? 'user',
        apiToken: token,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HotelStay - Hotel Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<User?>(
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: const Color(0xFF0F1B14),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 80),
                    SizedBox(height: 30),
                    CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    SizedBox(height: 20),
                    Text(
                      'THE EMERALD IMPERIAL',
                      style: TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            return HomePage(user: snapshot.data!);
          }
          
          return const LoginPage();
        },
      ),
    );
  }
}

