import 'package:flutter/material.dart';
import 'dart:ui';
import 'success_screen.dart'; // Pastikan file ini sudah ada

class GPSScreen extends StatefulWidget {
  const GPSScreen({Key? key}) : super(key: key);

  @override
  State<GPSScreen> createState() => _GPSScreenState();
}

class _GPSScreenState extends State<GPSScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  final Color surface = const Color(0xFFF8F9FA);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  final Color successGreen = const Color(0xFF10B981); 

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: surface.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: onSurfaceVariant), onPressed: () => Navigator.pop(context)),
        title: Text("Location Check", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Map Placeholder
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop", 
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: surface.withOpacity(0.2))), 

          // Lingkaran Radius Kantor
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                color: primaryContainer.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primary.withOpacity(0.3), width: 1),
              ),
              child: Center(child: Icon(Icons.corporate_fare, size: 48, color: primary.withOpacity(0.3))),
            ),
          ),

          // Titik User dengan Animasi Ping
          Positioned(
            top: MediaQuery.of(context).size.height * 0.48, 
            left: MediaQuery.of(context).size.width * 0.45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 3.0).animate(_pulseController),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.8, end: 0.0).animate(_pulseController),
                    child: Container(width: 32, height: 32, decoration: BoxDecoration(color: primary.withOpacity(0.5), shape: BoxShape.circle)),
                  ),
                ),
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: primary, width: 2), boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)]),
                  child: Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: primary, shape: BoxShape.circle))),
                ),
              ],
            ),
          ),

          // Tombol Recenter GPS
          Positioned(
            top: 100, right: 20,
            child: FloatingActionButton(
              mini: true, backgroundColor: Colors.white, foregroundColor: onSurface,
              onPressed: () {}, child: const Icon(Icons.my_location),
            ),
          ),

          // Floating Panel Bawah (Bento Glassmorphism)
          Positioned(
            bottom: 32, left: 20, right: 20,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildBentoCard(title: "GPS Signal", value: "High Accuracy", icon: Icons.satellite_alt, dotColor: successGreen)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBentoCard(title: "Distance", value: "12m", subtitle: "/ 50m max", icon: Icons.straighten)),
                  ],
                ),
                const SizedBox(height: 16),

                // Card Verifikasi & Tombol Confirm
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), border: Border.all(color: outlineVariant.withOpacity(0.3))),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: primary, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Location Verified", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
                                    const SizedBox(height: 4),
                                    Text("You are within the allowed check-in zone for HQ Office.", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // --- TOMBOL CONFIRM LOCATION ---
                          SizedBox(
                            width: double.infinity, height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // ANIMASI TRANSISI KE SUCCESS SCREEN
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const SuccessScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
                                      var scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

                                      return FadeTransition(
                                        opacity: fadeAnimation,
                                        child: ScaleTransition(scale: scaleAnimation, child: child),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 600),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              icon: const Text("Confirm Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              label: const Icon(Icons.arrow_forward, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({required String title, required String value, required IconData icon, String? subtitle, Color? dotColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), border: Border.all(color: outlineVariant.withOpacity(0.3))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: outlineVariant, letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (dotColor != null) ...[Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)), const SizedBox(width: 8)],
                  Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                  if (subtitle != null) ...[const SizedBox(width: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: onSurfaceVariant))],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}