import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
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
        // Font dasar, bisa diganti dengan google_fonts nanti
        fontFamily: 'Roboto', 
      ),
      home: const SplashScreen(),
    );
  }
}