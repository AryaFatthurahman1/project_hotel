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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController(text: 'arya');
  final TextEditingController _passController = TextEditingController(text: '123');
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveSession(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id.toString());
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    if (user.role != null) await prefs.setString('role', user.role!);
    if (user.apiToken != null) await prefs.setString('token', user.apiToken!);
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showMessage('Peringatan', 'Mohon lengkapi email dan kata sandi Anda.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> res = await ApiService.login(_emailController.text.trim(), _passController.text);
      
      final ok = (res['status'] == true) || (res['status'] == 'success');
      if (ok) {
        User user = User.fromJson(Map<String, dynamic>.from(res['data'] ?? {}));
        await _saveSession(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Selamat Datang Kembali, ${user.name}"),
              backgroundColor: const Color(0xFFD4AF37),
              behavior: SnackBarBehavior.floating,
            )
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user: user)));
        }
      } else {
        _showMessage('Gagal Masuk', res['message'] ?? 'Email atau kata sandi tidak sesuai.');
      }
    } catch (e) {
      _showMessage('Gangguan Koneksi', 'Pastikan localhost:8000 sudah aktif.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3022),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  const Color(0xFF0F1B14).withOpacity(0.9),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 60),
                      const SizedBox(height: 20),
                      const Text(
                        'THE EMERALD\nIMPERIAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 8,
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'KEMEWAHAN DALAM SETIAP DETAIL',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 2),
                      ),
                      const SizedBox(height: 50),
                      
                      // Login Card
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              label: 'EMAIL ATAU USERNAME',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _passController,
                              label: 'KATA SANDI',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : const Text('MASUK KE AKUN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Account Shortcuts
                      const Text('ATAU GUNAKAN AKUN KHUSUS:', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildShortcut('arya', () {
                            setState(() {
                              _emailController.text = 'arya';
                              _passController.text = '123';
                            });
                          }),
                          const SizedBox(width: 10),
                          _buildShortcut('aryafattur', () {
                            setState(() {
                              _emailController.text = 'aryafatthurahman4@gmail.com';
                              _passController.text = 'arya123';
                            });
                          }),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Belum memiliki akses? ',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'DAFTAR SEKARANG',
                                style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcut(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
