// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized');
      debugPrint('FirebaseAuth instance: ${FirebaseAuth.instance}');
    }
  } catch (e, st) {
    // Jangan rethrow di sini; tampilkan pesan lewat log dan biarkan app tetap mencoba jalan.
    // Jika kamu mau fatal error saat Firebase gagal, ubah menjadi `rethrow`.
    debugPrint('❌ Firebase initialization error: $e\n$st');
  }

  // Pastikan provider berada di root aplikasi (di atas MyApp)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(initialMode: ThemeMode.light),
        ),
        // Jika kamu ingin mengakses AuthService via Provider di UI, sediakan di sini.
        // AuthService tidak wajib disediakan, tapi berguna.
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BACA provider di dalam build (bukan di ctor)
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.mode,

      // Light theme
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF03045E),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        fontFamily: 'Inter',
        useMaterial3: false,
      ),

      // Dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF03045E),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        fontFamily: 'Inter',
        useMaterial3: false,
      ),

      home: const SplashScreen(),
    );
  }
}
