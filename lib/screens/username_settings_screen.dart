import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsernameSettingsScreen extends StatefulWidget {
  const UsernameSettingsScreen({super.key});

  @override
  State<UsernameSettingsScreen> createState() =>
      _UsernameSettingsScreenState();
}

class _UsernameSettingsScreenState extends State<UsernameSettingsScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = snap.data();
    if (data != null) {
      _fullNameController.text = data['fullName'] ?? '';
      _usernameController.text = data['username'] ?? '';
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_fullNameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      _showError('Full name dan username tidak boleh kosong.');
      return;
    }

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_fullNameController.text.trim());

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Gagal menyimpan data.\n$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ===== UI HELPERS =====

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  InputDecoration _decoration(BuildContext context, String hint) {
    final scheme = Theme.of(context).colorScheme;

    return InputDecoration(
      filled: true,
      fillColor: scheme.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: scheme.onSurface.withOpacity(0.6),
        fontSize: 14,
      ),
      border: _inputBorder(scheme.outline),
      enabledBorder: _inputBorder(scheme.outline),
      focusedBorder: _inputBorder(scheme.primary),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: scheme.onBackground,
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.primary),
        title: Text(
          'Username Settings',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            _buildLabel(context, 'Full Name'),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: TextFormField(
                controller: _fullNameController,
                decoration: _decoration(context, 'Full name'),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
            ),

            const SizedBox(height: 14),

            // Username
            _buildLabel(context, 'Username'),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: TextFormField(
                controller: _usernameController,
                decoration: _decoration(context, 'Username'),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
            ),

            const SizedBox(height: 40),

            // SAVE BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 110,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}