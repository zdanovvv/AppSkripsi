import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'face_utils.dart';

/// Hasil registrasi satu foto wajah.
class FaceCapture {
  final List<double> embedding;
  final String thumbBase64; // JPEG kecil (96x96) buat ditampilkan di Profil
  final double sharpness; // variansi Laplacian; makin kecil = makin buram
  const FaceCapture({
    required this.embedding,
    required this.thumbBase64,
    required this.sharpness,
  });
}

/// Pipeline verifikasi wajah:
///   frame/foto -> deteksi wajah (ML Kit) -> crop -> 224x224 -> MobileNet (TFLite)
///   -> embedding 1024-d -> L2 normalize -> cosine similarity vs embedding terdaftar.
///
/// Preprocessing HARUS sama dengan training di Colab:
///   RGB, 224x224, piksel = x / 127.5 - 1  (mobilenet.preprocess_input).
class FaceService {
  FaceService._();
  static final FaceService instance = FaceService._();

  /// Model hasil notebook Export_Embedding_Evaluasi.ipynb (output 1024-d, BUKAN 62 kelas).
  static const String modelAsset = 'assets/model_face_embedding.tflite';

  /// Versi model embedding. Embedding dari versi lain TIDAK dipakai (otomatis dianggap data lama).
  /// Naikkan angkanya setiap kali lu export ulang .tflite.
  static const String modelVersion = 'mobilenetv1-embedding-v2';

  /// Ambang cosine similarity. WAJIB diisi dengan angka yang dicetak notebook evaluasi.
  /// Placeholder ini sengaja ketat supaya gagal-aman (menolak), bukan menerima semua orang.
  static const double threshold = 0.82;

  static const int inputSize = 224;

  /// Jumlah foto terdaftar: minimal agar boleh absen, saran, dan batas atas.
  static const int minFaces = 3;
  static const int recommendedFaces = 5;
  static const int maxFaces = 8;

  /// Di bawah angka ini foto diberi label "Buram" (cuma peringatan, tidak menolak).
  /// Nilai kasar; lihat log "sharpness=" lalu sesuaikan dengan kamera HP lu.
  static const double blurThreshold = 60.0;

  /// Dataset LFW-deepfunneled = kotak wajah diperbesar ~2.2x lalu di-crop persegi.
  /// Crop di app dibuat meniru itu supaya distribusinya mirip data training.
  static const double cropScale = 2.2;

  /// Wajah lebih kecil dari ini (piksel, pada frame tegak) dianggap terlalu jauh.
  static const double minFaceSize = 80;

  /// Kalau skor diri sendiri rendah terus (foto registrasi vs kamera live beda
  /// mirror), ubah ke true lalu coba lagi.
  static const bool flipLiveFrames = false;

  Interpreter? _interpreter;
  int _embDim = 0;
  Future<void>? _loading;

  bool get isLoaded => _interpreter != null;

  /// Aman dipanggil berkali-kali; model cuma dimuat sekali dan dipakai selama app hidup.
  Future<void> load() {
    return _loading ??= () async {
      try {
        final interp = await Interpreter.fromAsset(modelAsset);
        _embDim = interp.getOutputTensor(0).shape.last;
        _interpreter = interp;
        debugPrint('FaceService: model dimuat, dimensi embedding = $_embDim');
      } catch (e) {
        _loading = null;
        rethrow;
      }
    }();
  }

  // ---------------------------------------------------------------------------
  // Embedding dari frame kamera (dipakai saat absen)
  // ---------------------------------------------------------------------------

  /// [sensorOrientation] = `cameraController.description.sensorOrientation`.
  /// Mengembalikan embedding ter-normalisasi, atau null kalau gagal / wajah terlalu kecil.
  List<double>? embedFromCameraImage(
      CameraImage frame, Face face, int sensorOrientation) {
    if (_interpreter == null) return null;

    var image = _cameraImageToImage(frame);
    if (image == null) return null;

    // Putar jadi tegak; koordinat bounding box ML Kit ada di frame tegak ini.
    if (sensorOrientation != 0) {
      image = img.copyRotate(image, angle: sensorOrientation);
    }
    final face224 = _cropFace(image, face.boundingBox, flip: flipLiveFrames);
    if (face224 == null) return null;
    return _embed(face224);
  }

  // ---------------------------------------------------------------------------
  // Embedding dari file foto (dipakai saat registrasi di Profile)
  // ---------------------------------------------------------------------------

  Future<FaceCapture?> embedFromFile(String path) async {
    await load();

    final decoded = img.decodeImage(await File(path).readAsBytes());
    if (decoded == null) return null;
    final image = img.bakeOrientation(decoded);

    final detector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );
    try {
      final faces = await detector.processImage(InputImage.fromFilePath(path));
      if (faces.isEmpty) return null;
      final face = faces.reduce((a, b) =>
          a.boundingBox.width * a.boundingBox.height >=
                  b.boundingBox.width * b.boundingBox.height
              ? a
              : b);
      final face224 = _cropFace(image, face.boundingBox);
      if (face224 == null) return null;
      final emb = _embed(face224);
      if (emb == null) return null;

      final sharp = _sharpness(face224);
      debugPrint('FaceService: registrasi sharpness=${sharp.toStringAsFixed(1)}');
      final thumb = img.copyResize(face224, width: 96, height: 96);
      return FaceCapture(
        embedding: emb,
        thumbBase64: base64Encode(img.encodeJpg(thumb, quality: 75)),
        sharpness: sharp,
      );
    } finally {
      await detector.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Inti: crop -> resize -> TFLite
  // ---------------------------------------------------------------------------

  /// Crop persegi di sekitar wajah, resize ke 224x224. Null kalau wajah terlalu kecil.
  img.Image? _cropFace(img.Image src, Rect box, {bool flip = false}) {
    if (math.max(box.width, box.height) < minFaceSize) return null;

    // Kotak persegi berpusat di wajah, ukuran = cropScale x sisi wajah, dijepit ke dalam gambar.
    double side = math.max(box.width, box.height) * cropScale;
    side = math.min(side, math.min(src.width, src.height).toDouble());
    final double x = (box.center.dx - side / 2).clamp(0.0, src.width - side).toDouble();
    final double y = (box.center.dy - side / 2).clamp(0.0, src.height - side).toDouble();

    var crop = img.copyCrop(
      src,
      x: x.round(),
      y: y.round(),
      width: side.round(),
      height: side.round(),
    );
    crop = img.copyResize(
      crop,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );
    if (flip) crop = img.flipHorizontal(crop);
    return crop;
  }

  /// Jalankan TFLite pada crop 224x224 -> embedding ter-normalisasi L2.
  List<double>? _embed(img.Image face224) {
    final interp = _interpreter;
    if (interp == null) return null;

    final input = [
      List.generate(inputSize, (py) {
        return List.generate(inputSize, (px) {
          final p = face224.getPixel(px, py);
          return <double>[
            p.r / 127.5 - 1.0,
            p.g / 127.5 - 1.0,
            p.b / 127.5 - 1.0,
          ];
        });
      }),
    ];
    final output = [List<double>.filled(_embDim, 0.0)];

    interp.run(input, output);
    return l2Normalize(output[0]);
  }

  /// Ketajaman = variansi Laplacian 3x3 pada gambar abu-abu. Makin kecil = makin buram.
  static double _sharpness(img.Image im) {
    final w = im.width, h = im.height;
    final g = List<double>.filled(w * h, 0.0);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = im.getPixel(x, y);
        g[y * w + x] = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      }
    }
    double sum = 0, sumSq = 0;
    int n = 0;
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final l = g[(y - 1) * w + x] + g[(y + 1) * w + x] + g[y * w + x - 1] + g[y * w + x + 1] - 4 * g[y * w + x];
        sum += l;
        sumSq += l * l;
        n++;
      }
    }
    if (n == 0) return 0.0;
    final mean = sum / n;
    return sumSq / n - mean * mean;
  }

  // ---------------------------------------------------------------------------
  // CameraImage -> img.Image (RGB). Ini pengganti image_converter.dart yang kosong.
  // ---------------------------------------------------------------------------

  img.Image? _cameraImageToImage(CameraImage c) {
    switch (c.format.group) {
      case ImageFormatGroup.nv21:
        return _fromNv21(c);
      case ImageFormatGroup.bgra8888:
        return _fromBgra(c);
      default:
        return null;
    }
  }

  static int _clamp255(double v) => v < 0 ? 0 : (v > 255 ? 255 : v.round());

  img.Image? _fromNv21(CameraImage c) {
    if (c.planes.isEmpty) return null;
    final w = c.width, h = c.height;
    final bytes = c.planes[0].bytes;
    final stride = c.planes[0].bytesPerRow;
    final uvStart = stride * h;
    if (bytes.length < uvStart + stride * (h ~/ 2)) return null;

    final out = img.Image(width: w, height: h);
    for (int y = 0; y < h; y++) {
      final uvRow = uvStart + (y >> 1) * stride;
      for (int x = 0; x < w; x++) {
        final yy = bytes[y * stride + x].toDouble();
        final uvIdx = uvRow + (x & ~1);
        final v = bytes[uvIdx] - 128; // NV21: V dulu, baru U
        final u = bytes[uvIdx + 1] - 128;
        out.setPixelRgb(
          x,
          y,
          _clamp255(yy + 1.402 * v),
          _clamp255(yy - 0.344136 * u - 0.714136 * v),
          _clamp255(yy + 1.772 * u),
        );
      }
    }
    return out;
  }

  img.Image? _fromBgra(CameraImage c) {
    if (c.planes.isEmpty) return null;
    final w = c.width, h = c.height;
    final bytes = c.planes[0].bytes;
    final stride = c.planes[0].bytesPerRow;

    final out = img.Image(width: w, height: h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final i = y * stride + x * 4;
        out.setPixelRgb(x, y, bytes[i + 2], bytes[i + 1], bytes[i]);
      }
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Pencocokan
  // ---------------------------------------------------------------------------

  /// Baca kolom JSONB `face_embeddings`. Entri lama yang `data`-nya String
  /// ("simulated_embedding_vector_data") otomatis diabaikan.
  static List<List<double>> parseEnrolled(dynamic raw) {
    final out = <List<double>>[];
    if (raw is! List) return out;
    for (final e in raw) {
      if (e is! Map || e['model'] != modelVersion) continue;
      final d = e['data'];
      if (d is List && d.isNotEmpty && d.first is num) {
        out.add(l2Normalize(d.map<double>((v) => (v as num).toDouble()).toList()));
      }
    }
    return out;
  }

  /// Cosine similarity tertinggi antara [query] dan semua embedding terdaftar.
  static double bestSimilarity(List<double> query, List<List<double>> enrolled) {
    double best = -1.0;
    for (final e in enrolled) {
      if (e.length != query.length) continue; // beda versi model -> lewati
      final s = cosineSimilarity(query, e);
      if (s > best) best = s;
    }
    return best < 0 ? 0.0 : best;
  }
}