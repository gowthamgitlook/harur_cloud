import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'zomato_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: ZomatoTheme.primaryRed,
      scaffoldBackgroundColor: ZomatoTheme.background,
      
      colorScheme: ColorScheme.light(
        primary: ZomatoTheme.primaryRed,
        secondary: ZomatoTheme.secondaryRed,
        surface: ZomatoTheme.surface,
        error: ZomatoTheme.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ZomatoTheme.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: ZomatoTheme.textPrimary,
        centerTitle: false,
        titleTextStyle: ZomatoTheme.headlineLarge.copyWith(fontSize: 20),
        iconTheme: const IconThemeData(color: ZomatoTheme.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      textTheme: TextTheme(
        headlineLarge: ZomatoTheme.headlineLarge,
        bodyLarge: ZomatoTheme.bodyLarge,
        bodyMedium: ZomatoTheme.bodyMedium,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ZomatoTheme.border),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZomatoTheme.primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZomatoTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZomatoTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZomatoTheme.primaryRed, width: 1.5),
        ),
        hintStyle: const TextStyle(color: ZomatoTheme.textTertiary),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ZomatoTheme.primaryRed,
        unselectedItemColor: ZomatoTheme.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
