import 'package:flutter/material.dart';
import 'animated_button_wrapper.dart'; // <--- TAMBAHKAN INI

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _showPwd = false;
  bool _showConfirmPwd = false;

  // Warna Material 3 dari HTML kamu
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryFixed = const Color(0xFFD8E2FF);
  final Color outline = const Color(0xFF727785);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => Navigator.pop(context), // Kembali ke halaman Login
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Text(
                "Register",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Create your FaceAttend profile.",
                style: TextStyle(fontSize: 16, color: onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // --- Photo Picker ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: surfaceContainerLow,
                            shape: BoxShape.circle,
                            // Di Flutter standar tidak ada dashed border, kita pakai solid border tipis
                            border: Border.all(color: outlineVariant, width: 2),
                          ),
                          child: Icon(Icons.add_a_photo_outlined, color: outline, size: 36),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: surface, width: 2),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Profile Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Form Fields ---
              _buildTextField(label: "Full Name", hint: "John Doe", icon: Icons.person_outline),
              const SizedBox(height: 16),
              
              _buildTextField(label: "ID Number", hint: "EMP-12345", icon: Icons.badge_outlined),
              const SizedBox(height: 16),
              
              _buildTextField(label: "Email", hint: "john@company.com", icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              
              _buildTextField(label: "Phone", hint: "+1 (555) 000-0000", icon: Icons.call_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: "Password", 
                hint: "••••••••", 
                icon: Icons.lock_outline, 
                isPassword: true,
                obscure: !_showPwd,
                onTogglePassword: () => setState(() => _showPwd = !_showPwd),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                label: "Confirm Password", 
                hint: "••••••••", 
                icon: Icons.lock_reset_outlined, 
                isPassword: true,
                obscure: !_showConfirmPwd,
                onTogglePassword: () => setState(() => _showConfirmPwd = !_showConfirmPwd),
              ),
              const SizedBox(height: 32),

              // --- Register Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    print("Tombol Register Ditekan!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Footer Login Link ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: onSurfaceVariant, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Kembali ke halaman Login
                    child: Text(
                      "Sign In",
                      style: TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk TextField yang rapi
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
        ),
        TextField(
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(color: onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: outlineVariant, fontSize: 16),
            prefixIcon: Icon(icon, color: outlineVariant, size: 22),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: outlineVariant, size: 22),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Mengikuti rounded-xl tailwind
              borderSide: BorderSide(color: outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}