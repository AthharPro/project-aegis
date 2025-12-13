import 'package:flutter/material.dart';

class AppTheme {
  // Medical Color Scheme
  static const Color medicalTeal = Color(0xFF008080);
  static const Color actionOrange = Color(0xFFFF5722);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF333333);
  
  static final ThemeData lightTheme = ThemeData(
    primaryColor: medicalTeal,
    scaffoldBackgroundColor: pureWhite,
    fontFamily: 'Roboto',
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: medicalTeal,
      secondary: actionOrange,
      surface: pureWhite,
      background: pureWhite,
      error: Colors.red,
      onPrimary: pureWhite,
      onSecondary: pureWhite,
      onSurface: darkGray,
      onBackground: darkGray,
    ),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: medicalTeal,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: pureWhite),
      titleTextStyle: TextStyle(
        color: pureWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    ),
    
    // Text Theme - Minimum 16pt for body text
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkGray),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkGray),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkGray),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkGray),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkGray),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: darkGray),
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: darkGray),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkGray),
      bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: darkGray),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: pureWhite),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: actionOrange,
        foregroundColor: pureWhite,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: medicalTeal,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: medicalTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.all(18),
      labelStyle: const TextStyle(fontSize: 16, color: darkGray),
      hintStyle: TextStyle(fontSize: 16, color: darkGray.withOpacity(0.6)),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: pureWhite,
    ),

    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: medicalTeal,
      size: 24,
    ),
  );
}
