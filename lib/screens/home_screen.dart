import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'attendance_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Warna Material 3
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF414754);
  static const Color primary = Color(0xFF005BBF);
  static const Color primaryContainer = Color(0xFF1A73E8);
  static const Color secondaryContainer = Color(0xFFD2E6EF);
  static const Color onSecondaryContainer = Color(0xFF55676F);
  static const Color tertiaryFixed = Color(0xFFD9E2FF);
  static const Color onTertiaryFixed = Color(0xFF001945);
  static const Color outlineVariant = Color(0xFFC1C6D6);

  // State Data Profil
  String _displayName = 'Zdanov';
  String _avatarUrl = '';

  // State Logika Absensi
  bool _hasCheckedIn = false;
  bool _hasCheckedOut = false;
  bool _isLoading = true;

  // Nama bucket Supabase storage (ganti sesuai konfigurasi)
  final String _bucketName = 'avatars';

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('profiles')
        .select('display_name, avatar_url')
        .limit(1)
        .single();

    setState(() {
      _displayName = response['display_name'] ?? 'Zdanov';
      _avatarUrl = response['avatar_url']?.toString() ?? '';
      _isLoading = false;
    });
  } catch (e) {
    print('ERROR: $e');
    if (mounted) setState(() => _isLoading = false);
  }
}

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final DateTime now = DateTime.now();
    const List<String> months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const List<String> days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

    final String dayName = days[now.weekday - 1];
    final String monthName = months[now.month - 1];

    String hour = now.hour > 12 ? (now.hour - 12).toString().padLeft(2, '0') : now.hour.toString().padLeft(2, '0');
    if (now.hour == 0) hour = '12';
    final String minute = now.minute.toString().padLeft(2, '0');
    final String ampm = now.hour >= 12 ? 'PM' : 'AM';

    return '$dayName, $monthName ${now.day}, ${now.year} • $hour:$minute $ampm';
  }

  Widget _buildAvatar() {
    const double radius = 16;

    if (_isLoading) {
      return const CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_avatarUrl.isEmpty) {
      final String? initials = _displayName.trim().isNotEmpty
          ? _displayName.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join()
          : null;
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: initials != null && initials.isNotEmpty
            ? Text(initials.toUpperCase(), style: const TextStyle(color: Colors.white))
            : const Icon(Icons.person, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          _avatarUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('HomeScreen: Avatar load error: $error');
            final String? initials = _displayName.trim().isNotEmpty
                ? _displayName.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join()
                : null;
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: initials != null && initials.isNotEmpty
                  ? Text(initials.toUpperCase(), style: const TextStyle(color: Colors.white))
                  : const Icon(Icons.person, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              child: _buildAvatar(),
            ),
            const SizedBox(width: 12),
            const Text('FaceAttend', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: onSurfaceVariant,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_getGreeting()}, $_displayName!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: primary),
                      const SizedBox(width: 8),
                      Text(_getFormattedDate(), style: const TextStyle(fontSize: 14, color: onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.location_on,
                          iconBg: secondaryContainer,
                          iconColor: onSecondaryContainer,
                          title: 'GPS Status',
                          value: 'Verified',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusCard(
                          icon: Icons.face,
                          iconBg: tertiaryFixed,
                          iconColor: onTertiaryFixed,
                          title: 'Face ID',
                          value: 'Ready',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                        Text(
                          _hasCheckedOut ? 'Attendance Complete' : _hasCheckedIn ? 'Ready for Check-out' : 'Ready for Check-in',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
                        ),
                        const SizedBox(height: 4),
                        const Text('Ensure your face is clearly visible', style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _hasCheckedOut
                              ? null
                              : () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen()));
                                },
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _hasCheckedOut ? outlineVariant : primary, width: 3),
                              color: Colors.white,
                              boxShadow: _hasCheckedOut ? [] : [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 20)],
                            ),
                            child: Icon(_hasCheckedOut ? Icons.check_circle : Icons.face_unlock_outlined, size: 48, color: _hasCheckedOut ? Colors.green : primary),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _hasCheckedIn
                                    ? null
                                    : () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen()));
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasCheckedIn ? surfaceContainerLow : primary,
                                  foregroundColor: _hasCheckedIn ? outlineVariant : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: _hasCheckedIn ? 0 : 2,
                                ),
                                icon: const Icon(Icons.login, size: 20),
                                label: const Text('Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: (!_hasCheckedIn || _hasCheckedOut)
                                    ? null
                                    : () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen()));
                                      },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: (!_hasCheckedIn || _hasCheckedOut) ? surfaceContainerLow : surfaceContainer,
                                  side: BorderSide(color: outlineVariant.withOpacity(0.3)),
                                  foregroundColor: (!_hasCheckedIn || _hasCheckedOut) ? outlineVariant : primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.logout, size: 20),
                                label: const Text('Check-out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Weekly Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
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
                              children: const [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: '34', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary)),
                                      TextSpan(text: ' hrs', style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('TOTAL HOURS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: secondaryContainer, borderRadius: BorderRadius.circular(100)),
                              child: const Text('On Track', style: TextStyle(color: onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('M', 80, true),
                            _buildBar('T', 85, true),
                            _buildBar('W', 40, true),
                            _buildBar('T', 0, false),
                            _buildBar('F', 0, false),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary)),
        ],
      ),
    );
  }

  static Widget _buildBar(String day, double heightPercent, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 80,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 80 * (heightPercent / 100),
            decoration: BoxDecoration(color: isActive ? primaryContainer : const Color(0xFFE1E3E4), borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 12, color: isActive ? onSurfaceVariant : outlineVariant)),
      ],
    );
  }
}
