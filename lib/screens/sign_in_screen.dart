import 'package:flutter/material.dart';
// Import untuk navigasi ke halaman utama
import 'home_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  void _navigateToHome(BuildContext context) {
    // --- LOGIKA UTAMA ---
    // Simulasikan login berhasil.
    // Navigasi ke HomePage dan hapus semua rute sebelumnya (seperti Splash, Welcome)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tambahkan UI sederhana untuk Login
    return Scaffold(
      backgroundColor: const Color(0xFF03045E),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'Sign In Page',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'MontserratAlternates',
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form Email
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Form Password
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 40),

                // Tombol Login (Navigasi ke Home Page)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _navigateToHome(context), // PANGGIL FUNGSI NAVIGASI KE HOME
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'LOG IN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF03045E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'This is the sign in page where you log in',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'Inter',
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