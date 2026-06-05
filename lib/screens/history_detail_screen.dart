import 'package:flutter/material.dart';
import 'dart:ui';

class HistoryDetailScreen extends StatelessWidget {
  final String date;
  final String status;
  final String checkInTime;
  final String checkOutTime;

  const HistoryDetailScreen({
    Key? key, 
    required this.date, 
    required this.status,
    required this.checkInTime,
    required this.checkOutTime,
  }) : super(key: key);

  // Warna Material 3
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color tertiaryFixed = const Color(0xFFD9E2FF);
  final Color onTertiaryFixedVariant = const Color(0xFF00429C);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  final Color outline = const Color(0xFF727785);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: outlineVariant.withOpacity(0.3), width: 1)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: onSurfaceVariant), onPressed: () => Navigator.pop(context)),
        title: Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Record ID: FA-8924A", style: TextStyle(fontSize: 12, color: outline, letterSpacing: 1.0, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text("Attendance Detail", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)),
                    const SizedBox(height: 4),
                    Text(date, style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: tertiaryFixed, borderRadius: BorderRadius.circular(100), border: Border.all(color: onTertiaryFixedVariant.withOpacity(0.2))),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: onTertiaryFixedVariant),
                      const SizedBox(width: 6),
                      Text("Verified $status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onTertiaryFixedVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 2. BENTO: BIOMETRIC CAPTURE ---
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=600&auto=format&fit=crop"), // Placeholder wajah
                  fit: BoxFit.cover,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Stack(
                children: [
                  // AI Overlay UI
                  Center(
                    child: Container(
                      width: 180, height: 180,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryContainer.withOpacity(0.5), width: 2)),
                      // Efek kedip sederhana
                      child: const CircularProgressIndicator(value: 1.0, color: Colors.white24, strokeWidth: 1),
                    ),
                  ),
                  // Glass Panel Skor
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), border: Border.all(color: Colors.white.withOpacity(0.5))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("AI CONFIDENCE SCORE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: onSurfaceVariant, letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text("99.8% Match", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryContainer)),
                                ],
                              ),
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: primaryContainer.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.verified_user, color: primaryContainer, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. BENTO: TIMES ---
            Row(
              children: [
                Expanded(child: _buildTimeCard(Icons.login, "Clock In", checkInTime, true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTimeCard(Icons.logout, "Clock Out", checkOutTime.isEmpty ? "--:--" : checkOutTime, false)),
              ],
            ),
            const SizedBox(height: 16),

            // --- 4. BENTO: TECHNICAL DETAILS ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: outlineVariant.withOpacity(0.5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TECHNICAL DETAILS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: onSurfaceVariant, letterSpacing: 1.0)),
                  const Divider(height: 24),
                  _buildTechRow(Icons.smartphone, "Device Model", "ASUS TUF Dash F15"), // Aku sesuaikan dengan hardware-mu!
                  const SizedBox(height: 16),
                  _buildTechRow(Icons.wifi, "Network Source", "Biznet Home 5G"), // Sesuai provider-mu
                  const SizedBox(height: 16),
                  _buildTechRow(Icons.policy, "Liveness Detection", "Passed", valueColor: primary),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 5. BENTO: LOCATION ---
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: outlineVariant.withOpacity(0.5))),
              child: Column(
                children: [
                  // Map Image
                  Container(
                    height: 140, width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop"), fit: BoxFit.cover),
                    ),
                    child: Center(
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)]),
                      ),
                    ),
                  ),
                  // Location Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: primaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text("UIB Campus / AWS Lab", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)), // Disesuaikan dengan kampusmu
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Batam, Riau Islands, Indonesia", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildCoordCard("Latitude", "1.1294° N")),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCoordCard("Longitude", "104.0152° E")),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 6. BENTO: NOTES ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: outlineVariant.withOpacity(0.5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, color: onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Text("SYSTEM & ADMIN NOTES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: onSurfaceVariant, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "Standard biometric check-in processed successfully. Location verified within the approved 50-meter geofence. No manual overrides applied.",
                      style: TextStyle(fontSize: 14, color: onSurfaceVariant, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Waktu Check In/Out
  Widget _buildTimeCard(IconData icon, String title, String time, bool isActive) {
    Color color = isActive ? onSurface : outline;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: outlineVariant.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isActive ? const Color(0xFF4F6169) : outline),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF4F6169) : outline, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(time, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  // Helper Widget: Baris Teknis
  Widget _buildTechRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: onSurfaceVariant),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? onSurface)),
      ],
    );
  }

  // Helper Widget: Koordinat GPS
  Widget _buildCoordCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: outlineVariant.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 10, color: onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface)),
        ],
      ),
    );
  }
}