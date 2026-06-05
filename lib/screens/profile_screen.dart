import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Pastikan ini di-import
import 'login_screen.dart'; // Pastikan ini di-import untuk fungsi Log Out

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Tema Warna Material 3 Light Mode
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color surfaceContainer = const Color(0xFFEDEEEF);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color primaryFixedDim = const Color(0xFFADC7FF);
  final Color secondaryContainer = const Color(0xFFD2E6EF);
  final Color onSecondaryContainer = const Color(0xFF55676F);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  
  final Color errorContainer = const Color(0xFFFFDAD6);
  final Color onErrorContainer = const Color(0xFF93000A);
  final Color successGreen = const Color(0xFF4CAF50);

  // State untuk switch 2FA
  bool _is2faEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: outlineVariant.withOpacity(0.3), width: 1)),
        title: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=Zdanov&background=random")),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () {
              // NAVIGASI KE SETTINGS
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            // --- 1. PROFILE HEADER SECTION ---
            Center(
              child: Column(
                children: [
                  // Avatar dengan Gradien & Status Aktif
                  SizedBox(
                    width: 128, height: 128,
                    child: Stack(
                      children: [
                        // Cincin Gradien
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [primary, primaryFixedDim], begin: Alignment.bottomLeft, end: Alignment.topRight),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, border: Border.all(color: surfaceContainerLowest, width: 4),
                              image: const DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=600&auto=format&fit=crop"), fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        // Dot Status Online
                        Positioned(
                          bottom: 4, right: 8,
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(color: surfaceContainerLowest, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                            child: Center(
                              child: Container(width: 14, height: 14, decoration: BoxDecoration(color: successGreen, shape: BoxShape.circle)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nama & ID
                  Text("Zdanov", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: onSurface, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text("ID: FA-293847", style: TextStyle(fontSize: 16, color: onSurfaceVariant, letterSpacing: 1.0)),
                  const SizedBox(height: 24),
                  
                  // Tombol Edit Profile
                  OutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membuka halaman Edit Profile..."))),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary, side: BorderSide(color: outlineVariant.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      backgroundColor: surfaceContainerLowest, elevation: 1,
                    ),
                    child: const Text("Edit Profile", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. BIOMETRIC STATUS CARD ---
            Container(
              decoration: BoxDecoration(
                color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: outlineVariant.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 24, offset: const Offset(0, 4))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Efek Glow Blur di pojok kanan atas
                  Positioned(
                    right: -24, top: -24,
                    child: Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(color: primaryFixedDim.withOpacity(0.3), shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryFixedDim.withOpacity(0.3), blurRadius: 40, spreadRadius: 20)]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: secondaryContainer, shape: BoxShape.circle),
                          child: Icon(Icons.face, color: onSecondaryContainer, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Registered Face", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
                              const SizedBox(height: 4),
                              Text("Biometric identity active", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: primaryContainer.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                          child: Row(
                            children: [
                              Icon(Icons.verified, color: primaryContainer, size: 16),
                              const SizedBox(width: 4),
                              Text("Verified", style: TextStyle(color: primaryContainer, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. SECURITY SETTINGS CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: outlineVariant.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 24, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Security Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
                  const SizedBox(height: 20),
                  
                  // Password Row
                  _buildInteractiveRow(
                    icon: Icons.lock_outline, title: "Password & PIN", subtitle: "Updated 3 months ago",
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buka Pengaturan Password"))),
                  ),
                  
                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: outlineVariant.withOpacity(0.3))),
                  
                  // 2FA Row
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: surfaceContainer, shape: BoxShape.circle),
                        child: Icon(Icons.phonelink_lock, color: onSurfaceVariant, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Two-Factor Auth", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
                            const SizedBox(height: 2),
                            Text("SMS & Email enabled", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _is2faEnabled,
                        activeColor: primary,
                        onChanged: (val) {
                          setState(() => _is2faEnabled = val);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? "2FA Diaktifkan" : "2FA Dimatikan")));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 4. DEVICE INFO CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: outlineVariant.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 24, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Device Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.laptop_chromebook, color: onSurfaceVariant, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ASUS TUF Laptop", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                            const SizedBox(height: 4),
                            Text("Active now • Batam, ID", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 5. LOGOUT BUTTON ---
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // LOGIKA LOG OUT: Hapus semua tumpukan layar dan kembali ke halaman Login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorContainer.withOpacity(0.5),
                  foregroundColor: onErrorContainer,
                  elevation: 0,
                  side: BorderSide(color: onErrorContainer.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 100), // Spacer untuk Bottom Nav
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Baris yang bisa di-klik
  Widget _buildInteractiveRow({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: surfaceContainer, shape: BoxShape.circle),
              child: Icon(icon, color: onSurfaceVariant, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: outlineVariant),
          ],
        ),
      ),
    );
  }
}