import 'package:flutter/material.dart';

class AnimatedButtonWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedButtonWrapper({Key? key, required this.child, this.onTap}) : super(key: key);

  @override
  State<AnimatedButtonWrapper> createState() => _AnimatedButtonWrapperState();
}

class _AnimatedButtonWrapperState extends State<AnimatedButtonWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Tween untuk mengatur seberapa kecil tombol mengecil.
  // begin: 1.0 (ukuran asli), end: 0.96 (mengecil jadi 96%)
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Durasi animasi cepet aja pas ditekan, biar responsif
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), 
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward(); // Mengecilkan tombol pas jari nempel
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse(); // Mengembalikan ukuran pas jari diangkat
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse(); // Mengembalikan ukuran kalau batal pencet
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap, // Fungsi aslinya dijalankan di sini
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child, // Tombol asli kamu ada di sini
      ),
    );
  }
}