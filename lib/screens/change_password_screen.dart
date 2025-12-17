import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  // ===== UI HELPERS =====

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
      hintStyle: GoogleFonts.inter(
        color: scheme.onSurface.withOpacity(0.6),
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

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = context.read<AuthService>();
    final email = auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.primary),
        title: Text(
          'Change Password',
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
            // Email
            _buildLabel(context, "Email"),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: TextFormField(
                readOnly: true,
                initialValue: email,
                decoration: _decoration(context, "Email"),
                style: GoogleFonts.inter(color: scheme.onSurface),
              ),
            ),

            const SizedBox(height: 32),

            // Send reset link
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.mail_outline),
                label: Text(
                  "Send reset link",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: email.isEmpty
                    ? null
                    : () async {
                        final err =
                            await auth.sendPasswordReset(email);
                        if (err == null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password reset link sent to your email",
                              ),
                            ),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}