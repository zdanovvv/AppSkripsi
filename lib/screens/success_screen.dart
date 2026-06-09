import 'package:flutter/material.dart';
import 'main_screen.dart'; 

class SuccessScreen extends StatelessWidget {
  // Parameter dinamis yang dikirim dari GPS Screen
  final String attendanceTime;
  final String attendanceLocation;
  final String attendanceStatus;

  const SuccessScreen({
    Key? key,
    required this.attendanceTime,
    required this.attendanceLocation,
    required this.attendanceStatus,
  }) : super(key: key);

  // Warna Material 3 sesuai dengan desain asli kamu
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
    // Logika warna dinamis untuk status keterlambatan agar bento card kamu makin hidup
    final Color currentStatusBg = attendanceStatus == "Telat" ? const Color(0xFFFFDAD6) : const Color(0xFFD1E7DD);
    final Color currentStatusText = attendanceStatus == "Telat" ? const Color(0xFFBA1A1A) : const Color(0xFF0F5132);

    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          // Efek bulatan blur di background agar estetik (Bawaan Asli Kamu)
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Bulatan Centang Sukses (Bawaan Asli Kamu)
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, size: 56, color: primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Attendance Success",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Data presensi kamu telah berhasil diverifikasi dan disimpan ke sistem.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),

                  // BENTO CARD DETAIL DATA (Menggunakan struktur baris asli kamu)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: outlineVariant.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.access_time,
                          title: "Waktu Absen",
                          value: attendanceTime,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          title: "Lokasi Presensi",
                          value: attendanceLocation,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildDetailRow(
                          icon: Icons.verified_user_outlined,
                          title: "Status Kehadiran",
                          value: attendanceStatus,
                          isStatus: true,
                          customStatusColor: currentStatusText,
                          customStatusBg: currentStatusBg,
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Tombol Selesai (Bawaan Asli Kamu)
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                        (route) => false,
                      );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Selesai", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  // Komponen baris Bento Detail bawaan codingan asli kamu
  Widget _buildDetailRow({
    required IconData icon, 
    required String title, 
    required String value, 
    String? subValue, 
    bool isStatus = false,
    Color? customStatusColor,
    Color? customStatusBg,
  }) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: surfaceContainerLow, shape: BoxShape.circle),
          child: Icon(icon, color: primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: onSurfaceVariant, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              if (isStatus)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: customStatusBg ?? secondaryContainer, 
                    borderRadius: BorderRadius.circular(100)
                  ),
                  child: Text(
                    value, 
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w700, 
                      color: customStatusColor ?? onSecondaryContainer
                    )
                  ),
                )
              else
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
            ],
          ),
        ),
        if (subValue != null)
          Text(subValue, style: TextStyle(fontSize: 14, color: onSurfaceVariant, fontWeight: FontWeight.w500)),
      ],
    );
  }
}