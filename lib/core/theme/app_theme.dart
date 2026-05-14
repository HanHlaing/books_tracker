import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary   = Color(0xFF1A1A2E);
  static const Color surface   = Color(0xFFF8F5F0);
  static const Color card      = Color(0xFFFFFFFF);
  static const Color accent    = Color(0xFFE8572A);
  static const Color textDark  = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF8A8A9A);
  static const Color border    = Color(0xFFE8E4DE);

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: surface,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, surface: surface),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark, fontSize: 22,
        fontWeight: FontWeight.w700, letterSpacing: -0.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2,
        ),
      ),
    ),
  );
}
