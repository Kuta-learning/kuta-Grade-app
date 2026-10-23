import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kuta_learning_app/core/constants/app_colors.dart';
import 'package:kuta_learning_app/core/router/route_names.dart';
import 'package:kuta_learning_app/core/widgets/rive_loading_widget.dart';

/// Ultra high-performance preview screen for Kuta Loading animation.
///
/// Stripped of all duplicate animations, heavy filters, and debug overhead
/// to benchmark pure 60/120 FPS performance exactly as it will run on
/// dashboards and page transitions.
class AnimationPreviewScreen extends StatefulWidget {
  const AnimationPreviewScreen({super.key});

  @override
  State<AnimationPreviewScreen> createState() => _AnimationPreviewScreenState();
}

class _AnimationPreviewScreenState extends State<AnimationPreviewScreen> {
  bool _showOverlay = false;
  double _selectedSize = 120; // Default dashboard size
  int _bgIndex = 0; // 0: White card, 1: Soft Peach, 2: Dark Navy (contrast test)

  static const List<Map<String, dynamic>> _sizes = [
    {'label': 'Small (60px)', 'size': 60.0},
    {'label': 'Medium (100px)', 'size': 100.0},
    {'label': 'Large (150px)', 'size': 150.0},
  ];

  static const List<Map<String, dynamic>> _backgrounds = [
    {
      'name': 'Clean White',
      'cardColor': Colors.white,
      'border': Color(0xFFE2E8F0),
      'textColor': Color(0xFF0F172A),
    },
    {
      'name': 'Kuta Soft Peach',
      'cardColor': Color(0xFFFFF7ED),
      'border': Color(0xFFFED7AA),
      'textColor': Color(0xFF9A3412),
    },
    {
      'name': 'Navy Contrast',
      'cardColor': Color(0xFF0A3366),
      'border': Color(0xFF1E40AF),
      'textColor': Colors.white,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentBg = _backgrounds[_bgIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Loading Animation Preview',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                backgroundColor: AppColors.navyLight100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => context.go(RouteNames.splash),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(
                'Go to App',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Performance Status Badge ────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.speed_rounded,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pure Native Performance Mode: 1 instance active • Zero per-frame overhead',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Hero Card (Only 1 Single Instance) ───────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 24),
                    decoration: BoxDecoration(
                      color: currentBg['cardColor'] as Color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: currentBg['border'] as Color,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: KutaLoadingWidget(
                        size: _selectedSize,
                        label: 'Loading dashboard content…',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: currentBg['textColor'] as Color,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Size Selector ───────────────────────────────────
                  Text(
                    'Preview Size',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _sizes.map((s) {
                      final isSelected = _selectedSize == (s['size'] as double);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(
                                () => _selectedSize = s['size'] as double),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.orange500
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.orange500
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Text(
                                s['label'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Background Contrast Toggle ──────────────────────
                  Text(
                    'Test Background Transparency',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_backgrounds.length, (idx) {
                      final isSelected = _bgIndex == idx;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _bgIndex = idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Text(
                                _backgrounds[idx]['name'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // ── Test Real Overlay Demo ──────────────────────────
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      setState(() => _showOverlay = true);
                      await Future.delayed(const Duration(seconds: 3));
                      if (mounted) setState(() => _showOverlay = false);
                    },
                    icon: const Icon(Icons.fullscreen_rounded, size: 20),
                    label: Text(
                      'Trigger Full-Screen Overlay (3 sec)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Full-screen overlay as it runs during actual page loads ──
          if (_showOverlay)
            const KutaLoadingOverlay(
              label: 'Loading dashboard…',
            ),
        ],
      ),
    );
  }
}
