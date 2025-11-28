// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullNameController = TextEditingController(text: 'Markus Lee');
  final _usernameController = TextEditingController(text: 'onyourm_ark');
  final _passwordController = TextEditingController(text: 'password123');
  final _emailController = TextEditingController(text: 'markuslee@gmail.com');
  final _phoneController = TextEditingController(text: '819 3535 1327');

  final List<String> _countryCodes = ['+62', '+1', '+44', '+91'];
  String _selectedCountryCode = '+62';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickFromCamera() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _deleteImage() {
    setState(() => _imageFile = null);
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF03045E)),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFD9E9EC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: GoogleFonts.inter(),
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Expanded(
                      child: Center(
                        child: Text("Foto Profil",
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (_imageFile != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          _deleteImage();
                          Navigator.pop(context);
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
    if (_imageFile == null) return;

    showDialog(
      context: context,
      builder: (_) {
        final isDark = context.read<ThemeProvider>().isDark;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black,
                  child: InteractiveViewer(
                    child: Image.file(_imageFile!, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: 32,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close
                    CircleAvatar(
                      backgroundColor:
                          isDark ? Colors.black54 : Colors.white.withOpacity(.9),
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: isDark ? Colors.white : Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Edit + Delete
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDark
                              ? Colors.black54
                              : Colors.white.withOpacity(.9),
                          child: IconButton(
                            icon: Icon(Icons.edit,
                                color: isDark ? Colors.white : Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
                              _showImageOptions();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_imageFile != null)
                          const CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.delete, color: Colors.white),
                          )
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

  Widget _buildLabel(String text) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.bold, color: kInkTone));
  }

  Widget _buildModeSelector(ThemeProvider provider) {
    final bool isDark = provider.isDark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFD9E9EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF03045E)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => provider.toggle(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isDark ? kAccentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.light_mode,
                        color: !isDark ? Colors.white : kInkTone, size: 20),
                    const SizedBox(width: 6),
                    Text("Light",
                        style: GoogleFonts.inter(
                            color:
                                !isDark ? Colors.white : const Color(0xFF03045E),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => provider.toggle(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? kAccentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dark_mode,
                        color: isDark ? Colors.white : kInkTone, size: 20),
                    const SizedBox(width: 6),
                    Text("Dark",
                        style: GoogleFonts.inter(
                            color:
                                isDark ? Colors.white : const Color(0xFF03045E),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bool isDark = themeProvider.isDark;

    final double topSpacing = MediaQuery.of(context).padding.top + 28;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: EdgeInsets.only(top: topSpacing - 18),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text("My Profile",
                style: GoogleFonts.montserratAlternates(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 10),

          // Profile Photo
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _imageFile != null
                      ? _openImagePreview
                      : _showImageOptions,
                  child: Container(
                    width: 121,
                    height: 118,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(28),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imageFile == null
                        ? Center(
                            child: Icon(Icons.person,
                                size: 56, color: Colors.white.withOpacity(.8)))
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
                          color: const Color(0xFF031D44),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.edit,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // FULL NAME
          _buildLabel("Full Name"),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextFormField(
              controller: _fullNameController,
              decoration: _decoration("Markus Lee"),
              style: GoogleFonts.inter(),
            ),
          ),

          const SizedBox(height: 14),

          // USERNAME
          _buildLabel("Username"),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextFormField(
              controller: _usernameController,
              decoration: _decoration("onyourm_ark"),
              style: GoogleFonts.inter(),
            ),
          ),

          const SizedBox(height: 14),

          // PASSWORD
          _buildLabel("Password"),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: _decoration("••••••••"),
              style: GoogleFonts.inter(),
            ),
          ),

          const SizedBox(height: 14),

          // EMAIL
          _buildLabel("Email"),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextFormField(
              controller: _emailController,
              decoration: _decoration("markuslee@gmail.com"),
              style: GoogleFonts.inter(),
              keyboardType: TextInputType.emailAddress,
            ),
          ),

          const SizedBox(height: 14),

          // Phone num
          _buildLabel("Phone Number"),
          const SizedBox(height: 6),
          Row(
            children: [
              // kode negara
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E9EC),
                  border: Border.all(color: Color(0xFF03045E)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    items: _countryCodes
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: GoogleFonts.inter()),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCountryCode = v!),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: _decoration("819 3535 1327"),
                    style: GoogleFonts.inter(),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // MODE
          _buildLabel("Mode"),
          const SizedBox(height: 6),
          _buildModeSelector(themeProvider),

          const SizedBox(height: 26),

          // SAVE
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {},
              child: Text("Save",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}
