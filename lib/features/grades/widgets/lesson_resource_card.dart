import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../models/note_models.dart';

/// Card presenting a downloadable lesson resource document or worksheet matching the screenshot.
class LessonResourceCard extends StatelessWidget {
  final LessonResource resource;
  final VoidCallback onDownload;

  const LessonResourceCard({
    super.key,
    required this.resource,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = resource.title.toLowerCase().endsWith('.pdf') ||
        resource.fileType.toLowerCase().contains('pdf');

    final iconBgColor =
        isPdf ? const Color(0xFFFFECEF) : const Color(0xFFE8F1FC);
    final iconColor =
        isPdf ? const Color(0xFFDC2626) : const Color(0xFF2563EB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Container matching screenshot
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.article_outlined,
              size: 22,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),

          // File title and meta description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${resource.fileSize} • ${resource.fileType}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Download action button with tray download icon
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              size: 22,
              color: Color(0xFF475569),
            ),
            tooltip: 'Download',
            splashRadius: 20,
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}
