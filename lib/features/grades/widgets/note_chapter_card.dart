import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../models/note_models.dart';

/// Reusable card displaying an individual chapter note item with Read and Download actions.
class NoteChapterCard extends StatelessWidget {
  final ChapterNoteItem chapter;
  final VoidCallback onRead;
  final VoidCallback onDownload;

  const NoteChapterCard({
    super.key,
    required this.chapter,
    required this.onRead,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter number badge (Orange pill/circle)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.orange500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              chapter.chapterNumber,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Chapter title
          Text(
            chapter.title,
            style: GoogleFonts.inter(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.headlineDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),

          // Description
          Text(
            chapter.description,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Meta row (Page count & file size)
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                chapter.pageCount,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.description_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                chapter.fileSize,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action buttons row (Read & Download)
          Row(
            children: [
              // Read button (Orange pill)
              Expanded(
                child: InkWell(
                  onTap: onRead,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: AppColors.orange500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Read',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Download button (Light grey pill)
              Expanded(
                child: InkWell(
                  onTap: onDownload,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.file_download_outlined,
                          size: 15,
                          color: AppColors.orange500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Download',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headlineDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

