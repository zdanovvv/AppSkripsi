import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Import halaman setting yang barusan dibuat

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color surfaceContainer = const Color(0xFFEDEEEF);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  
  final Color error = const Color(0xFFBA1A1A);
  final Color errorContainer = const Color(0xFFFFDAD6);
  final Color onErrorContainer = const Color(0xFF93000A);
  final Color tertiaryFixed = const Color(0xFFD9E2FF);
  final Color onTertiaryFixed = const Color(0xFF001945);

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
            const CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=Alex&background=random")),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () {
              // NAVIGASI KE HALAMAN SETTINGS
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notifications", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurface)),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text("Mark all as read", style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Notifications List ---
            
            // 1. Late Notice (Unread, Error colors)
            _buildNotificationItem(
              title: "Late Arrival Recorded", time: "9:15 AM",
              description: "Your check-in was recorded at 9:15 AM, which is past the expected arrival time of 9:00 AM.",
              icon: Icons.schedule, iconBgColor: errorContainer, iconColor: onErrorContainer,
              isUnread: true, accentColor: error,
            ),

            // 2. System Sync (Read)
            _buildNotificationItem(
              title: "System Sync Complete", time: "Yesterday",
              description: "Weekly biometric sync with HR systems has been successfully completed.",
              icon: Icons.cloud_sync, iconBgColor: surfaceContainer, iconColor: onSurfaceVariant,
              isUnread: false,
            ),

            // 3. Attendance Reminder (Unread, with action button)
            _buildNotificationItem(
              title: "Missing Checkout", time: "Yesterday",
              description: "We didn't record a checkout scan for your shift yesterday. Please update your timesheet.",
              icon: Icons.notifications_active, iconBgColor: primaryContainer.withOpacity(0.2), iconColor: primaryContainer,
              isUnread: true, accentColor: primary,
              actionButtonText: "Review Timesheet",
            ),

            // 4. System Update (Read)
            _buildNotificationItem(
              title: "FaceAttend App Updated", time: "Oct 24",
              description: "Version 2.4.1 brings faster biometric recognition and minor bug fixes.",
              icon: Icons.update, iconBgColor: surfaceContainer, iconColor: onSurfaceVariant,
              isUnread: false,
            ),

            // 5. Approval (Read, Tertiary colors)
            _buildNotificationItem(
              title: "Time Off Approved", time: "Oct 20",
              description: "Your request for PTO on November 15th has been approved by your manager.",
              icon: Icons.check_circle, iconBgColor: tertiaryFixed, iconColor: onTertiaryFixed,
              isUnread: false,
            ),

            const SizedBox(height: 80), // Spacer buat bottom nav
          ],
        ),
      ),
    );
  }

  // Helper Widget: Kartu Notifikasi
  Widget _buildNotificationItem({
    required String title, required String time, required String description,
    required IconData icon, required Color iconBgColor, required Color iconColor,
    required bool isUnread, Color? accentColor, String? actionButtonText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? surfaceContainerLowest : surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(isUnread ? 0.5 : 0.3)),
        boxShadow: isUnread ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      // Clip anti alias biar border radiusnya nutupin garis aksen
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: isUnread ? 1.0 : 0.7, // Kalau udah dibaca, agak transparan
        child: IntrinsicHeight( // Biar garis samping tingginya ngikutin konten
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis Aksen Samping (untuk pesan yang belum dibaca)
              if (isUnread && accentColor != null)
                Container(width: 4, color: accentColor),

              // Konten Notifikasi
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ikon
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      
                      // Teks
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                Text(time, style: TextStyle(fontSize: 10, color: onSurfaceVariant)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(description, style: TextStyle(fontSize: 12, color: onSurfaceVariant, height: 1.5)),
                            
                            // Tombol Aksi Opsional
                            if (actionButtonText != null) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                  side: BorderSide(color: outlineVariant.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                ),
                                child: Text(actionButtonText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: primary)),
                              ),
                            ]
                          ],
                        ),
                      ),
                      
                      // Titik Penanda Belum Dibaca
                      if (isUnread && accentColor != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}