import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color secondaryWhite = Color(0xFFFFFFFF);
  static const Color accentDarkGray = Color(0xFF424242);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Order Status Colors
  static const Color orderPlaced = Color(0xFF2196F3);
  static const Color orderPreparing = Color(0xFFFFC107);
  static const Color orderOutForDelivery = Color(0xFFFF6B00);
  static const Color orderDelivered = Color(0xFF4CAF50);
  static const Color orderCancelled = Color(0xFFF44336);

  // Additional Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color placeholder = Color(0xFFE0E0E0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
