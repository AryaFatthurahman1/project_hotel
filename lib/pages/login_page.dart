import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(text: 'arya');
  final TextEditingController _passController = TextEditingController(text: '123');
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Simpan session ke SharedPreferences
  Future<void> _saveSession(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id.toString());
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    if (user.role != null) await prefs.setString('role', user.role!);
    if (user.apiToken != null) await prefs.setString('token', user.apiToken!);
  }

  // Login
  void _login() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showMessage('Peringatan', 'Username/Email dan kata sandi harus diisi!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kita coba kirim ke API login
      Map<String, dynamic> res = await ApiService.login(_emailController.text.trim(), _passController.text);
      
      final ok = (res['status'] == true) || (res['status'] == 'success');
      if (ok) {
        User user = User.fromJson(Map<String, dynamic>.from(res['data'] ?? {}));
        await _saveSession(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Selamat Datang, ${user.name}!"),
              backgroundColor: const Color(0xFFD4AF37), // Gold
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(user: user)),
          );
        }
      } else {
        _showMessage('Akses Ditolak', res['message'] ?? 'Data yang Anda masukkan tidak sesuai.');
      }
    } catch (e) {
      _showMessage('Gangguan Koneksi', 'Gagal terhubung ke server. Pastikan server lokal Anda aktif.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Message Box
  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('MENGERTI', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Color(0xFF0F1B14), // Ultra dark green
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&q=80'),
            fit: BoxFit.cover,
            opacity: 0.2, // Dark overlay effect
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
              child: Column(
                children: [
                  // Logo dan Judul
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome,
                              size: 45,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'ARYA HOTEL',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 2,
                          width: 50,
                          color: const Color(0xFFD4AF37),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'KEMEWAHAN DALAM SETIAP DETAIL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Form Masuk
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SELAMAT DATANG KEMBALI',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Input Field Email
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "USERNAME / EMAIL",
                            labelStyle: const TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1),
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFD4AF37), size: 20),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          enabled: !_isLoading,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Input Field Password
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "KATA SANDI",
                            labelStyle: const TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.white38,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          enabled: !_isLoading,
                        ),

                        const SizedBox(height: 50),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                : const Text(
                                    'MASUK KE AKUN',
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Register Link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: 'TIDAK MEMILIKI AKUN? ',
                                style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                                children: [
                                  TextSpan(
                                    text: 'DAFTAR SEKARANG',
                                    style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),

                  // Footer
                  const Text(
                    '© 2026 ARYA HOTEL GROUP. ALL RIGHTS RESERVED.',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white24,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
