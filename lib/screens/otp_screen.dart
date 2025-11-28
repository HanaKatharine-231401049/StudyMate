// lib/screens/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'set_new_password_screen.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp';
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _ctrls) c.dispose();
    for (var n in _nodes) n.dispose();
    super.dispose();
  }

  void _onChanged(String v, int index) {
    if (v.isNotEmpty) {
      if (index + 1 < _nodes.length) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
    } else {
      if (index - 1 >= 0) _nodes[index - 1].requestFocus();
    }
  }

  void _resendCode() {
    // TODO: call resend API
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code resent')));
  }

  void _submitOtp() {
    final otp = _ctrls.map((c) => c.text).join();
    if (otp.length == 6) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SetNewPasswordScreen(),
          settings: RouteSettings(arguments: otp),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter 6-digit code')));
    }
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
              Text('Enter OTP Code', style: GoogleFonts.poppins(textStyle: headingStyle)),
              const SizedBox(height: 12),
              Text(
                "We've sent you an OTP code to your registered email address. Please check your inbox and enter the code here.",
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 24),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: TextField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (v) => _onChanged(v, i),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _resendCode,
                  child: Text(
                    'Resend Code',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF007AFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03045E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Verify code',
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
