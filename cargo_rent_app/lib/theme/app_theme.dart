import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors ─────────────────────────────────────
  static const Color navyDark    = Color(0xFF0F172A);
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color accentGold  = Color(0xFFFFD700);

  // ── Status Colors ────────────────────────────────────
  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFBA7517);
  static const Color danger  = Color(0xFFE24B4A);
  static const Color info    = Color(0xFF3B8BD4);

  // ── Neutral Colors ───────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundCard  = Color(0xFFFFFFFF);
  static const Color textPrimary     = Color(0xFF0F172A);
  static const Color textSecondary   = Color(0xFF64748B);
  static const Color borderLight     = Color(0xFFE2E8F0);

  // ── MaterialApp Theme ────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: navyDark,
        secondary: primaryBlue,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundCard,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      ),
      cardTheme: CardTheme(
        color: backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}