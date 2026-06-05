import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib import ini
import 'screens/splash_screen.dart';

// Ubah main() jadi asynchronous karena kita butuh waktu buat konek database
Future<void> main() async {
  // Wajib dipanggil sebelum inisialisasi Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Ini dia jembatan koneksinya!
  await Supabase.initialize(
    url: 'https://cbnnlmtguowjcwlprkcp.supabase.co',     // <--- ISI DENGAN PROJECT URL SUPABASE-MU
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNibm5sbXRndW93amN3bHBya2NwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjY1OTQsImV4cCI6MjA5NjIwMjU5NH0.7hI_8KF8c1wrPIftifuj1Q9npZK9JQpwSDarv32nWW8',  // <--- ISI DENGAN ANON KEY SUPABASE-MU
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FaceAttend',
      theme: ThemeData(
        fontFamily: 'Roboto', 
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005BBF)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}