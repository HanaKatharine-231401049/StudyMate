// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';        // <= add this
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'utils/dark_theme_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialMode: ThemeMode.light),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthService(),    // provides Google + email auth
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
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthService>();     // <== watch auth state

    return MaterialApp(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.mode,

      // ---------------- LIGHT THEME ----------------
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          background: Colors.white,
          onBackground: Colors.black,
          surface: Color(0xFFD9E9EC),
          onSurface: Color(0xFF0B0B0B),
          surfaceVariant: Color(0xFFEAF3F5),
          primary: Color(0xFF031D44),
          onPrimary: Colors.white,
          outline: Color(0xFF03045E),
          error: Colors.redAccent,
          onError: Colors.white,
        ),
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
      ),

      // ---------------- DARK THEME ----------------
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          background: DarkThemeColors.backgroundColor,
          onBackground: DarkThemeColors.textPrimary,
          surface: DarkThemeColors.surfaceColor,
          onSurface: DarkThemeColors.textPrimary,
          surfaceVariant: DarkThemeColors.cardColor,
          primary: DarkThemeColors.primary,
          onPrimary: DarkThemeColors.onPrimary,
          outline: DarkThemeColors.borderColor,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: DarkThemeColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: DarkThemeColors.backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: DarkThemeColors.textPrimary),
          titleTextStyle: TextStyle(
            color: DarkThemeColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: DarkThemeColors.textPrimary,
          displayColor: DarkThemeColors.textPrimary,
        ),
        fontFamily: 'Inter',
      ),

      // If already signed in (email or Google), skip to HomePage
      // otherwise show SplashScreen (which can lead to SignIn)
      home: auth.isSignedIn ? const HomePage() : const SplashScreen(),
    );
  }
}
