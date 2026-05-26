import 'package:flutter/material.dart';

class VidaraTheme {
  // Color Palette
  static const Color background = Color(0xFF070708);
  static const Color surface = Color(0xFF111114);
  static const Color cardBg = Color(0xFF16161A);
  
  static const Color primary = Color(0xFFFF3B30);
  static const Color primaryGradientStart = Color(0xFFE50914);
  static const Color primaryGradientEnd = Color(0xFFFF5E3A);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EA7);
  static const Color textMuted = Color(0xFF6C6C73);
  
  static const Color border = Color(0xFF222226);
  static const Color activeBorder = Color(0xFFFF3B30);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [Color(0x33FF3B30), Color(0x05FF5E3A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: cardBg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryGradientEnd,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontFamily: 'Outfit',
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: 'Outfit',
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
