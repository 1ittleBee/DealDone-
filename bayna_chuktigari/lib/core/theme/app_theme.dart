import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// App typography definitions and theme configuration
class AppTypography {
  AppTypography._();

  static const String fontFamilyBengali = 'HindSiliguri';

  // Scaled dimensions adhering to DESIGN.md
  static const double headlineLarge = 24.0;
  static const double headlineMedium = 20.0;
  static const double titleMedium = 16.0;
  static const double bodyLarge = 15.0;
  static const double bodyMedium = 14.0;
  static const double labelSmall = 12.0;

  // Generous line-height to prevent Bengali vowel marker clipping
  static const double lineHeightStandard = 1.5;
  static const double lineHeightBody = 1.6;
}

/// AppTheme encapsulating design tokens, shape constants, and dimensions
class AppTheme {
  AppTheme._();

  // Colors
  static const int primaryColor = AppColors.accentInt;
  static const int backgroundColor = AppColors.surfaceBaseInt;
  static const int cardColor = AppColors.surfaceRaisedInt;
  static const int textColor = AppColors.inkPrimaryInt;
  static const int secondaryTextColor = AppColors.inkSecondaryInt;
  static const String fontFamily = AppTypography.fontFamilyBengali;

  // Dark Mode Palette
  static const int backgroundDark = 0xFF0B1120;
  static const int cardDark = 0xFF1E293B;
  static const int textDark = 0xFFF8FAFC;
  static const int secondaryTextDark = 0xFF94A3B8;

  // Accessibility & Grid Dimensions
  static const double minTouchTarget = 48.0;
  static const double defaultPadding = 16.0;

  // Shapes & Corner Radii per DESIGN.md
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusFull = 9999.0;

  // Material 3 Flutter ThemeData
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(primaryColor),
      onPrimary: Colors.white,
      secondary: Color(AppColors.accentHighlightInt),
      onSecondary: Colors.white,
      error: Color(AppColors.dangerInt),
      onError: Colors.white,
      surface: Color(cardColor),
      onSurface: Color(textColor),
      surfaceContainerHighest: Color(AppColors.surfaceOverlayInt),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Color(backgroundColor),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: AppTypography.headlineMedium,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: Color(cardColor),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: Color(AppColors.borderHairlineInt)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(primaryColor),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: AppTypography.titleMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(cardColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Color(AppColors.borderHairlineInt)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Color(AppColors.borderHairlineInt)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Color(primaryColor), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Color(AppColors.dangerInt)),
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: AppTypography.bodyMedium,
          color: Color(secondaryTextColor),
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: AppTypography.labelSmall,
          color: Color(AppColors.dangerInt),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(backgroundDark),
      colorScheme: ColorScheme.dark(
        primary: Color(AppColors.accentDarkInt),
        surface: Color(cardDark),
        onSurface: Color(textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(cardDark),
        foregroundColor: Color(textDark),
        elevation: 0,
      ),
    );
  }
}
