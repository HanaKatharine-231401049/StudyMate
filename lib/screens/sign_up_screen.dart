// lib/screens/sign_up_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final error = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (error != null) {
      _showErrorDialog(error);
    } else {
      // sukses - pindah ke layar utama misalnya
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gagal masuk'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
    if (kDebugMode) {
      // print agar mudah dilihat di debug log
      debugPrint('Google sign-in error: $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Daftar / Masuk', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/google_logo.png',
                        width: 20,
                        height: 20,
                      ),
                      label: const Text('Masuk dengan Google'),
                      onPressed: _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // contoh: pindah ke halaman login biasa
                        Navigator.of(context).pushNamed('/email_signin');
                      },
                      child: const Text('Gunakan email'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}