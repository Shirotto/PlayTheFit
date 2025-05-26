import 'package:flutter/material.dart';

/// Design System unificato per PlayTheFit
/// Questo file contiene tutti i colori, stili e componenti standard dell'app
class AppDesignSystem {
  // ========== COLORI ==========
  
  // Colori di base
  static const Color darkPrimary = Color(0xFF0F172A);
  static const Color darkSecondary = Color(0xFF1E293B);
  static const Color darkAccent = Color(0xFF334155);
  
  // Gradiente principale dell'app
  static const List<Color> primaryGradient = [
    Color(0xFF1E1B4B), // indigo-900
    Color(0xFF000000), // black
  ];
  
  // Gradiente secondario
  static const List<Color> secondaryGradient = [
    Color(0xFF312E81), // indigo-800
    Color(0xFF1E1B4B), // indigo-900
  ];
  
  // Colori funzionali
  static const Color primary = Color(0xFF3B82F6); // blue-500
  static const Color primaryDark = Color(0xFF1D4ED8); // blue-700
  static const Color secondary = Color(0xFF8B5CF6); // violet-500
  static const Color accent = Color(0xFF06B6D4); // cyan-500
  
  // Colori di stato
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6); // blue-500
  
  // Colori del testo
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE2E8F0); // slate-200
  static const Color textTertiary = Color(0xFF94A3B8); // slate-400
  static const Color textDisabled = Color(0xFF64748B); // slate-500
  
  // Colori di background per card e superfici
  static Color cardBackground = Colors.grey.shade900.withOpacity(0.7);
  static Color cardBackgroundSecondary = Colors.grey.shade800.withOpacity(0.5);
  static Color surfaceOverlay = Colors.black.withOpacity(0.3);
  
  // ========== DIMENSIONI ==========
  
  // Padding e margini standard
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCircle = 50.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
  
  // ========== TYPOGRAPHY ==========
  
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textTertiary,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    height: 1.3,
  );
  
  // ========== SHADOWS ==========
  
  static List<BoxShadow> shadowS = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowM = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowL = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Shadow colorati per elementi speciali
  static List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];
  
  static List<BoxShadow> glowSuccess = [
    BoxShadow(
      color: success.withOpacity(0.3),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];
  
  static List<BoxShadow> glowWarning = [
    BoxShadow(
      color: warning.withOpacity(0.3),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];
  
  // ========== DECORAZIONI CONTAINER ==========
  
  static BoxDecoration primaryCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [primary.withOpacity(0.1), primaryDark.withOpacity(0.05)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radiusM),
    border: Border.all(color: primary.withOpacity(0.2), width: 1),
    boxShadow: glowPrimary,
  );
  
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusM),
    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
    boxShadow: shadowM,
  );
  
  static BoxDecoration surfaceDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: secondaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: shadowL,
  );
  
  // ========== BUTTON STYLES ==========
  
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textPrimary,
    padding: const EdgeInsets.symmetric(horizontal: paddingL, vertical: paddingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    elevation: elevationM,
    shadowColor: primary.withOpacity(0.3),
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: primary,
    padding: const EdgeInsets.symmetric(horizontal: paddingL, vertical: paddingM),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
      side: BorderSide(color: primary, width: 1.5),
    ),
    elevation: 0,
  );
  
  static ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: success,
    foregroundColor: textPrimary,
    padding: const EdgeInsets.symmetric(horizontal: paddingL, vertical: paddingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    elevation: elevationM,
    shadowColor: success.withOpacity(0.3),
  );
  
  static ButtonStyle warningButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: warning,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: paddingL, vertical: paddingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    elevation: elevationM,
    shadowColor: warning.withOpacity(0.3),
  );
  
  static ButtonStyle errorButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: error,
    foregroundColor: textPrimary,
    padding: const EdgeInsets.symmetric(horizontal: paddingL, vertical: paddingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    elevation: elevationM,
    shadowColor: error.withOpacity(0.3),
  );
  
  // ========== INPUT DECORATION ==========
  
  static InputDecoration inputDecoration({
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Widget? suffixWidget,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium.copyWith(color: textTertiary),
      prefixIcon: prefixIcon != null 
        ? Icon(prefixIcon, color: textTertiary) 
        : null,
      suffixIcon: suffixIcon != null 
        ? Icon(suffixIcon, color: textTertiary) 
        : suffixWidget,
      filled: true,
      fillColor: cardBackgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingM,
        vertical: paddingM,
      ),
    );
  }
  
  // ========== GRADIENTS ==========
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: primaryGradient,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: secondaryGradient,
  );
  
  static LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, success.withOpacity(0.8)],
  );
  
  static LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, warning.withOpacity(0.8)],
  );
  
  static LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, error.withOpacity(0.8)],
  );
  
  // ========== ICONE CON COLORI FUNZIONALI ==========
  
  static Icon primaryIcon(IconData icon, {double? size}) => Icon(
    icon,
    color: primary,
    size: size ?? 24,
  );
  
  static Icon successIcon(IconData icon, {double? size}) => Icon(
    icon,
    color: success,
    size: size ?? 24,
  );
  
  static Icon warningIcon(IconData icon, {double? size}) => Icon(
    icon,
    color: warning,
    size: size ?? 24,
  );
  
  static Icon errorIcon(IconData icon, {double? size}) => Icon(
    icon,
    color: error,
    size: size ?? 24,
  );
  
  static Icon secondaryIcon(IconData icon, {double? size}) => Icon(
    icon,
    color: secondary,
    size: size ?? 24,
  );
  
  // ========== HELPER METHODS ==========
  
  /// Crea un container con background e decorazione standard
  static Container standardContainer({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Gradient? gradient,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(paddingM),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? cardBackground,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
        boxShadow: boxShadow ?? shadowM,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
  
  /// Crea una card standard dell'app
  static Container standardCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    bool hasPrimaryAccent = false,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(paddingM),
      margin: margin ?? const EdgeInsets.only(bottom: paddingM),
      decoration: hasPrimaryAccent ? primaryCardDecoration : cardDecoration,
      child: child,
    );
  }
  
  /// Crea un header standard per le pagine
  static Widget standardHeader({
    required String title,
    String? subtitle,
    List<Widget>? actions,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(paddingL),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(paddingS),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(radiusS),
              ),
              child: Icon(icon, color: primary, size: 24),
            ),
            const SizedBox(width: paddingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: headingLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: paddingXS),
                  Text(subtitle, style: bodyMedium),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions,
        ],
      ),
    );
  }
}
