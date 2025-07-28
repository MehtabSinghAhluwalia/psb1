import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00723E); // Punjab & Sind Bank Green
  static const Color secondaryColor = Color(0xFFFFE600); // Punjab & Sind Bank Yellow
  static const Color accentColor = Color(0xFFB71C1C); // Punjab & Sind Bank Red
  static const Color errorColor = Color(0xFFB71C1C); // Red
  static const Color successColor = Color(0xFF388E3C); // Green
  static const Color warningColor = Color(0xFFF57C00); // Orange
  static const Color textLightColor = Color(0xFF757575); // Grey
  static const Color backgroundColor = Color(0xFFFFFDE7); // Light Yellow

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: ThemeData.light().cardTheme.copyWith(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
} 