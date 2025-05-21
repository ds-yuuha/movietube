import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimaryColor = Colors.white;
  static const Color _lightPrimaryVariantColor = Color(0xFFF5F5F5);
  static const Color _lightSecondaryColor = Color(0xFFFF0000);
  static const Color _lightOnPrimaryColor = Colors.black;

  // Dark Theme Colors
  static const Color _darkPrimaryColor = Color(0xFF121212);
  static const Color _darkPrimaryVariantColor = Color(0xFF1F1F1F);
  static const Color _darkSecondaryColor = Color(0xFFFF0000);
  static const Color _darkOnPrimaryColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightPrimaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: _lightOnPrimaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightPrimaryColor,
      selectedItemColor: _lightSecondaryColor,
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardTheme(
      color: _lightPrimaryVariantColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: _lightOnPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: _lightOnPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _lightOnPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: _lightOnPrimaryColor),
      bodyMedium: TextStyle(color: _lightOnPrimaryColor),
    ),
    colorScheme: ColorScheme.light(
      primary: _lightSecondaryColor,
      secondary: _lightSecondaryColor,
      onPrimary: Colors.white,
      surface: _lightPrimaryVariantColor,
      onSurface: _lightOnPrimaryColor,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkPrimaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: _darkOnPrimaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkPrimaryColor,
      selectedItemColor: _darkSecondaryColor,
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardTheme(
      color: _darkPrimaryVariantColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: _darkOnPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: _darkOnPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _darkOnPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: _darkOnPrimaryColor),
      bodyMedium: TextStyle(color: _darkOnPrimaryColor),
    ),
    colorScheme: ColorScheme.dark(
      primary: _darkSecondaryColor,
      secondary: _darkSecondaryColor,
      onPrimary: Colors.white,
      surface: _darkPrimaryVariantColor,
      onSurface: _darkOnPrimaryColor,
    ),
  );
}
