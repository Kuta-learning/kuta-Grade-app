import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Supported types for [AppSnackBar].
enum AppSnackBarType { welcome, success, error, info }

/// A standard, premium-styled animated SnackBar matching Kuta's design tokens
/// (orange and warm brown brand colors, elevated white card, and smooth animations).
class AppSnackBar {
  AppSnackBar._();

  /// Displays the animated Welcome SnackBar on the Dashboard once all setup steps are complete.
  static void showWelcome(
    BuildContext context, {
    required String name,
    String? subtitle,
  }) {
    show(
      context,
      type: AppSnackBarType.welcome,
      title: 'Welcome, $name!',
      message: subtitle ?? 'Your Journey Starts Now!!',
      duration: const Duration(milliseconds: 3200),
    );
  }

  /// Displays a success SnackBar using the brand palette.
  static void showSuccess(
    BuildContext context,
    String message, {
    String title = 'Success',
  }) {
    show(
      context,
      type: AppSnackBarType.success,
      title: title,
      message: message,
    );
  }

  /// Displays an error SnackBar.
  static void showError(
    BuildContext context,
    String message, {
    String title = 'Something went wrong',
  }) {
    show(context, type: AppSnackBarType.error, title: title, message: message);
  }

  /// Displays an informational SnackBar using the warm brown and orange palette.
  static void showInfo(
    BuildContext context,
    String message, {
    String title = 'Notice',
  }) {
    show(context, type: AppSnackBarType.info, title: title, message: message);
  }

  /// Generic display method for [AppSnackBar].
  static void show(
    BuildContext context, {
    required AppSnackBarType type,
    required String title,
    required String message,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: EdgeInsets.zero,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        content: _AnimatedSnackBarContent(
          type: type,
          title: title,
          message: message,
          duration: duration,
          onDismiss: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }
}

class _AnimatedSnackBarContent extends StatefulWidget {
  final AppSnackBarType type;
  final String title;
  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AnimatedSnackBarContent({
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<_AnimatedSnackBarContent>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _progressController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (450ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _entranceController.forward();

    // 2. Countdown progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..reverse(from: 1.0);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(widget.type);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(color: style.borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.authBrown.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: style.glowColor.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft warm ambient glow behind the leading icon
              Positioned(
                top: -30,
                left: -20,
                child: IgnorePointer(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: style.glowColor.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),

              // Main content row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated Bouncy Leading Icon in Orange / Brown container
                    ScaleTransition(
                      scale: _iconScaleAnimation,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: style.iconBackgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: style.glowColor.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(style.icon, color: Colors.white, size: 22),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Texts: Title & Message
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTypography.headlineLg.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                          if (widget.message.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.message,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.authBrown,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Dismiss Close Icon
                    GestureDetector(
                      onTap: widget.onDismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.containerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.authBrown.withValues(alpha: 0.7),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Animated Countdown Progress Line (Bottom) using Orange/Brown accent
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressController.value,
                      child: Container(
                        height: 3.0,
                        decoration: BoxDecoration(
                          color: style.progressColor,
                          gradient: style.progressGradient,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _SnackBarVisualConfig _getStyle(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.welcome:
        return _SnackBarVisualConfig(
          icon: Icons.auto_awesome_rounded,
          iconBackgroundColor: AppColors.orange500,
          glowColor: AppColors.orange500,
          borderColor: AppColors.orange500.withValues(alpha: 0.40),
          progressColor: AppColors.orange500,
          progressGradient: const LinearGradient(
            colors: [AppColors.orange500, AppColors.accentDark],
          ),
        );
      case AppSnackBarType.success:
        return _SnackBarVisualConfig(
          icon: Icons.check_rounded,
          iconBackgroundColor: AppColors.orange500,
          glowColor: AppColors.orange500,
          borderColor: AppColors.orange500.withValues(alpha: 0.35),
          progressColor: AppColors.orange500,
        );
      case AppSnackBarType.info:
        return _SnackBarVisualConfig(
          icon: Icons.info_outline_rounded,
          iconBackgroundColor: AppColors.accentDark, // Brown
          glowColor: AppColors.accentDark,
          borderColor: AppColors.accentDark.withValues(alpha: 0.30),
          progressColor: AppColors.accentDark,
        );
      case AppSnackBarType.error:
        return _SnackBarVisualConfig(
          icon: Icons.error_outline_rounded,
          iconBackgroundColor: AppColors.error,
          glowColor: AppColors.error,
          borderColor: AppColors.error.withValues(alpha: 0.35),
          progressColor: AppColors.error,
        );
    }
  }
}

class _SnackBarVisualConfig {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color glowColor;
  final Color borderColor;
  final Color progressColor;
  final Gradient? progressGradient;

  const _SnackBarVisualConfig({
    required this.icon,
    required this.iconBackgroundColor,
    required this.glowColor,
    required this.borderColor,
    required this.progressColor,
    this.progressGradient,
  });
}
