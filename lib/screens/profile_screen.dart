import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'settings_screen.dart'; 
import 'login_screen.dart'; 
import 'edit_profile_screen.dart'; // IMPORT HALAMAN EDIT PROFILE BARU

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

  // State untuk data Supabase
  String _userDbId = ''; 
  String _displayName = 'Loading...';
  String _userIdDisplay = 'Loading...';
  String _avatarUrl = ''; // TAMBAHAN UNTUK NAMPUNG LINK FOTO
  
  // State untuk Face Recognition
  int _registeredFacesCount = 0; 
  final int _maxFaces = 3; 
  final int _minFaces = 1; 

  // State untuk switch 2FA
  bool _is2faEnabled = true;

  final ImagePicker _picker = ImagePicker();
  bool _isUploadingFace = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('profiles')
          .select()
          .limit(1)
          .single();

      setState(() {
        _userDbId = response['id']?.toString() ?? '';
        _displayName = response['display_name'] ?? response['full_name'] ?? 'No Name';
        
        // AMBIL AVATAR URL DARI DATABASE
        _avatarUrl = response['avatar_url']?.toString() ?? '';
        
        final studentId = response['student_id']?.toString();
        if (studentId != null && studentId.isNotEmpty) {
          _userIdDisplay = 'ID: $studentId';
        } else {
          _userIdDisplay = 'ID: Belum diisi';
        }

        final rawEmbeddings = response['face_embeddings'];
        if (rawEmbeddings is List) {
          _registeredFacesCount = rawEmbeddings.length;
        } else {
          _registeredFacesCount = 0;
        }
      });
    } catch (e) {
      print("ERROR SUPABASE: $e");
    }
  }

  // FUNGSI UNTUK MEMBUKA KAMERA/GALERI & UPDATE JSONB face_embeddings
  Future<void> _pickAndRegisterFace(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isUploadingFace = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Memproses wajah (Ekstraksi Embedding)...")));

        final supabase = Supabase.instance.client;

        if (_userDbId.isNotEmpty) {
          final checkDb = await supabase.from('profiles').select('face_embeddings').eq('id', _userDbId).single();
          
          List<dynamic> currentEmbeddings = [];
          if (checkDb['face_embeddings'] is List) {
            currentEmbeddings = List<dynamic>.from(checkDb['face_embeddings']);
          }

          currentEmbeddings.add({
            "timestamp": DateTime.now().toIso8601String(),
            "data": "simulated_embedding_vector_data" 
          });

          await supabase
              .from('profiles')
              .update({'face_embeddings': currentEmbeddings})
              .eq('id', _userDbId);
          
          setState(() {
            _registeredFacesCount = currentEmbeddings.length;
          });
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wajah berhasil diregistrasi! ($_registeredFacesCount/$_maxFaces)")));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploadingFace = false);
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pilih Sumber Foto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
                const SizedBox(height: 16),
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: primaryContainer.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.camera_front, color: primary, size: 24),
                  ),
                  title: Text("Buka Kamera", style: TextStyle(fontWeight: FontWeight.w600, color: onSurface)),
                  subtitle: Text("Ambil foto wajah secara langsung", style: TextStyle(color: onSurfaceVariant, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndRegisterFace(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: secondaryContainer, shape: BoxShape.circle),
                    child: Icon(Icons.photo_library_outlined, color: onSecondaryContainer, size: 24),
                  ),
                  title: Text("Pilih dari Galeri", style: TextStyle(fontWeight: FontWeight.w600, color: onSurface)),
                  subtitle: Text("Pilih foto wajah dari album perangkat", style: TextStyle(color: onSurfaceVariant, fontSize: 13)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndRegisterFace(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            CircleAvatar(
              radius: 16, 
              // LOGIKA FOTO KECIL DI APPBAR: Kalau ada foto di database pakai itu, kalau gak bikin avatar singkatan nama
              backgroundImage: _avatarUrl.isNotEmpty 
                  ? NetworkImage(_avatarUrl) 
                  : NetworkImage("https://ui-avatars.com/api/?name=$_displayName&background=random"),
            ),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () {
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
                  SizedBox(
                    width: 128, height: 128,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [primary, primaryFixedDim], begin: Alignment.bottomLeft, end: Alignment.topRight),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, border: Border.all(color: surfaceContainerLowest, width: 4),
                              // UBAH FOTO CEWEK UNSPLASH JADI FOTO DARI DATABASE
                              image: DecorationImage(
                                image: _avatarUrl.isNotEmpty 
                                    ? NetworkImage(_avatarUrl) 
                                    : NetworkImage("https://ui-avatars.com/api/?name=$_displayName&background=random&size=256"), 
                                fit: BoxFit.cover
                              ),
                            ),
                          ),
                        ),
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
                  
                  Text(_displayName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: onSurface, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(_userIdDisplay, style: TextStyle(fontSize: 16, color: onSurfaceVariant, letterSpacing: 1.0)),
                  const SizedBox(height: 24),
                  
                  OutlinedButton(
                    onPressed: () async {
                      // PINDAH KE HALAMAN EDIT PROFILE
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                      // REFRESH DATA KETIKA KEMBALI DARI HALAMAN EDIT (Agar foto barunya langsung muncul)
                      _fetchUserData(); 
                    },
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
                  Positioned(
                    right: -24, top: -24,
                    child: Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        color: _registeredFacesCount >= _minFaces ? primaryFixedDim.withOpacity(0.3) : errorContainer.withOpacity(0.5), 
                        shape: BoxShape.circle, 
                        boxShadow: [
                          BoxShadow(
                            color: _registeredFacesCount >= _minFaces ? primaryFixedDim.withOpacity(0.3) : errorContainer.withOpacity(0.5), 
                            blurRadius: 40, spreadRadius: 20
                          )
                        ]
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: _registeredFacesCount >= _minFaces ? secondaryContainer : errorContainer, 
                                shape: BoxShape.circle
                              ),
                              child: Icon(
                                _registeredFacesCount >= _minFaces ? Icons.face : Icons.face_retouching_off, 
                                color: _registeredFacesCount >= _minFaces ? onSecondaryContainer : onErrorContainer, 
                                size: 24
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _registeredFacesCount >= _minFaces 
                                      ? "Registered Face ($_registeredFacesCount/$_maxFaces)" 
                                      : "No Face Registered", 
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _registeredFacesCount >= _minFaces 
                                      ? "Biometric identity active" 
                                      : "Minimal $_minFaces wajah dibutuhkan", 
                                    style: TextStyle(fontSize: 14, color: onSurfaceVariant)
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _registeredFacesCount >= _minFaces ? primaryContainer.withOpacity(0.1) : onErrorContainer.withOpacity(0.1), 
                                borderRadius: BorderRadius.circular(100)
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _registeredFacesCount >= _minFaces ? Icons.verified : Icons.warning_amber_rounded, 
                                    color: _registeredFacesCount >= _minFaces ? primaryContainer : onErrorContainer, 
                                    size: 16
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _registeredFacesCount >= _minFaces ? "Verified" : "Action Needed", 
                                    style: TextStyle(color: _registeredFacesCount >= _minFaces ? primaryContainer : onErrorContainer, fontSize: 12, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        if (_registeredFacesCount < _maxFaces)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isUploadingFace ? null : () => _showImageSourceDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _registeredFacesCount >= _minFaces ? surfaceContainer : primary,
                                foregroundColor: _registeredFacesCount >= _minFaces ? onSurface : surfaceContainerLowest,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: _isUploadingFace 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Icon(_registeredFacesCount >= _minFaces ? Icons.add_a_photo : Icons.camera_front, size: 20),
                              label: Text(
                                _isUploadingFace ? "Memproses..." : 
                                _registeredFacesCount >= _minFaces ? "Add Another Face" : "Register Face Now", 
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                              ),
                            ),
                          )
                        else 
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: successGreen.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: successGreen, size: 20),
                                const SizedBox(width: 8),
                                Text("Maksimal Wajah Terdaftar ($_maxFaces/$_maxFaces)", style: TextStyle(color: successGreen, fontWeight: FontWeight.bold)),
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
                  
                  _buildInteractiveRow(
                    icon: Icons.lock_outline, title: "Password & PIN", subtitle: "Updated 3 months ago",
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buka Pengaturan Password"))),
                  ),
                  
                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: outlineVariant.withOpacity(0.3))),
                  
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
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

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