import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import database
import 'settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  // Tambahan parameter untuk callback agar bisa mematikan red dot di navigasi bawah
  final VoidCallback? onMarkAllRead;

  const NotificationsScreen({Key? key, this.onMarkAllRead}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Warna Material 3
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

  // Variabel profil dari database
  String _displayName = 'Zdanov';
  String _avatarUrl = '';

  // Data List Interaktif Notifikasi
  late List<Map<String, dynamic>> _notificationsList;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();

    // Menginisialisasi list notifikasi yang status isUnread-nya bisa kita ubah
    _notificationsList = [
      {
        "title": "Late Arrival Recorded",
        "time": "9:15 AM",
        "description": "Your check-in was recorded at 9:15 AM, which is past the expected arrival time of 9:00 AM.",
        "icon": Icons.schedule,
        "iconBgColor": errorContainer,
        "iconColor": onErrorContainer,
        "isUnread": true,
        "accentColor": error,
        "actionButtonText": null,
      },
      {
        "title": "System Sync Complete",
        "time": "Yesterday",
        "description": "Weekly biometric sync with HR systems has been successfully completed.",
        "icon": Icons.cloud_sync,
        "iconBgColor": surfaceContainer,
        "iconColor": onSurfaceVariant,
        "isUnread": false,
        "accentColor": null,
        "actionButtonText": null,
      },
      {
        "title": "Missing Checkout",
        "time": "Yesterday",
        "description": "We didn't record a checkout scan for your shift yesterday. Please update your timesheet.",
        "icon": Icons.notifications_active,
        "iconBgColor": primaryContainer.withOpacity(0.2),
        "iconColor": primaryContainer,
        "isUnread": true,
        "accentColor": primary,
        "actionButtonText": "Review Timesheet",
      },
      {
        "title": "FaceAttend App Updated",
        "time": "Oct 24",
        "description": "Version 2.4.1 brings faster biometric recognition and minor bug fixes.",
        "icon": Icons.update,
        "iconBgColor": surfaceContainer,
        "iconColor": onSurfaceVariant,
        "isUnread": false,
        "accentColor": null,
        "actionButtonText": null,
      },
      {
        "title": "Time Off Approved",
        "time": "Oct 20",
        "description": "Your request for PTO on November 15th has been approved by your manager.",
        "icon": Icons.check_circle,
        "iconBgColor": tertiaryFixed,
        "iconColor": onTertiaryFixed,
        "isUnread": false,
        "accentColor": null,
        "actionButtonText": null,
      },
    ];
  }

  // Fungsi Narik Data Profil
  Future<void> _fetchProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('profiles').select('display_name, avatar_url').limit(1).single();

      if (mounted) {
        setState(() {
          _displayName = response['display_name'] ?? 'Zdanov';
          _avatarUrl = response['avatar_url']?.toString() ?? '';
        });
      }
    } catch (_) {}
  }

  // FUNGSI 1: Menandai satu notifikasi saja ketika di-tap
  void _markAsRead(int index) {
    if (_notificationsList[index]['isUnread'] == false) return; // Kalau udah dibaca, abaikan

    setState(() {
      _notificationsList[index]['isUnread'] = false;
    });
    
    // Cek apakah semua sudah dibaca, kalau iya beritahu Main Screen matikan red dot
    _checkIfAllRead();
  }

  // FUNGSI 2: Menandai semua notifikasi menjadi sudah dibaca
  void _markAllAsRead() {
    setState(() {
      for (var notif in _notificationsList) {
        notif['isUnread'] = false;
      }
    });

    // Panggil callback ke Main Screen untuk matikan red dot
    if (widget.onMarkAllRead != null) {
      widget.onMarkAllRead!();
    }
  }

  void _checkIfAllRead() {
    bool isAnyUnread = _notificationsList.any((notif) => notif['isUnread'] == true);
    if (!isAnyUnread && widget.onMarkAllRead != null) {
      widget.onMarkAllRead!();
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
        shape: Border(bottom: BorderSide(color: outlineVariant.withOpacity(0.3), width: 1)),
        title: Row(
          children: [
            // INTEGRASI PROFIL DATABASE
            CircleAvatar(
              radius: 16, 
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
                  onPressed: _markAllAsRead, // Tombol ini sekarang hidup
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text("Mark all as read", style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Notifications List Builder ---
            ...List.generate(_notificationsList.length, (index) {
              final notif = _notificationsList[index];
              return InkWell( // Tambah Inkwell agar tiap notif bisa diklik satu-satu untuk read
                onTap: () => _markAsRead(index),
                borderRadius: BorderRadius.circular(16),
                child: _buildNotificationItem(
                  title: notif['title'],
                  time: notif['time'],
                  description: notif['description'],
                  icon: notif['icon'],
                  iconBgColor: notif['iconBgColor'],
                  iconColor: notif['iconColor'],
                  isUnread: notif['isUnread'],
                  accentColor: notif['accentColor'],
                  actionButtonText: notif['actionButtonText'],
                  onActionPressed: () {
                    // Logika ketika tombol di dalam kotak notif dipencet (misal Review Timesheet)
                    _markAsRead(index); // Otomatis nandain terbaca saat tombol ini dipencet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Action for '${notif['title']}' executed!")),
                    );
                  }
                ),
              );
            }),

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
    VoidCallback? onActionPressed, // Tambahan parameter aksi
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? surfaceContainerLowest : surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(isUnread ? 0.5 : 0.3)),
        boxShadow: isUnread ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedOpacity( // Transisi biar smooth pas diklik read
        duration: const Duration(milliseconds: 300),
        opacity: isUnread ? 1.0 : 0.7, 
        child: IntrinsicHeight( 
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
                            
                            // Tombol Aksi Opsional yang sekarang bisa dipencet
                            if (actionButtonText != null) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: onActionPressed, // Disambungkan ke aksi
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