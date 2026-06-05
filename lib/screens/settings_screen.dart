import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Tema Warna Material 3 Light Mode
  final Color surface = const Color(0xFFF8F9FA);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFF3F4F5);
  final Color surfaceContainerHighest = const Color(0xFFE1E3E4);
  final Color onSurface = const Color(0xFF191C1D);
  final Color onSurfaceVariant = const Color(0xFF414754);
  final Color primary = const Color(0xFF005BBF);
  final Color primaryContainer = const Color(0xFF1A73E8);
  final Color secondaryContainer = const Color(0xFFD2E6EF);
  final Color onSecondaryContainer = const Color(0xFF55676F);
  final Color outlineVariant = const Color(0xFFC1C6D6);
  final Color outline = const Color(0xFF727785);

  // State Variabel agar layar menjadi interaktif
  bool _isDarkMode = false;
  String _selectedLanguage = "English (US)";
  String _selectedSensitivity = "High";
  String _selectedGpsRate = "5 mins";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: outlineVariant.withOpacity(0.3), width: 1)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("FaceAttend", style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Judul Utama ---
            Text("Settings", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: onSurface, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text("Manage your app preferences and biometric settings.", style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
            const SizedBox(height: 32),

            // --- 1. APPEARANCE GROUP ---
            _buildSectionTitle("Appearance"),
            _buildSettingsCard(
              children: [
                _buildSettingRow(
                  icon: Icons.dark_mode_outlined, iconBg: secondaryContainer, iconColor: onSecondaryContainer,
                  title: "Dark Mode", subtitle: "System default",
                  trailing: Switch(
                    value: _isDarkMode,
                    activeColor: primary,
                    onChanged: (val) {
                      setState(() => _isDarkMode = val);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? "Dark Mode Enabled (Mock)" : "Light Mode Enabled (Mock)"), duration: const Duration(seconds: 1)));
                    },
                  ),
                ),
                _buildDivider(),
                _buildSettingRow(
                  icon: Icons.language, iconBg: secondaryContainer, iconColor: onSecondaryContainer,
                  title: "Language", trailingText: _selectedLanguage,
                  onTap: () => _showSelectionBottomSheet(
                    title: "Select Language",
                    options: ["English (US)", "Bahasa Indonesia", "Melayu"],
                    currentValue: _selectedLanguage,
                    onSelected: (val) => setState(() => _selectedLanguage = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 2. BIOMETRICS GROUP ---
            _buildSectionTitle("Biometrics"),
            _buildSettingsCard(
              children: [
                _buildSettingRow(
                  icon: Icons.face, iconBg: primaryContainer.withOpacity(0.1), iconColor: primaryContainer,
                  title: "Recognition Sensitivity", subtitle: "Adjust AI confidence threshold",
                  trailingText: _selectedSensitivity, trailingTextColor: primary,
                  onTap: () => _showSelectionBottomSheet(
                    title: "AI Sensitivity",
                    options: ["Low (Faster)", "Medium", "High", "Strict (Most Secure)"],
                    currentValue: _selectedSensitivity,
                    onSelected: (val) => setState(() => _selectedSensitivity = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 3. SYSTEM GROUP ---
            _buildSectionTitle("System"),
            _buildSettingsCard(
              children: [
                _buildSettingRow(
                  icon: Icons.location_on_outlined, iconBg: secondaryContainer, iconColor: onSecondaryContainer,
                  title: "GPS Refresh Rate", subtitle: "Location tracking frequency",
                  trailingText: _selectedGpsRate,
                  onTap: () => _showSelectionBottomSheet(
                    title: "Refresh Rate",
                    options: ["Real-time", "1 min", "5 mins", "15 mins"],
                    currentValue: _selectedGpsRate,
                    onSelected: (val) => setState(() => _selectedGpsRate = val),
                  ),
                ),
                _buildDivider(),
                _buildSettingRow(
                  icon: Icons.notifications_outlined, iconBg: secondaryContainer, iconColor: onSecondaryContainer,
                  title: "Notification Preferences", subtitle: "Alerts and check-in reminders",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Notification Settings...")));
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 4. INFORMATION GROUP ---
            _buildSectionTitle("Information"),
            _buildSettingsCard(
              children: [
                _buildSettingRow(
                  icon: Icons.policy_outlined, iconBg: surfaceContainerHighest, iconColor: onSurfaceVariant,
                  title: "Privacy Policy",
                  onTap: () => _showInfoDialog("Privacy Policy", "This is a placeholder for the FaceAttend privacy policy. Your biometric data is encrypted and stored securely."),
                ),
                _buildDivider(),
                _buildSettingRow(
                  icon: Icons.info_outline, iconBg: surfaceContainerHighest, iconColor: onSurfaceVariant,
                  title: "About App", subtitle: "Version 2.4.1 (Build 8902)",
                  onTap: () => _showInfoDialog("About App", "FaceAttend Smart Attendance System\nVersion: 2.4.1\n\nDeveloped for Skripsi Project."),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary)),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineVariant.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingRow({
    required IconData icon, required Color iconBg, required Color iconColor,
    required String title, String? subtitle,
    Widget? trailing, String? trailingText, Color? trailingTextColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: onSurfaceVariant)),
                    ]
                  ],
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: 8),
                Text(trailingText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: trailingTextColor ?? onSurfaceVariant)),
                const SizedBox(width: 8),
              ],
              if (trailing != null) trailing
              else if (onTap != null) Icon(Icons.chevron_right, color: outlineVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: outlineVariant.withOpacity(0.2), indent: 80);
  }

  // --- HELPER FUNCTIONS (MODALS & DIALOGS) ---

  // Bottom Sheet untuk memilih opsi (Language, Sensitivity, dll)
  void _showSelectionBottomSheet({
    required String title, required List<String> options, 
    required String currentValue, required Function(String) onSelected
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onSurface)),
                const SizedBox(height: 16),
                ...options.map((option) {
                  bool isSelected = option == currentValue;
                  return ListTile(
                    title: Text(option, style: TextStyle(color: isSelected ? primary : onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    trailing: isSelected ? Icon(Icons.check_circle, color: primary) : null,
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }
    );
  }

  // Dialog sederhana untuk Privacy Policy & About
  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: TextStyle(color: onSurface, fontWeight: FontWeight.bold)),
        content: Text(content, style: TextStyle(color: onSurfaceVariant, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}