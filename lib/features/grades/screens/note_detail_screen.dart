import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../bloc/grades_bloc.dart';
import '../models/note_models.dart';
import '../services/mock_notes_service.dart';
import '../widgets/grade_screen_shell.dart';
import '../widgets/note_chapter_card.dart';
import '../widgets/notes_loading_skeleton.dart';

/// Screen presenting individual chapter notes, study summaries, and downloadable PDFs
/// for a selected subject and grade level, integrated with [NotesBloc].
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
  SubjectNotesDetail? _detail;
  SubjectNotesDetail? _fallbackDetail;

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.gradeLevel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final bloc = context.read<NotesBloc>();
        final cached = bloc.getCachedDetail(widget.subjectTitle);
        if (cached != null) {
          setState(() => _detail = cached);
        } else {
          bloc.add(LoadSubjectNotesDetail(widget.subjectTitle));
        }
      } catch (_) {
        MockNotesService()
            .getSubjectNotesDetails(widget.subjectTitle)
            .then((data) {
          if (mounted) setState(() => _fallbackDetail = data);
        });
      }
    });
  }

  void _onDownloadAll() {
    AppSnackBar.showSuccess(
      context,
      'Downloading all $_selectedGrade ${widget.subjectTitle} notes...',
    );
  }

  void _onReadChapter(ChapterNoteItem chapter) {
    context.push(
      '${RouteNames.lessonDetail}'
      '?subject=${Uri.encodeComponent(widget.subjectTitle)}'
      '&gradeLevel=${Uri.encodeComponent(_selectedGrade)}'
      '&chapterTitle=${Uri.encodeComponent(chapter.title)}'
      '&chapterNumber=${Uri.encodeComponent(chapter.chapterNumber)}'
      '&chapterId=${Uri.encodeComponent(chapter.id)}',
    );
  }

  void _onDownloadChapter(ChapterNoteItem chapter) {
    AppSnackBar.showSuccess(
      context,
      'Downloading Chapter ${chapter.chapterNumber} (${chapter.fileSize})...',
    );
  }

  @override
  Widget build(BuildContext context) {
    NotesBloc? bloc;
    try {
      bloc = context.read<NotesBloc>();
    } catch (_) {
      bloc = null;
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.brandBlue,
          child: SafeArea(
            bottom: false,
            child: GradeExamAppBar(
              title: 'Note Detail',
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.highSchoolNotes);
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
                        widget.subjectTitle,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

              // 2. Hero Subject Card
              _SubjectHeroCard(
                title: '${widget.subjectTitle} - $_selectedGrade',
                subtitle: '14 Chapters Available • PDF & Interactive Reader',
                onDownloadAll: _onDownloadAll,
              ),
              const SizedBox(height: 20),

              // 3. Section Title & Filter Icon Row
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
                        '(Showing 5 of 14)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
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

              // 4. Chapter Notes List (from Bloc or Fallback)
              if (bloc != null)
                BlocConsumer<NotesBloc, NotesState>(
                  listener: (context, state) {
                    if (state is SubjectNotesDetailLoaded) {
                      setState(() => _detail = state.detail);
                    }
                  },
                  builder: (context, state) {
                    final detail = (state is SubjectNotesDetailLoaded)
                        ? state.detail
                        : (_detail ??
                            bloc?.getCachedDetail(widget.subjectTitle) ??
                            _fallbackDetail);

                    if (detail != null) {
                      return _buildChaptersList(detail.chapters);
                    }
                    if (state is NotesLoading) {
                      return const NotesLoadingSkeleton(itemCount: 4);
                    }
                    return const NotesLoadingSkeleton(itemCount: 4);
                  },
                )
              else if (_fallbackDetail != null || _detail != null)
                _buildChaptersList((_detail ?? _fallbackDetail)!.chapters)
              else
                const NotesLoadingSkeleton(itemCount: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChaptersList(List<ChapterNoteItem> chapters) {
    return ListView.separated(
      itemCount: chapters.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return NoteChapterCard(
          chapter: chapter,
          onRead: () => _onReadChapter(chapter),
          onDownload: () => _onDownloadChapter(chapter),
        );
      },
    );
  }
}

/// Hero card at top of NoteDetailScreen
class _SubjectHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onDownloadAll;

  const _SubjectHeroCard({
    required this.title,
    required this.subtitle,
    required this.onDownloadAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderVariant, width: 1),
        boxShadow: AppElevation.cardLow,
      ),
      child: Stack(
        children: [
          // Background soft orange gradient aura on the top right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 130,
              height: 110,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.2,
                  colors: [
                    Color(0x33FFB68D),
                    Color(0x00FFB68D),
                  ],
                ),
              ),
            ),
          ),

          // Faded math symbol watermark
          Positioned(
            right: 15,
            top: 15,
            child: Text(
              'Σ',
              style: GoogleFonts.inter(
                fontSize: 60,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFDE8DE),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headlineDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: onDownloadAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.file_download_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Download All Notes (42 MB)',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
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
    );
  }
}

