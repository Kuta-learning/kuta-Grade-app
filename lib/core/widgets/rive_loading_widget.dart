import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// A reusable widget that plays the Kuta loading animation.
///
/// Features per-frame fine-grained vector coloring:
/// - [handColor]: Fills all shape fills with Kuta orange.
/// - [borderColor]: Strokes all shape outlines with deep brown.
/// - [transparentBackground]: Makes the artboard background fully transparent.
class KutaLoadingWidget extends StatelessWidget {
  /// Width & height of the Rive canvas.
  final double size;

  /// Optional text shown below the animation.
  final String? label;

  /// Text style for [label]. Falls back to theme bodyMedium.
  final TextStyle? labelStyle;

  /// Color for the hand fill. Defaults to Kuta Orange (0xFFFF7A00).
  final Color? handColor;

  /// Color for the hand border/stroke. Defaults to Brown (0xFF5D3A1A).
  final Color? borderColor;

  /// Whether to force transparent background. Defaults to true.
  final bool transparentBackground;

  /// Optional global color tint filter (overrides all vector strokes/fills if set).
  final Color? color;

  /// Blend mode used when [color] is provided.
  final BlendMode blendMode;

  /// Optional callback that receives all component names and types found in the file.
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget riveChild = RiveAnimation.asset(
      'assets/animation/progress_of_loading_hand.riv',
      fit: BoxFit.contain,
      onInit: (artboard) {
        // Fast one-time transparent background handling
        if (transparentBackground) {
          for (final fill in artboard.fills.toList()) {
            artboard.removeFill(fill);
          }
        }

        // Auto-play state machine if available, otherwise first linear animation
        if (artboard.stateMachines.isNotEmpty) {
          final sm = StateMachineController.fromArtboard(
            artboard,
            artboard.stateMachines.first.name,
          );
          if (sm != null) {
            artboard.addController(sm);
          }
        } else if (artboard.animations.isNotEmpty) {
          artboard.addController(
            SimpleAnimation(artboard.animations.first.name),
          );
        }

        // Pure performance: Only attach the per-frame modifier if color overrides are provided
        if (handColor != null || borderColor != null || onComponentsFound != null) {
          artboard.addController(
            _RiveColorModifierController(
              handColor: handColor,
              borderColor: borderColor,
              transparentBackground: transparentBackground,
              onComponentsFound: onComponentsFound,
            ),
          );
        }
      },
    );

    if (color != null) {
      riveChild = ColorFiltered(
        colorFilter: ColorFilter.mode(color!, blendMode),
        child: riveChild,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: riveChild,
        ),
        if (label != null) ...[
          const SizedBox(height: 12),
          Text(
            label!,
            style: labelStyle ??
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

/// Custom per-frame Rive controller that dynamically recolors all
/// SolidColor components based on whether their parent is a Fill or Stroke.
///
/// This approach is reliable because it does NOT depend on component names —
/// it uses the Rive object tree: SolidColor → parent is Fill (hand color)
/// or SolidColor → parent is Stroke (border color).
class _RiveColorModifierController extends RiveAnimationController<Artboard> {
  final Color? handColor;
  final Color? borderColor;
  final bool transparentBackground;
  final void Function(List<String>)? onComponentsFound;

  final Set<Artboard> _artboards = {};
  final Set<SolidColor> _handFills = {};
  final Set<SolidColor> _handStrokes = {};
  final Set<SolidColor> _bgFills = {};
  final Set<SolidColor> _progressFills = {};
  bool _discovered = false;

  // Known progress dot / particle colors in the Rive animation (RGB):
  // Purple, Red, Yellow, Dark Blue, Green
  static const _knownProgressColors = {
    0x573FB4,
    0xC30025,
    0xFFC300,
    0x003566,
    0x55C043,
  };

  _RiveColorModifierController({
    required this.handColor,
    required this.borderColor,
    required this.transparentBackground,
    this.onComponentsFound,
  }) {
    isActive = true;
  }

  @override
  bool init(Artboard artboard) {
    _applyModifications(artboard);
    return true;
  }

  @override
  void apply(Artboard artboard, double elapsedSeconds) {
    _applyModifications(artboard);
  }

  void _collectAllArtboards(Artboard root, Set<Artboard> collected) {
    if (!collected.add(root)) return;

    // 1. Check components in the current artboard for NestedArtboards
    root.forEachComponent((child) {
      if (child is NestedArtboard) {
        final dynamic nested = child;
        final dynamic mounted = nested.mountedArtboard;
        if (mounted != null) {
          final dynamic instance = mounted.artboardInstance;
          if (instance is Artboard) {
            _collectAllArtboards(instance, collected);
          }
        }
      }
    });

    // 2. Check activeNestedArtboards
    for (final nested in root.activeNestedArtboards) {
      final dynamic m = (nested as dynamic).mountedArtboard;
      if (m != null) {
        final dynamic instance = m.artboardInstance;
        if (instance is Artboard) {
          _collectAllArtboards(instance, collected);
        }
      }
    }
  }

  void _applyModifications(Artboard rootArtboard) {
    // 1. Recursively discover all artboards (including nested ones)
    final allArtboards = <Artboard>{};
    _collectAllArtboards(rootArtboard, allArtboards);

    // 2. Inspect newly found artboards for SolidColor nodes
    bool newlyFound = false;
    for (final a in allArtboards) {
      if (_artboards.add(a)) {
        newlyFound = true;

        a.forEachComponent((child) {
          if (child is SolidColor) {
            final argb = child.colorValue;
            final rgb = argb & 0x00FFFFFF;
            final parent = child.parent;

            // Background fill (white or artboard-level fill)
            if (rgb == 0xFFFFFF || parent?.parent is Artboard) {
              _bgFills.add(child);
            }
            // Hand outline / stroke (original color 0x544240 or any Stroke parent)
            else if (parent is Stroke || rgb == 0x544240) {
              _handStrokes.add(child);
            }
            // Hand skin (0x8D5740) or hand shadow (0x73553E)
            else if (rgb == 0x8D5740 || rgb == 0x73553E) {
              _handFills.add(child);
            }
            // Known progress dots (purple, red, yellow, blue, green)
            else if (_knownProgressColors.contains(rgb)) {
              _progressFills.add(child);
            }
            // Any other fill belongs to the hand artwork
            else if (parent is Fill) {
              _handFills.add(child);
            }
          }
        });
      }
    }

    // Fallback: If no specific hand fill was found, treat all non-bg fills as hand
    if (_handFills.isEmpty && _progressFills.isNotEmpty) {
      for (final p in _progressFills) {
        if (!_bgFills.contains(p) && !_handStrokes.contains(p)) {
          _handFills.add(p);
        }
      }
    }

    // 3. Dump discovered hierarchy once we find nested components
    if (newlyFound && !_discovered && (_artboards.length > 1 || _handFills.isNotEmpty)) {
      _discovered = true;
      final info = <String>[];

      debugPrint('═══════════════════════════════════════════════');
      debugPrint('🎉 RIVE COMPONENT RECOLOR DISCOVERY');
      debugPrint('   Total Artboards: ${_artboards.length}');
      debugPrint('   Hand Fills: ${_handFills.length}');
      debugPrint('   Hand Border Strokes: ${_handStrokes.length}');
      debugPrint('   Background Fills: ${_bgFills.length}');
      debugPrint('   Progress Dot Fills: ${_progressFills.length}');
      debugPrint('───────────────────────────────────────────────');

      for (final a in _artboards) {
        final aName = a.name.isEmpty ? 'Root Artboard' : a.name;
        debugPrint('📦 Artboard: "$aName" (${a.runtimeType})');
        a.forEachComponent((c) {
          final pType = c.parent?.runtimeType.toString() ?? 'null';
          final pName = c.parent?.name ?? '';
          if (c is SolidColor) {
            final hex = '0x${c.colorValue.toRadixString(16).toUpperCase()}';
            String role = 'other';
            if (_handFills.contains(c)) role = 'HAND FILL';
            if (_handStrokes.contains(c)) role = 'HAND STROKE';
            if (_bgFills.contains(c)) role = 'BACKGROUND';
            if (_progressFills.contains(c)) role = 'PROGRESS DOT';
            debugPrint('  🎨 SolidColor: "$role" → parent=$pType "$pName" (original: $hex)');
            info.add('• SolidColor "$role" → parent: $pType "$pName" ($hex)');
          } else {
            info.add('• "${c.name}" (${c.runtimeType}) → parent: $pType "$pName"');
          }
        });
      }
      debugPrint('═══════════════════════════════════════════════');

      onComponentsFound?.call(info);
    }

    // 4. Apply background transparency every frame
    if (transparentBackground) {
      for (final a in _artboards) {
        for (final fill in a.fills.toList()) {
          a.removeFill(fill);
        }
      }
      for (final bg in _bgFills) {
        bg.colorValue = 0x00000000;
      }
    }

    // 5. Apply hand color every frame
    if (handColor != null) {
      final handArgb = handColor!.toARGB32();
      for (final fill in _handFills) {
        fill.colorValue = handArgb;
      }
    }

    // 6. Apply border color every frame
    if (borderColor != null) {
      final borderArgb = borderColor!.toARGB32();
      for (final stroke in _handStrokes) {
        stroke.colorValue = borderArgb;
      }
    }
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

