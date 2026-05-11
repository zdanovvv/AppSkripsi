import 'package:flutter/material.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("Attendance Screen Placeholder", style: TextStyle(color: Colors.white))),
    const Center(child: Text("History Screen Placeholder", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Notifications Screen Placeholder", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Profile Screen Placeholder", style: TextStyle(color: Colors.white))),
  ];

  // Data Navigasi (Icon non-aktif, Icon aktif, Label)
  final List<Map<String, dynamic>> _navItemsData = [
    {"icon": Icons.home_outlined, "activeIcon": Icons.home, "label": "Home"},
    {"icon": Icons.fingerprint_outlined, "activeIcon": Icons.fingerprint, "label": "Attend"},
    {"icon": Icons.history_outlined, "activeIcon": Icons.history, "label": "History"},
    {"icon": Icons.notifications_outlined, "activeIcon": Icons.notifications, "label": "Notif"},
    {"icon": Icons.person_outline, "activeIcon": Icons.person, "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    // Menghitung lebar tiap item navigasi secara dinamis
    double totalWidth = MediaQuery.of(context).size.width;
    double navItemWidth = totalWidth / _navItemsData.length;
    
    // Diameter lingkaran background
    double indicatorDiameter = 56.0; 
    // Tinggi Bottom Bar
    double bottomBarHeight = 76.0; 

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Sesuaikan background utama gelap kamu
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: bottomBarHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA), // Surface bright dari HTML kamu
          border: Border(top: BorderSide(color: const Color(0xFFC1C6D6).withOpacity(0.3))),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, -2))
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- 1. CIRCULAR MOVING INDICATOR (Background Lingkaran) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350), // Kecepatan geser lingkaran
              curve: Curves.easeOutQuart, // Gerakan yang smooth
              // Hitung posisi horizontal lingkaran (berdasarkan index aktif)
              left: (navItemWidth * _currentIndex) + (navItemWidth / 2) - (indicatorDiameter / 2),
              // Hitung posisi vertikal agar lingkaran berada di tengah area ikon
              top: (bottomBarHeight - indicatorDiameter) / 2 - 4, // Sedikit geser ke atas biar gak mepet teks
              child: Container(
                width: indicatorDiameter, // Gunakan diameter yang sama (lebar = tinggi)
                height: indicatorDiameter,
                decoration: const BoxDecoration(
                  color: Color(0xFFD2E6EF), // secondary-container color
                  shape: BoxShape.circle, // Membuatnya menjadi lingkaran sempurna
                ),
              ),
            ),

            // --- 2. THE NAV ITEMS (Ikon & Label) ---
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(_navItemsData.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      if (_currentIndex != index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: navItemWidth,
                      color: Colors.transparent, // Biar area kliknya luas
                      alignment: Alignment.center,
                      child: StatefulNavItem(
                        iconData: _navItemsData[index]["icon"],
                        activeIconData: _navItemsData[index]["activeIcon"],
                        label: _navItemsData[index]["label"],
                        isActive: _currentIndex == index,
                        hasBadge: index == 3, // Asumsi Notifications ada badge
                        circleDiameter: indicatorDiameter,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET KHUSUS UNTUK ICON NAVIGASI (Hanya pakai animasi Scale & Color)
// =========================================================================
class StatefulNavItem extends StatefulWidget {
  final IconData iconData;
  final IconData activeIconData;
  final String label;
  final bool isActive;
  final bool hasBadge;
  final double circleDiameter;

  const StatefulNavItem({
    Key? key,
    required this.iconData,
    required this.activeIconData,
    required this.label,
    required this.isActive,
    required this.hasBadge,
    required this.circleDiameter,
  }) : super(key: key);

  @override
  State<StatefulNavItem> createState() => _StatefulNavItemState();
}

class _StatefulNavItemState extends State<StatefulNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Tween untuk animasi perbesaran ikon (Scale)
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Kecepatan animasi pop-up
    );

    // Animasi membesar dikit (Scale) dari 90% ke 100%
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack), // Efek membal di akhir
    );

    if (widget.isActive) {
      _controller.forward(); // Jalankan animasi jika aktif saat pertama kali load
    }
  }

  @override
  void didUpdateWidget(covariant StatefulNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cek perubahan status aktif/tidak aktif
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward(); // Perbesar ikon pas aktif
      } else {
        _controller.reverse(); // Kecilkan kembali ikon pas non-aktif
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna aktif dan non-aktif
    Color activeColor = const Color(0xFF55676F); // on-secondary-container
    Color inactiveColor = const Color(0xFF414754); // on-surface-variant

    return Column(
      mainAxisSize: MainAxisSize.min, // Hug content
      children: [
        // --- ANIMATED ICON AREA (Tinggal Scale & Color aja) ---
        // Kita bungkus ikon dalam SizedBox dengan ukuran yang sama dengan diameter lingkaran
        // agar ikon diam di tengah-tengah area lingkaran.
        SizedBox(
          width: widget.circleDiameter,
          height: widget.circleDiameter,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    widget.isActive ? widget.activeIconData : widget.iconData,
                    color: widget.isActive ? activeColor : inactiveColor,
                    size: widget.isActive ? 26 : 24, // Subtle increase
                  ),
                  // Badge Notifikasi
                  if (widget.hasBadge)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBA1A1A), // Error color
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 0), // Atur jarak ikon ke teks
        // --- TEXT LABEL (Memudar masuk/keluar) ---
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.isActive ? 1.0 : 0.7, // Redupkan teks non-aktif
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              color: widget.isActive ? activeColor : inactiveColor,
            ),
          ),
        ),
      ],
    );
  }
}