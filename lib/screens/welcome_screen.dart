import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart'; // Tambahkan import ini

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToSignIn(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
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
            alignment: const Alignment(0, -0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tulisan "Your True Study Mate"
                Text(
                  'Your True Study Mate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600, 
                    fontFamily: 'Roboto',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Tulisan "Be a mate, be part of us"
                Text(
                  'Be a mate, be part of us',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.normal, 
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
                const SizedBox(height: 1),
                // Tulisan "StudyMate"
                Text(
                  'StudyMate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'MontserratAlternates',
                    color: const Color(0xFF03045E),
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Button Continue with Google
                SizedBox(
                  width: 345,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFD8DADC), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/google_icon.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.web,
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
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Button Continue with Email
                SizedBox(
                  width: 345,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => _navigateToSignUp(context), 
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFD8DADC), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/email_icon.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.email,
                              size: 20,
                              color: Colors.grey,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                            fontSize: 14, 
                            fontWeight: FontWeight.normal, 
                            fontFamily: 'Inter',
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w800, 
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