import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';

/// Splash Screen designed from the design tokens and layout specifications.
/// Features ambient atmospheric blur glows, central branding badge with accent dot,
/// animated progress bar with shine gradient, and footer branding anchor.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.95, curve: Curves.easeInOutCubic),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Navigate to registration screen until onboarding screen is made
        context.go(RouteNames.register);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sizing tokens derived from 8pt grid
    final double logoCardSize = AppSpacing.space8 * 3; // 96px
    final double glowCircleSize = AppSpacing.space8 * 12; // 384px
    final double glowOffset = -(AppSpacing.space8 * 3); // -96px
    final double badgeSize = AppSpacing.space6; // 24px

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==========================================
          // 1. AMBIENT BACKGROUND GLOWS (Blur spheres)
          // ==========================================

          // Top-right Orange Ambient Glow
          Positioned(
            top: glowOffset,
            right: glowOffset,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: AppSpacing.space8, // 32px blur
                  sigmaY: AppSpacing.space8,
                ),
                child: Container(
                  width: glowCircleSize,
                  height: glowCircleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orange500.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),

          // Bottom-left Blue Ambient Glow
          Positioned(
            bottom: glowOffset,
            left: glowOffset,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: AppSpacing.space8, // 32px blur
                  sigmaY: AppSpacing.space8,
                ),
                child: Container(
                  width: glowCircleSize,
                  height: glowCircleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.navy700.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. CENTRAL BRANDING SECTION
          // ==========================================
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Card with Orange Corner Accent
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // White Rounded Logo Box
                      Container(
                        width: logoCardSize,
                        height: logoCardSize,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: AppRadius.roundedXl,
                          border: Border.all(
                            color: AppColors.borderVariant,
                            width: 1,
                          ),
                          boxShadow: AppElevation.elevation2,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondAccent.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: AppRadius.roundedXl,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              AppIcons.menuBookSvg,
                              width: 44,
                              height: 32,
                              colorFilter: const ColorFilter.mode(
                                AppColors.secondAccent,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Subtle Orange Accent Corner Dot
                      Positioned(
                        top: -(AppSpacing.space1 + 3.0), // -7px
                        right: -(AppSpacing.space1 + 3.0),
                        child: Container(
                          width: badgeSize,
                          height: badgeSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.orange500,
                            border: Border.all(
                              color: AppColors.surfaceWhite,
                              width: AppSpacing.space1, // 4px white border
                            ),
                            boxShadow: AppElevation.elevation1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.vGap8, // 32px margin
                  // Brand Title
                  Text(
                    AppConstants.appName,
                    style: AppTypography.displayLg.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: -0.7,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.vGap2, // 8px margin
                  // Brand Subtitle / Tagline
                  Text(
                    'Empowering Next-Gen Learning',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 3. LOADING PROGRESS AREA (Bottom)
          // ==========================================
          Positioned(
            left: AppSpacing.space8,
            right: AppSpacing.space8,
            bottom: AppSpacing.space8 + AppSpacing.space4, // 48px
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Progress Bar Track
                Container(
                  width: AppSpacing.space8 * 9, // 288px
                  height: AppSpacing.space2, // 8px height
                  decoration: BoxDecoration(
                    color: AppColors.borderVariant,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.xl2),
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value.clamp(0.05, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.orange500,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppRadius.xl2),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.orange500,
                                AppColors.orange600,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                AppSpacing.vGap2, // 8px margin
                // Status Indicator Text
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    final percentage = (_progressAnimation.value * 100).toInt();
                    return Text(
                      percentage < 100
                          ? 'LOADING EXPERIENCE ($percentage%)...'
                          : 'READY',
                      style: AppTypography.labelSm.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ==========================================
          // 4. FOOTER BRAND ANCHOR (Very Bottom)
          // ==========================================
          Positioned(
            left: AppSpacing.space4,
            right: AppSpacing.space4,
            bottom: AppSpacing.space2 + 4, // 12px
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Kuta Learning',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space1,
                  ),
                  child: Container(
                    width: AppSpacing.space1, // 4px dot
                    height: AppSpacing.space1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  'v${AppConstants.appVersion}',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
