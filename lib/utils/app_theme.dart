import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Saffron + Deep Saffron/Wood (Vedic Sanatan)
  static const Color primarySaffron = Color(0xFFB56A00);
  static const Color deepWood = Color(0xFF5C3A21);
  static const Color softGold = Color(0xFFFFD700);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightBg = Color(0xFFFAF7F2);
  static const Color darkBg = Color(0xFF120B06);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E140E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primarySaffron,
      scaffoldBackgroundColor: lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySaffron,
        primary: deepWood,
        secondary: primarySaffron,
        surface: cardLight,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deepWood,
        foregroundColor: const Color(0xFFFAF2E4),
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFAF2E4),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C180C),
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2C180C),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF334155),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEADBCC), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepWood,
          foregroundColor: const Color(0xFFFAF2E4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: deepWood,
          foregroundColor: const Color(0xFFFAF2E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primarySaffron,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySaffron,
        primary: const Color(0xFFE69A33),
        secondary: softGold,
        surface: cardDark,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF241913),
        foregroundColor: const Color(0xFFFFD88A),
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFFD88A),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: softGold,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFFD88A),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFFFAF2E4),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFFD9C4A9),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF5C3A21), width: 1),
        ),
      ),
    );
  }
}
