import 'package:flutter/material.dart';

/// A single step of the dashboard intro tour.
///
/// Each step points at a [targetKey] whose rendered box is spotlighted with a
/// rounded-rect "hole" in the dark scrim. Steps without a [targetKey] (e.g.
/// the welcome step) show a centered card and no hole.
class CoachMarkStep {
  /// Short title shown in the coach card (Poppins).
  final String title;

  /// One-or-two line description shown in the coach card (Open Sans).
  final String body;

  /// [GlobalKey] of the widget to spotlight. Null = full-screen welcome step.
  final GlobalKey? targetKey;

  const CoachMarkStep({required this.title, required this.body, this.targetKey});

  /// Resolves the global screen-space rectangle of [targetKey].
  ///
  /// Returns `null` when the step has no target or its widget is not
  /// currently attached/laid out (e.g. the nav bar is not mounted yet).
  Rect? targetRect() {
    if (targetKey == null) return null;
    final box = targetKey!.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }
}
