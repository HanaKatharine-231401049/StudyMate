import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/dark_theme_colors.dart';

class AppTheme {
  static ThemeData light(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      background: Colors.white,
      onBackground: Colors.black,
      surface: Color(0xFFF2F5F7),
      onSurface: Color(0xFF0B0B0B),
      surfaceVariant: Color(0xFFE6EBEF),
      primary: Color(0xFF03045E),
      onPrimary: Colors.white,
      outline: Color(0xFFCED6DC),
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    textTheme: GoogleFonts.interTextTheme(
      Theme.of(context).textTheme,
    ),
    fontFamily: 'Inter',
  );

  static ThemeData dark(BuildContext context) => ThemeData(
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
  );
}
