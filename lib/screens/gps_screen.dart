import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import '../utils/face_utils.dart'; 
import 'success_screen.dart'; 

class GPSScreen extends StatefulWidget {
  final double aiScore;
  const GPSScreen({Key? key, required this.aiScore}) : super(key: key);

  @override
  State<GPSScreen> createState() => _GPSScreenState();
}

class _GPSScreenState extends State<GPSScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  GoogleMapController? _mapController;
  
  // KOORDINAT TARGET ABSEN (Rumah)
  final double targetLat = 1.104778;
  final double targetLng = 103.967333;
  final double maxRadius = 50.0; 

  bool _isLoadingLoc = true;
  bool _isSavingDB = false;
  double _currentDistance = 0.0;
  bool _isInRange = false;
  Position? _currentPosition;

  final Color surface = const Color(0xFFF8F9FA);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  final Color successGreen = const Color(0xFF10B981); 
  final Color errorRed = const Color(0xFFBA1A1A); 

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() => _isLoadingLoc = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLoc = false);
      _showEnableGPSDialog(); 
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Izin lokasi ditolak.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Izin lokasi diblokir permanen di pengaturan.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      if (position.isMocked) {
        _showError("Aplikasi Fake GPS terdeteksi. Presensi ditolak.");
        return;
      }

      double distance = haversineDistance(
        position.latitude, position.longitude, 
        targetLat, targetLng
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentDistance = distance;
          _isInRange = distance <= maxRadius;
          _isLoadingLoc = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 17),
        );
      }
    } catch (e) {
      _showError("Gagal mendapatkan lokasi: $e");
    }
  }

  void _showEnableGPSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("GPS Nonaktif"),
          content: const Text("Fitur presensi membutuhkan akses lokasi. Silakan nyalakan GPS kamu terlebih dahulu."),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); 
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
              child: const Text("Buka Pengaturan"),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // --- LOGIKA UTAMA SINKRONISASI DATABASE + TELAT ---
  Future<void> _submitAttendance() async {
    if (!_isInRange || _currentPosition == null) return;
    
    setState(() => _isSavingDB = true);

    try {
      final supabase = Supabase.instance.client;
      String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        final fallbackProfile = await supabase.from('profiles').select('id').limit(1).maybeSingle();
        if (fallbackProfile != null) {
          userId = fallbackProfile['id'] as String;
        }
      }

      if (userId == null) throw Exception("Sesi login tidak valid.");

      final now = DateTime.now();
      
      // 1. Format String Jam (Contoh hasil: 07:45 AM atau 02:15 PM)
      String period = now.hour >= 12 ? "PM" : "AM";
      int displayHour = now.hour > 12 ? now.hour - 12 : now.hour;
      if (displayHour == 0) displayHour = 12;
      String formattedTime = "${displayHour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period";

      // 2. Logika Hitung Keterlambatan (Batas jam masuk kantor: 08:00 AM)
      String calculatedStatus = "Tepat Waktu";
      if (now.hour > 8 || (now.hour == 8 && now.minute > 0)) {
        calculatedStatus = "Telat";
      }

      // 3. Nama Tempat Presensi Berdasarkan Radius Zona
      String locationPlaceName = "Rumah Zdanov";

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

      final existingRecord = await supabase
          .from('attendance')
          .select('id, check_in_time, check_out_time')
          .eq('user_id', userId)
          .gte('check_in_time', startOfDay)
          .lte('check_in_time', endOfDay)
          .maybeSingle();

      if (existingRecord == null) {
        // PROSES INSERT CHECK-IN
        await supabase.from('attendance').insert({
          'user_id': userId,
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'ai_match_score': widget.aiScore,
          'status': calculatedStatus, // MENYIMPAN STATUS ASLI KE DB SUPABASE
        });
      } else if (existingRecord['check_out_time'] == null) {
        // PROSES UPDATE CHECK-OUT
        await supabase.from('attendance').update({
          'check_out_time': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', existingRecord['id']);
        
        locationPlaceName = "$locationPlaceName (Pulang)";
      } else {
        _showError("Kamu sudah menyelesaikan presensi masuk dan pulang hari ini.");
        setState(() => _isSavingDB = false);
        return;
      }

      if (mounted) {
        // LEMPAR DATA TERVERIFIKASI KE SCREEN BERIKUTNYA
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              attendanceTime: formattedTime,
              attendanceLocation: locationPlaceName,
              attendanceStatus: calculatedStatus,
            ),
          ),
        );
      }
    } catch (e) {
      _showError("Gagal menyimpan ke database: $e");
      setState(() => _isSavingDB = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      setState(() => _isLoadingLoc = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: errorRed));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: surface.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: onSurfaceVariant), onPressed: () => Navigator.pop(context)),
        title: Text("Location Check", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.grey[200]),
),
          // Positioned.fill(
          //   child: GoogleMap(
          //     initialCameraPosition: CameraPosition(
          //       target: LatLng(targetLat, targetLng),
          //       zoom: 16,
          //     ),
          //     myLocationEnabled: true,
          //     myLocationButtonEnabled: false,
          //     zoomControlsEnabled: false,
          //     onMapCreated: (controller) => _mapController = controller,
          //     circles: {
          //       Circle(
          //         circleId: const CircleId("zone_radius"),
          //         center: LatLng(targetLat, targetLng),
          //         radius: maxRadius,
          //         fillColor: (_isInRange ? primary : errorRed).withOpacity(0.15),
          //         strokeColor: _isInRange ? primary : errorRed,
          //         strokeWidth: 2,
          //       ),
          //     },
          //     markers: {
          //       Marker(
          //         markerId: const MarkerId("office_target"),
          //         position: LatLng(targetLat, targetLng),
          //         infoWindow: const InfoWindow(title: "Batas Absen Rumah"),
          //       ),
          //     },
          //   ),
          // ),

          Positioned(
            top: 100, right: 20,
            child: FloatingActionButton(
              mini: true, backgroundColor: Colors.white, foregroundColor: onSurface,
              onPressed: _checkLocation, child: const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            bottom: 32, left: 20, right: 20,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildBentoCard(
                      title: "GPS Signal", 
                      value: _isLoadingLoc ? "Scanning..." : (_isInRange ? "High Accuracy" : "Out of Zone"), 
                      icon: Icons.satellite_alt, 
                      dotColor: _isLoadingLoc ? Colors.grey : (_isInRange ? successGreen : errorRed)
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBentoCard(
                      title: "Distance", 
                      value: _isLoadingLoc ? "--" : "${_currentDistance.toInt()}m", 
                      subtitle: "/ ${maxRadius.toInt()}m", 
                      icon: Icons.straighten
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), border: Border.all(color: outlineVariant.withOpacity(0.3))),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _isLoadingLoc ? Icons.hourglass_empty : (_isInRange ? Icons.check_circle : Icons.cancel), 
                                color: _isLoadingLoc ? outlineVariant : (_isInRange ? primary : errorRed), 
                                size: 28
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isLoadingLoc ? "Locating..." : (_isInRange ? "Location Verified" : "Too Far Away"), 
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isLoadingLoc ? "Please wait while we check your position." : 
                                      (_isInRange ? "You are within the allowed check-in zone." : "You must be closer to the center point to check-in."), 
                                      style: TextStyle(fontSize: 14, color: onSurfaceVariant)
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          SizedBox(
                            width: double.infinity, height: 56,
                            child: ElevatedButton.icon(
                              onPressed: (!_isInRange || _isLoadingLoc || _isSavingDB) ? null : _submitAttendance,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary, 
                                disabledBackgroundColor: outlineVariant.withOpacity(0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                              icon: _isSavingDB 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(_isInRange ? "Confirm Attendance" : "Locked", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              label: _isSavingDB ? const SizedBox.shrink() : const Icon(Icons.arrow_forward, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({required String title, required String value, required IconData icon, String? subtitle, Color? dotColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), border: Border.all(color: outlineVariant.withOpacity(0.3))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: outlineVariant, letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (dotColor != null) ...[Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)), const SizedBox(width: 8)],
                  Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                  if (subtitle != null) ...[const SizedBox(width: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: onSurfaceVariant))],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}