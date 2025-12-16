// lib/utils/dark_theme_colors.dart
import 'package:flutter/material.dart';

/// Standardized dark theme colors used across all pages
class DarkThemeColors {
  // Background colors (darker)
  static const Color backgroundColor = Color(0xFF0A0A0D); // almost black
  static const Color surfaceColor    = Color(0xFF141418); // inputs/cards
  static const Color cardColor       = Color(0xFF1C1D23); // raised surfaces

  // Text colors
  static const Color textPrimary   = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB8BCC8);
  static const Color textHint      = Color(0xFF7A7F8B);

  // Border colors (more subtle)
  static const Color borderColor      = Color(0xFF2A2B33);
  static const Color inputBorderColor = Color(0xFF2A2B33);

  // Input field colors (same as surface so they don't glow)
  static const Color inputFillColor = surfaceColor;

  // Component colors
  static const Color dividerColor = Color(0xFF23242B);

  // Accent colors (so blue isn't neon)
  static const Color primary   = Color(0xFF2F6FED);
  static const Color onPrimary = Colors.white;
}