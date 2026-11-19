import 'package:flutter/material.dart';

/// Design system color tokens extracted from the design specifications.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ==========================================
  // 1. PRIMARY BRAND & ACCENT TONES
  // ==========================================

  /// Dark Primary (Navy 900) - Used for Admin Sidebar
  static const Color navy900 = Color(0xFF0A3366);
  static const Color darkPrimary = navy900;

  static const Color navy700 = Color(0xFF0F4C97);
  static const Color mainPrimary = navy700;
  static const Color brandPrimary = navy700;

  /// Primary Container (Navy Light 100) - Used for Active tabs
  static const Color navyLight100 = Color(0xFFE8F1FC);
  static const Color primaryContainer = navyLight100;

  /// Main Accent (Orange 500 - CTA) - Used for Primary CTAs, Buttons
  static const Color orange500 = Color(0xFFF97316);
  static const Color accent = orange500;
  static const Color mainAccent = orange500;

  /// Accent Hover (Orange 600) - Used for Hover & Pressed states
  static const Color orange600 = Color(0xFFEA580C);
  static const Color accentHover = orange600;

  /// Accent Light (Orange 50) - Used for Pills, badges, alerts
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color accentLight = orange50;

  /// Second Accent (Deep Terracotta / Orange 900) - Used for Brand Logo Marks (#9D4300)
  static const Color orange900 = Color(0xFF9D4300);
  static const Color secondAccent = orange900;
  static const Color accentDark = orange900;

  /// Brand Blue (Heading & Links) - Used for Auth titles and link text (#2A5DA9)
  static const Color brandBlue = Color(0xFF2A5DA9);

  /// Atmospheric Glow Blue - Used for background atmospheric blur (#81AEFF)
  static const Color glowBlue = Color(0xFF81AEFF);

  /// Auth Warm Brown - Used for form labels, subtitles, helper text (#584237)
  static const Color authBrown = Color(0xFF584237);

  /// Auth Icon Brown - Used for input prefix icons (#8C7164)
  static const Color authIconBrown = Color(0xFF8C7164);

  /// Button Text Dark Brown - Used for CTA text on orange buttons (#582200)
  static const Color buttonTextBrown = Color(0xFF582200);

  /// Input Container Fill (#F2F4F6)
  static const Color inputFill = Color(0xFFF2F4F6);

  /// Input Placeholder Gray (#6B7280)
  static const Color inputPlaceholder = Color(0xFF6B7280);

  /// Headline Dark (#191C1E) - Used for primary auth headings
  static const Color headlineDark = Color(0xFF191C1E);

  // ==========================================
  // 2. SYSTEM FUNCTIONAL & FEEDBACK STATES
  // ==========================================

  /// Success / Online (bg-emerald-500) - Used for Approved & Online status
  static const Color success = Color(0xFF10B981);
  static const Color online = success;
  static const Color emerald500 = success;

  /// Warning / Alert (bg-amber-500) - Used for Pending review & Warning alerts
  static const Color warning = Color(0xFFF59E0B);
  static const Color alert = warning;
  static const Color amber500 = warning;

  /// Danger / Rejected (bg-rose-500) - Used for Suspended & Error states
  static const Color danger = Color(0xFFEF4444);
  static const Color error = danger;
  static const Color rejected = danger;
  static const Color rose500 = danger;

  /// Information (bg-sky-600) - Used for System notice & Info badges
  static const Color info = Color(0xFF0284C7);
  static const Color sky600 = info;

  // ==========================================
  // 3. NEUTRAL & SURFACE CONTAINER RAMP
  // ==========================================

  /// Surface White - Used for Card background
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surface = surfaceWhite;

  /// Surface App - Used for Canvas & Page backdrop
  static const Color surfaceApp = Color(0xFFF8FAFC);
  static const Color background = surfaceApp;

  /// Container High - Used for Input fills & headers
  static const Color containerHigh = Color(0xFFF1F5F9);

  /// Border Variant - Used for Dividers & stroke
  static const Color borderVariant = Color(0xFFE2E8F0);
  static const Color border = borderVariant;

  /// Text Secondary - Used for Labels, subtitles, hints
  static const Color textSecondary = Color(0xFF64748B);

  /// Text Primary - Used for Titles, body, high-contrast
  static const Color textPrimary = Color(0xFF0F172A);

  // ==========================================
  // 4. KINDERGARTEN SPECIFIC ACCENT COLORS (Optional)
  // ==========================================
  static const Color kgYellow = Color(0xFFFFD166);
  static const Color kgPink = Color(0xFFEF476F);
  static const Color kgGreen = Color(0xFF06D6A0);
}
