import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Warna Material 3 dari HTML kamu
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color surfaceContainer = const Color(0xFFEDEEEF);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color secondaryContainer = const Color(0xFFD2E6EF);
  final Color onSecondaryContainer = const Color(0xFF55676F);
  final Color tertiaryFixed = const Color(0xFFD9E2FF);
  final Color onTertiaryFixed = const Color(0xFF001945);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      // --- Top App Bar ---
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage("https://ui-avatars.com/api/?name=Alex&background=random"),
            ),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      // --- Body Content ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Greeting Section
            Text("Good Morning, Alex!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: primary),
                const SizedBox(width: 8),
                Text("Monday, October 23, 2023 • 08:45 AM", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 32),

            // 2. Status & System Checks
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    icon: Icons.location_on, 
                    iconBg: secondaryContainer, 
                    iconColor: onSecondaryContainer, 
                    title: "GPS Status", 
                    value: "Verified"
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    icon: Icons.face, 
                    iconBg: tertiaryFixed, 
                    iconColor: onTertiaryFixed, 
                    title: "Face ID", 
                    value: "Ready"
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 3. Primary Action Area (Biometric Scan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: outlineVariant.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Text("Ready for Check-in", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
                  const SizedBox(height: 4),
                  Text("Ensure your face is clearly visible", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                  const SizedBox(height: 24),
                  
                  // Biometric Ring
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primary, width: 3),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 20)],
                    ),
                    child: Icon(Icons.face_unlock_outlined, size: 48, color: primary),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.login, color: Colors.white, size: 20),
                          label: const Text("Check-in", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: surfaceContainer,
                            side: BorderSide(color: outlineVariant.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: Icon(Icons.logout, color: onSurface, size: 20),
                          label: Text("Check-out", style: TextStyle(color: onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Weekly Summary
            Text("Weekly Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "34", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary)),
                                TextSpan(text: " hrs", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Text("TOTAL HOURS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: secondaryContainer, borderRadius: BorderRadius.circular(100)),
                        child: Text("On Track", style: TextStyle(color: onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Simple Bar Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("M", 80, true),
                      _buildBar("T", 85, true),
                      _buildBar("W", 40, true),
                      _buildBar("T", 0, false),
                      _buildBar("F", 0, false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), // Spacer biar gak ketutup bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({required IconData icon, required Color iconBg, required Color iconColor, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary)),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightPercent, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 80, // Max height
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 80 * (heightPercent / 100),
            decoration: BoxDecoration(
              color: isActive ? primaryContainer : const Color(0xFFE1E3E4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 12, color: isActive ? onSurfaceVariant : outlineVariant)),
      ],
    );
  }
}