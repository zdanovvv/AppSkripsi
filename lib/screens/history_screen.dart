import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart'; // TAMBAHAN: Import Supabase
import 'history_detail_screen.dart';
import 'settings_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Mode View: true = List View, false = Analytics View
  bool _isListView = false; 

  // TAMBAHAN: Variabel untuk menyimpan data profil dari database
  String _displayName = 'Zdanov';
  String _avatarUrl = '';

  // Tema Warna Material 3 
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color surfaceContainer = const Color(0xFFEDEEEF);
  final Color surfaceContainerHigh = const Color(0xFFE7E8E9);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color onPrimaryContainer = const Color(0xFFFFFFFF);
  final Color secondary = const Color(0xFF4F6169);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  final Color outline = const Color(0xFF727785);
  final Color error = const Color(0xFFBA1A1A);

  // TAMBAHAN: Menjalankan fetch saat halaman dibuka
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // TAMBAHAN: Fungsi narik data avatar dan nama dari Supabase
  Future<void> _fetchProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('profiles')
          .select('display_name, avatar_url')
          .limit(1)
          .single();

      if (mounted) {
        setState(() {
          _displayName = response['display_name'] ?? 'Zdanov';
          _avatarUrl = response['avatar_url']?.toString() ?? '';
        });
      }
    } catch (_) {}
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
            // TAMBAHAN: CircleAvatar logic diubah agar mengambil data dari _avatarUrl
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER & TOGGLE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isListView ? "Attendance History" : "Analytics Overview", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onSurface)
                ),
                
                // Toggle Button
                Container(
                  decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(100), border: Border.all(color: outlineVariant.withOpacity(0.5))),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      // List View Button
                      GestureDetector(
                        onTap: () => setState(() => _isListView = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isListView ? surfaceContainerLowest : Colors.transparent, 
                            borderRadius: BorderRadius.circular(100), 
                            boxShadow: _isListView ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : []
                          ),
                          child: Icon(Icons.format_list_bulleted, size: 18, color: _isListView ? primary : onSurfaceVariant),
                        ),
                      ),
                      // Analytics View Button
                      GestureDetector(
                        onTap: () => setState(() => _isListView = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: !_isListView ? surfaceContainerLowest : Colors.transparent, 
                            borderRadius: BorderRadius.circular(100), 
                            boxShadow: !_isListView ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : []
                          ),
                          child: Icon(Icons.calendar_month, size: 18, color: !_isListView ? primary : onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- ANIMATED SWITCHER ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isListView ? _buildListView() : _buildAnalyticsView(),
            ),
            
            const SizedBox(height: 80), // Spacer Bottom Nav
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 1. LIST VIEW (Riwayat Harian)
  // =========================================================================
  Widget _buildListView() {
    return Column(
      key: const ValueKey("ListView"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(color: onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search records...",
                  hintStyle: TextStyle(color: outline, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: outline, size: 20),
                  filled: true, fillColor: surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: outlineVariant)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: primary, width: 2)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(backgroundColor: surfaceContainerLowest, side: BorderSide(color: outlineVariant), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
              icon: Icon(Icons.filter_list, size: 18, color: onSurfaceVariant),
              label: Text("Filter", style: TextStyle(color: onSurfaceVariant, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Summary Bento
        Row(
          children: [
            Expanded(child: _buildSummaryCard("Present", "21")),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard("Late", "2")),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard("Absent", "0")),
          ],
        ),
        const SizedBox(height: 32),

        // List
        Text("October 2023", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
        const SizedBox(height: 12),
        _buildHistoryRecord(date: "24", day: "Tue", checkIn: "08:55 AM", checkOut: "05:05 PM", status: "On Time", statusColor: const Color(0xFF00429C), statusBg: const Color(0xFFD9E2FF)),
        _buildHistoryRecord(date: "23", day: "Mon", checkIn: "08:42 AM", checkOut: "05:10 PM", status: "On Time", statusColor: const Color(0xFF00429C), statusBg: const Color(0xFFD9E2FF)),
        _buildHistoryRecord(date: "20", day: "Fri", checkIn: "09:15 AM", checkOut: "05:00 PM", status: "Late", statusColor: const Color(0xFF0B1E24), statusBg: const Color(0xFFD2E6EF), isCheckInLate: true),
        _buildHistoryRecord(date: "19", day: "Thu", checkIn: "No scan data recorded", checkOut: "", status: "Absent", statusColor: const Color(0xFF93000A), statusBg: const Color(0xFFFFDAD6), isAbsent: true),
      ],
    );
  }

  // =========================================================================
  // 2. ANALYTICS VIEW (Responsive Mobile)
  // =========================================================================
  Widget _buildAnalyticsView() {
    return Column(
      key: const ValueKey("AnalyticsView"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Review organization attendance trends and biometric efficiency metrics.", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
        const SizedBox(height: 24),

        // --- Insights Summary Banner ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: primaryContainer, borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.insights, color: onPrimaryContainer, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Productivity Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onPrimaryContainer)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: onPrimaryContainer.withOpacity(0.9), fontSize: 14, height: 1.5),
                        children: const [
                          TextSpan(text: "Overall attendance stabilized at "),
                          TextSpan(text: "94%", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: " this week. Late arrivals spiked by 12% on Tuesday morning due to regional transit delays."),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- DASHBOARD GRID (VERTIKAL UNTUK MOBILE) ---
        Column(
          children: [
            // Chart 1: Daily Attendance (Bar)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: outlineVariant.withOpacity(0.3)), boxShadow: [BoxShadow(color: primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daily Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                  Text("Current active workforce", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("94%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary, height: 1.0)),
                      const SizedBox(width: 4),
                      Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("Present", style: TextStyle(fontSize: 14, color: secondary))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  Container(
                    height: 12, width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFE1E3E4), borderRadius: BorderRadius.circular(100)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft, widthFactor: 0.94,
                      child: Container(decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(100))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("0%", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                      Text("Target: 95%", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                      Text("100%", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Chart 2: Punctuality (Donut)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: outlineVariant.withOpacity(0.3)), boxShadow: [BoxShadow(color: primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))]),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Punctuality", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                        Text("Check-in status", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                        const SizedBox(height: 16),
                        _buildPunctualityRow(primary, "On Time", "82%"),
                        const SizedBox(height: 8),
                        _buildPunctualityRow(error, "Late", "13%"),
                        const SizedBox(height: 8),
                        _buildPunctualityRow(outline, "Absent", "5%"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Donut Chart menggunakan CustomPaint
                  SizedBox(
                    width: 90, height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(size: const Size(90, 90), painter: DonutChartPainter()),
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: surfaceContainerLowest, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                          child: Icon(Icons.schedule, color: primary, size: 28),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Chart 3: Weekly Trend Line Graph ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: outlineVariant.withOpacity(0.3)), boxShadow: [BoxShadow(color: primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Weekly Check-in", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                        Text("Total scans per day", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: surfaceContainerHigh, borderRadius: BorderRadius.circular(100)),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text("This Week", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              // SVG Line Graph Custom Paint
              SizedBox(
                height: 180, width: double.infinity,
                child: Row(
                  children: [
                    // Y Axis
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("500", style: TextStyle(fontSize: 10, color: outlineVariant, fontWeight: FontWeight.w500)),
                        Text("400", style: TextStyle(fontSize: 10, color: outlineVariant, fontWeight: FontWeight.w500)),
                        Text("300", style: TextStyle(fontSize: 10, color: outlineVariant, fontWeight: FontWeight.w500)),
                        Text("200", style: TextStyle(fontSize: 10, color: outlineVariant, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Garis Grafik
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: LineChartPainter(primary),
                            ),
                          ),
                          // X Axis
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Mon", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                              Text("Tue", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                              Text("Wed", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                              Text("Thu", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                              Text("Fri", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                              Text("Sat", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- Chart 4: Heatmap ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: outlineVariant.withOpacity(0.3)), boxShadow: [BoxShadow(color: primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Check-in Density", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
              Text("Peak arrival times over the last 5 days", style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
              const SizedBox(height: 20),
              
              // Custom Heatmap Grid persis desain Tailwind
              _buildHeatmapHeader(),
              _buildHeatmapRow("Mon", [0.2, 0.8, 1.0, 0.4]),
              _buildHeatmapRow("Tue", [0.1, 0.4, 0.9, 0.6]),
              _buildHeatmapRow("Wed", [0.3, 0.7, 0.8, 0.2]),
              _buildHeatmapRow("Thu", [0.2, 0.6, 0.9, 0.3]),
              _buildHeatmapRow("Fri", [0.4, 0.9, 0.5, 0.1]),
              
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Low", style: TextStyle(fontSize: 10, color: outlineVariant)),
                  const SizedBox(width: 8),
                  Container(
                    width: 80, height: 8,
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [primary.withOpacity(0.1), primary]), borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 8),
                  Text("High", style: TextStyle(fontSize: 10, color: outlineVariant)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  // Helper List View
  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: outlineVariant.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurface)),
        ],
      ),
    );
  }

  Widget _buildHistoryRecord({required String date, required String day, required String checkIn, required String checkOut, required String status, required Color statusColor, required Color statusBg, bool isCheckInLate = false, bool isAbsent = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: outlineVariant.withOpacity(0.5))),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryDetailScreen(date: "October $date, 2023", status: status, checkInTime: checkIn, checkOutTime: checkOut))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: outlineVariant.withOpacity(0.3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(date, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isAbsent ? onSurfaceVariant : onSurface, height: 1.1)), Text(day, style: TextStyle(fontSize: 10, color: onSurfaceVariant))])),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (isAbsent) Text(checkIn, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: onSurfaceVariant))
                    else ...[
                      Row(children: [Icon(Icons.login, size: 16, color: isCheckInLate ? error : outline), const SizedBox(width: 6), Text(checkIn, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface))]),
                      const SizedBox(height: 4),
                      Row(children: [Icon(Icons.logout, size: 16, color: outline), const SizedBox(width: 6), Text(checkOut, style: TextStyle(fontSize: 14, color: onSurfaceVariant))]),
                    ]
                  ]),
                ],
              ),
              Row(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100), border: Border.all(color: statusColor.withOpacity(0.2))), child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor))),
                  const SizedBox(width: 8), Icon(Icons.chevron_right, color: outlineVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Analytics View - DIPERBAIKI MENGGUNAKAN EXPANDED
  Widget _buildPunctualityRow(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: onSurface), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: onSurfaceVariant)),
      ],
    );
  }

  Widget _buildHeatmapHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 36),
          Expanded(child: Center(child: Text("7:30", style: TextStyle(fontSize: 10, color: outline)))),
          Expanded(child: Center(child: Text("8:00", style: TextStyle(fontSize: 10, color: outline)))),
          Expanded(child: Center(child: Text("8:30", style: TextStyle(fontSize: 10, color: outline)))),
          Expanded(child: Center(child: Text("9:00", style: TextStyle(fontSize: 10, color: outline)))),
        ],
      ),
    );
  }

  Widget _buildHeatmapRow(String day, List<double> intensities) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text(day, style: TextStyle(fontSize: 12, color: onSurfaceVariant))),
          ...intensities.map((intensity) => Expanded(
            child: Container(
              height: 32, margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: primary.withOpacity(intensity), borderRadius: BorderRadius.circular(6)),
            )
          )).toList(),
        ],
      ),
    );
  }
}

// =========================================================================
// CUSTOM PAINTERS UNTUK GRAFIK ANALYTICS
// =========================================================================

// 1. Donut Chart Painter (Untuk persentase keterlambatan)
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 14.0; 
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));

    // 82% On Time (Biru)
    paint.color = const Color(0xFF005BBF);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * 0.82, false, paint);
    
    // 13% Late (Merah)
    paint.color = const Color(0xFFBA1A1A);
    canvas.drawArc(rect, -math.pi / 2 + (2 * math.pi * 0.82), 2 * math.pi * 0.13, false, paint);
    
    // 5% Absent (Abu-abu)
    paint.color = const Color(0xFF727785);
    canvas.drawArc(rect, -math.pi / 2 + (2 * math.pi * 0.95), 2 * math.pi * 0.05, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Line Chart Painter (Untuk grafik garis mingguan)
class LineChartPainter extends CustomPainter {
  final Color primaryColor;
  LineChartPainter(this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Grid Lines Background
    final gridPaint = Paint()
      ..color = const Color(0xFFC1C6D6).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    for (int i = 0; i <= 3; i++) {
      double y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Border Kiri & Bawah
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), gridPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);

    // Titik Koordinat
    final points = [
      Offset(0, size.height * 0.60),
      Offset(size.width * 0.20, size.height * 0.40),
      Offset(size.width * 0.40, size.height * 0.80),
      Offset(size.width * 0.60, size.height * 0.30),
      Offset(size.width * 0.80, size.height * 0.20),
      Offset(size.width, size.height * 0.50),
    ];

    // 1. Draw Area Gradient 
    final areaPath = Path();
    areaPath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTRB(0, 0, 0, size.height));
      
    canvas.drawPath(areaPath, gradientPaint);

    // 2. Draw Line Stroke
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // 3. Draw Dots
    final dotPaintOuter = Paint()..color = primaryColor..style = PaintingStyle.fill;
    final dotPaintInner = Paint()..color = Colors.white..style = PaintingStyle.fill;

    for (int i = 1; i < points.length; i++) {
      canvas.drawCircle(points[i], 4.5, dotPaintOuter);
      canvas.drawCircle(points[i], 2.5, dotPaintInner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}