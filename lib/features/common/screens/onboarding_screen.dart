import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';

/// Onboarding screen displaying key product highlights matching the reference design.
/// Features a soft ambient background, elevated square illustration cards,
/// centered typography, responsive pagination dots, and primary CTA.
class OnboardingScreen extends StatefulWidget {
  final int initialPage;

  const OnboardingScreen({super.key, this.initialPage = 0});

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
      ),

      // Slide 2: Learn at Your Pace
      _OnboardingPageData(
        title: 'Learn at Your Pace',
        description:
            'Interactive lessons with videos, audio and quizzes designed to keep you engaged and motivated every day.',
        imageAsset: AssetConstants.onboardingImage2,
      ),

      // Slide 3: Track Your Progress
      _OnboardingPageData(
        title: 'Track Your Progress',
        description:
            'See how far you\'ve come. Complete lessons, earn badges and show your achievements to the world!',
        imageAsset: AssetConstants.onboardingImage3,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all onboarding images at the target decode resolution (1080px)
    // so Flutter never has to decode a full 6000x6000 image on-demand.
    for (final page in _pages) {
      precacheImage(
        ResizeImage(AssetImage(page.imageAsset), width: 1080),
        context,
      );
    }
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Row: Back Arrow (left) + Skip (right) ──
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 4.0,
                right: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow – visible on slides 2 and 3
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF9D4300),
                        size: 24.0,
                      ),
                      tooltip: 'Back',
                      padding: const EdgeInsets.all(8.0),
                    )
                  else
                    const SizedBox(
                      width: 48.0,
                    ), // placeholder to keep Skip aligned
                  // Skip Button – hidden on last slide
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _navigateToRegister,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF9D4300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: AppTypography.labelMdSemiBold.copyWith(
                          fontSize: 14.5,
                          letterSpacing: 0.2,
                          color: AppColors.orange900,
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 48.0,
                    ), // reserve space so layout is stable
                ],
              ),
            ),

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
                            // Square illustration card – no shadow, no badges
                            _OnboardingCard(item: item),

                            AppSpacing.vGap8, // 32px
                            // Heading Text
                            Text(
                              item.title,
                              style: AppTypography.displayLg.copyWith(
                                fontSize: 32,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.7,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            AppSpacing.vGap2, // 8px
                            // Subtitle / Body Description
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 320,
                              ),
                              child: Text(
                                item.description,
                                style: AppTypography.bodyLg.copyWith(
                                  fontSize: 17,
                                  height: 1.55,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.3,
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

            // Functional Pagination Dots
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

            // Primary Bottom CTA Button: "Get Started ->"
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
                        color: const Color(
                          0xFFF97316,
                        ).withValues(alpha: 0.35),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage < _pages.length - 1
                              ? 'Next'
                              : 'Get Started',
                          style: AppTypography.headlineLg.copyWith(
                            color: Colors.white,
                            fontSize: 17.5,
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
    );
  }
}

/// Onboarding page content data container.
class _OnboardingPageData {
  final String title;
  final String description;
  final String imageAsset;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

/// Square illustration card — clean image display, no shadows, no floating badges.
class _OnboardingCard extends StatelessWidget {
  final _OnboardingPageData item;

  const _OnboardingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive width clamped between 280 and 360
    final cardWidth = (screenWidth - 48).clamp(280.0, 360.0);
    // Images are square (6000x6000), so height == width (1:1 ratio)
    final cardHeight = cardWidth;

    return Center(
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            item.imageAsset,
            fit: BoxFit.contain,
            // Decode at 1080px max — matches a 360px card at 3× density.
            // Avoids decoding the full 6000x6000 source, cutting load time dramatically.
            cacheWidth: 1080,
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
    );
  }
}
