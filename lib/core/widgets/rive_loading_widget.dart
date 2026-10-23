import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// A reusable widget that plays the Kuta loading animation using modern Rive (v0.14+).
class KutaLoadingWidget extends StatefulWidget {
  /// Width & height of the Rive canvas.
  final double size;

  /// Optional text shown below the animation.
  final String? label;

  /// Text style for [label]. Falls back to theme bodyMedium.
  final TextStyle? labelStyle;

  /// Color for the hand fill (kept for backward compatibility; colors are embedded in the .riv asset).
  final Color? handColor;

  /// Color for the hand border/stroke (kept for backward compatibility).
  final Color? borderColor;

  /// Whether artboard background is transparent.
  final bool transparentBackground;

  /// Optional global color tint filter (overrides all vector strokes/fills if set).
  final Color? color;

  /// Blend mode used when [color] is provided.
  final BlendMode blendMode;

  /// Optional callback for discovered components (kept for backward compatibility).
  final void Function(List<String> components)? onComponentsFound;

  const KutaLoadingWidget({
    super.key,
    this.size = 160,
    this.label,
    this.labelStyle,
    this.handColor,
    this.borderColor,
    this.transparentBackground = true,
    this.color,
    this.blendMode = BlendMode.srcIn,
    this.onComponentsFound,
  });

  @override
  State<KutaLoadingWidget> createState() => _KutaLoadingWidgetState();
}

class _KutaLoadingWidgetState extends State<KutaLoadingWidget> {
  late final FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(
      'assets/animation/progress_of_loading_hand.riv',
      riveFactory: Factory.rive,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget riveChild = RiveWidgetBuilder(
      fileLoader: _fileLoader,
      builder: (context, state) => switch (state) {
        RiveLoading() => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        RiveFailed() => const SizedBox.shrink(),
        RiveLoaded() => RiveWidget(
            controller: state.controller,
            fit: Fit.contain,
          ),
      },
    );

    if (widget.color != null) {
      riveChild = ColorFiltered(
        colorFilter: ColorFilter.mode(widget.color!, widget.blendMode),
        child: riveChild,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: riveChild,
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.label!,
            style: widget.labelStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Full-screen loading overlay — wraps any scaffold body while async
/// work is in progress.
class KutaLoadingOverlay extends StatelessWidget {
  final String? label;
  final Color? handColor;
  final Color? borderColor;
  final bool transparentBackground;
  final Color? color;
  final BlendMode blendMode;

  const KutaLoadingOverlay({
    super.key,
    this.label,
    this.handColor = const Color(0xFFFF7A00),
    this.borderColor = const Color(0xFF5D3A1A),
    this.transparentBackground = true,
    this.color,
    this.blendMode = BlendMode.srcIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: KutaLoadingWidget(
        size: 180,
        label: label ?? 'Loading…',
        handColor: handColor,
        borderColor: borderColor,
        transparentBackground: transparentBackground,
        color: color,
        blendMode: blendMode,
      ),
    );
  }
}
