import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF090E1A);
  static const Color surface = Color(0xFF0F1629);
  static const Color surfaceLight = Color(0xFF151C2E);
  static const Color primary = Color(0xFF00D9FF);
  static const Color foreground = Color(0xFFFFFFFF);
  static const Color mutedForeground = Color(0xFF8B92A8);
  static const Color border = Color(0xFF1E2740);
  static const Color destructive = Color(0xFFFF5555);
  static const Color green = Color(0xFF10B981);
  static const Color card = Color(0xFF0F1629);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        error: destructive,
        onPrimary: background,
        onSurface: foreground,
        onError: foreground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: foreground),
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: mutedForeground),
        labelStyle: const TextStyle(color: mutedForeground),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      useMaterial3: true,
    );
  }
}
