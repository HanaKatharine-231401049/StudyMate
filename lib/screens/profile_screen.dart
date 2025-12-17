import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import '../widgets/settings_card_tile.dart';
import 'username_settings_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _photoBase64;

  bool _loadingImage = false;
  bool _initializedFromDb = false;

  // -------- FIRESTORE STREAM --------
  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in.');
    }
    return _db.collection('users').doc(user.uid).snapshots();
  }

  // -------- IMAGE PICK --------
  Future<void> _pickFromGallery() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      _saveImage(File(picked.path));
    }
  }

  Future<void> _pickFromCamera() async {
    final picked =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      _saveImage(File(picked.path));
    }
  }

  Future<void> _saveImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loadingImage = true);

    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);

    await _db.collection('users').doc(user.uid).update({
      'photoBase64': base64,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _photoBase64 = base64;
      _imageFile = file;
      _loadingImage = false;
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------- LOGOUT --------
  Future<void> _confirmLogout() async {
    final scheme = Theme.of(context).colorScheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log out', style: TextStyle(color: scheme.error)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await context.read<AuthService>().signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    }
  }

  // -------- BUILD --------
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data();
          if (data == null) {
            return const Center(child: Text('User data not found'));
          }

          if (!_initializedFromDb) {
            _photoBase64 = data['photoBase64'];
            _initializedFromDb = true;
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // ===== TITLE =====
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scheme.onBackground,
                        ),
                        children: [
                          TextSpan(
                            text: "Profile ",
                            style: TextStyle(color: scheme.primary),
                          ),
                          const TextSpan(text: "account"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===== AVATAR =====
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _showImageOptions,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: scheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(28),
                              image: _photoBase64 != null
                                  ? DecorationImage(
                                      image: MemoryImage(
                                        base64Decode(_photoBase64!),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _photoBase64 == null
                                ? Icon(Icons.person,
                                    size: 56,
                                    color: scheme.onSurface.withOpacity(0.7))
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: scheme.primary,
                            child: _loadingImage
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.edit,
                                    size: 16, color: scheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== SETTINGS =====
                  SettingsCardTile(
                    icon: Icons.person_outline,
                    title: "Username settings",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UsernameSettingsScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SettingsCardTile(
                    icon: Icons.lock_outline,
                    title: "Change password",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== MODE =====
                  Text(
                    "Mode",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildModeSelector(themeProvider),

                  
                  const Spacer(), // Push log out to bottom

                  // ===== LOGOUT =====
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      icon: Icon(Icons.logout, color: scheme.error),
                      label: Text(
                        "Log out",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: scheme.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: scheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== MODE SELECTOR =====
  Widget _buildModeSelector(ThemeProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = provider.isDark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          _modeItem(
            icon: Icons.light_mode,
            text: "Light",
            selected: !isDark,
            onTap: () => provider.setMode(ThemeMode.light),
          ),
          _modeItem(
            icon: Icons.dark_mode,
            text: "Dark",
            selected: isDark,
            onTap: () => provider.setMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }

  Widget _modeItem({
    required IconData icon,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color:
                      selected ? scheme.onPrimary : scheme.onSurface),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color:
                      selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}