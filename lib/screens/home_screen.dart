import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings_screen.dart'; 

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSwitchToAttend;

  const HomeScreen({Key? key, this.onSwitchToAttend}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void refresh() => _fetchHomeData();
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

  String _displayName = 'Zdanov';
  String _avatarUrl = ''; 

  bool _hasCheckedIn = false;
  bool _hasCheckedOut = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final supabase = Supabase.instance.client;
      final sessionUserId = supabase.auth.currentUser?.id;

      // FIX PROFILE: Menggunakan .limit(1) agar tidak bergantung pada sesi login auth saat testing
      final profileResponse = await supabase
          .from('profiles')
          .select('id, display_name, avatar_url')
          .limit(1)
          .maybeSingle();

      String activeUserId = sessionUserId ?? '';

      if (profileResponse != null) {
        _displayName = profileResponse['display_name'] ?? 'Zdanov';
        _avatarUrl = profileResponse['avatar_url']?.toString() ?? '';
        
        // Cadangan: Jika session auth kosong, gunakan ID dari profil teratas agar sinkron
        if (activeUserId.isEmpty) {
          activeUserId = profileResponse['id'] ?? '';
        }
      }

      // Tarik Data Absensi Spesifik Hari Ini berdasarkan ID aktif
      if (activeUserId.isNotEmpty) {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
        final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

        final attendanceResponse = await supabase
            .from('attendance')
            .select()
            .eq('user_id', activeUserId)
            .gte('check_in_time', startOfDay)
            .lte('check_in_time', endOfDay)
            .maybeSingle();

        if (mounted) {
          setState(() {
            if (attendanceResponse != null) {
              _hasCheckedIn = true;
              _hasCheckedOut = attendanceResponse['check_out_time'] != null; 
            }
          });
        }
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    
    String hour = now.hour > 12 ? (now.hour - 12).toString().padLeft(2, '0') : now.hour.toString().padLeft(2, '0');
    if (now.hour == 0) hour = "12";
    String minute = now.minute.toString().padLeft(2, '0');
    String ampm = now.hour >= 12 ? "PM" : "AM";

    return "$dayName, $monthName ${now.day}, ${now.year} • $hour:$minute $ampm";
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
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primary)) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${_getGreeting()}, $_displayName!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: primary),
                const SizedBox(width: 8),
                Text(_getFormattedDate(), style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    icon: Icons.location_on, iconBg: secondaryContainer, iconColor: onSecondaryContainer, 
                    title: "GPS Status", value: "Verified"
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    icon: Icons.face, iconBg: tertiaryFixed, iconColor: onTertiaryFixed, 
                    title: "Face ID", value: "Ready"
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceContainerLowest, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: outlineVariant.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Text(
                    _hasCheckedOut ? "Attendance Complete" 
                    : _hasCheckedIn ? "Ready for Check-out" 
                    : "Ready for Check-in", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)
                  ),
                  const SizedBox(height: 4),
                  Text("Ensure your face is clearly visible", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: _hasCheckedOut ? null : () {
                      if (widget.onSwitchToAttend != null) widget.onSwitchToAttend!();
                    },
                    child: Container(
                      width: 128, height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _hasCheckedOut ? outlineVariant : primary, width: 3),
                        color: Colors.white,
                        boxShadow: _hasCheckedOut ? [] : [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 20)],
                      ),
                      child: Icon(
                        _hasCheckedOut ? Icons.check_circle : Icons.face_unlock_outlined, 
                        size: 48, color: _hasCheckedOut ? Colors.green : primary
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _hasCheckedIn ? null : () {
                            if (widget.onSwitchToAttend != null) widget.onSwitchToAttend!();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasCheckedIn ? surfaceContainerLow : primary,
                            foregroundColor: _hasCheckedIn ? outlineVariant : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: _hasCheckedIn ? 0 : 2,
                          ),
                          icon: const Icon(Icons.login, size: 20),
                          label: const Text("Check-in", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (!_hasCheckedIn || _hasCheckedOut) ? null : () {
                            if (widget.onSwitchToAttend != null) widget.onSwitchToAttend!();
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: (!_hasCheckedIn || _hasCheckedOut) ? surfaceContainerLow : surfaceContainerLowest,
                            side: BorderSide(color: (!_hasCheckedIn || _hasCheckedOut) ? outlineVariant.withOpacity(0.3) : primary),
                            foregroundColor: (!_hasCheckedIn || _hasCheckedOut) ? outlineVariant : primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text("Check-out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text("Weekly Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("M", 80, true), _buildBar("T", 85, true),
                      _buildBar("W", 40, true), _buildBar("T", 0, false),
                      _buildBar("F", 0, false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({required IconData icon, required Color iconBg, required Color iconColor, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 40, decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
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
          width: 32, height: 80, alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity, height: 80 * (heightPercent / 100),
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