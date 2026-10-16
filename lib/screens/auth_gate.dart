import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

/// Pintu masuk aplikasi.
///  - Belum login  -> SplashScreen -> Onboarding -> Login (alur lama).
///  - Sudah login  -> loading singkat -> langsung MainScreen (tanpa splash/onboarding/login).
/// Sesi login disimpan otomatis oleh supabase_flutter, jadi tetap login walau app ditutup.
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _hasSession;

  @override
  void initState() {
    super.initState();
    _hasSession = Supabase.instance.client.auth.currentSession != null;
    if (_hasSession) _verifyAndEnter();
  }

  Future<void> _verifyAndEnter() async {
    final auth = Supabase.instance.client.auth;
    final minDelay = Future.delayed(const Duration(milliseconds: 1200)); // biar loading terlihat
    var valid = true;

    try {
      final session = auth.currentSession;
      if (session != null && session.isExpired) {
        await auth.refreshSession();
      }
    } on AuthException {
      // Token ditolak server (akun dihapus / sesi dicabut) -> paksa login ulang.
      valid = false;
      try {
        await auth.signOut();
      } catch (_) {}
    } catch (_) {
      // Error lain (mis. offline): tetap masuk, sesi lokal masih ada.
    }

    await minDelay;
    if (!mounted) return;

    if (!valid) {
      setState(() => _hasSession = false); // jatuh ke alur Splash -> Login
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSession) return const SplashScreen();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          children: const [
            Icon(Icons.face_retouching_natural, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'FaceAttend',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text('Memuat data...', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
