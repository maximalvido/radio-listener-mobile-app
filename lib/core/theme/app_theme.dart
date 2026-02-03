import 'package:flutter/material.dart';
import 'package:radio_player/core/theme/border_radius.dart';
import 'package:radio_player/core/theme/colors.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryPurple = AppColors.primaryPurple;
  static const Color backgroundDark = AppColors.backgroundDark;
  static const Color surfaceDark = AppColors.surfaceDark;
  static const Color cardBackground = AppColors.cardBackground;
  static const Color accentPurple = AppColors.accentPurple;
  static const Color liveRed = AppColors.liveRed;

  static const TextStyle _appBarTitleStyle = TextStyle(
    color: AppColors.onSurface,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.onSurface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: _appBarTitleStyle,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusCard),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.onSurfaceSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardBackground,
        contentTextStyle: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
