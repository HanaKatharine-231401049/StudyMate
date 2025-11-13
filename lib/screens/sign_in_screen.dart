import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03045E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'MontserratAlternates',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'This is the sign in page',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}