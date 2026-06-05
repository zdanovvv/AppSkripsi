import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'gps_screen.dart'; 

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;
  
  // Variabel Kamera & Machine Learning
  CameraController? _cameraController;
  Interpreter? _interpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableClassification: false,
      performanceMode: FaceDetectorMode.fast, // Mode cepat karena butuh real-time
    ),
  );
  bool _isDetecting = false;
  double _aiMatchScore = 0.0;

  // Warna Material 3
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerHighest = const Color(0xFFE1E3E4);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _initCameraAndML();
  }

  Future<void> _initCameraAndML() async {
    // 1. Muat Model TFLite MobileNet v1
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_mobilenet.tflite');
      debugPrint("Model TFLite berhasil dimuat!");
    } catch (e) {
      debugPrint("Gagal memuat model: $e");
      // Cek apakah nama file sudah sesuai di folder assets
    }

    // 2. Inisialisasi Kamera Depan
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Resolusi Medium agar pemrosesan ML tidak lag
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Format standar Android
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});

      // 3. Mulai menangkap frame kamera untuk di-scan oleh AI
      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || _isScanning) return;
        _isDetecting = true;
        _processCameraFrame(image);
      });
    } catch (e) {
      debugPrint("Gagal membuka kamera: $e");
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_interpreter == null) {
      _isDetecting = false;
      return;
    }

    try {
      // 1. Ubah format gambar kamera mentah ke format yang bisa dibaca Google ML Kit
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      // 2. ML Kit mendeteksi apakah ada wajah di dalam frame
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        // Jika tidak ada wajah, skor AI jadi 0
        if (mounted) setState(() => _aiMatchScore = 0.0);
        _isDetecting = false;
        return;
      }

      // 3. Jika ada wajah, ambil wajah pertama (paling dominan)
      final face = faces.first;
      final boundingBox = face.boundingBox; 

      // 4. DI SINI LOGIKA MOBILENET BERJALAN
      // Untuk TFLite, kita biasanya perlu memotong (crop) gambar sesuai 'boundingBox'
      // lalu di-resize ke ukuran input MobileNet v1 (biasanya 224x224 pixel).
      
      // Karena implementasi crop YUV420 ke Tensor cukup panjang, untuk memastikan 
      // alurnya berjalan dulu, kita asumsikan model berjalan dan mengeluarkan output.
      // Nanti array angka dari crop wajah dimasukkan ke: _interpreter!.run(input, output);
      
      // Simulasi hasil inferensi MobileNet v1 (sementara kita buat skor acak di atas 80 
      // jika terdeteksi wajah, agar kamu bisa tes UI-nya)
      if (mounted) {
        setState(() {
          _aiMatchScore = 85.0 + (DateTime.now().millisecond % 10); // Simulasi skor 85-94%
        });
      }

    } catch (e) {
      debugPrint("Gagal memproses frame: $e");
    }

    _isDetecting = false;
  }

  // --- FUNGSI HELPER UNTUK ML KIT ---
  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;
    
    InputImageRotation? rotation;
    if (sensorOrientation == 90) rotation = InputImageRotation.rotation90deg;
    else if (sensorOrientation == 180) rotation = InputImageRotation.rotation180deg;
    else if (sensorOrientation == 270) rotation = InputImageRotation.rotation270deg;
    else rotation = InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || rotation == null) return null;

    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes, // Hanya mengambil plane pertama untuk deteksi wajah cepat
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _interpreter?.close();
    _faceDetector.close();
    _scanController.dispose();
    super.dispose();
  }

  void _onCapture() {
    setState(() => _isScanning = true);
    
    // Nanti logika ini diubah:
    // Jika _aiMatchScore > threshold (misal 80%), maka simpan ke SUPABASE lalu lanjut ke GPS
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isScanning = false);
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const GPSScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
              var scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

              return FadeTransition(opacity: fadeAnimation, child: ScaleTransition(scale: scaleAnimation, child: child));
            },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=Alex&background=random")), // Nanti ini ditarik dari profile Supabase
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: onSurfaceVariant), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Text("Biometric Check-In", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)),
            const SizedBox(height: 8),
            Text("Position your face within the frame.", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
            const SizedBox(height: 32),

            // Camera Area
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: outlineVariant.withOpacity(0.5)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Tampilan Live Camera
                            (_cameraController != null && _cameraController!.value.isInitialized)
                                ? CameraPreview(_cameraController!)
                                : const Center(child: CircularProgressIndicator()),
                            
                            // Efek Kaca Redup
                            Container(color: Colors.white.withOpacity(0.1)),
                            
                            // Border Target
                            Positioned(
                              top: 16, bottom: 16, left: 16, right: 16,
                              child: Container(
                                decoration: BoxDecoration(border: Border.all(color: primary.withOpacity(0.4), width: 2), borderRadius: BorderRadius.circular(24)),
                                child: Stack(
                                  children: [
                                    _buildCorner(Alignment.topLeft), _buildCorner(Alignment.topRight),
                                    _buildCorner(Alignment.bottomLeft), _buildCorner(Alignment.bottomRight),
                                    
                                    AnimatedBuilder(
                                      animation: _scanController,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: _scanController.value * (MediaQuery.of(context).size.width * 1.2 - 64),
                                          left: 0, right: 0,
                                          child: Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.8),
                                              boxShadow: [BoxShadow(color: primary.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Real-time Metrics (Kiri atas)
                            Positioned(
                              top: 24, left: 24, right: 24,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildGlassPill(child: Row(
                                    children: [
                                      Container(width: 8, height: 8, decoration: BoxDecoration(color: _aiMatchScore > 80 ? Colors.green : primary, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(_isScanning ? "Verifying..." : "Scanning...", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  )),
                                  _buildGlassPill(child: Text("AI Match: ${_aiMatchScore.toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Capture
            GestureDetector(
              onTap: _isScanning ? null : _onCapture,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: surface, width: 4),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 15)],
                ),
                child: _isScanning 
                    ? const Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.fingerprint, color: Colors.white, size: 36), // Ganti ikon kamera jadi identitas
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y == -1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
            bottom: alignment.y == 1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
            left: alignment.x == -1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
            right: alignment.x == 1.0 ? BorderSide(color: primary, width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(24) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(24) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(24) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(24) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPill({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), border: Border.all(color: outlineVariant.withOpacity(0.3))),
          child: child,
        ),
      ),
    );
  }
}