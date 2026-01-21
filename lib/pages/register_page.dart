// lib/pages/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Peringatan', 'Password dan konfirmasi password tidak sama');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Register dengan API
      Map<String, dynamic> res = await ApiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      final ok = (res['status'] == true) || (res['status'] == 'success');
      
      if (ok) {
        // Jika register berhasil, login otomatis
        Map<String, dynamic> loginRes = await ApiService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        final loginOk = (loginRes['status'] == true) || (loginRes['status'] == 'success');
        
        if (loginOk) {
          User user = User.fromJson(Map<String, dynamic>.from(loginRes['data'] ?? {}));
          await _saveSession(user);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Selamat! Akun ${user.name} telah dibuat."),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user: user)),
            );
          }
        } else {
          _showMessage('Registrasi Berhasil', 'Silakan login dengan akun Anda');
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        _showMessage('Registrasi Gagal', res['message'] ?? 'Terjadi kesalahan saat mendaftar');
      }
    } catch (e) {
      _showMessage('Error', 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Color(0xFF0F1B14),
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&q=80'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: Column(
                children: [
                  // Logo
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 35,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'BERGABUNG DENGAN KAMI',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD4AF37),
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Card Register
                  Container(
                    width: double.infinity,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BUAT AKUN BARU',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'NIKMATI PENGALAMAN MENGINAP TAK TERLUPAKAN',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white38,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Nama Field
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "NAMA LENGKAP",
                              labelStyle: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                              prefixIcon: Icon(Icons.person_outline, color: Color(0xFFD4AF37), size: 18),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                            ),
                            enabled: !_isLoading,
                            validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 25),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "ALAMAT EMAIL",
                              labelStyle: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                              prefixIcon: Icon(Icons.mail_outline, color: Color(0xFFD4AF37), size: 18),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                              if (!value.contains('@')) return 'Format email salah';
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "KATA SANDI",
                              labelStyle: const TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white24, size: 16),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                            ),
                            enabled: !_isLoading,
                            validator: (value) => value == null || value.length < 6 ? 'Minimal 6 karakter' : null,
                          ),
                          const SizedBox(height: 25),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "KONFIRMASI KATA SANDI",
                              labelStyle: const TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                              prefixIcon: const Icon(Icons.lock_reset_outlined, color: Color(0xFFD4AF37), size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white24, size: 16),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                            ),
                            enabled: !_isLoading,
                            validator: (value) => value != _passwordController.text ? 'Kata sandi tidak sesuai' : null,
                          ),
                          
                          const SizedBox(height: 50),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                  : const Text('DAFTAR SEKARANG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Login Link
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'SUDAH MEMILIKI AKUN? ',
                                  style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                                  children: [
                                    TextSpan(
                                      text: 'MASUK DI SINI',
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
                  ),

                  const SizedBox(height: 50),

                  // Footer
                  const Text(
                    '© 2026 ARYA HOTEL GROUP. ALL RIGHTS RESERVED.',
                    style: TextStyle(fontSize: 8, color: Colors.white24, letterSpacing: 2),
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
