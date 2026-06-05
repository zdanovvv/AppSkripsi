import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib import ini
import 'screens/splash_screen.dart';

// Ubah main() jadi asynchronous karena kita butuh waktu buat konek database
Future<void> main() async {
  // Wajib dipanggil sebelum inisialisasi Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Ini dia jembatan koneksinya!
  await Supabase.initialize(
    url: 'https://cbnnlmtguowjcwlprkcp.supabase.co/rest/v1/',     // <--- ISI DENGAN PROJECT URL SUPABASE-MU
    anonKey: 'sb_publishable_EJMjq3nAiTaMDqo6xizzrA_JI18L9M6',  // <--- ISI DENGAN ANON KEY SUPABASE-MU
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