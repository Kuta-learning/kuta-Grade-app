import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';

/// Onboarding screen displaying key product highlights matching the reference design.
/// Features a soft ambient background, elevated landscape illustration with floating icons,
/// centered typography, responsive pagination dots, and primary CTA.
class OnboardingScreen extends StatefulWidget {
  final int initialPage;

  const OnboardingScreen({
    super.key,
    this.initialPage = 0,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late int _currentPage;

  late final List<_OnboardingPageData> _pages;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);

    _pages = [
      // Slide 1: Excel in Your Exams
      _OnboardingPageData(
        title: 'Excel in Your Exams',
        description:
            'Personalized learning paths for Grade 6 to 8. Master complex topics with interactive practice and expert guidance.',
        imageAsset: AssetConstants.onboardingImage1,
        topBadge: _OnboardingBadge(
          child: SvgPicture.asset(
            AppIcons.calculationSvg,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF9D4300), // Terracotta brown math icon
              BlendMode.srcIn,
            ),
          ),
        ),
        bottomBadge: _OnboardingBadge(
          child: SvgPicture.asset(
            AppIcons.greenMenuSvg,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF006E2F), // Emerald green open book icon
              BlendMode.srcIn,
            ),
          ),
        ),
      ),

      // Slide 2: Learn at Your Pace
      _OnboardingPageData(
        title: 'Learn at Your Pace',
        description:
            'Interactive lessons with videos, audio and quizzes designed to keep you engaged and motivated every day.',
        imageAsset: AssetConstants.onboardingImage2,
        topBadge: _OnboardingBadge(
          child: SvgPicture.asset(
            AppIcons.quizSvg,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF2563EB), // Interactive quiz blue
              BlendMode.srcIn,
            ),
          ),
        ),
        bottomBadge: const _OnboardingBadge(
          child: Icon(
            Icons.headphones_rounded,
            color: Color(0xFF0D9488), // Audio lessons teal
            size: 26,
          ),
        ),
      ),

      // Slide 3: Track Your Progress
      _OnboardingPageData(
        title: 'Track Your Progress',
        description:
            'See how far you\'ve come. Complete lessons, earn badges and show your achievements to the world!',
        imageAsset: AssetConstants.onboardingImage3,
        topBadge: _OnboardingBadge(
          child: SvgPicture.asset(
            AppIcons.militaryTechSvg,
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              Color(0xFFD97706), // Milestone badge amber/gold
              BlendMode.srcIn,
            ),
          ),
        ),
        bottomBadge: _OnboardingBadge(
          child: SvgPicture.asset(
            AppIcons.analyticsSvg,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF4F46E5), // Progress analytics indigo
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToRegister();
    }
  }

  Future<void> _navigateToRegister() async {
    // Record in local storage that onboarding has been completed
    final storage = await SharedPrefsStorage.getInstance();
    await storage.setBool(StorageKeys.hasSeenOnboarding, value: true);

    if (mounted) {
      context.go(RouteNames.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Soft Warm Ambient Glow (Top-Right)
          Positioned(
            top: -60,
            right: -60,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.45,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFDBCA),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Onboarding Content (Safe Area)
          SafeArea(
            child: Column(
              children: [
                // Scrollable Page Content Area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _pages[index];

                      return Center(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space6,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Centered Landscape Illustration with Floating Badges
                                _OnboardingCard(item: item),

                                AppSpacing.vGap8, // 32px matching splash_screen exactly

                                // Heading Text
                                Text(
                                  item.title,
                                  style: AppTypography.displayLg.copyWith(
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.7,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                AppSpacing.vGap2, // 8px matching splash_screen exactly

                                // Subtitle / Body Description
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: Text(
                                    item.description,
                                    style: AppTypography.bodyLg.copyWith(
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 3. Functional Pagination Dots
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.space2,
                    bottom: AppSpacing.space6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final bool isActive = index == _currentPage;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3.5,
                            vertical: 8.0,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            width: isActive ? 26.0 : 7.5,
                            height: 7.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: isActive
                                  ? const Color(0xFF9D4300)
                                  : const Color(0xFFD6CDC6),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 4. Primary Bottom CTA Button: "Get Started ->"
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space6,
                    0,
                    AppSpacing.space6,
                    AppSpacing.space8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(29.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF97316).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage < _pages.length - 1
                                  ? 'Next'
                                  : 'Get Started',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
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

/// Onboarding page content data container.
class _OnboardingPageData {
  final String title;
  final String description;
  final String imageAsset;
  final Widget topBadge;
  final Widget bottomBadge;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.topBadge,
    required this.bottomBadge,
  });
}

/// Central illustration card with soft circular backdrop shadow, blue glow, and floating corner badges.
class _OnboardingCard extends StatelessWidget {
  final _OnboardingPageData item;

  const _OnboardingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive width clamped between 280 and 340
    final cardWidth = (screenWidth - 48).clamp(280.0, 340.0);
    // Natural aspect ratio for 512x279 landscape illustrations (approx 1.835)
    final cardHeight = cardWidth / 1.835;

    return Center(
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Soft Blue Ambient Glow behind illustration
            Positioned.fill(
              child: Center(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
                  child: Container(
                    width: cardWidth * 0.95,
                    height: cardHeight * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF81AEFF).withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Diffused Dark Radial Shadow behind illustration
            Positioned.fill(
              child: Center(
                child: Container(
                  width: cardWidth * 0.85,
                  height: cardHeight * 1.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.16),
                        blurRadius: 45,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Crisp landscape illustration image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE8F1FC),
                    child: Center(
                      child: Icon(
                        Icons.school_outlined,
                        size: 56,
                        color: AppColors.navy700.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Floating Top-Right Badge (positioned above the card top, indented from right)
            Positioned(
              top: -36.0,
              right: 28.0,
              child: item.topBadge,
            ),

            // 5. Floating Bottom-Left Badge (overlapping bottom-left corner)
            Positioned(
              bottom: -22.0,
              left: 6.0,
              child: item.bottomBadge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating badge matching the reference design: pure white, smooth rounded corners, soft drop shadow.
class _OnboardingBadge extends StatelessWidget {
  final Widget child;

  const _OnboardingBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.0,
      height: 52.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
