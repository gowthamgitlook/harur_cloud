import 'package:flutter/material.dart';

class ZomatoTheme {
  ZomatoTheme._();

  // Primary Colors
  static const Color primaryRed = Color(0xFFE23744);
  static const Color secondaryRed = Color(0xFFFF5252);
  
  // Neutral Colors
  static const Color background = Color(0xFFF8F8F8); // Slightly darker for better card contrast
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE8E8E8);
  
  // Shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF696969);
  static const Color textTertiary = Color(0xFF9C9C9C);
  
  // Status Colors
  static const Color success = Color(0xFF2D8A39);
  static const Color warning = Color(0xFFF6AD55);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1C75BC);

  // Custom Text Styles
  static TextStyle get headlineLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );
}
