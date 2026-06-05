import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  int _registeredFacesCount = 0;
  final int _maxFaces = 3;

  // --- Palet Warna Material 3 sesuai HTML Tailwind ---
  final Color surface = const Color(0xFFF8F9FA);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFFE8EEF9); // Adaptasi transparansi
  final Color secondaryContainer = const Color(0xFFD2E6EF);
  final Color onSecondaryContainer = const Color(0xFF55676F);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  final Color errorContainer = const Color(0xFFFFDAD6);
  final Color onErrorContainer = const Color(0xFF93000A);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainer = const Color(0xFFEDEEEF);
  
  // ID Dummy untuk testing
  final String dummyUserId = '187ffdb7-121c-4581-8dfe-6b9299cafdbb';

  @override
  void initState() {
    super.initState();
    _fetchFaceData();
  }

  // Tarik data dari Supabase
  Future<void> _fetchFaceData() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('face_embeddings')
          .eq('id', dummyUserId)
          .maybeSingle();

      if (data != null && data['face_embeddings'] != null) {
        final embeddings = data['face_embeddings'] as List<dynamic>;
        if (mounted) {
          setState(() {
            _registeredFacesCount = embeddings.length;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _registeredFacesCount = 0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Tembak data ke Supabase
  Future<void> _registerDummyFace() async {
    setState(() => _isLoading = true);
    try {
      final dummyFaceEmbedding = [0.12, 0.45, 0.89, 0.33, 0.91]; 
      List<dynamic> currentEmbeddings = [];
      
      try {
        final existingData = await _supabase
            .from('profiles')
            .select('face_embeddings')
            .eq('id', dummyUserId)
            .maybeSingle();
            
        if (existingData != null && existingData['face_embeddings'] != null) {
          currentEmbeddings = List.from(existingData['face_embeddings']);
        }
      } catch (e) {
        // Abaikan jika belum ada data
      }

      if (currentEmbeddings.length < _maxFaces) {
        currentEmbeddings.add(dummyFaceEmbedding);
      }

      await _supabase.from('profiles').upsert({
        'id': dummyUserId,
        'full_name': 'Jane Doe',
        'student_id': 'FA-293847',
        'face_embeddings': currentEmbeddings,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Berhasil kirim muka ke Supabase!"), backgroundColor: Colors.green),
        );
      }
      await _fetchFaceData(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal: $e"), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      // --- TopAppBar ---
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0, // Mencegah perubahan warna saat di-scroll
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: secondaryContainer,
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage("https://ui-avatars.com/api/?name=J+D&background=D2E6EF&color=55676F"),
                )
              ),
            ),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: outlineVariant.withOpacity(0.2), height: 1.0),
        ),
      ),
      
      // --- Main Content ---
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Profile Header
                _buildProfileHeader(),
                const SizedBox(height: 32),

                // 2. Bento Grid Cards
                _buildBiometricStatusCard(),
                const SizedBox(height: 16),
                _buildSecuritySettingsCard(),
                const SizedBox(height: 16),
                _buildDeviceInfoCard(),
                const SizedBox(height: 24),

                // 3. Logout Button
                _buildLogoutButton(),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 128,
              height: 128,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, const Color(0xFFADC7FF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: surfaceContainerLowest, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage("https://i.pravatar.cc/300?img=47"), // Avatar dummy wanita
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Active Status Dot
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text("Jane Doe", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.5)),
        Text("ID: FA-293847", style: TextStyle(fontSize: 16, color: onSurfaceVariant, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: surfaceContainerLowest,
            foregroundColor: primary,
            side: BorderSide(color: outlineVariant.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {},
          child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // Card Biometrik yang Dinamis (Gabungan HTML + Logic Supabase)
  Widget _buildBiometricStatusCard() {
    bool isNotRegistered = _registeredFacesCount == 0;
    bool isMaxReached = _registeredFacesCount >= _maxFaces;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isNotRegistered ? Colors.red.withOpacity(0.3) : outlineVariant.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isNotRegistered ? errorContainer : secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNotRegistered ? Icons.warning_amber_rounded : Icons.face, 
                  color: isNotRegistered ? onErrorContainer : onSecondaryContainer
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMaxReached ? "Max Faces Registered" : (isNotRegistered ? "Face Not Registered" : "Registered Face"),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_registeredFacesCount/$_maxFaces biometric data active",
                      style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Badge Verified / Unverified
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isNotRegistered ? errorContainer : primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNotRegistered ? Icons.cancel : Icons.verified, 
                      size: 16, 
                      color: isNotRegistered ? onErrorContainer : primary
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isNotRegistered ? "Required" : "Verified",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isNotRegistered ? onErrorContainer : primary),
                    ),
                  ],
                ),
              )
            ],
          ),
          
          // Menambahkan Tombol Action di dalam Card
          if (!isMaxReached) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNotRegistered ? onErrorContainer : primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _registerDummyFace, // Tetap gunakan fungsi tembak Supabase
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: Text(
                  isNotRegistered ? "Scan Face Now" : "Add More Face Variation",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSecuritySettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineVariant.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Security Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
          const SizedBox(height: 16),
          _buildListTile(Icons.lock_outline, "Password & PIN", "Updated 3 months ago", trailing: Icon(Icons.chevron_right, color: outlineVariant)),
          Divider(color: outlineVariant.withOpacity(0.2), height: 24),
          _buildListTile(Icons.phonelink_lock, "Two-Factor Auth", "SMS & Email enabled", trailing: _buildToggleSwitch()),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineVariant.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Device Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
          const SizedBox(height: 16),
          _buildListTile(Icons.smartphone, "iPhone 14 Pro Max", "Active now • San Francisco, CA"),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: errorContainer.withOpacity(0.5),
          foregroundColor: onErrorContainer,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.withOpacity(0.1)),
          ),
        ),
        onPressed: () {},
        icon: const Icon(Icons.logout, size: 20),
        label: const Text("Log Out", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- Widget Bantuan ---
  Widget _buildListTile(IconData icon, String title, String subtitle, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: onSurfaceVariant),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: onSurface)),
              Text(subtitle, style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.all(4),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: surfaceContainerLowest,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}