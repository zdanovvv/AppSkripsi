import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color primary = const Color(0xFF005BBF);
  final Color onSurface = const Color(0xFF191C1D);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  final TextEditingController _nameController = TextEditingController();
  String _avatarUrl = '';
  String _userDbId = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final supabase = Supabase.instance.client;
      // Narik data user yang pertama
      final response = await supabase.from('profiles').select().limit(1).single();
      
      setState(() {
        _userDbId = response['id'] ?? '';
        _nameController.text = response['display_name'] ?? '';
        _avatarUrl = response['avatar_url'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // FUNGSI GANTI FOTO DAN UPLOAD KE SUPABASE STORAGE
  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return; // Kalo batal milih foto

    setState(() => _isSaving = true);
    try {
      final file = File(image.path);
      final fileExtension = image.path.split('.').last;
      // Bikin nama file unik pakai waktu biar nggak bentrok
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      final supabase = Supabase.instance.client;

      // 1. Upload foto ke bucket 'avatars'
      await supabase.storage.from('avatars').upload(fileName, file);

      // 2. Ambil Link URL publik dari foto yang baru diupload
      final String publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // 3. Update kolom avatar_url di tabel profiles
      await supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', _userDbId);

      setState(() => _avatarUrl = publicUrl);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto Profil Berhasil Diperbarui!")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal upload foto: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'display_name': _nameController.text})
          .eq('id', _userDbId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil tersimpan!")));
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: outlineVariant.withOpacity(0.3), width: 1)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // --- BAGIAN FOTO PROFIL ---
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primary, width: 3),
                        image: DecorationImage(
                          image: _avatarUrl.isNotEmpty 
                            ? NetworkImage(_avatarUrl) 
                            : NetworkImage("https://ui-avatars.com/api/?name=${_nameController.text}&background=random&size=256"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isSaving ? null : _updateProfilePicture,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // --- BAGIAN NAMA ---
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Display Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: surfaceContainerLowest,
                  ),
                ),
                const SizedBox(height: 40),
                
                // --- TOMBOL SIMPAN ---
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}