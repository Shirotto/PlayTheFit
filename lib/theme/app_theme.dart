import 'package:flutter/material.dart';
import 'app_design_system.dart';

class AppTheme {
  // Utilizza i colori dal design system unificato
  static const Color primaryColor = AppDesignSystem.primary;
  static const Color accentColor = AppDesignSystem.secondary;

  // Background colors per modalità scura
  static const Color scaffoldColor = AppDesignSystem.darkPrimary;
  static const Color cardColor = AppDesignSystem.darkSecondary;

  // Text colors
  static const Color textPrimaryColor = AppDesignSystem.textPrimary;
  static const Color textSecondaryColor = AppDesignSystem.textSecondary;

  // Button colors
  static const Color buttonColor = primaryColor;
  static const Color buttonTextColor = Colors.white;

  // Status colors
  static const Color successColor = AppDesignSystem.success;
  static const Color errorColor = AppDesignSystem.error;
  static const Color warningColor = AppDesignSystem.warning;

  // Create and return the theme data
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldColor,      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        brightness: Brightness.dark,
        surface: cardColor,
        background: scaffoldColor,
      ),
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        headlineLarge: AppDesignSystem.headingLarge,
        headlineMedium: AppDesignSystem.headingMedium,
        headlineSmall: AppDesignSystem.headingSmall,
        bodyLarge: AppDesignSystem.bodyLarge,
        bodyMedium: AppDesignSystem.bodyMedium,
        bodySmall: AppDesignSystem.bodySmall,
        labelSmall: AppDesignSystem.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppDesignSystem.primaryButtonStyle,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: AppDesignSystem.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDesignSystem.cardBackgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        hintStyle: AppDesignSystem.bodyMedium.copyWith(
          color: AppDesignSystem.textTertiary,
        ),
        labelStyle: AppDesignSystem.bodyMedium,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppDesignSystem.headingMedium,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppDesignSystem.darkSecondary,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppDesignSystem.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppDesignSystem.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppDesignSystem.bodySmall,
      ),
    );
  }
}
