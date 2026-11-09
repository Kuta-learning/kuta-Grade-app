import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/models/user_model.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/models/profile_model.dart';
import '../bloc/grades_bloc.dart';
import '../models/note_models.dart';

import '../widgets/grade_screen_shell.dart';
import '../widgets/notes_loading_skeleton.dart';

/// Screen presenting the Curriculum notes, study guides & cheat sheets
/// per subject and grade level, automatically tailoring content to the student's grade.
class HighSchoolNotesScreen extends StatefulWidget {
  final bool showBottomNav;

  const HighSchoolNotesScreen({
    super.key,
    this.showBottomNav = false,
  });

  @override
  State<HighSchoolNotesScreen> createState() => _HighSchoolNotesScreenState();
}

class _HighSchoolNotesScreenState extends State<HighSchoolNotesScreen> {
  // Local cached state to ensure instant recovery during back navigation
  List<NoteSubjectItem>? _subjects;
  String? _curriculumType;
  int _studentGrade = 12;
  Set<int> _expandedIndices = {0}; // Mathematics expanded by default (Grade 12)
  Map<int, String> _selectedGrades = {0: 'Grade 12'}; // Grade 12 selected by default

  @override
  void initState() {
    super.initState();
    _studentGrade = _resolveInitialStudentGrade();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCachedStorageGrade();
      try {
        final bloc = context.read<NotesBloc>();
        // Force refresh when: (a) grade mismatch with cached grade, OR
        // (b) cached subjects exist but were loaded for a different grade
        // (cachedStudentGrade is null means first load — still refresh if
        //  subjects are cached so stale cross-grade data never shows).
        final cachedGrade = bloc.cachedStudentGrade;
        final hasCachedSubjects =
            bloc.cachedSubjects != null && bloc.cachedSubjects!.isNotEmpty;
        final gradeMismatch =
            cachedGrade != null && cachedGrade != _studentGrade;
        // If subjects are cached but we don't know which grade they belong to,
        // treat it as a mismatch so we always load fresh data for the student.
        final unknownGradeCached = hasCachedSubjects && cachedGrade == null;
        final needsRefresh = gradeMismatch || unknownGradeCached;

        if (!needsRefresh && hasCachedSubjects) {
          setState(() {
            _subjects = bloc.cachedSubjects;
            _curriculumType = bloc.cachedCurriculumType;
            if (bloc.cachedStudentGrade != null) {
              _studentGrade = bloc.cachedStudentGrade!;
            }
            _expandedIndices = Set<int>.from(bloc.cachedExpanded);
            _selectedGrades = Map<int, String>.from(bloc.cachedSelectedGrades);
          });
        }
        if (needsRefresh || bloc.state is! NotesSubjectsLoaded) {
          bloc.add(LoadNotesSubjects(forceRefresh: needsRefresh));
        }
      } catch (_) {
        // BlocProvider unavailable — error shown via NotesError state
      }
    });
  }

  Future<void> _checkCachedStorageGrade() async {
    try {
      final storage = SharedPrefsStorage.instanceOrNull;
      if (storage != null) {
        final rawUser = await storage.getString(StorageKeys.authUser);
        if (rawUser != null && rawUser.isNotEmpty) {
          final user = UserModel.fromJsonString(rawUser);
          final cachedGrade = _extractGradeFromEntity(user);
          if (cachedGrade != null &&
              cachedGrade > 0 &&
              cachedGrade != _studentGrade &&
              mounted) {
            setState(() {
              _studentGrade = cachedGrade;
            });
            try {
              context
                  .read<NotesBloc>()
                  .add(const LoadNotesSubjects(forceRefresh: true));
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  /// Extracts the numeric grade level from [UserModel] or [ProfileModel].
  int? _extractGradeFromEntity(dynamic entity) {
    if (entity == null) return null;
    if (entity is UserModel && entity.gradeLevel != null) {
      final val = entity.gradeLevel!.numericValue;
      if (val > 0) return val;
    }
    if (entity is ProfileModel && entity.gradeLevel != null) {
      final val = entity.gradeLevel!.numericValue;
      if (val > 0) return val;
    }
    return null;
  }

  /// Fast synchronous grade resolution from in-memory Blocs and SharedPreferences cache.
  int _resolveInitialStudentGrade() {
    // 1. Check AuthBloc in-memory state
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final g = _extractGradeFromEntity(authState.user);
        if (g != null) return g;
      }
    } catch (_) {}

    // 2. Check ProfileBloc in-memory state
    try {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        final g = _extractGradeFromEntity(profileState.profile);
        if (g != null) return g;
      }
    } catch (_) {}

    // 3. Default fallback
    return 12;
  }

  void _onToggle(int index, NotesBloc? bloc) {
    if (bloc != null) {
      bloc.add(ToggleSubjectExpand(index));
    }
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  void _onSelectGrade(
    int subjectIndex,
    String gradeName,
    NoteSubjectItem subject,
    NotesBloc? bloc,
  ) {
    if (bloc != null) {
      bloc.add(SelectGradeLevel(subjectIndex, gradeName));
    }
    setState(() {
      _selectedGrades[subjectIndex] = gradeName;
    });

    // Navigate to Note Detail for the selected subject and grade
    context.push(
      '${RouteNames.noteDetail}'
      '?subject=${Uri.encodeComponent(subject.name)}'
      '&gradeLevel=${Uri.encodeComponent(gradeName)}'
      '&subjectId=${Uri.encodeComponent(subject.id)}',
    );
  }

  void _onOpenPrimarySubject(NoteSubjectItem subject, int studentGrade) {
    final gradeLabel = subject.gradeBadge ?? 'Grade $studentGrade';
    context.push(
      '${RouteNames.noteDetail}'
      '?subject=${Uri.encodeComponent(subject.name)}'
      '&gradeLevel=${Uri.encodeComponent(gradeLabel)}'
      '&subjectId=${Uri.encodeComponent(subject.id)}',
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

    final currentGrade = (bloc?.state is NotesSubjectsLoaded)
        ? ((bloc!.state as NotesSubjectsLoaded).studentGrade ?? _studentGrade)
        : (bloc?.cachedStudentGrade ?? _studentGrade);
    final isPrimary = currentGrade <= 8;

    final currentCurriculum = (bloc?.state is NotesSubjectsLoaded)
        ? (bloc!.state as NotesSubjectsLoaded).curriculumType
        : (bloc?.cachedCurriculumType ?? _curriculumType);
    // Use isPrimary (derived from the already-resolved currentGrade) as the
    // source of truth for the curriculum title so it is correct even before
    // the API responds — avoids briefly showing "High School Curriculum" for
    // primary grade students.
    final curriculumTitle = currentCurriculum ??
        (isPrimary ? 'Primary School Curriculum' : 'High School Curriculum');

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surfaceApp,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.brandPrimary, // Match other bottom-nav tab headers
          child: SafeArea(
            bottom: false,
            child: GradeExamAppBar(
              title: 'Notes',
              showBackButton: false, // Main tab screen: no back arrow
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 108),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle guide text tailored to curriculum
              Text(
                isPrimary
                    ? 'Select a subject to access\nsummarized study guides & cheat sheets.'
                    : 'Select a subject and grade to access\nsummarized study guides & cheat sheets.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: AppColors.authBrown,
                ),
              ),
              const SizedBox(height: 16),

              if (bloc != null)
                BlocConsumer<NotesBloc, NotesState>(
                  listener: (context, state) {
                    if (state is NotesSubjectsLoaded) {
                      setState(() {
                        _subjects = state.subjects;
                        _curriculumType = state.curriculumType;
                        if (state.studentGrade != null) {
                          _studentGrade = state.studentGrade!;
                        }
                        _expandedIndices = Set<int>.from(state.expandedIndices);
                        _selectedGrades =
                            Map<int, String>.from(state.selectedGrades);
                      });
                    }
                  },
                  builder: (context, state) {
                    final displaySubjects = (state is NotesSubjectsLoaded)
                        ? state.subjects
                        : (_subjects ?? bloc?.cachedSubjects);
                    final displayExpanded = (state is NotesSubjectsLoaded)
                        ? state.expandedIndices
                        : (_expandedIndices.isNotEmpty
                            ? _expandedIndices
                            : (bloc?.cachedExpanded ?? const {0}));
                    final displaySelected = (state is NotesSubjectsLoaded)
                        ? state.selectedGrades
                        : (_selectedGrades.isNotEmpty
                            ? _selectedGrades
                            : (bloc?.cachedSelectedGrades ??
                                const {0: 'Grade 12'}));

                    final subjectCount = displaySubjects?.length ?? 0;
                    final subjectCountText = subjectCount > 0
                        ? '$subjectCount Subjects'
                        : (isPrimary ? '4 Subjects' : '6 Subjects');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title & subject counter row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              curriculumTitle,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.headlineDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              subjectCountText,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (displaySubjects != null && displaySubjects.isNotEmpty)
                          _buildSubjectList(
                            displaySubjects,
                            displayExpanded,
                            displaySelected,
                            bloc,
                            isPrimary,
                            currentGrade,
                          )
                        else if (state is NotesLoading)
                          const NotesLoadingSkeleton(itemCount: 4)
                        else
                          const NotesLoadingSkeleton(itemCount: 4),
                      ],
                    );
                  },
                )
              else if (_subjects != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curriculumTitle,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.headlineDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      '${_subjects!.length} Subjects',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSubjectList(
                  _subjects!,
                  _expandedIndices,
                  _selectedGrades,
                  null,
                  isPrimary,
                  currentGrade,
                ),
              ] else
                const NotesLoadingSkeleton(itemCount: 4),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const GradeBottomNavBar(currentIndex: 1)
          : null,
    );
  }

  Widget _buildSubjectList(
    List<NoteSubjectItem> subjects,
    Set<int> expandedIndices,
    Map<int, String> selectedGrades,
    NotesBloc? bloc,
    bool isPrimary,
    int currentGrade,
  ) {
    return ListView.separated(
      itemCount: subjects.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final isExpanded = expandedIndices.contains(index);
        final selectedGrade = selectedGrades[index];

        return _SubjectCard(
          subject: subject,
          isExpanded: isExpanded,
          selectedGrade: selectedGrade,
          isPrimary: isPrimary,
          studentGrade: currentGrade,
          onToggle: () => _onToggle(index, bloc),
          onSelectGrade: (gradeName) =>
              _onSelectGrade(index, gradeName, subject, bloc),
          onOpenPrimary: (s) => _onOpenPrimarySubject(s, currentGrade),
        );
      },
    );
  }
}

/// Typedef alias for alternative import references
typedef GradeNotesScreen = HighSchoolNotesScreen;

class _SubjectCard extends StatelessWidget {
  final NoteSubjectItem subject;
  final bool isExpanded;
  final String? selectedGrade;
  final bool isPrimary;
  final int studentGrade;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelectGrade;
  final ValueChanged<NoteSubjectItem>? onOpenPrimary;

  const _SubjectCard({
    required this.subject,
    required this.isExpanded,
    required this.selectedGrade,
    this.isPrimary = false,
    this.studentGrade = 12,
    required this.onToggle,
    required this.onSelectGrade,
    this.onOpenPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final grades = subject.grades.isNotEmpty
        ? subject.grades
        : (isPrimary
            ? [
                NoteGradeOption(
                  name: 'Grade $studentGrade',
                  chapters: '${subject.totalChapters} Chapters',
                  gradeLevel: studentGrade,
                )
              ]
            : const [
                NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
                NoteGradeOption(name: 'Grade 10', chapters: '10 Chapters', gradeLevel: 10),
                NoteGradeOption(name: 'Grade 11', chapters: '12 Chapters', gradeLevel: 11),
                NoteGradeOption(name: 'Grade 12', chapters: '14 Chapters', gradeLevel: 12),
              ]);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Tappable: directly navigates if primary, expands if high school)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isPrimary
                  ? () => onOpenPrimary?.call(subject)
                  : onToggle,
              child: Row(
                children: [
                  _buildIcon(subject),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.headlineDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (isPrimary) ...[
                          const SizedBox(height: 3),
                          Text(
                            subject.gradeBadge ?? 'Grade $studentGrade',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ] else if (!isExpanded) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Tap to choose Grade 9–12',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Circular chevron indicator button
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPrimary
                          ? Icons.chevron_right_rounded
                          : (isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded),
                      color: const Color(0xFF475569),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Grid of Grades (only for High School multiple grade selections)
            if (!isPrimary && isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                'Select  grade level:',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authBrown,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 10.0;
                  final itemWidth = (constraints.maxWidth - spacing) / 2;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: grades.map((grade) {
                      final isSelected = selectedGrade == grade.name;
                      return SizedBox(
                        width: itemWidth,
                        child: _GradeTile(
                          grade: grade,
                          isSelected: isSelected,
                          onTap: () => onSelectGrade(grade.name),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(NoteSubjectItem subject) {
    Color bgColor;
    Color iconColor;
    Widget iconWidget;

    final normName = subject.name.toLowerCase();
    if (normName.contains('math') || normName.contains('ሒሳብ')) {
      bgColor = const Color(0xFFFFDBCA);
      iconColor = const Color(0xFF341100);
      iconWidget = Text(
        'Σ',
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: iconColor,
        ),
      );
    } else if (normName.contains('physic')) {
      bgColor = const Color(0xFFDBE9FF);
      iconColor = const Color(0xFF1A56DB);
      iconWidget = Icon(Icons.offline_bolt_outlined, color: iconColor, size: 24);
    } else if (normName.contains('chem')) {
      bgColor = const Color(0xFF6BFF8F);
      iconColor = const Color(0xFF003914);
      iconWidget = Icon(Icons.science_outlined, color: iconColor, size: 24);
    } else if (normName.contains('bio')) {
      bgColor = const Color(0xFFE8ECEF);
      iconColor = const Color(0xFF9D4300);
      iconWidget = Icon(Icons.psychology_outlined, color: iconColor, size: 24);
    } else if (normName.contains('eng')) {
      bgColor = const Color(0xFFDBE9FF);
      iconColor = const Color(0xFF1A56DB);
      iconWidget = Icon(Icons.menu_book_rounded, color: iconColor, size: 24);
    } else if (normName.contains('civic') || normName.contains('ethic')) {
      bgColor = const Color(0xFFE0C0B1);
      iconColor = const Color(0xFF584237);
      iconWidget = Icon(Icons.balance_rounded, color: iconColor, size: 24);
    } else {
      bgColor = subject.iconBgColor;
      iconColor = subject.iconColor;
      iconWidget = subject.isSymbol
          ? Text(
              subject.symbol ?? 'Σ',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            )
          : Icon(Icons.menu_book_rounded, color: iconColor, size: 24);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: iconWidget,
    );
  }
}

class _GradeTile extends StatelessWidget {
  final NoteGradeOption grade;
  final bool isSelected;
  final VoidCallback onTap;

  const _GradeTile({
    required this.grade,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warm peach background when selected, light grey when unselected matching screenshot
    final bgColor =
        isSelected ? const Color(0xFFFFDBCA) : const Color(0xFFF1F5F9);
    final titleColor =
        isSelected ? AppColors.buttonTextBrown : AppColors.headlineDark;
    final subtitleColor =
        isSelected ? AppColors.orange900 : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  grade.name,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                if (!isSelected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              grade.chapters,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
