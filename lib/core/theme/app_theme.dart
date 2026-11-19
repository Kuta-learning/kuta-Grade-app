import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Application ThemeData configuration.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mainPrimary,
        primary: AppColors.mainPrimary,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  AppTheme._();
}
