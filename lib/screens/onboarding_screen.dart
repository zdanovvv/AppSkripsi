import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Konfigurasi Warna (Sama dengan Login Screen)
  final Color surface = const Color(0xFFF8F9FA);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  final List<Map<String, dynamic>> _slides = [
    {
      "icon": Icons.face_retouching_natural,
      "title": "Smart Face Recognition",
      "subtitle": "AI-POWERED BIOMETRIC",
      "description": "Our advanced AI instantly recognizes your face with 99.8% accuracy. Secure and contactless.",
    },
    {
      "icon": Icons.location_on_outlined,
      "title": "GPS Location Verified",
      "subtitle": "SECURE GEOFENCING",
      "description": "Precise GPS validation ensures you can only check in from approved locations in real-time.",
    },
    {
      "icon": Icons.bar_chart_outlined,
      "title": "Real-time Analytics",
      "subtitle": "LIVE DATA SYNC",
      "description": "Comprehensive dashboards with live Firebase sync to track attendance trends and insights.",
    },
  ];

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(0.0, 0.05), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: animation.drive(tween), child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Skip Button (Light Style) ---
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton(
                  onPressed: _goToLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: outlineVariant.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: onSurfaceVariant,
                  ),
                  child: const Text("Skip", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ),

            // --- 2. Page Content (Cards) ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ikon dalam Lingkaran Halus (Material 3 Vibe)
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: primary.withOpacity(0.1)),
                          ),
                          child: Icon(_slides[index]["icon"], size: 72, color: primary),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _slides[index]["subtitle"],
                          style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _slides[index]["title"],
                          style: TextStyle(color: onSurface, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _slides[index]["description"],
                          style: TextStyle(color: onSurfaceVariant, fontSize: 14, height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- 3. Bottom Controls ---
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Indicators (Blue Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? primary : outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button dengan Gradien (Sama dengan Login Button)
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      } else {
                        _goToLogin();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryContainer, primary]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _slides.length - 1 ? "Get Started" : "Continue",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}