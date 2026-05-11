import 'package:flutter/material.dart';
import 'dart:async'; // Diperlukan untuk fungsi Timer
import '../theme/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // Menjalankan timer selama 3 detik sebelum pindah halaman
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          // Durasi transisi kita lamain dikit jadi 1 detik biar elegan
          transitionDuration: const Duration(milliseconds: 1000), 
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            
            // Efek memudar perlahan (Fade)
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );
            
            // Efek nge-zoom membesar (Scale) dari 90% ke 100%
            var scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Background dengan gradien linear sesuai desain
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 0.7, 1.0],
            colors: [
              AppColors.splashBg1,
              AppColors.splashBg2,
              AppColors.splashBg3,
              AppColors.splashBg4,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Logo dengan efek Glassmorphism
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.glassBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Judul Aplikasi: FaceAttend
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.w800, 
                  letterSpacing: -0.5
                ),
                children: [
                  TextSpan(
                    text: 'Face', 
                    style: TextStyle(color: Colors.white)
                  ),
                  TextSpan(
                    text: 'Attend', 
                    style: TextStyle(color: AppColors.textAttend)
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Slogan/Subtitle
            const Text(
              'SMART ATTENDANCE SYSTEM',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                letterSpacing: 2.0,
              ),
            ),
            
            const Spacer(),
            
            // Informasi Footer
            const Text(
              'Powered by AI · Firebase · GPS',
              style: TextStyle(
                color: AppColors.textMuted, 
                fontSize: 12
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 2.4.1',
              style: TextStyle(
                color: Colors.white38, 
                fontSize: 11
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}