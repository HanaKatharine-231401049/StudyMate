import 'package:flutter/material.dart';
import 'sign_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToSignIn(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bagian atas dengan logo dan teks
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tulisan "Your True Study Mate"
                Text(
                  'Your True Study Mate',
                  style: TextStyle(
                    fontSize: 20, // Ukuran font 20
                    fontWeight: FontWeight.w600, // Semi bold
                    fontFamily: 'Roboto',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Tulisan "Be a mate, be part of us"
                Text(
                  'Be a mate, be part of us',
                  style: TextStyle(
                    fontSize: 14, // Ukuran font 14 (lebih kecil)
                    fontWeight: FontWeight.normal, // Regular
                    fontFamily: 'Roboto',
                    color: const Color(0xFFA4A1A1),
                  ),
                ),
                const SizedBox(height: 24),
                // Logo StudyMate
                Image.asset(
                  'assets/images/studymateLogo.png',
                  width: 250,
                  height: 230,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school_outlined,
                      size: 100,
                      color: const Color(0xFF03045E),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Tulisan "StudyMate"
                Text(
                  'StudyMate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'MontserratAlternates',
                    color: const Color(0xFF03045E),
                  ),
                ),
              ],
            ),
          ),
          
          // Bagian bawah dengan buttons dan tulisan
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Button Continue with Google
                SizedBox(
                  width: 535,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFD8DADC), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_icon.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 20,
                              color: Colors.grey,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Button Continue with Apple
                SizedBox(
                  width: 535,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFD8DADC), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/apple_icon.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.apple,
                              size: 20,
                              color: Colors.grey,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Apple',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Tulisan "Already have an account?"
                GestureDetector(
                  onTap: () => _navigateToSignIn(context),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14, // Ukuran font 14
                            fontWeight: FontWeight.normal, // Regular
                            fontFamily: 'Inter',
                            color: Colors.black.withOpacity(0.7), // Hitam 70%
                          ),
                        ),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            fontSize: 14, // Ukuran font 14
                            fontWeight: FontWeight.w600, // Semi bold
                            fontFamily: 'Inter',
                            color: const Color(0xFF0386D0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}