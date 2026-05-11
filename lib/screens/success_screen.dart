import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  // Warna Material 3
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color surfaceContainerHighest = const Color(0xFFE1E3E4);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color primaryFixed = const Color(0xFFD8E2FF);
  final Color secondaryContainer = const Color(0xFFD2E6EF);
  final Color onSecondaryContainer = const Color(0xFF55676F);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          // Ambient Background Elements (Blurry circles)
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(color: primaryContainer.withOpacity(0.15), shape: BoxShape.circle),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const Spacer(),

                  // --- Hero Animation / Success Icon ---
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: primaryFixed, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 40)]),
                    child: Center(
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: Colors.white, size: 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text("Check-In Successful", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text("Your attendance has been securely recorded.", style: TextStyle(fontSize: 16, color: onSurfaceVariant)),
                  const SizedBox(height: 24),

                  // Face Verified Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: surfaceContainerHighest.withOpacity(0.5), borderRadius: BorderRadius.circular(100), border: Border.all(color: outlineVariant.withOpacity(0.3))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user, color: primary, size: 16),
                        const SizedBox(width: 8),
                        const Text("FACE VERIFIED", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Summary Card ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: outlineVariant.withOpacity(0.3)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Decorative Top Gradient Line
                        Container(height: 4, decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryContainer, primary]), borderRadius: const BorderRadius.vertical(top: Radius.circular(24)))),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Session Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
                              const Divider(height: 24),
                              
                              _buildDetailRow(icon: Icons.schedule, title: "Time", value: "08:45 AM", subValue: "Oct 24, 2023"),
                              const SizedBox(height: 16),
                              _buildDetailRow(icon: Icons.location_on, title: "Location", value: "Main Office HQ"),
                              const SizedBox(height: 16),
                              _buildDetailRow(icon: Icons.work, title: "Status", value: "On Time", isStatus: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // --- Primary Action Button (Done) ---
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                      // Kembali ke layar awal (Home) dan buang semua tumpukan layar sebelumnya (GPS, Wajah)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4, shadowColor: primary.withOpacity(0.5),
                      ),
                      child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk baris detail card
  Widget _buildDetailRow({required IconData icon, required String title, required String value, String? subValue, bool isStatus = false}) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: surfaceContainerLow, shape: BoxShape.circle),
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: onSurfaceVariant, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              if (isStatus)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: secondaryContainer, borderRadius: BorderRadius.circular(100)),
                  child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSecondaryContainer)),
                )
              else
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
            ],
          ),
        ),
        if (subValue != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("DATE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: onSurfaceVariant, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(subValue, style: TextStyle(fontSize: 14, color: onSurface)),
            ],
          ),
      ],
    );
  }
}