import 'dart:math' as math;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Tantangan yang harus dilakukan user untuk membuktikan wajahnya "hidup".
enum LivenessChallenge { blink, turnLeft, turnRight }

/// Active liveness detection (challenge-response) memakai ML Kit Face Detection.
///
/// Cara kerja:
///   * Tiap sesi, user diminta 2 gerakan acak: KEDIP + TENGOK (kiri/kanan), urutannya diacak.
///   * Kedip dibaca dari leftEyeOpenProbability / rightEyeOpenProbability
///     (butuh FaceDetectorOptions(enableClassification: true)).
///   * Tengok dibaca dari headEulerAngleY, lalu user harus kembali menghadap depan
///     supaya embedding wajah berikutnya diambil dari wajah yang frontal.
///   * Foto diam (cetak / layar HP) tidak bisa kedip atau menoleh, jadi gagal.
///
/// BATASAN (tulis di skripsi): video rekaman / replay yang kebetulan melakukan
/// gerakan sama masih bisa lolos. Untuk itu butuh passive anti-spoofing berbasis
/// model (deteksi tekstur / pantulan layar) yang di luar cakupan ini.
class LivenessChecker {
  // --- Parameter (silakan di-tuning setelah dites di HP asli) -----------------

  /// Mata dianggap terbuka kalau probabilitas >= nilai ini.
  static const double eyeOpenThreshold = 0.6;

  /// Mata dianggap tertutup kalau probabilitas <= nilai ini.
  static const double eyeClosedThreshold = 0.3;

  /// Derajat minimal putaran kepala (sumbu Y) agar dihitung "menengok".
  static const double turnAngle = 20.0;

  /// Batas derajat untuk dianggap sudah kembali menghadap depan.
  static const double centerAngle = 10.0;

  /// Kalau instruksi "tengok kiri" ternyata mengharuskan user menoleh ke kanan
  /// (arah terbalik di HP lu), ubah jadi true.
  static const bool invertYaw = false;

  /// Waktu maksimal per sesi. Habis -> tantangan diacak ulang.
  static const Duration timeout = Duration(seconds: 12);

  /// Jumlah frame berturut-turut tanpa wajah sebelum sesi di-reset.
  static const int maxLostFrames = 10;

  // --- State -------------------------------------------------------------------

  final math.Random _rng = math.Random.secure();
  late List<LivenessChallenge> _queue;
  int _index = 0;
  int _phase = 0;
  int _lostFrames = 0;
  DateTime _startedAt = DateTime.now();
  bool _timedOut = false;

  LivenessChecker() {
    reset();
  }

  /// true kalau semua tantangan sudah selesai.
  bool get isPassed => _index >= _queue.length;

  /// true kalau sesi barusan habis waktu (UI boleh menampilkan pesan, lalu
  /// tantangan sudah otomatis diacak ulang).
  bool get timedOut => _timedOut;

  int get totalSteps => _queue.length;
  int get completedSteps => _index.clamp(0, _queue.length);

  LivenessChallenge? get current => isPassed ? null : _queue[_index];

  /// Teks instruksi untuk user.
  String get instruction {
    switch (current) {
      case LivenessChallenge.blink:
        return 'Kedipkan mata kamu';
      case LivenessChallenge.turnLeft:
        return 'Tengok ke kiri, lalu kembali menghadap depan';
      case LivenessChallenge.turnRight:
        return 'Tengok ke kanan, lalu kembali menghadap depan';
      case null:
        return 'Liveness lolos';
    }
  }

  /// Acak ulang tantangan dan mulai dari awal.
  void reset() {
    final turn = _rng.nextBool() ? LivenessChallenge.turnLeft : LivenessChallenge.turnRight;
    _queue = [LivenessChallenge.blink, turn]..shuffle(_rng);
    _index = 0;
    _phase = 0;
    _lostFrames = 0;
    _timedOut = false;
    _startedAt = DateTime.now();
  }

  /// Dipanggil setiap frame yang TIDAK ada wajahnya.
  void onFaceLost() {
    // Wajah hilang cukup lama (termasuk setelah lolos) -> wajib ulang dari awal,
    // supaya tidak bisa ganti orang / ganti ke foto setelah liveness lolos.
    _lostFrames++;
    if (_lostFrames >= maxLostFrames) reset();
  }

  /// Dipanggil setiap frame yang ada wajahnya (pakai wajah terbesar).
  /// Mengembalikan true kalau seluruh tantangan sudah lolos.
  bool update(Face face) {
    _lostFrames = 0;
    if (isPassed) return true;

    if (DateTime.now().difference(_startedAt) > timeout) {
      reset();
      _timedOut = true;
      return false;
    }
    _timedOut = false;

    switch (_queue[_index]) {
      case LivenessChallenge.blink:
        _updateBlink(face);
        break;
      case LivenessChallenge.turnLeft:
        _updateTurn(face, left: true);
        break;
      case LivenessChallenge.turnRight:
        _updateTurn(face, left: false);
        break;
    }
    return isPassed;
  }

  void _advance() {
    _index++;
    _phase = 0;
  }

  /// Kedip = terlihat terbuka -> tertutup -> terbuka lagi.
  void _updateBlink(Face face) {
    final l = face.leftEyeOpenProbability;
    final r = face.rightEyeOpenProbability;
    if (l == null || r == null) return; // classification tidak aktif / tidak terbaca

    final open = l >= eyeOpenThreshold && r >= eyeOpenThreshold;
    final closed = l <= eyeClosedThreshold && r <= eyeClosedThreshold;

    switch (_phase) {
      case 0:
        if (open) _phase = 1; // baseline: mata terbuka
        break;
      case 1:
        if (closed) _phase = 2; // mata menutup
        break;
      case 2:
        if (open) _advance(); // mata membuka lagi = 1 kedipan
        break;
    }
  }

  /// Tengok = sudut Y melewati [turnAngle] ke arah yang diminta, lalu kembali ke tengah.
  void _updateTurn(Face face, {required bool left}) {
    final y = face.headEulerAngleY;
    if (y == null) return;

    // Default: sudut Y positif = tengok kiri. Balik dengan invertYaw kalau terbalik.
    final double signed = (left ? y : -y) * (invertYaw ? -1 : 1);

    switch (_phase) {
      case 0:
        if (signed >= turnAngle) _phase = 1;
        break;
      case 1:
        if (y.abs() <= centerAngle) _advance();
        break;
    }
  }
}