import 'package:flutter/material.dart';

/// Design system layout spacing tokens extracted from the 8pt Spatial Grid specification.
class AppSpacing {
  // Prevent instantiation
  AppSpacing._();

  // ==========================================
  // SPACING RHYTHM (8PT GRID) - RAW DOUBLE VALUES
  // ==========================================

  /// space-1: 4px (gap-1 / p-1)
  static const double space1 = 4.0;
  static const double s1 = space1;

  /// space-2: 8px (gap-2 / p-2)
  static const double space2 = 8.0;
  static const double s2 = space2;

  /// space-4: 16px (gap-4 / p-4)
  static const double space4 = 16.0;
  static const double s4 = space4;

  /// space-6: 24px (gap-6 / p-6)
  static const double space6 = 24.0;
  static const double s6 = space6;

  /// space-8: 32px (gap-8 / p-8)
  static const double space8 = 32.0;
  static const double s8 = space8;

  // ==========================================
  // CONVENIENCE SIZEDBOX GAPS
  // ==========================================

  // Vertical Gaps
  static const SizedBox vGap1 = SizedBox(height: space1);
  static const SizedBox vGap2 = SizedBox(height: space2);
  static const SizedBox vGap4 = SizedBox(height: space4);
  static const SizedBox vGap6 = SizedBox(height: space6);
  static const SizedBox vGap8 = SizedBox(height: space8);

  // Horizontal Gaps
  static const SizedBox hGap1 = SizedBox(width: space1);
  static const SizedBox hGap2 = SizedBox(width: space2);
  static const SizedBox hGap4 = SizedBox(width: space4);
  static const SizedBox hGap6 = SizedBox(width: space6);
  static const SizedBox hGap8 = SizedBox(width: space8);

  // ==========================================
  // CONVENIENCE EDGEINSETS PADDING
  // ==========================================

  /// All sides: 4px
  static const EdgeInsets p1 = EdgeInsets.all(space1);

  /// All sides: 8px
  static const EdgeInsets p2 = EdgeInsets.all(space2);

  /// All sides: 16px
  static const EdgeInsets p4 = EdgeInsets.all(space4);

  /// All sides: 24px
  static const EdgeInsets p6 = EdgeInsets.all(space6);

  /// All sides: 32px
  static const EdgeInsets p8 = EdgeInsets.all(space8);
}

/// Design system border radius hierarchy tokens.
class AppRadius {
  // Prevent instantiation
  AppRadius._();

  // ==========================================
  // RAW DOUBLE VALUES
  // ==========================================

  /// rounded-md: 6px - Used for Badges, table action icons
  static const double md = 6.0;

  /// rounded-lg: 8px - Used for Buttons, form inputs, dropdowns
  static const double lg = 8.0;

  /// rounded-xl: 12px - Used for Standard cards, modal containers
  static const double xl = 12.0;

  /// rounded-2xl: 16px - Used for Dashboard modules, Kids UI
  static const double xl2 = 16.0;
  static const double xxl = xl2;

  // ==========================================
  // BORDERRADIUS OBJECTS
  // ==========================================

  /// Rounded 6px (Badges, table action icons)
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));

  /// Rounded 8px (Buttons, form inputs, dropdowns)
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));

  /// Rounded 12px (Standard cards, modal containers)
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));

  /// Rounded 16px (Dashboard modules, Kids UI)
  static const BorderRadius rounded2Xl = BorderRadius.all(Radius.circular(xl2));
}

/// Design system elevation and shadow tokens.
class AppElevation {
  // Prevent instantiation
  AppElevation._();

  // ==========================================
  // ELEVATION & SHADOW TOKENS
  // ==========================================

  /// Elevation 0 / Flat - Standard tables, sidebars
  /// Flat style with no shadow (uses border-slate-200 / borderVariant)
  static const List<BoxShadow> elevation0 = <BoxShadow>[];
  static const List<BoxShadow> flat = elevation0;

  /// Elevation 1 / Card Low - KPI metrics, list panels
  /// CSS spec: shadow-sm (0 1px 2px rgba(0, 0, 0, 0.05))
  static const List<BoxShadow> elevation1 = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  static const List<BoxShadow> cardLow = elevation1;

  /// Elevation 2 / Floating - Dropdown menus, hover cards
  /// CSS spec: shadow-md (0 4px 6px -1px rgba(0, 0, 0, 0.1))
  static const List<BoxShadow> elevation2 = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];
  static const List<BoxShadow> floating = elevation2;

  /// Elevation Large - Used for Logo card mark, floating panels
  /// CSS spec: shadow-lg (0px 10px 15px -3px rgba(0, 0, 0, 0.1), 0px 4px 6px -4px rgba(0, 0, 0, 0.1))
  static const List<BoxShadow> elevationLg = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];
  static const List<BoxShadow> logoCard = elevationLg;

  /// Elevation 3 / Modal Dialog - Confirmation modals, bottom sheets
  /// CSS spec: shadow-xl (0 20px 25px -5px rgba(0, 0, 0, 0.1))
  static const List<BoxShadow> elevation3 = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
  ];
  static const List<BoxShadow> modalDialog = elevation3;
}
