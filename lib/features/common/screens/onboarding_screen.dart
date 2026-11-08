import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';

/// Onboarding screen recreated to match the reference designs exactly.
/// Features full illustration with circular backdrop, rounded bottom card container,
/// smooth animated transitions, custom pill indicator, and primary orange CTA.
class OnboardingScreen extends StatefulWidget {
  final int initialPage;

  const OnboardingScreen({super.key, this.initialPage = 0});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late int _currentPage;
  double _pageOffset = 0.0;

  late final List<_OnboardingPageData> _pages;

  // Design Tokens matching reference UI screenshots
  static const Color _bgCardColor = Color(0xFFDFDFDF); // Soft warm gray card
  static const Color _bgBottomColor = Color(0xFFEAE8EB); // Bottom area tone
  static const Color _btnColor = Color(0xFFFE5722); // Vibrant warm orange CTA
  static const Color _titleColor = Color(0xFF141414); // Near black title
  static const Color _descColor = Color(0xFF555555); // Neutral medium gray
  static const Color _activeDotColor = Color(0xFF34211A); // Dark brownish active indicator
  static const Color _inactiveDotColor = Color(0xFFB6B4B7); // Light gray inactive dot

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageOffset = widget.initialPage.toDouble();
    _pageController = PageController(initialPage: widget.initialPage)
      ..addListener(_onPageScroll);

    _pages = const [
      _OnboardingPageData(
        title: 'Excel in Your Exam',
        description:
            'Personalized learning paths for grade 6 to 8. Master complex topics with interactive practice and expert guidance',
        imageAsset: AssetConstants.onboardingImage1,
      ),
      _OnboardingPageData(
        title: 'Learn at Your Pace',
        description:
            'Interactive lessons with videos, audios and quizzes designed to keep you engaged and motivated everyday',
        imageAsset: AssetConstants.onboardingImage2,
      ),
      _OnboardingPageData(
        title: 'Track Your Progress',
        description:
            'see how far you\'ve come. Complete lessons,earn badges and show your achievement to the world!',
        imageAsset: AssetConstants.onboardingImage3,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (!mounted) return;
    final offset = _pageController.page ?? _currentPage.toDouble();
    setState(() => _pageOffset = offset);
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
    final storage = await SharedPrefsStorage.getInstance();
    await storage.setBool(StorageKeys.hasSeenOnboarding, value: true);

    if (mounted) {
      context.go(RouteNames.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _pages[_currentPage];
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive illustration sizing: scaled cleanly to fit circle + graphic
    final double illustrationSize = (screenWidth * 0.76).clamp(240.0, 340.0);

    // Screen-height based proportional spacing matching the reference screenshots
    final double cardHeight = (screenHeight * 0.774).clamp(520.0, 800.0);
    final double gapDescToCurve = (screenHeight * 0.038).clamp(24.0, 48.0);
    final double gapCurveToDots = (screenHeight * 0.075).clamp(32.0, 90.0);
    final double gapDotsToButton = (screenHeight * 0.027).clamp(16.0, 32.0);
    final double bottomMargin = (screenHeight * 0.032).clamp(18.0, 36.0);
    final double buttonHeight = (screenHeight * 0.052).clamp(48.0, 56.0);

    return Scaffold(
      backgroundColor: _bgBottomColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Upper Card Container with Rounded Bottom Corners ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: cardHeight,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _bgCardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(42.0),
                  bottomRight: Radius.circular(42.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x331E1E24),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Top Bar: Back (if not first) and Skip (if not last)
                    Positioned(
                      top: 4,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentPage > 0)
                            IconButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOutCubic,
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: _titleColor,
                              ),
                              tooltip: 'Back',
                            )
                          else
                            const SizedBox(width: 48),
                          if (_currentPage < _pages.length - 1)
                            TextButton(
                              onPressed: _navigateToRegister,
                              style: TextButton.styleFrom(
                                foregroundColor: _descColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: AppTypography.labelMdSemiBold.copyWith(
                                  color: _descColor,
                                  fontSize: 14.5,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Centered Content (Illustration PageView + Animated Text)
                    Column(
                      children: [
                        SizedBox(height: screenHeight > 700 ? 36 : 18),

                        // Image PageView with smooth parallax and natural scaling
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
                              final parallax = (index - _pageOffset) * 24.0;
                              final pageItem = _pages[index];

                              return Center(
                                child: Transform.translate(
                                  offset: Offset(parallax, 0),
                                  child: SizedBox(
                                    width: illustrationSize,
                                    height: illustrationSize,
                                    child: Image.asset(
                                      pageItem.imageAsset,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 80,
                                          color: Colors.black26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Animated Text Section (Title & Description)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.08),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            key: ValueKey<int>(_currentPage),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title (Bold, rounded sans-serif matching reference)
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.displayLg.copyWith(
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.w800,
                                    color: _titleColor,
                                    letterSpacing: -0.4,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 12.0),

                                // Subtitle / Description
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 320,
                                  ),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyLg.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      color: _descColor,
                                      height: 1.5,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                                SizedBox(height: gapDescToCurve),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Section: Indicators and Primary CTA Button ──
          Positioned(
            left: 24.0,
            right: 24.0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: gapCurveToDots),

                  // Indicator Dots (Active is elongated pill, inactive are small circles)
                  Row(
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 3.5),
                          width: isActive ? 26.0 : 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: isActive
                                ? _activeDotColor
                                : _inactiveDotColor,
                          ),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: gapDotsToButton),

                  // Primary Orange CTA Button: "Next" or "Get Started"
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _btnColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonHeight / 2),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: AppTypography.headlineLg.copyWith(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: bottomMargin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data holder for an onboarding page item.
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
