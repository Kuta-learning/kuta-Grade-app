import 'package:flutter/material.dart';

/// Shimmer skeleton loader for the top section of the Exam Simulator.
/// Matches the royal blue banner, welcome card, and active exam card layout.
class ExamHeaderSkeleton extends StatefulWidget {
  const ExamHeaderSkeleton({super.key});

  @override
  State<ExamHeaderSkeleton> createState() => _ExamHeaderSkeletonState();
}

class _ExamHeaderSkeletonState extends State<ExamHeaderSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) {
        // Only the welcome banner skeleton — sits cleanly inside the blue header.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 160,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _opacityAnim.value),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 110,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _opacityAnim.value * 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
