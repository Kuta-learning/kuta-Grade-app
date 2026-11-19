import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Animated ambient background glows for authentication screens.
/// Features a rapid bloom/expansion entrance where both the top-right (orange)
/// and bottom-left (light blue) glows expand to their full size from small points
/// at their dedicated corner positions upon screen arrival.
class AnimatedAuthBackground extends StatefulWidget {
  final bool animate;
  final Duration duration;

  const AnimatedAuthBackground({
    super.key,
    this.animate = true,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<AnimatedAuthBackground> createState() => _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<AnimatedAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _orangeScaleAnimation;
  late final Animation<double> _orangeOpacityAnimation;
  late final Animation<double> _blueScaleAnimation;
  late final Animation<double> _blueOpacityAnimation;

  static bool get _isInTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Top-right Orange Glow bloom curve (begins immediately)
    _orangeScaleAnimation = Tween<double>(begin: 0.02, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _orangeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Bottom-left Light Blue Glow bloom curve (slight rhythmic delay)
    _blueScaleAnimation = Tween<double>(begin: 0.02, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _blueOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.55, curve: Curves.easeOut),
      ),
    );

    if (widget.animate && !_isInTest) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Top-right Orange Glow (expands from its corner-tucked center)
                Positioned(
                  top: -160.0,
                  right: -130.0,
                  child: Opacity(
                    opacity: _orangeOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _orangeScaleAnimation.value,
                      alignment: Alignment.center,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                        child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.orange500.withValues(alpha: 0.24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom-left Light Blue Glow (expands from its corner-tucked center)
                Positioned(
                  bottom: -150.0,
                  left: -120.0,
                  child: Opacity(
                    opacity: _blueOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _blueScaleAnimation.value,
                      alignment: Alignment.center,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.glowBlue.withValues(alpha: 0.24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
