import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Testing login with arya/123...');
  
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8081/test_login.php'),
      body: {
        'email': 'arya',
        'password': '123',
      },
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        print('Login successful!');
        print('User: ${data['data']['nama_lengkap']}');
        print('Token: ${data['data']['token']}');
      } else {
        print('Login failed: ${data['message']}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
