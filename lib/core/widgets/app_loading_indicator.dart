import 'package:flutter/material.dart';

/// Shared loading indicator.
/// Optionally accepts a [color] override; defaults to the theme's default
/// spinner so existing screens are unaffected.
class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
