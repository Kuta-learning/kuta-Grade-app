import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/router/route_names.dart';
import 'package:kuta_learning_app/core/widgets/app_snackbar.dart';
import 'shared/widgets/grade_screen_shell.dart';

/// Screen presenting individual chapter notes, study summaries, and downloadable PDFs
/// for a selected subject and grade level (e.g. Mathematics - Grade 12).
class NoteDetailScreen extends StatefulWidget {
  final String subjectTitle;
  final String gradeLevel;

  const NoteDetailScreen({
    super.key,
    this.subjectTitle = 'Mathematics',
    this.gradeLevel = 'Grade 12',
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late String _selectedGrade;
  late final List<_ChapterNoteItem> _chapters;

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.gradeLevel;
    _chapters = const [
      _ChapterNoteItem(
        chapterNumber: '01',
        title: 'Sequences and Series',
        description:
            'Arithmetic & Geometric progressions, sum to infinity, sigma notation, convergence limits.',
        pageCount: '12 pages',
        fileSize: '2.4 MB',
      ),
      _ChapterNoteItem(
        chapterNumber: '02',
        title: 'Introduction to Calculus & Limits',
        description:
            'One-sided limits, algebraic continuity, vertical/horizontal asymptotes, and L\'Hôpital\'s rule.',
        pageCount: '18 pages',
        fileSize: '3.1 MB',
      ),
      _ChapterNoteItem(
        chapterNumber: '03',
        title: 'Derivatives and Applications',
        description:
            'Product & chain rule, implicit differentiation, optimization problems, related rates.',
        pageCount: '24 pages',
        fileSize: '4.0 MB',
      ),
      _ChapterNoteItem(
        chapterNumber: '04',
        title: 'Integrals and Applications',
        description:
            'Definite/indefinite integrals, substitution technique, area bounded under curve, Riemann sums.',
        pageCount: '20 pages',
        fileSize: '3.8 MB',
      ),
      _ChapterNoteItem(
        chapterNumber: '05',
        title: 'Vectors in Two & Three Dimensions',
        description:
            'Dot product, cross product geometric interpretations, lines & planes in 3D Cartesian space.',
        pageCount: '16 pages',
        fileSize: '2.9 MB',
      ),
    ];
  }

  void _onDownloadAll() {
    AppSnackBar.showSuccess(
      context,
      'Downloading all Grade 12 Mathematics notes (42 MB)...',
    );
  }

  void _onReadChapter(_ChapterNoteItem chapter) {
    context.push(
      '${RouteNames.lessonDetail}'
      '?subject=${Uri.encodeComponent(widget.subjectTitle)}'
      '&gradeLevel=${Uri.encodeComponent(widget.gradeLevel)}'
      '&chapterTitle=${Uri.encodeComponent(chapter.title)}'
      '&chapterNumber=${Uri.encodeComponent(chapter.chapterNumber)}',
    );
  }

  void _onDownloadChapter(_ChapterNoteItem chapter) {
    AppSnackBar.showSuccess(
      context,
      'Downloading Chapter ${chapter.chapterNumber} (${chapter.fileSize})...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.navy700,
          child: SafeArea(
            bottom: false,
            child: GradeExamAppBar(
              title: 'Note Detail',
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Breadcrumb and Grade Selector Pill Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Breadcrumb trail
                  Row(
                    children: [
                      Text(
                        'Notes',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '>',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        'Maths',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '>',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        _selectedGrade,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange900,
                        ),
                      ),
                    ],
                  ),

                  // Grade Selector Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.borderVariant.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.orange500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _selectedGrade,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headlineDark,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Mathematics - Grade 12 Summary Banner Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  gradient: const RadialGradient(
                    center: Alignment(0.9, -0.9),
                    radius: 1.15,
                    colors: [
                      Color(0xFFFFF2EA),
                      Color(0xFFFFFAF6),
                      Colors.white,
                    ],
                    stops: [0.0, 0.45, 0.85],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderVariant.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                  boxShadow: AppElevation.cardLow,
                ),
                child: Stack(
                  children: [
                    // Watermark symbol matching the reference screenshot in the top-right corner
                    Positioned(
                      right: 18,
                      top: 14,
                      child: Transform.flip(
                        flipX: true,
                        child: Text(
                          'Σ',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9D4300).withValues(alpha: 0.12),
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),

                    // Card Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mathematics - $_selectedGrade',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.headlineDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '14 Chapters Available • PDF & Interactive Reader •',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.authBrown,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Download All Notes Pill Button
                          InkWell(
                            onTap: _onDownloadAll,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: double.infinity,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cloud_download_outlined,
                                    size: 19,
                                    color: AppColors.navy700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Download All Notes (42 MB)',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navy700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Section Title & Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Chapter Notes',
                        style: GoogleFonts.inter(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.headlineDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(Showing ${_chapters.length} of 14)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppColors.headlineDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Chapter Cards List
              ListView.separated(
                itemCount: _chapters.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 13),
                itemBuilder: (context, index) {
                  final chapter = _chapters[index];
                  return _ChapterCard(
                    chapter: chapter,
                    onRead: () => _onReadChapter(chapter),
                    onDownload: () => _onDownloadChapter(chapter),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterNoteItem {
  final String chapterNumber;
  final String title;
  final String description;
  final String pageCount;
  final String fileSize;

  const _ChapterNoteItem({
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.pageCount,
    required this.fileSize,
  });
}

class _ChapterCard extends StatelessWidget {
  final _ChapterNoteItem chapter;
  final VoidCallback onRead;
  final VoidCallback onDownload;

  const _ChapterCard({
    required this.chapter,
    required this.onRead,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderVariant.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge (orange circle)
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: AppColors.orange500,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              chapter.chapterNumber,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Chapter Title
          Text(
            chapter.title,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.headlineDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Chapter Description
          Text(
            chapter.description,
            style: GoogleFonts.inter(
              fontSize: 11.2,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Metadata row (Pages & File size)
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 13,
                color: AppColors.headlineDark,
              ),
              const SizedBox(width: 4),
              Text(
                chapter.pageCount,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.headlineDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '•',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Icon(
                Icons.insert_drive_file_outlined,
                size: 13,
                color: AppColors.headlineDark,
              ),
              const SizedBox(width: 4),
              Text(
                chapter.fileSize,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.headlineDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
