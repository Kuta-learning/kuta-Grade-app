import 'dart:math' as math;
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
    with TickerProviderStateMixin {
  int _index = 0;
  late AnimationController _controller;
  late AnimationController _dashController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final GlobalKey _cardKey = GlobalKey(debugLabel: 'introCoachCard');
  Rect? _cardRect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward().whenComplete(_measureCard);

    // Drives the flowing dashes of the connector line.
    _dashController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
    WidgetsBinding.instance.addPostFrameCallback(_measureCard);
  }

  @override
  void dispose() {
    _controller.dispose();
    _dashController.dispose();
    super.dispose();
  }

  /// Resolves the coach card's final on-screen rect (after the entrance
  /// animation settles) so the connector line can start from its edge.
  void _measureCard([_]) {
    final box = _cardKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (mounted && _cardRect != rect) {
      setState(() => _cardRect = rect);
    }
  }

  void _goNext() {
    if (_index >= widget.steps.length - 1) {
      widget.onComplete();
      return;
    }
    setState(() => _index++);
    _controller.forward().whenComplete(_measureCard);
  }

  void _skip() => widget.onComplete();

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

        // 3. Flowing dashed connector from the card edge to the spotlight.
        if (hole != null && _cardRect != null)
          Positioned.fill(
            child: CustomPaint(
              painter: _ConnectorPainter(
                from: Offset(_cardRect!.center.dx, _cardRect!.bottom + 6),
                to: hole.center - Offset(0, hole.shortestSide / 2 + 12 + 10),
                dash: _dashController,
              ),
            ),
          ),

        // 4. Coach card, always centered on screen so the spotlight hole at
        // the nav bar stays fully visible (animated fade + slide per step).
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
            child: Center(
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: _CoachCard(
                    key: _cardKey,
                    title: step.title,
                    body: step.body,
                    stepCount: steps.length,
                    currentStep: _index,
                    isLast: _isLastStep,
                    onNext: _goNext,
                    onSkip: _skip,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Clips a circular spotlight hole out of the fullscreen scrim.
/// The circle is centered on the target rect (the nav item icon) with a
/// small padding halo, so it hugs the icon instead of spanning the slot.
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
      Path()..addOval(Rect.fromCircle(center: hole.center, radius: _radius));

  double get _radius => hole.shortestSide / 2 + 12;

  @override
  bool shouldReclip(_SpotlightClipper old) => old.hole != hole || old.screen != screen;
}

/// Soft white glow + crisp circular ring drawn around the spotlight hole.
class _SpotlightBorderPainter extends CustomPainter {
  final Rect hole;

  const _SpotlightBorderPainter({required this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final center = hole.center;
    final radius = hole.shortestSide / 2 + 12;

    // Soft outer glow.
    canvas.drawCircle(
      center,
      radius + 6,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Crisp highlight ring.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightBorderPainter old) => old.hole != hole;
}

/// Animated dashed S-curve connecting the coach card to the spotlighted
/// icon. Dashes flow toward the target ("direction" cue) and a small dot
/// marks the landing point, Driver.js / Intro.js style.
class _ConnectorPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Animation<double> dash;

  _ConnectorPainter({
    required this.from,
    required this.to,
    required this.dash,
  }) : super(repaint: dash);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx,
        from.dy + (to.dy - from.dy) * 0.45,
        to.dx,
        to.dy - (to.dy - from.dy) * 0.45,
        to.dx,
        to.dy,
      );

    // Dashes are drawn as short segments along the path (no dart:ui
    // PathEffect needed). Each cycle the start offset advances by one dash
    // period, so the pattern flows seamlessly toward the icon.
    const dashLength = 7.0;
    const period = 13.0; // dash 7 + gap 6
    final phase = dash.value * period;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      // Start one period back so the pattern stays continuous; as phase
      // advances the drawn segments move forward, i.e. toward the icon.
      double start = phase - period;
      while (start < length) {
        final segStart = math.max(start, 0.0);
        final segEnd = math.min(start + dashLength, length);
        if (segEnd > segStart) {
          canvas.drawPath(metric.extractPath(segStart, segEnd), dashPaint);
        }
        start += period;
      }
    }

    // Landing dot on the spotlight edge.
    canvas.drawCircle(
      to,
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) => old.from != from || old.to != to;
}

/// The floating coach card: title, description, step dots, Skip + Next.
/// Rendered centered on screen for every step.
class _CoachCard extends StatelessWidget {
  final String title;
  final String body;
  final int stepCount;
  final int currentStep;
  final bool isLast;

  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CoachCard({
    super.key,
    required this.title,
    required this.body,
    required this.stepCount,
    required this.currentStep,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
