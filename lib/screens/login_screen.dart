import 'package:flutter/material.dart';
import 'register_screen.dart'; // Pastikan file ini sudah kamu buat
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPwd = false;
  bool _remember = false;
  bool _loading = false;

  // Warna yang diekstrak dari desain HTML kamu
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color surfaceContainer = const Color(0xFFEDEEEF);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color outline = const Color(0xFF727785);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  void _handleLogin() {
    setState(() => _loading = true);
    
    Future.delayed(const Duration(milliseconds: 1500), () {
  if (mounted) {
    setState(() => _loading = false);
    
    // GANTI DENGAN PAGE_ROUTE_BUILDER UNTUK ANIMASI PREMIUM
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          
          // Animasi Muncul dari Bawah (Slide Up)
          var begin = const Offset(0.0, 0.05); // Mulai sedikit dari bawah
          var end = Offset.zero; // Berhenti di posisi asli
          var curve = Curves.easeOutQuart; // Gerakan melambat elegan

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // Animasi Memudar (Fade)
          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700), // Sedikit dilamain biar berasa premium
      ),
    );
  }
});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            // Perbaikan maxWidth menggunakan BoxConstraints
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: outlineVariant.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Decorative Header Shape (Gradient transparan di bagian atas card)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Container(
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryContainer.withOpacity(0.05), 
                          primary.withOpacity(0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // 2. Konten Utama Card
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: surfaceContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: outlineVariant.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.face_retouching_natural, color: primary, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "FaceAttend",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Secure biometric access",
                        style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),

                      // Input Email
                      _buildLabel("Email"),
                      _buildTextField(
                        hint: "name@company.com",
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel("Password"),
                          Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w600, 
                              color: primary
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        hint: "••••••••",
                        icon: Icons.lock_outline,
                        obscure: !_showPwd,
                        isPassword: true,
                      ),
                      const SizedBox(height: 12),

                      // Remember Me Checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _remember,
                              onChanged: (val) => setState(() => _remember = val!),
                              activeColor: primary,
                              side: BorderSide(color: outlineVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Remember me", 
                            style: TextStyle(fontSize: 14, color: onSurfaceVariant)
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tombol Login dengan Gradien
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryContainer, primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _loading ? null : _handleLogin,
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 20, 
                                      height: 20, 
                                      child: CircularProgressIndicator(
                                        color: Colors.white, 
                                        strokeWidth: 2
                                      )
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontSize: 16, 
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Divider "OR"
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Expanded(child: Container(height: 1, color: outlineVariant.withOpacity(0.3))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR", 
                                style: TextStyle(
                                  color: outline, 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w600
                                )
                              ),
                            ),
                            Expanded(child: Container(height: 1, color: outlineVariant.withOpacity(0.3))),
                          ],
                        ),
                      ),

                      // Social Buttons (Google & Face ID)
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                              icon: Icons.g_mobiledata,
                              label: "Google",
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSocialButton(
                              icon: Icons.fingerprint,
                              label: "Face ID",
                              color: primary,
                              isFaceId: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Navigasi ke Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ", 
                            style: TextStyle(color: onSurfaceVariant, fontSize: 14)
                          ),
                            GestureDetector(
                            onTap: () {
                              // Navigasi dengan Animasi Custom
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    
                                    // 1. Animasi Geser dari Kanan (Horizontal Slide)
                                    var begin = const Offset(1.0, 0.0); // Mulai dari luar layar sebelah kanan
                                    var end = Offset.zero; // Berhenti di posisi asli
                                    var curve = Curves.easeOutQuart; // Gerakan melambat yang elegan

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);

                                    // 2. Animasi Memudar (Fade)
                                    var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                      CurvedAnimation(parent: animation, curve: Curves.easeIn),
                                    );

                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  // Durasi transisi (600ms biar kerasa smooth tapi tetep cepet)
                                  transitionDuration: const Duration(milliseconds: 600),
                                ),
                              );
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: primary, 
                                fontSize: 14, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Label Input
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text, 
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w500, 
          color: onSurfaceVariant
        )
      ),
    );
  }

  // Widget Helper untuk TextField
  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    bool obscure = false, 
    bool isPassword = false
  }) {
    return TextField(
      obscureText: obscure,
      style: TextStyle(color: onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: outline, fontSize: 14),
        prefixIcon: Icon(icon, color: outline, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                  color: outline, 
                  size: 20
                ),
                onPressed: () => setState(() => _showPwd = !_showPwd),
              )
            : null,
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // Widget Helper untuk Social Button
  Widget _buildSocialButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    bool isFaceId = false
  }) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: surfaceContainerLow,
        side: BorderSide(
          color: isFaceId ? primary.withOpacity(0.2) : outlineVariant.withOpacity(0.5)
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, color: color, size: isFaceId ? 24 : 28),
      label: Text(
        label, 
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)
      ),
    );
  }
}