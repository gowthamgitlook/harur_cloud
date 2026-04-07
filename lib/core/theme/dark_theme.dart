import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class DarkTheme {
  DarkTheme._();

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryRed,
        secondary: AppColors.accentDarkGray,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.textLight,
        onSurface: AppColors.textLight,
        onError: AppColors.textLight,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textLight,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: AppSizes.fontXL,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textLight,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppSizes.fontHeading,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        displayMedium: TextStyle(
          fontSize: AppSizes.fontTitle,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        displaySmall: TextStyle(
          fontSize: AppSizes.fontXXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        headlineMedium: TextStyle(
          fontSize: AppSizes.fontXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        titleLarge: TextStyle(
          fontSize: AppSizes.fontLG,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        titleMedium: TextStyle(
          fontSize: AppSizes.fontMD,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: AppSizes.fontLG,
          color: AppColors.textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontMD,
          color: AppColors.textLight,
        ),
        bodySmall: TextStyle(
          fontSize: AppSizes.fontSM,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: AppSizes.fontLG,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.textLight,
          elevation: AppSizes.cardElevation,
          minimumSize: Size(AppSizes.buttonMinWidth, AppSizes.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: TextStyle(
            fontSize: AppSizes.fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          side: const BorderSide(
            color: AppColors.primaryRed,
            width: 1.5,
          ),
          minimumSize: Size(AppSizes.buttonMinWidth, AppSizes.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: TextStyle(
            fontSize: AppSizes.fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          textStyle: TextStyle(
            fontSize: AppSizes.fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(
            color: AppColors.accentDarkGray,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(
            color: AppColors.accentDarkGray,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(
            color: AppColors.primaryRed,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2.0,
          ),
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppSizes.fontMD,
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppSizes.fontMD,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppSizes.cardElevation,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        margin: EdgeInsets.all(AppSizes.paddingSM),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: AppSizes.fontSM,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppSizes.fontSM,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.textLight,
        elevation: AppSizes.cardElevationHigh,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.accentDarkGray,
        thickness: AppSizes.dividerThickness,
        space: AppSizes.spacingMD,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentDarkGray,
        selectedColor: AppColors.primaryRed,
        labelStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: AppSizes.fontSM,
        ),
        secondaryLabelStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: AppSizes.fontSM,
        ),
        padding: EdgeInsets.all(AppSizes.paddingSM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: AppSizes.cardElevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: AppSizes.fontMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
