import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import 'coach_mark_step.dart';

/// One-time dashboard intro tour ("coach marks").
///
/// Shows a dark, blurred scrim with a glowing rounded-rect spotlight hole
/// over each navigation item, plus a coach card with step dots, a Skip action
/// and a Next / Get Started button. Dashboard input is blocked (the dialog
/// route is not dismissible) until the user finishes or skips the tour.
class DashboardIntroOverlay extends StatefulWidget {
  /// Ordered steps to walk through.
  final List<CoachMarkStep> steps;

  /// Called once, when the tour finishes (last step) or is skipped.
  final VoidCallback onComplete;

  const DashboardIntroOverlay({super.key, required this.steps, required this.onComplete});

  /// The shared global keys for the 4 bottom-nav tabs, in the order the tour
  /// should visit them. Provided by [GradeBottomNavBar.itemKeys].
  static List<CoachMarkStep> defaultSteps(List<GlobalKey> navItemKeys) => [
        const CoachMarkStep(
          title: 'Welcome to Kuta!',
          body:
              'A quick 4-stop tour of your dashboard. Use Next to move along, '
              'or Skip if you prefer to explore on your own.',
        ),
        CoachMarkStep(
          title: 'Exams',
          body:
              'Start here for national exam simulators, past papers and '
              'bookmarked questions.',
          targetKey: navItemKeys[0],
        ),
        CoachMarkStep(
          title: 'Notes',
          body: 'Short notes and chapter lessons for every high-school subject.',
          targetKey: navItemKeys[1],
        ),
        CoachMarkStep(
          title: 'Practice',
          body: 'Practice courses and chapter-by-chapter study sessions.',
          targetKey: navItemKeys[2],
        ),
        CoachMarkStep(
          title: 'Profile',
          body: 'Your profile, progress stats and app settings live here.',
          targetKey: navItemKeys[3],
        ),
      ];

  @override
  State<DashboardIntroOverlay> createState() => _DashboardIntroOverlayState();
}

class _DashboardIntroOverlayState extends State<DashboardIntroOverlay>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_index >= widget.steps.length - 1) {
      widget.onComplete();
      return;
    }
    setState(() => _index++);
    _controller.forward(from: 0);
  }

  void _skip() => widget.onComplete();

  bool get _isWelcomeStep => widget.steps[_index].targetKey == null;
  bool get _isLastStep => _index == widget.steps.length - 1;

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final step = steps[_index];
    final screen = MediaQuery.of(context).size;
    final hole = step.targetRect();

    return Material(
      type: MaterialType.transparency,
      child: Stack(children: [
        // 1. Dark blurred scrim, clipped so the spotlight hole stays sharp.
        if (hole != null)
          Positioned.fill(
            child: ClipPath(
              clipper: _SpotlightClipper(hole: hole, screen: screen),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: const ColoredBox(color: Colors.black54),
              ),
            ),
          )
        else
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const ColoredBox(color: Colors.black54),
            ),
          ),

        // 2. Glowing border around the spotlight hole.
        if (hole != null)
          Positioned.fill(
            child: CustomPaint(
              painter: _SpotlightBorderPainter(hole: hole),
              size: screen,
            ),
          ),

        // 3. Coach card (animated fade + slide per step).
        Positioned(
          left: AppSpacing.space6,
          right: AppSpacing.space6,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: _CoachCard(
                title: step.title,
                body: step.body,
                stepCount: steps.length,
                currentStep: _index,
                isWelcome: _isWelcomeStep,
                isLast: _isLastStep,
                bottomAligned: hole != null,
                holeBottom: hole?.bottom ?? 0,
                onNext: _goNext,
                onSkip: _skip,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Clips out the rounded-rect spotlight hole from the fullscreen scrim.
class _SpotlightClipper extends CustomClipper<Path> {
  final Rect hole;
  final Size screen;

  const _SpotlightClipper({required this.hole, required this.screen});

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Offset.zero & size);
    return Path.combine(
      PathOperation.difference,
      path,
      _holePath(),
    );
  }

  Path _holePath() =>
      Path()..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(16)));

  @override
  bool shouldReclip(_SpotlightClipper old) => old.hole != hole || old.screen != screen;
}

/// Soft white glow + crisp border drawn around the spotlight hole.
class _SpotlightBorderPainter extends CustomPainter {
  final Rect hole;

  const _SpotlightBorderPainter({required this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(hole, const Radius.circular(16));

    // Soft outer glow.
    canvas.drawRRect(
      rrect.inflate(6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Crisp highlight line.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightBorderPainter old) => old.hole != hole;
}

/// The floating coach card: title, description, step dots, Skip + Next.
class _CoachCard extends StatelessWidget {
  final String title;
  final String body;
  final int stepCount;
  final int currentStep;
  final bool isWelcome;
  final bool isLast;

  /// When true the card sits above the spotlight hole (bottom-aligned hole),
  /// otherwise it is centered on screen (welcome step).
  final bool bottomAligned;
  final double holeBottom;

  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CoachCard({
    required this.title,
    required this.body,
    required this.stepCount,
    required this.currentStep,
    required this.isWelcome,
    required this.isLast,
    required this.bottomAligned,
    required this.holeBottom,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final cardHeightEstimate = 210.0;

    // Anchor: above the hole for targeted steps; vertically centered for the
    // welcome step; fall back to below-center when the hole is too high.
    double top;
    if (!bottomAligned) {
      top = (screen.height - cardHeightEstimate) / 2;
    } else {
      final above = holeBottom - cardHeightEstimate - AppSpacing.space6;
      top = above > AppSpacing.space8 ? above : holeBottom + AppSpacing.space6;
      if (top + cardHeightEstimate > screen.height - AppSpacing.space4) {
        top = screen.height - cardHeightEstimate - AppSpacing.space4;
      }
    }

    return Container(
      margin: EdgeInsets.only(top: top),
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.rounded2Xl,
        boxShadow: AppElevation.modalDialog,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineMd.copyWith(color: AppColors.textPrimary),
          ),
          AppSpacing.vGap2,
          Text(
            body,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textSecondary,
              height: 20 / 14,
            ),
          ),
          AppSpacing.vGap6,
          Row(
            children: [
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              // Step dots.
              ...List.generate(stepCount, (i) {
                final active = i == currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.s1),
                  width: active ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.accent
                        : AppColors.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              AppSpacing.hGap4,
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.s2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
                ),
                onPressed: onNext,
                child: Text(
                  isLast ? 'Get Started' : 'Next',
                  style: AppTypography.labelMd.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
