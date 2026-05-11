import 'package:flutter/material.dart';
import 'dart:ui';
import 'gps_screen.dart'; // Nanti kita buat file ini

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;

  // Warna Material 3
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerHighest = const Color(0xFFE1E3E4);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  @override
  void initState() {
    super.initState();
    // Animasi garis scanner yang naik turun berulang-ulang
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _onCapture() {
    setState(() => _isScanning = true);
    
    // Simulasi proses AI verifikasi wajah (1.5 detik)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isScanning = false);
        
        // --- ANIMASI TRANSISI PINDAH KE GPS SCREEN ---
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const GPSScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Animasi Fade dan Scale (Nge-zoom halus ke dalam)
              var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
              var scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

              return FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(scale: scaleAnimation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=Alex&background=random")),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: onSurfaceVariant), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Header Text
            Text("Biometric Check-In", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)),
            const SizedBox(height: 8),
            Text("Position your face within the frame.", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
            const SizedBox(height: 32),

            // Camera Area
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: outlineVariant.withOpacity(0.5)),
                        image: const DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=600&auto=format&fit=crop"), // Placeholder wajah
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Efek Kaca Redup
                          Container(color: Colors.white.withOpacity(0.1)),
                          
                          // Border Target
                          Positioned(
                            top: 16, bottom: 16, left: 16, right: 16,
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: primary.withOpacity(0.4), width: 2), borderRadius: BorderRadius.circular(24)),
                              child: Stack(
                                children: [
                                  // Siku Pojok
                                  _buildCorner(Alignment.topLeft), _buildCorner(Alignment.topRight),
                                  _buildCorner(Alignment.bottomLeft), _buildCorner(Alignment.bottomRight),
                                  
                                  // Garis Scanner Animasi
                                  AnimatedBuilder(
                                    animation: _scanController,
                                    builder: (context, child) {
                                      return Positioned(
                                        top: _scanController.value * (MediaQuery.of(context).size.width * 1.2 - 64), // Bergerak dari atas ke bawah
                                        left: 0, right: 0,
                                        child: Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(0.8),
                                            boxShadow: [BoxShadow(color: primary.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Real-time Metrics (Kiri atas)
                          Positioned(
                            top: 24, left: 24, right: 24,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildGlassPill(child: Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    const Text("Scanning...", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                )),
                                _buildGlassPill(child: Text("AI Match: 87%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Capture
            GestureDetector(
              onTap: _isScanning ? null : _onCapture,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: surface, width: 4),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 15)],
                ),
                child: _isScanning 
                    ? const Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y == -1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
            bottom: alignment.y == 1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
            left: alignment.x == -1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
            right: alignment.x == 1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(24) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(24) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(24) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(24) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPill({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), border: Border.all(color: outlineVariant.withOpacity(0.3))),
          child: child,
        ),
      ),
    );
  }
}