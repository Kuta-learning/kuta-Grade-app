import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';

/// Reusable App Bar for Grade screens matching the Figma reference design.
/// Includes back navigation, screen title, bookmark action, and student profile avatar.
class GradeExamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onProfilePressed;
  final List<Widget>? actions;

  const GradeExamAppBar({
    super.key,
    required this.title,
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
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
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              splashRadius: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              tooltip: 'My Profile',
              onPressed: () {
                if (onProfilePressed != null) {
                  onProfilePressed!();
                } else {
                  context.push(RouteNames.profile);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Common bottom navigation bar for Grade screens (Exams, Notes, Practice, Profile).
class GradeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const GradeBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppColors.borderVariant, width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: bottomInset > 0 ? bottomInset : 6,
      ),
      child: Row(
        children: [
          _buildItem(
            context: context,
            index: 0,
            label: 'Exams',
            icon: Icons.assignment_outlined,
          ),
          _buildItem(
            context: context,
            index: 1,
            label: 'Notes',
            icon: Icons.article_outlined,
          ),
          _buildItem(
            context: context,
            index: 2,
            label: 'Practice',
            icon: Icons.edit_note_rounded,
          ),
          _buildItem(
            context: context,
            index: 3,
            label: 'Profile',
            icon: Icons.person_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.orange500 : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          } else {
            if (index == 0) {
              context.go(RouteNames.grade12MatricExam);
            } else if (index == 3) {
              context.push(RouteNames.profile);
            }
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable navigation shell and scaffold for Grade module screens.
/// Enforces consistent status bar styling, unified brand blue header with app bar,
/// optional stream/subtitle banner, content body slot, and common bottom navigation bar.
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
    this.showBottomNav = true,
    this.selectedNavIndex = 0,
    this.onNavTap,
    this.backgroundColor = AppColors.surfaceApp,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final hasSubheader = (streamTitle != null && streamTitle!.isNotEmpty) ||
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
            Expanded(
              child: body,
            ),
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
