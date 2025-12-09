// lib/screens/welcome_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _loadingGoogle = false;

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

  Future<void> _handleContinueWithGoogle() async {
    setState(() => _loadingGoogle = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      if (kDebugMode) debugPrint('WelcomeScreen: calling signInWithGoogle');

      // forceAccountSelection true supaya account chooser muncul
      final String? error = await auth.signInWithGoogle(forceAccountSelection: true);

      if (kDebugMode) debugPrint('WelcomeScreen: signInWithGoogle returned: $error');

      if (!mounted) return;
      setState(() => _loadingGoogle = false);

      if (error != null) {
        _showErrorDialog(error);
        return;
      }

      // sukses -> arahkan ke Home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('Unexpected error in _handleContinueWithGoogle: $e\n$st');
      if (mounted) setState(() => _loadingGoogle = false);
      _showErrorDialog('Terjadi kesalahan saat proses Google Sign-In.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Gagal masuk'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup')),
        ],
      ),
    );
    if (kDebugMode) debugPrint('Google sign-in error: $message');
  }

  @override
  Widget build(BuildContext context) {
    // responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final btnWidth = screenWidth * 0.9; // 90% of width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top content (logo + texts)
          Align(
            alignment: const Alignment(0, -0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                // Logo with fallback
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

          // Bottom buttons
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Continue with Google
                SizedBox(
                  width: btnWidth,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _loadingGoogle ? null : _handleContinueWithGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFD8DADC), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.centerLeft,
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            'assets/images/google_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.web, size: 20, color: Colors.grey);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _loadingGoogle
                              ? const SizedBox(
                                  height: 20,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                )
                              : Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Continue with Email
                SizedBox(
                  width: btnWidth,
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
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            'assets/images/email_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.email, size: 20, color: Colors.grey);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
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

                // Already have an account?
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
