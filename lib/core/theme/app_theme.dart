import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// خط العرض العربي — اضبطه إلى 'Amiri' بعد إضافة الخط إلى fonts/
  static const String? displayFont = null;
  static const String? ayahFont = null; // 'KFGQPC_Uthmanic_Script' للإنتاج

  static bool isDark(ThemeData t) => t.brightness == Brightness.dark;

  static ThemeData light() => _base(
        bg: AppColors.paper,
        card: AppColors.paperCard,
        ink: AppColors.ink,
        muted: AppColors.muted,
        accent: AppColors.emerald,
        gold: AppColors.gold,
        dark: false,
      );

  static ThemeData dark() => _base(
        bg: AppColors.oledBlack,
        card: AppColors.darkCard,
        ink: AppColors.darkInk,
        muted: AppColors.darkMuted,
        accent: AppColors.darkEmerald,
        gold: AppColors.darkGold,
        dark: true,
      );

  static ThemeData _base({
    required Color bg,
    required Color card,
    required Color ink,
    required Color muted,
    required Color accent,
    required Color gold,
    required bool dark,
  }) {
    final scheme = ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: accent,
      secondary: gold,
      surface: card,
      error: AppColors.danger,
      onPrimary: dark ? Colors.black : Colors.white,
      onSecondary: ink,
      onSurface: ink,
      onError: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      cardColor: card,
      dividerColor: muted.withOpacity(0.3),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontSize: 36, fontWeight: FontWeight.bold, color: ink,
            fontFamily: displayFont, height: 1.5),
        headlineMedium: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: ink,
            fontFamily: displayFont, height: 1.5),
        titleLarge: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: ink,
            fontFamily: displayFont, height: 1.5),
        bodyLarge: TextStyle(fontSize: 16, color: ink, height: 1.8),
        bodyMedium: TextStyle(fontSize: 14, color: muted, height: 1.7),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: ink,
            fontFamily: displayFont),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent, elevation: 0),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(color: ink),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
