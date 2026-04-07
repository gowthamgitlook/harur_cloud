import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Zomato Style)
  static const Color primaryRed = Color(0xFFE23744);
  static const Color secondaryWhite = Color(0xFFFFFFFF);
  static const Color accentDarkGray = Color(0xFF2D2D2D);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F8F8);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF696969);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);

  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFED8936);
  static const Color info = Color(0xFF4299E1);

  // Order Status Colors
  static const Color orderPlaced = Color(0xFF4299E1);
  static const Color orderPreparing = Color(0xFFED8936);
  static const Color orderOutForDelivery = Color(0xFFE23744);
  static const Color orderDelivered = Color(0xFF48BB78);
  static const Color orderCancelled = Color(0xFFE53E3E);

  // Additional Colors
  static const Color divider = Color(0xFFE8E8E8);
  static const Color shadow = Color(0x0D000000);
  static const Color overlay = Color(0x80000000);
  static const Color disabled = Color(0xFFD1D1D1);
  static const Color placeholder = Color(0xFFF0F0F0);
  static const Color backgroundGrey = Color(0xFFF8F8F8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, Color(0xFFF05E68)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
