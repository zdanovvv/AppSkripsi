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
  
  // Data dari Supabase
  String _userName = "Loading...";
  String _userId = "Loading...";

  final Color surface = const Color(0xFFF8F9FA);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color secondaryContainer = const Color(0xFFD2E6EF);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  final Color errorContainer = const Color(0xFFFFDAD6);
  final Color onErrorContainer = const Color(0xFF93000A);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainer = const Color(0xFFEDEEEF);
  
  // PASTE ID DARI AUTHENTICATION SUPABASE DI SINI
  final String dummyUserId = '187ffdb7-121c-4581-8dfe-6b9299cafdbb';

  @override
  void initState() {
    super.initState();
    _fetchFaceData();
  }

  Future<void> _fetchFaceData() async {
    try {
      // Narik semua kolom yang dibutuhin
      final data = await _supabase
          .from('profiles')
          .select('full_name, student_id, face_embeddings')
          .eq('id', dummyUserId)
          .maybeSingle();

      if (data != null) {
        if (mounted) {
          setState(() {
            _userName = data['full_name'] ?? "User";
            _userId = data['student_id'] ?? "No ID";
            _registeredFacesCount = (data['face_embeddings'] as List<dynamic>? ?? []).length;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: secondaryContainer, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 32),
                _buildBiometricStatusCard(),
                const SizedBox(height: 16),
                _buildSecuritySettingsCard(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(width: 128, height: 128, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blueGrey)),
        const SizedBox(height: 16),
        // NAMA KAMU MUNCUL DI SINI
        Text(_userName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface)),
        Text("ID: $_userId", style: TextStyle(fontSize: 16, color: onSurfaceVariant)),
      ],
    );
  }

  // --- Widget lainnya tetap sama persis seperti sebelumnya ---
  Widget _buildBiometricStatusCard() {
    bool isNotRegistered = _registeredFacesCount == 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(isNotRegistered ? Icons.warning_amber_rounded : Icons.face, color: isNotRegistered ? onErrorContainer : primary),
              const SizedBox(width: 16),
              Text(isNotRegistered ? "Face Not Registered" : "Registered Face", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettingsCard() => Container(height: 100, color: surfaceContainerLowest);
  Widget _buildLogoutButton() => const SizedBox.shrink();
}