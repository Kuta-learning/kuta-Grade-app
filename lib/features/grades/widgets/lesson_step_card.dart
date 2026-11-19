import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/note_models.dart';

/// Card presenting an individual numbered study or practice step matching the design screenshot.
class LessonStepCard extends StatelessWidget {
  final LessonStep step;

  const LessonStepCard({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Soft grey container matching screenshot
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle badge in burnt orange / terracotta
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF9E380E),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${step.number}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Step instruction text with inline bold keywords
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.45,
                    color: const Color(0xFF334155),
                  ),
                  children: _buildSpans(step.text),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parses text with **bold** markers or known highlighted keywords into styled TextSpans.
  List<TextSpan> _buildSpans(String rawText) {
    // If text contains **bold** markdown tags
    if (rawText.contains('**')) {
      final spans = <TextSpan>[];
      final parts = rawText.split('**');
      for (int i = 0; i < parts.length; i++) {
        final isBold = i % 2 == 1;
        if (parts[i].isNotEmpty) {
          spans.add(
            TextSpan(
              text: parts[i],
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold ? const Color(0xFF0F172A) : const Color(0xFF334155),
              ),
            ),
          );
        }
      }
      return spans;
    }

    // Keyword based fallback highlighting
    final keywords = [
      'Greatest Common Factor (GCF)',
      'Greatest Common Factor',
      'simplest form',
    ];

    String text = rawText;
    for (final kw in keywords) {
      if (text.contains(kw)) {
        final idx = text.indexOf(kw);
        final before = text.substring(0, idx);
        final match = text.substring(idx, idx + kw.length);
        final after = text.substring(idx + kw.length);

        return [
          if (before.isNotEmpty)
            TextSpan(
              text: before,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          TextSpan(
            text: match,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          if (after.isNotEmpty)
            TextSpan(
              text: after,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
        ];
      }
    }

    return [
      TextSpan(
        text: rawText,
        style: const TextStyle(fontWeight: FontWeight.w400),
      ),
    ];
  }
}
