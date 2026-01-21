import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/test_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      title: 'HotelStay - Hotel Booking App', // Poin c
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
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://picsum.photos/seed/hotellogo/150/150',
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Loading...'),
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
      routes: {
        '/test': (context) => const TestLoginPage(),
      },
    );
  }
}

