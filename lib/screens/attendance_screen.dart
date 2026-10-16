import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io'; 
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'gps_screen.dart';
import 'settings_screen.dart';
import '../utils/face_service.dart';
import '../utils/face_utils.dart';
import '../utils/liveness_service.dart';

class AttendanceScreen extends StatefulWidget {
  final bool isActive; 
  const AttendanceScreen({Key? key, required this.isActive}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;
  
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableClassification: true, // dibutuhkan liveness (probabilitas mata terbuka)
      performanceMode: FaceDetectorMode.fast, 
    ),
  );
  
  bool _isDetecting = false;
  double _aiMatchScore = 0.0; // cosine similarity ASLI x 100 (bukan probabilitas)
  bool _isFaceDetected = false;

  int _faceDetectedFrames = 0;
  bool _isScoreLocked = false; // true = proses verifikasi selesai (cocok / tidak cocok)
  bool _isMatch = false; // true = wajah cocok dengan data terdaftar
  double _finalLockedScore = 0.0;

  final LivenessChecker _liveness = LivenessChecker(); // challenge-response anti foto statis

  List<List<double>> _enrolled = []; // embedding wajah terdaftar milik user
  bool _enrolledLoaded = false;
  final List<List<double>> _samples = []; // embedding dari beberapa frame berturut-turut
  static const int _warmupFrames = 8; // frame stabil sebelum mulai ambil sampel
  static const int _samplesNeeded = 3; // jumlah sampel yang dirata-rata

  Color get _stateColor => _isScoreLocked
      ? (_isMatch ? Colors.green : Colors.red)
      : (_isFaceDetected ? Colors.orange : primary);

  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerHighest = const Color(0xFFE1E3E4);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color outlineVariant = const Color(0xFFC1C6D6);

  String _displayName = 'Zdanov';
  String _avatarUrl = '';

  @override
void initState() {
  super.initState();
  _scanController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);
  
  _fetchUserData();
  if (widget.isActive) {
    _initCameraAndML();
  }
}

  @override
  void didUpdateWidget(covariant AttendanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _initCameraAndML();
      } else {
        _stopCamera(); 
      }
    }
  }

  Future<void> _stopCamera() async {
    _isDetecting = true;
    _samples.clear();
    _liveness.reset();
    _isMatch = false;
    final controller = _cameraController;
    _cameraController = null;
    try {
      if (controller != null && controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      await controller?.dispose();
    } catch (e) {
      debugPrint("Gagal menutup kamera: $e");
    }
    if (mounted) {
      setState(() {
        _cameraController = null;
        _isFaceDetected = false;
        _aiMatchScore = 0.0;
        _faceDetectedFrames = 0;
        _isScoreLocked = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('profiles')
          .select('display_name, avatar_url')
          .eq('id', supabase.auth.currentUser?.id ?? '')
          .maybeSingle();

      if (mounted && response != null) {
        setState(() {
          _displayName = response['display_name'] ?? 'Zdanov';
          _avatarUrl = response['avatar_url']?.toString() ?? '';
        });
      }
    } catch (_) {}
  }

  bool _isInitializing = false;

  Future<void> _initCameraAndML() async {
    if (_isInitializing) return;
    _isInitializing = true;

    // Bersihkan sisa controller/interpreter sebelumnya supaya tidak bocor.
    await _stopCamera();
    _isDetecting = false; // _stopCamera mengisi true; tanpa reset deteksi mati setelah pindah tab
    try {
      await FaceService.instance.load();
      await _loadEnrolled();
    } catch (e) {
      debugPrint("Gagal load model / embedding: $e");
    }

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, 
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888, 
      );

      final controller = _cameraController!;
      await controller.initialize();
      if (!mounted || !widget.isActive || _cameraController != controller) {
        // Layar sudah ditinggalkan saat inisialisasi: lepaskan kamera, jangan dibiarkan menggantung.
        if (_cameraController == controller) _cameraController = null;
        await controller.dispose();
        return;
      }
      setState(() {});

      controller.startImageStream((CameraImage image) {
        if (!mounted || _isDetecting || _isScanning || !widget.isActive) return;
        _isDetecting = true;
        _processCameraFrame(image);
      });
    } catch (e) {
      debugPrint("Kamera error: $e");
    } finally {
      _isInitializing = false;
    }
  }

  // Ambil embedding wajah terdaftar milik user dari Supabase (kolom JSONB face_embeddings).
  Future<void> _loadEnrolled() async {
    try {
      final supabase = Supabase.instance.client;
      final uid = supabase.auth.currentUser?.id;
      final row = uid == null
          ? null
          : await supabase.from('profiles').select('face_embeddings').eq('id', uid).maybeSingle();
      final list = FaceService.parseEnrolled(row?['face_embeddings']);
      debugPrint("Embedding terdaftar: ${list.length}");
      if (mounted) {
        setState(() {
          _enrolled = list;
          _enrolledLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil embedding: $e");
      if (mounted) setState(() => _enrolledLoaded = true);
    }
  }

  void _resetVerification() {
    _samples.clear();
    _liveness.reset();
    if (!mounted) return;
    setState(() {
      _isScoreLocked = false;
      _isMatch = false;
      _faceDetectedFrames = 0;
      _aiMatchScore = 0.0;
    });
  }

  void _finishVerification() {
    if (_samples.isEmpty) return;
    final dim = _samples.first.length;
    final mean = List<double>.filled(dim, 0.0);
    for (final s in _samples) {
      for (int i = 0; i < dim; i++) {
        mean[i] += s[i];
      }
    }
    final sim = FaceService.bestSimilarity(l2Normalize(mean), _enrolled);
    final match = sim >= FaceService.threshold;
    debugPrint("VERIFIKASI: similarity=${sim.toStringAsFixed(4)} threshold=${FaceService.threshold} match=$match");
    _samples.clear();

    if (!mounted) return;
    setState(() {
      _finalLockedScore = (sim * 100).clamp(0, 100).toDouble();
      _aiMatchScore = _finalLockedScore;
      _isMatch = match;
      _isScoreLocked = true;
    });

    // Kalau tidak cocok, otomatis coba scan lagi setelah 2 detik.
    if (!match) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isScoreLocked && !_isMatch) _resetVerification();
      });
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    // Belum siap / tidak ada wajah terdaftar / hasil sudah final -> lewati frame.
    if (!widget.isActive || !FaceService.instance.isLoaded || _enrolled.length < FaceService.minFaces || _isScoreLocked) {
      _isDetecting = false;
      return;
    }

    final int sensor = _cameraController?.description.sensorOrientation ?? 0;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _samples.clear();
        _liveness.onFaceLost();
        if (mounted) {
          setState(() {
            _aiMatchScore = 0.0;
            _isFaceDetected = false;
            _faceDetectedFrames = 0;
          });
        }
        _isDetecting = false;
        return;
      }

      // Pakai wajah terbesar di frame.
      final face = faces.reduce((a, b) =>
          a.boundingBox.width * a.boundingBox.height >= b.boundingBox.width * b.boundingBox.height ? a : b);

      if (mounted) {
        setState(() {
          _isFaceDetected = true;
          _faceDetectedFrames++;
        });
      }

      // TAHAP 1 - Liveness: user harus kedip & tengok sesuai instruksi acak.
      // Embedding baru diambil SETELAH lolos, jadi foto statis tidak pernah sampai ke model.
      if (!_liveness.isPassed) {
        _samples.clear();
        _liveness.update(face);
        if (mounted) setState(() => _aiMatchScore = 0.0);
        _isDetecting = false;
        return;
      }

      // TAHAP 2 - Tunggu wajah stabil beberapa frame, lalu ambil embedding sungguhan dari model.
      if (_faceDetectedFrames >= _warmupFrames) {
        final emb = FaceService.instance.embedFromCameraImage(image, face, sensor);
        if (emb != null) {
          _samples.add(emb);
          final live = FaceService.bestSimilarity(emb, _enrolled);
          debugPrint("sample sim=${live.toStringAsFixed(4)}");
          if (mounted) setState(() => _aiMatchScore = (live * 100).clamp(0, 100).toDouble());
          if (_samples.length >= _samplesNeeded) _finishVerification();
        }
      }
    } catch (e) {
      debugPrint("Gagal proses AI: $e");
    }

    _isDetecting = false;
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    if (_cameraController == null) return null;
    
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

    final bytes = image.planes[0].bytes;

    return InputImage.fromBytes(
      bytes: bytes, 
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
  _isDetecting = true; // hentikan pemrosesan frame baru
  final controller = _cameraController;
  _cameraController = null;
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      if (controller != null) {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        await controller.dispose();
      }
    } catch (_) {}
    // Detector & interpreter ditutup SETELAH stream berhenti, agar tidak dipakai saat frame diproses.
    try { await _faceDetector.close(); } catch (_) {}
  });
  _scanController.dispose();
  super.dispose();
}

  // LOGIKA AMAN TOMBOL JEP RET MANUAL
  // LOGIKA AMAN TOMBOL JEP RET MANUAL (ANTI FREEZE)
  void _onCapture() async {
  if (_enrolledLoaded && _enrolled.length < FaceService.minFaces) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wajah terdaftar ${_enrolled.length}/${FaceService.minFaces}. Tambah foto wajah dulu di menu Profil."), backgroundColor: Colors.red),
    );
    return;
  }

  if (!_isFaceDetected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Wajah belum terdeteksi!"), backgroundColor: Colors.red),
    );
    return;
  }

  if (!_isScoreLocked) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mohon stabilkan wajah sebentar..."), backgroundColor: Colors.orange),
    );
    return;
  }

  if (!_isMatch) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Wajah tidak cocok dengan data terdaftar."), backgroundColor: Colors.red),
    );
    return;
  }

  setState(() => _isScanning = true);

  // Matikan kamera sepenuhnya (stream + dispose) sebelum pindah layar.
  await _stopCamera();

  await Future.delayed(const Duration(milliseconds: 500));

  if (!mounted) return;
  setState(() => _isScanning = false);

  // Baru navigate
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => GPSScreen(aiScore: _aiMatchScore)),
  );

  // GPSScreen yang sukses diganti SuccessScreen lewat pushReplacement, sehingga await di atas
  // selesai seketika. Nyalakan kamera lagi HANYA kalau layar ini kembali jadi layar teratas
  // (misalnya user menekan tombol back dari GPS).
  if (mounted && widget.isActive && (ModalRoute.of(context)?.isCurrent ?? false)) {
    _initCameraAndML();
  }
}

  // LOGIKA TEXT DUA KONDISI SESUAI PERMINTAAN KAMU
  Widget _buildDynamicInstructionText() {
    if (_enrolledLoaded && _enrolled.length < FaceService.minFaces) {
      return Text(
        "Wajah terdaftar ${_enrolled.length}/${FaceService.minFaces}. Tambah foto di menu Profil.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
    if (!_isFaceDetected) {
      return Text(
        "Tempatkan wajah di dalam frame kamera.",
        style: TextStyle(fontSize: 14, color: onSurfaceVariant, fontWeight: FontWeight.normal),
      );
    } else if (!_liveness.isPassed) {
      return Text(
        _liveness.timedOut ? "Waktu habis, ikuti instruksi baru:" : "Liveness ${_liveness.completedSteps + 1}/${_liveness.totalSteps}: ${_liveness.instruction}",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold),
      );
    } else if (!_isScoreLocked) {
      return const Text(
        "Mohon tunggu, AI sedang memverifikasi wajah...",
        style: TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold),
      );
    } else if (_isMatch) {
      return const Text(
        "Wajah terverifikasi! Silakan tekan tombol sidik jari.",
        style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
      );
    } else {
      return const Text(
        "Wajah tidak cocok. Mencoba lagi...",
        style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : NetworkImage("https://ui-avatars.com/api/?name=$_displayName&background=random"),
            ),
            const SizedBox(width: 12),
            Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: onSurfaceVariant),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Text("Biometric Check-In", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface)),
            const SizedBox(height: 8),
            
            // PANGGIL TEKS LOGIKA BARU DI SINI
            _buildDynamicInstructionText(),
            
            const SizedBox(height: 32),

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
                            (_cameraController != null && _cameraController!.value.isInitialized)
                                ? CameraPreview(_cameraController!)
                                : const Center(child: CircularProgressIndicator()),
                            
                            Positioned(
                              top: 16, bottom: 16, left: 16, right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: _stateColor.withOpacity(_isFaceDetected ? 0.8 : 0.4), width: 2), 
                                  borderRadius: BorderRadius.circular(24)
                                ),
                              ),
                            ),

                            Positioned(
                              top: 24, left: 24, right: 24,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildGlassPill(child: Row(
                                    children: [
                                      Container(width: 8, height: 8, decoration: BoxDecoration(color: _stateColor, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(_isScanning ? "Verifying..." : (_isScoreLocked ? (_isMatch ? "Face Verified!" : "Not Matched") : (_isFaceDetected ? (_liveness.isPassed ? "Analyzing..." : "Liveness check...") : "Scanning..."))),
                                    ],
                                  )),
                                  _buildGlassPill(child: Text("Similarity: ${_aiMatchScore.toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _stateColor))),
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

            GestureDetector(
              onTap: _isScanning ? null : _onCapture,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: _isMatch ? Colors.green : primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: surface, width: 4),
                  boxShadow: [BoxShadow(color: (_isMatch ? Colors.green : primary).withOpacity(0.4), blurRadius: 15)],
                ),
                child: _isScanning 
                    ? const Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.fingerprint, color: Colors.white, size: 36),
              ),
            ),
          ],
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