import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design system typography tokens extracted from the typography scale specifications.
/// Supported Font Families:
/// - Inter (Primary System Font - Adult / Admin)
/// - Quicksand (Kids & Youth Modules - Ages 6-10)
/// - JetBrains Mono (Data, Code & Timestamps)
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // ==========================================
  // FONT FAMILIES
  // ==========================================
  static const String fontFamilyInter = 'Inter';
  static const String fontFamilyQuicksand = 'Quicksand';
  static const String fontFamilyMono = 'JetBrains Mono';

  // ==========================================
  // 1. MOBILE TYPE SCALE (Primary / Mobile App)
  // ==========================================

  /// display-lg (Mobile: 28px / 36px line height, Bold 700)
  static final TextStyle displayLg = GoogleFonts.inter(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// headline-lg (Mobile: 20px / 28px line height, Bold 700)
  static final TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// title-md (Mobile: 16px / 22px line height, SemiBold 600)
  static final TextStyle titleMd = GoogleFonts.inter(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// body-lg (Mobile: 15px / 22px line height, Regular 400)
  static final TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// body-md (Mobile: 14px / 20px line height, Regular 400)
  static final TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// body-md medium (Mobile: 14px / 20px line height, Medium 500)
  static final TextStyle bodyMdMedium = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// label-sm (Mobile: 11px / 14px line height, SemiBold 600)
  static final TextStyle labelSm = GoogleFonts.inter(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// caption-mono (Mobile: 10px / 12px line height, JetBrains Mono 500)
  static final TextStyle captionMono = GoogleFonts.jetBrainsMono(
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ==========================================
  // 2. DESKTOP TYPE SCALE
  // ==========================================

  /// display-lg (Desktop: 36px / 44px line height, Bold 700)
  static final TextStyle displayLgDesktop = GoogleFonts.inter(
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// headline-lg (Desktop: 24px / 32px line height, Bold 700)
  static final TextStyle headlineLgDesktop = GoogleFonts.inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// title-md (Desktop: 18px / 24px line height, SemiBold 600)
  static final TextStyle titleMdDesktop = GoogleFonts.inter(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// body-lg (Desktop: 16px / 24px line height, Regular 400)
  static final TextStyle bodyLgDesktop = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// body-md (Desktop: 14px / 20px line height, Regular 400)
  static final TextStyle bodyMdDesktop = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// label-sm (Desktop: 12px / 16px line height, SemiBold 600)
  static final TextStyle labelSmDesktop = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// caption-mono (Desktop: 11px / 14px line height, JetBrains Mono 500)
  static final TextStyle captionMonoDesktop = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ==========================================
  // 3. KIDS & YOUTH MODULES (AGES 6-10) - QUICKSAND
  // ==========================================

  /// kids display-lg (Quicksand, Bold 700)
  static final TextStyle kidsDisplayLg = GoogleFonts.quicksand(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// kids headline-lg (Quicksand, Bold 700)
  static final TextStyle kidsHeadlineLg = GoogleFonts.quicksand(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// kids title-md (Quicksand, SemiBold 600)
  static final TextStyle kidsTitleMd = GoogleFonts.quicksand(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// kids body-md (Quicksand, Medium 500)
  static final TextStyle kidsBodyMd = GoogleFonts.quicksand(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ==========================================
  // 4. BACKWARD COMPATIBILITY ALIASES
  // ==========================================
  static final TextStyle heading1 = displayLg;
  static final TextStyle heading2 = headlineLg;
  static final TextStyle body = bodyMd;
  static final TextStyle caption = labelSm;
}
