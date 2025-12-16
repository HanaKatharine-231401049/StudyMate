import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';        // <<< add this
import 'sign_in_screen.dart';                 // <<< and this

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Controllers (NO hardcoded dummy text anymore)
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController(); // only UI, not saved
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> _countryCodes = ['+62', '+1', '+44', '+91'];
  String _selectedCountryCode = '+62';

  // Image
  File? _imageFile;          // local picked file (for immediate preview)
  String? _photoBase64;      // stored avatar from Firestore
  final ImagePicker _picker = ImagePicker();

  bool _loadingImage = false;
  bool _saving = false;
  bool _initializedFromDb = false; // make sure we only fill controllers once

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --------- Firebase user stream ---------
  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to access ProfileScreen.');
    }
    return _db.collection('users').doc(user.uid).snapshots();
  }

  // --------- Image picking & saving (base64) ---------
  Future<void> _pickFromGallery() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      await _handlePickedImage(File(picked.path));
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      await _handlePickedImage(File(picked.path));
    }
  }

  Future<void> _handlePickedImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loadingImage = true);

    try {
      final bytes = await file.readAsBytes();
      final String base64 = base64Encode(bytes);

      await _db.collection('users').doc(user.uid).update({
        'photoBase64': base64,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _imageFile = file;
        _photoBase64 = base64;
        _loadingImage = false;
      });
    } catch (e) {
      setState(() => _loadingImage = false);
      _showErrorDialog('Failed to update profile picture.\n$e');
    }
  }

  Future<void> _deleteImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('users').doc(user.uid).update({
        'photoBase64': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _showErrorDialog('Failed to delete profile picture.\n$e');
    }

    setState(() {
      _imageFile = null;
      _photoBase64 = null;
    });

    Navigator.of(context).maybePop();
  }

  // --------- Save profile info ---------
  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phoneLocal = _phoneController.text.trim();
    final phoneNumber =
        phoneLocal.isEmpty ? '' : '$_selectedCountryCode $phoneLocal';

    if (username.isEmpty || fullName.isEmpty) {
      _showErrorDialog('Full name and username cannot be empty.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _db.collection('users').doc(user.uid).update({
        'username': username,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Optional: sync FirebaseAuth displayName with full name
      await user.updateDisplayName(fullName);

      if (!mounted) return;
      _showSnackBar('Profile updated');
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Failed to save profile.\n$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // --------- LOGOUT ---------
  Future<void> _confirmLogout() async {
    final scheme = Theme.of(context).colorScheme;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log out',
              style: TextStyle(color: scheme.error),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final authService = context.read<AuthService>();
      await authService.signOut();

      if (!mounted) return;

      // Clear navigation stack and go to SignInScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  // --------- UI helpers ---------
  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }

  InputDecoration _decoration(BuildContext context, String hint) {
    final scheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: scheme.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: GoogleFonts.inter(color: scheme.onSurface.withOpacity(0.6)),
      border: _inputBorder(scheme.outline),
      enabledBorder: _inputBorder(scheme.outline),
      focusedBorder: _inputBorder(scheme.primary),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Foto Profil",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    if (_imageFile != null || _photoBase64 != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteImage();
                        },
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text("Kamera", style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined),
                title: Text("Galeri", style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openImagePreview() {
    if (_imageFile == null &&
        (_photoBase64 == null || _photoBase64!.isEmpty)) {
      return;
    }

    Widget imageWidget;
    if (_imageFile != null) {
      imageWidget = Image.file(_imageFile!, fit: BoxFit.contain);
    } else {
      try {
        final bytes = base64Decode(_photoBase64!);
        imageWidget = Image.memory(bytes, fit: BoxFit.contain);
      } catch (_) {
        return;
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        final scheme = Theme.of(context).colorScheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black,
                  child: InteractiveViewer(child: imageWidget),
                ),
              ),
              Positioned(
                top: 32,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(Icons.close, color: scheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(Icons.edit, color: scheme.onSurface),
                            onPressed: () {
                              Navigator.pop(context);
                              _showImageOptions();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: scheme.error,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: scheme.onError),
                            onPressed: _deleteImage,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: scheme.onBackground,
      ),
    );
  }

  Widget _buildModeSelector(ThemeProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = provider.isDark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => provider.setMode(ThemeMode.light),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isDark ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.light_mode,
                        color: !isDark
                            ? scheme.onPrimary
                            : scheme.onSurface,
                        size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Light",
                      style: GoogleFonts.inter(
                        color: !isDark
                            ? scheme.onPrimary
                            : scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => provider.setMode(ThemeMode.dark),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dark_mode,
                        color: isDark
                            ? scheme.onPrimary
                            : scheme.onSurface,
                        size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Dark",
                      style: GoogleFonts.inter(
                        color: isDark
                            ? scheme.onPrimary
                            : scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // --------- Build ---------
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final scheme = Theme.of(context).colorScheme;
    final topSpacing = MediaQuery.of(context).padding.top + 28;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: EdgeInsets.only(top: topSpacing - 18),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              "My Profile",
              style: GoogleFonts.montserratAlternates(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.onBackground,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data();
          if (data == null) {
            return const Center(child: Text('User data not found.'));
          }

          // Initialize controllers once from Firestore
          if (!_initializedFromDb) {
            _fullNameController.text = data['fullName']?.toString() ?? '';
            _usernameController.text = data['username']?.toString() ?? '';
            _emailController.text = data['email']?.toString() ?? '';

            final phone = data['phoneNumber']?.toString() ?? '';
            String localPhone = phone;

            for (final code in _countryCodes) {
              if (phone.startsWith(code)) {
                _selectedCountryCode = code;
                localPhone = phone.substring(code.length).trim();
                break;
              }
            }
            _phoneController.text = localPhone;

            _photoBase64 = data['photoBase64']?.toString();
            _initializedFromDb = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Avatar
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: (_imageFile != null ||
                                (_photoBase64 != null &&
                                    _photoBase64!.isNotEmpty))
                            ? _openImagePreview
                            : _showImageOptions,
                        child: Container(
                          width: 121,
                          height: 118,
                          decoration: BoxDecoration(
                            color: scheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(28),
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : (_photoBase64 != null &&
                                        _photoBase64!.isNotEmpty)
                                    ? DecorationImage(
                                        image: MemoryImage(
                                          base64Decode(_photoBase64!),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: (_imageFile == null &&
                                  (_photoBase64 == null ||
                                      _photoBase64!.isEmpty))
                              ? Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 56,
                                    color: scheme.onSurface.withOpacity(.8),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: -2,
                        child: InkWell(
                          onTap: _showImageOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _loadingImage
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.edit,
                                    size: 18, color: scheme.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Full Name
                _buildLabel(context, "Full Name"),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    controller: _fullNameController,
                    decoration: _decoration(context, "Full name"),
                    style: GoogleFonts.inter(color: scheme.onSurface),
                  ),
                ),

                const SizedBox(height: 14),

                // Username
                _buildLabel(context, "Username"),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: _decoration(context, "Username"),
                    style: GoogleFonts.inter(color: scheme.onSurface),
                  ),
                ),

                const SizedBox(height: 14),

                // Password (UI only, not wired to backend here)
                _buildLabel(context, "Password"),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _decoration(context, "••••••••"),
                    style: GoogleFonts.inter(color: scheme.onSurface),
                  ),
                ),

                const SizedBox(height: 14),

                // Email (read-only)
                _buildLabel(context, "Email"),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: _decoration(context, "Email"),
                    style: GoogleFonts.inter(color: scheme.onSurface),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),

                const SizedBox(height: 14),

                // Phone Number + Country code
                _buildLabel(context, "Phone Number"),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        border: Border.all(color: scheme.outline),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          dropdownColor: scheme.surface,
                          items: _countryCodes
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: GoogleFonts.inter(
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCountryCode = v!),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextFormField(
                          controller: _phoneController,
                          decoration:
                              _decoration(context, "819 3535 1327"),
                          style: GoogleFonts.inter(color: scheme.onSurface),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Mode selector
                _buildLabel(context, "Mode"),
                const SizedBox(height: 6),
                _buildModeSelector(themeProvider),

                const SizedBox(height: 26),

                // Save button
                SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _saving ? null : _saveProfile,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Save",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // --------- LOGOUT BUTTON ---------
                SizedBox(
                  height: 44,
                  width: double.infinity,
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

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
