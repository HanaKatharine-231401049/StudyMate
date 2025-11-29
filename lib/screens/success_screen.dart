import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessScreen extends StatelessWidget {
  static const routeName = '/success';
  const SuccessScreen({super.key});

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // logo 
                if (true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset(
                        'assets/images/studymateLogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                Text('Ready To Explore!', style: GoogleFonts.poppins(textStyle: headingStyle)),
                const SizedBox(height: 12),
                Text(
                  'Your password account has been changed successfully.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 16),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03045E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Back To Sign In',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
