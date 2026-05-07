import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Testing registration for Arya...');
  
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8081/test_register_fixed.php'),
      body: {
        'nama_lengkap': 'Muhammad Arya Fatthurahman',
        'email': 'aryafatthurahman4@gmail.com',
        'phone': '',
        'password': 'arya123',
        'password_confirmation': 'arya123',
      },
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        print('✅ Registration successful!');
        print('User: ${data['data']['nama_lengkap']}');
        print('Email: ${data['data']['email']}');
        print('Token: ${data['data']['token']}');
      } else {
        print('❌ Registration failed: ${data['message']}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
