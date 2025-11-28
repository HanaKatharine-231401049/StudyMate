// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailCtrl.text.trim();
    // NOTE: put API call to send OTP here
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
        ),
        settings: RouteSettings(arguments: email),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Forgot Password?', style: GoogleFonts.poppins(textStyle: headingStyle)),
            const SizedBox(height: 14),
            Text(
              "Enter the email you used to sign up with StudyMate. We'll send you a one-time code to reset your password.",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 22),
            Text('Registered email address',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8),
                    child: Icon(Icons.mail_outline, color: Colors.black54),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: 'your.email@example.com',
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
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
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Send OTP code',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
