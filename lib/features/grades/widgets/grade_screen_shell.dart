import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';

/// Reusable App Bar for Grade screens matching the Figma reference design.
/// Includes back navigation, screen title, bookmark action, and student profile avatar.
class GradeExamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onProfilePressed;
  final List<Widget>? actions;

  const GradeExamAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.onBookmarkPressed,
    this.onProfilePressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              splashRadius: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Back',
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('${RouteNames.gradeSelection}?step=2');
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null)
            ...actions!
          else ...[
            IconButton(
              icon: const Icon(
                Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 23,
              ),
              splashRadius: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Saved Bookmarks',
              onPressed: () {
                if (onBookmarkPressed != null) {
                  onBookmarkPressed!();
                } else {
                  context.push(RouteNames.bookmarks);
                }
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondAccent,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              splashRadius: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              tooltip: 'My Profile',
              onPressed: () {
                if (onProfilePressed != null) {
                  onProfilePressed!();
                } else {
                  context.go(RouteNames.profile);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Common bottom navigation bar matching the premium Figma reference design.
/// Displays the 4 app tabs: Exams, Notes, Practice, Profile.
/// Active item is highlighted with a vibrant orange capsule pill (#FF6A00),
/// with white icon and white label.
/// Animated floating-circle bottom navigation bar with continuous concave scooped background.
/// Features a floating active circular indicator in Kuta orange, smooth Bézier concave notch,
/// spring-based horizontal transitions, and clean icon-only layout.
class GradeBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const GradeBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  State<GradeBottomNavBar> createState() => _GradeBottomNavBarState();
}

class _GradeBottomNavBarState extends State<GradeBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _fromIndex = 0.0;
  double _toIndex = 0.0;
  int _lastActiveIndex = 0;
  int _targetIndex = 0;

  static const List<({IconData icon, IconData activeIcon, String label, String route})> _items = [
    (
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Exams',
      route: RouteNames.examSimulator,
    ),
    (
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Notes',
      route: RouteNames.highSchoolNotes,
    ),
    (
      icon: Icons.edit_note_rounded,
      activeIcon: Icons.edit_note_rounded,
      label: 'Practice',
      route: RouteNames.courses,
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: RouteNames.profile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex.toDouble();
    _toIndex = widget.currentIndex.toDouble();
    _lastActiveIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _lastActiveIndex = _targetIndex;
        });
      }
    });
  }

  @override
  void didUpdateWidget(GradeBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _targetIndex) {
      _fromIndex = _currentPosition;
      _lastActiveIndex = _targetIndex;
      _targetIndex = widget.currentIndex;
      _toIndex = widget.currentIndex.toDouble();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _currentPosition {
    if (!_controller.isAnimating && _controller.isCompleted) {
      return _toIndex;
    }
    return _fromIndex + (_toIndex - _fromIndex) * _animation.value;
  }

  void _handleTap(int index) {
    if (widget.onTap != null) {
      widget.onTap!(index);
    } else {
      final route = _items[index].route;
      context.go(route);
    }

    if (index != _targetIndex || !_controller.isCompleted) {
      _fromIndex = _currentPosition;
      _lastActiveIndex = _targetIndex;
      _targetIndex = index;
      _toIndex = index.toDouble();
      _controller.forward(from: 0.0);
    }
  }

  double _getElevation(int index) {
    if (!_controller.isAnimating && _controller.isCompleted) {
      return index == _targetIndex ? 1.0 : 0.0;
    }
    if (_lastActiveIndex == _targetIndex) {
      return index == _targetIndex ? 1.0 : 0.0;
    }

    final t = _controller.value.clamp(0.0, 1.0);

    if (index == _targetIndex) {
      return Curves.easeOutCubic.transform(t);
    } else if (index == _lastActiveIndex) {
      return 1.0 - Curves.easeOutCubic.transform(t);
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barHeight = 64.0;
    const double circleDiameter = 52.0;
    const double circleRadius = circleDiameter / 2;
    const double floatOverhead = 24.0;
    const double totalHeight = barHeight + floatOverhead;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final slotWidth = width / _items.length;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final pos = _currentPosition;
            final circleCenterX = (pos + 0.5) * slotWidth;

            return ColoredBox(
              color: Colors.transparent,
              child: SizedBox(
                height: totalHeight + bottomPadding,
                child: Stack(
                  clipBehavior: Clip.none,
                children: [
                  // 1. White Scooped Navbar Background
                  Positioned(
                    left: 0,
                    right: 0,
                    top: floatOverhead,
                    height: barHeight + bottomPadding,
                    child: CustomPaint(
                      size: Size(width, barHeight + bottomPadding),
                      painter: _CurvedNavBarPainter(
                        normalizedPosition: pos,
                        itemCount: _items.length,
                        scoopDepth: 42.0,
                        scoopHalfWidth: 46.0,
                        topCornerRadius: 22.0,
                        barColor: Colors.white,
                        shadowColor: Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                  ),

                  // 2. Floating Orange Circle Pill (BACKGROUND ONLY, NO ORANGE SHADOW)
                  Positioned(
                    left: circleCenterX - circleRadius,
                    top: 6.0,
                    width: circleDiameter,
                    height: circleDiameter,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF851B),
                            Color(0xFFFF6A00),
                            Color(0xFFFF4800),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [
                          // Subtle dark contact shadow only — NO orange shadow
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Interactive Icons Layer (ALL 4 ICONS MOVE VERTICALLY IN THEIR FIXED COLUMNS)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: totalHeight,
                    child: Row(
                      children: List.generate(_items.length, (index) {
                        final elevation = _getElevation(index);
                        final iconY = 44.0 - (25.0 * elevation);
                        final iconSize = 24.0 + (2.0 * elevation);
                        final iconColor = Color.lerp(
                          const Color(0xFF64748B),
                          Colors.white,
                          elevation,
                        )!;
                        final iconData = elevation > 0.4
                            ? _items[index].activeIcon
                            : _items[index].icon;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleTap(index),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Positioned(
                                  top: iconY,
                                  child: Icon(
                                    iconData,
                                    color: iconColor,
                                    size: iconSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CurvedNavBarPainter extends CustomPainter {
  final double normalizedPosition;
  final int itemCount;
  final double scoopDepth;
  final double scoopHalfWidth;
  final double topCornerRadius;
  final Color barColor;
  final Color shadowColor;

  const _CurvedNavBarPainter({
    required this.normalizedPosition,
    required this.itemCount,
    required this.scoopDepth,
    required this.scoopHalfWidth,
    required this.topCornerRadius,
    required this.barColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final slotWidth = size.width / itemCount;
    final currentCenterX = (normalizedPosition + 0.5) * slotWidth;

    final x0 = currentCenterX - scoopHalfWidth;
    final xMid = currentCenterX;
    final x1 = currentCenterX + scoopHalfWidth;

    final leftCornerR = (x0 < topCornerRadius)
        ? (x0 > 0 ? x0 : 0.0)
        : topCornerRadius;
    final rightDist = size.width - x1;
    final rightCornerR = (rightDist < topCornerRadius)
        ? (rightDist > 0 ? rightDist : 0.0)
        : topCornerRadius;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, leftCornerR);

    if (leftCornerR > 0) {
      path.arcToPoint(
        Offset(leftCornerR, 0),
        radius: Radius.circular(leftCornerR),
      );
    }

    if (x0 > leftCornerR) {
      path.lineTo(x0, 0);
    }

    // Smooth concave cutout around floating circle
    path.cubicTo(
      x0 + scoopHalfWidth * 0.38,
      0.0,
      xMid - scoopHalfWidth * 0.44,
      scoopDepth,
      xMid,
      scoopDepth,
    );

    path.cubicTo(
      xMid + scoopHalfWidth * 0.44,
      scoopDepth,
      x1 - scoopHalfWidth * 0.38,
      0.0,
      x1,
      0.0,
    );

    if (size.width - rightCornerR > x1) {
      path.lineTo(size.width - rightCornerR, 0);
    }

    if (rightCornerR > 0) {
      path.arcToPoint(
        Offset(size.width, rightCornerR),
        radius: Radius.circular(rightCornerR),
      );
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Ambient drop shadow
    canvas.drawShadow(path, shadowColor, 12.0, false);

    // Solid fill
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Top hairline border following contour
    final borderPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final borderPath = Path();
    borderPath.moveTo(0, leftCornerR);

    if (leftCornerR > 0) {
      borderPath.arcToPoint(
        Offset(leftCornerR, 0),
        radius: Radius.circular(leftCornerR),
      );
    }

    if (x0 > leftCornerR) {
      borderPath.lineTo(x0, 0);
    }

    borderPath.cubicTo(
      x0 + scoopHalfWidth * 0.38,
      0.0,
      xMid - scoopHalfWidth * 0.44,
      scoopDepth,
      xMid,
      scoopDepth,
    );

    borderPath.cubicTo(
      xMid + scoopHalfWidth * 0.44,
      scoopDepth,
      x1 - scoopHalfWidth * 0.38,
      0.0,
      x1,
      0.0,
    );

    if (size.width - rightCornerR > x1) {
      borderPath.lineTo(size.width - rightCornerR, 0);
    }

    if (rightCornerR > 0) {
      borderPath.arcToPoint(
        Offset(size.width, rightCornerR),
        radius: Radius.circular(rightCornerR),
      );
    }

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNavBarPainter oldDelegate) {
    return oldDelegate.normalizedPosition != normalizedPosition ||
        oldDelegate.barColor != barColor;
  }
}

class GradeScreenShell extends StatelessWidget {
  final String title;
  final String? streamTitle;
  final String? subtitle;
  final Widget? headerExtension;
  final VoidCallback? onBackPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onProfilePressed;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool showBottomNav;
  final int selectedNavIndex;
  final ValueChanged<int>? onNavTap;
  final Color backgroundColor;
  final bool showBackButton;

  const GradeScreenShell({
    super.key,
    required this.title,
    this.streamTitle,
    this.subtitle,
    this.headerExtension,
    this.onBackPressed,
    this.onBookmarkPressed,
    this.onProfilePressed,
    required this.body,
    this.bottomNavigationBar,
    this.showBottomNav = false,
    this.selectedNavIndex = 0,
    this.onNavTap,
    this.backgroundColor = AppColors.surfaceApp,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final hasSubheader =
        (streamTitle != null && streamTitle!.isNotEmpty) ||
        (subtitle != null && subtitle!.isNotEmpty);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // Brand primary blue header container
            Container(
              color: AppColors.brandPrimary,
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: hasSubheader || headerExtension != null ? 14 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradeExamAppBar(
                    title: title,
                    showBackButton: showBackButton,
                    onBackPressed: onBackPressed,
                    onBookmarkPressed: onBookmarkPressed,
                    onProfilePressed: onProfilePressed,
                  ),
                  if (headerExtension != null)
                    headerExtension!
                  else if (hasSubheader) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (streamTitle != null && streamTitle!.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  streamTitle!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.95),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Scrollable / primary content area
            Expanded(child: body),
          ],
        ),
        bottomNavigationBar: showBottomNav
            ? (bottomNavigationBar ??
                  GradeBottomNavBar(
                    currentIndex: selectedNavIndex,
                    onTap: onNavTap,
                  ))
            : null,
      ),
    );
  }
}
