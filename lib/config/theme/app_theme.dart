import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFFBF3A34); // Deep Coral
  static const Color secondaryColor = Color(0xFF1DB954); // Spotify Green
  static const Color backgroundColor = Color(0xFF121212); // Deep Black
  static const Color errorColor = Color(0xFFE50914); // Netflix Red
  
  // Text colors
  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFFB3B3B3);
  
  static final ThemeData darkTheme = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      displaySmall: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      ),
      bodyLarge: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.poppins().copyWith(
        color: textSecondaryColor,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      titleLarge: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: GoogleFonts.poppins().copyWith(
        color: textPrimaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.poppins().copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.poppins().copyWith(
        color: secondaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.poppins().copyWith(
        color: errorColor,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  );
}