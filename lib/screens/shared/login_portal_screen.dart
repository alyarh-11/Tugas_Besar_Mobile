import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../constants/colors.dart';
import '../../api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPortalScreen extends StatefulWidget {
  const LoginPortalScreen({super.key});

  @override
  State<LoginPortalScreen> createState() => _LoginPortalScreenState();
}

class _LoginPortalScreenState extends State<LoginPortalScreen> {
  int _selectedRole = 0; // 0: Admin, 1: Student
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // <--- State untuk indikator loading (Slide 10)

  // === INTEGRASI DINAMIS BACKEND LARAGON (Sesuai Slide 6 & 10) ===
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String emailInput = _emailController.text.trim();
      String passwordInput = _passwordController.text.trim();

      // Menembak REST API login.php di Laragon via ApiService
      var response = await ApiService.login(emailInput, passwordInput);

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        String dbRole = response['role']; // Mengambil nilai role dari database ('admin' / 'student')

        // Validasi kecocokan role pilihan UI dengan role asli di database MySQL
        String selectedRoleStr = _selectedRole == 0 ? 'admin' : 'student';

        if (dbRole == selectedRoleStr) {
          // Save session to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', response['id'].toString());
          await prefs.setString('user_email', response['email'] ?? '');
          await prefs.setString('user_role', dbRole);
          await prefs.setString('user_full_name', response['full_name'] ?? '');
          await prefs.setString('user_phone', response['phone'] ?? '');
          await prefs.setString('user_profile_image', response['profile_image'] ?? '');

          // Jika cocok, lakukan Conditional Routing sesuai Hak Akses
          if (dbRole == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/student-dashboard');
          }
        } else {
          // Jika akun terdaftar namun user salah memilih segment peran di UI
          _showErrorSnackBar("Akses ditolak! Akun Anda terdaftar sebagai $dbRole.");
        }
      } else {
        // Tampilkan pesan kegagalan jika password salah / jaringan putus (Slide 10)
        _showErrorSnackBar(response['message']);
      }
    }
  }

  // Fungsi pembantu untuk memunculkan SnackBar (Slide 10)
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            margin: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_balance, size: 64, color: AppColors.primaryBlue),
                  const SizedBox(height: 16),
                  const Text('Pocket Library', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 24),
                  
                  // Segmented Control iOS Style
                  CupertinoSlidingSegmentedControl<int>(
                    groupValue: _selectedRole,
                    backgroundColor: AppColors.background,
                    thumbColor: Colors.white,
                    children: {
                      0: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Admin', style: TextStyle(fontWeight: _selectedRole == 0 ? FontWeight.bold : FontWeight.normal, color: AppColors.textPrimary))),
                      1: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Student', style: TextStyle(fontWeight: _selectedRole == 1 ? FontWeight.bold : FontWeight.normal, color: AppColors.textPrimary))),
                    },
                    onValueChanged: (val) => setState(() => _selectedRole = val ?? 0),
                  ),
                  const SizedBox(height: 24),

                  // Input Email
                  TextFormField( 
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading, 
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Please enter your email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !_isLoading, // Kunci input jika sedang loading
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val!.length < 6 ? 'Password must be min 6 characters' : null,
                  ),
                  const SizedBox(height: 12),



                  // Button Sign In dengan Animasi Loading Indikator
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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