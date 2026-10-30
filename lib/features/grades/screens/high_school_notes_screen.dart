import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../bloc/grades_bloc.dart';
import '../models/note_models.dart';
import '../services/mock_notes_service.dart';
import '../widgets/grade_screen_shell.dart';
import '../widgets/notes_loading_skeleton.dart';

/// Screen presenting the High School Curriculum notes, study guides & cheat sheets
/// per subject and grade level, exactly matching the reference screenshot.
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
  Set<int> _expandedIndices = {0}; // Mathematics expanded by default
  Map<int, String> _selectedGrades = {0: 'Grade 12'}; // Grade 12 selected by default
  List<NoteSubjectItem>? _fallbackSubjects;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final bloc = context.read<NotesBloc>();
        if (bloc.cachedSubjects != null && bloc.cachedSubjects!.isNotEmpty) {
          setState(() {
            _subjects = bloc.cachedSubjects;
            _expandedIndices = Set<int>.from(bloc.cachedExpanded);
            _selectedGrades = Map<int, String>.from(bloc.cachedSelectedGrades);
          });
        }
        if (bloc.state is! NotesSubjectsLoaded) {
          bloc.add(const LoadNotesSubjects());
        }
      } catch (_) {
        // Fallback for isolated widget testing without BlocProvider
        MockNotesService().getShortNotesSubjects().then((data) {
          if (mounted) {
            setState(() {
              _fallbackSubjects = data;
              _subjects = data;
            });
          }
        });
      }
    });
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
              title: 'Notes',
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.examSimulator);
                }
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle guide text matching screenshot
              Text(
                'Select a subject and grade to access\nsummarized study guides & cheat sheets.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: AppColors.authBrown,
                ),
              ),
              const SizedBox(height: 16),

              // Section title & subject counter row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'High School Curriculum',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headlineDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '6 Subjects',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (bloc != null)
                BlocConsumer<NotesBloc, NotesState>(
                  listener: (context, state) {
                    if (state is NotesSubjectsLoaded) {
                      setState(() {
                        _subjects = state.subjects;
                        _expandedIndices = Set<int>.from(state.expandedIndices);
                        _selectedGrades =
                            Map<int, String>.from(state.selectedGrades);
                      });
                    }
                  },
                  builder: (context, state) {
                    final displaySubjects = (state is NotesSubjectsLoaded)
                        ? state.subjects
                        : (_subjects ??
                            bloc?.cachedSubjects ??
                            _fallbackSubjects);
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

                    if (displaySubjects != null && displaySubjects.isNotEmpty) {
                      return _buildSubjectList(
                        displaySubjects,
                        displayExpanded,
                        displaySelected,
                        bloc,
                      );
                    }
                    if (state is NotesLoading) {
                      return const NotesLoadingSkeleton(itemCount: 4);
                    }
                    return const NotesLoadingSkeleton(itemCount: 4);
                  },
                )
              else if (_fallbackSubjects != null || _subjects != null)
                _buildSubjectList(
                  _subjects ?? _fallbackSubjects!,
                  _expandedIndices,
                  _selectedGrades,
                  null,
                )
              else
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
          onToggle: () => _onToggle(index, bloc),
          onSelectGrade: (gradeName) =>
              _onSelectGrade(index, gradeName, subject, bloc),
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
  final VoidCallback onToggle;
  final ValueChanged<String> onSelectGrade;

  const _SubjectCard({
    required this.subject,
    required this.isExpanded,
    required this.selectedGrade,
    required this.onToggle,
    required this.onSelectGrade,
  });

  @override
  Widget build(BuildContext context) {
    final grades = subject.grades.isNotEmpty
        ? subject.grades
        : const [
            NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
            NoteGradeOption(name: 'Grade 10', chapters: '10 Chapters', gradeLevel: 10),
            NoteGradeOption(name: 'Grade 11', chapters: '12 Chapters', gradeLevel: 11),
            NoteGradeOption(name: 'Grade 12', chapters: '14 Chapters', gradeLevel: 12),
          ];

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
            // Header Row (Tappable to expand / collapse)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onToggle,
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
                        if (!isExpanded) ...[
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
                  // Circular chevron indicator button matching screenshot
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF475569),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Grid of Grades matching screenshot
            if (isExpanded) ...[
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
    if (normName.contains('math')) {
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
