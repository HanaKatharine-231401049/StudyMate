// lib/screens/set_new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'success_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  static const routeName = '/set-new-password';
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _newPwCtrl = TextEditingController();
  final TextEditingController _confirmPwCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _toggleNew() => setState(() => _obscureNew = !_obscureNew);
  void _toggleConfirm() => setState(() => _obscureConfirm = !_obscureConfirm);

  void _confirmPassword() {
    final a = _newPwCtrl.text.trim();
    final b = _confirmPwCtrl.text.trim();

    if (a.isEmpty || b.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both fields')),
      );
      return;
    }
    if (a != b) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // TODO: call API to change password here. If success -> navigate to SuccessScreen.

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const headingStyle = TextStyle(
      color: Color(0xFF03045E),
      fontSize: 30,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF03045E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set New Password', style: GoogleFonts.poppins(textStyle: headingStyle)),
              const SizedBox(height: 18),

              Text('New Password', style: GoogleFonts.inter(fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 54,
                child: TextFormField(
                  controller: _newPwCtrl,
                  obscureText: _obscureNew,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF03045E))),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                      onPressed: _toggleNew,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text('Confirm password', style: GoogleFonts.inter(fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 54,
                child: TextFormField(
                  controller: _confirmPwCtrl,
                  obscureText: _obscureConfirm,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Repeat Password',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF03045E))),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                      onPressed: _toggleConfirm,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _confirmPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03045E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Confirmation Password',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}