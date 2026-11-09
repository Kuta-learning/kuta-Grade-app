import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design system typography tokens extracted from the typography scale specifications.
///
/// Fonts are bundled locally (see `pubspec.yaml`), so no text style in this
/// layer fetches fonts from the network. Supported families:
/// - Poppins (Titles & Headings)
/// - Open Sans (Body, Labels, Captions & UI text)
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // ==========================================
  // FONT FAMILIES
  // ==========================================
  static const String fontFamilyPoppins = 'Poppins';
  static const String fontFamilyOpenSans = 'Open Sans';

  // ==========================================
  // 1. MOBILE TYPE SCALE (Primary / Mobile App)
  // ==========================================

  /// display-lg (Mobile: 28px / 36px line height, Bold 700)
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamilyPoppins,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// headline-md (Mobile: 20px / 28px line height, Medium 500) - Auth/Modal Headings
  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamilyPoppins,
    fontSize: 20,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// headline-lg (Mobile: 22px / 28px line height, Bold 700)
  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamilyPoppins,
    fontSize: 22,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// body-xl (Mobile: 16px / 24px line height, Regular 400) - Subtitles & form inputs
  static const TextStyle bodyXl = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// title-md (Mobile: 16px / 22px line height, SemiBold 600)
  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamilyPoppins,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// body-lg (Mobile: 15px / 22px line height, Regular 400)
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// subtitle-lg (Mobile: 18px / 28px line height, Regular 400) - Profile subtitles
  static const TextStyle subtitleLg = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// stat-value (Mobile: 32px / 40px line height, SemiBold 600) - Profile metric values
  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// label-md (Mobile: 14px / 20px line height, SemiBold 600) - Form labels & buttons
  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// body-md (Mobile: 14px / 20px line height, Regular 400)
  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// body-md medium (Mobile: 14px / 20px line height, Medium 500)
  static const TextStyle bodyMdMedium = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// label-md medium (Mobile: 12px / 16px line height, Medium 500) - Auth hints & dividers
  static const TextStyle labelMdMedium = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// label-md semibold (Mobile: 12px / 16px line height, SemiBold 600) - Link buttons
  static const TextStyle labelMdSemiBold = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: AppColors.brandBlue,
  );

  /// label-sm (Mobile: 11px / 14px line height, SemiBold 600)
  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// caption-sm (Mobile: 10px / 15px line height, Regular 400) - Helper text
  static const TextStyle captionSm = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 10,
    height: 15 / 10,
    fontWeight: FontWeight.w400,
    color: AppColors.authBrown,
  );

  /// caption-bold (Mobile: 10px / 15px line height, Bold 700) - Badges & security marks
  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 10,
    height: 15 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  // ==========================================
  // 2. DESKTOP TYPE SCALE
  // ==========================================

  /// display-lg (Desktop: 36px / 44px line height, Bold 700)
  static const TextStyle displayLgDesktop = TextStyle(
    fontFamily: fontFamilyPoppins,
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// headline-lg (Desktop: 24px / 32px line height, Bold 700)
  static const TextStyle headlineLgDesktop = TextStyle(
    fontFamily: fontFamilyPoppins,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// title-md (Desktop: 18px / 24px line height, SemiBold 600)
  static const TextStyle titleMdDesktop = TextStyle(
    fontFamily: fontFamilyPoppins,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// body-lg (Desktop: 16px / 24px line height, Regular 400)
  static const TextStyle bodyLgDesktop = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// body-md (Desktop: 14px / 20px line height, Regular 400)
  static const TextStyle bodyMdDesktop = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// label-sm (Desktop: 12px / 16px line height, SemiBold 600)
  static const TextStyle labelSmDesktop = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // ==========================================
  // 3. BACKWARD COMPATIBILITY ALIASES
  // ==========================================
  static const TextStyle heading1 = displayLg;
  static const TextStyle heading2 = headlineLg;
  static const TextStyle body = bodyMd;
  static const TextStyle caption = labelSm;
}
