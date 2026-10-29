import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/router/route_names.dart';
import 'shared/widgets/grade_screen_shell.dart';

/// Screen presenting the High School Curriculum notes, study guides & cheat sheets
/// per subject and grade level, matching the design specifications.
class HighSchoolNotesScreen extends StatefulWidget {
  const HighSchoolNotesScreen({super.key});

  @override
  State<HighSchoolNotesScreen> createState() => _HighSchoolNotesScreenState();
}

class _HighSchoolNotesScreenState extends State<HighSchoolNotesScreen> {
  // Set of expanded subject indices. Subject 0 (Mathematics) is expanded by default.
  final Set<int> _expandedIndices = {0};

  // Map of selected grade name per subject index. Mathematics defaults to Grade 12.
  final Map<int, String> _selectedGrades = {0: 'Grade 12'};

  late final List<_SubjectItem> _subjects;

  @override
  void initState() {
    super.initState();
    _subjects = [
      const _SubjectItem(
        name: 'Mathematics',
        iconBgColor: Color(0xFFFFDBCA),
        iconColor: Color(0xFF341100),
        isSymbol: true,
        symbol: 'Σ',
        grades: [
          _GradeOption(name: 'Grade 9', chapters: '8 Chapters'),
          _GradeOption(name: 'Grade 10', chapters: '10 Chapters'),
          _GradeOption(name: 'Grade 11', chapters: '12 Chapters'),
          _GradeOption(name: 'Grade 12', chapters: '14 Chapters'),
        ],
      ),
      const _SubjectItem(
        name: 'Physics',
        iconBgColor: Color(0xFFD7E3FF),
        iconColor: AppColors.navy700,
        iconData: Icons.offline_bolt_outlined,
        grades: [
          _GradeOption(name: 'Grade 9', chapters: '7 Chapters'),
          _GradeOption(name: 'Grade 10', chapters: '8 Chapters'),
          _GradeOption(name: 'Grade 11', chapters: '10 Chapters'),
          _GradeOption(name: 'Grade 12', chapters: '12 Chapters'),
        ],
      ),
      const _SubjectItem(
        name: 'Chemistry',
        iconBgColor: Color(0xFF6BFF8F),
        iconColor: Color(0xFF003914),
        iconData: Icons.science_outlined,
        grades: [
          _GradeOption(name: 'Grade 9', chapters: '6 Chapters'),
          _GradeOption(name: 'Grade 10', chapters: '8 Chapters'),
          _GradeOption(name: 'Grade 11', chapters: '10 Chapters'),
          _GradeOption(name: 'Grade 12', chapters: '12 Chapters'),
        ],
      ),
      const _SubjectItem(
        name: 'Biology',
        iconBgColor: Color(0xFFE6E8EA),
        iconColor: AppColors.orange900,
        iconData: Icons.psychology_outlined,
        grades: [
          _GradeOption(name: 'Grade 9', chapters: '6 Chapters'),
          _GradeOption(name: 'Grade 10', chapters: '7 Chapters'),
          _GradeOption(name: 'Grade 11', chapters: '9 Chapters'),
          _GradeOption(name: 'Grade 12', chapters: '11 Chapters'),
        ],
      ),
      _SubjectItem(
        name: 'English',
        iconBgColor: const Color(0xFFABC7FF),
        iconColor: const Color(0xFF002D6C),
        customIcon: SvgPicture.asset(
          'assets/icons/menu_book.svg',
          width: 23,
          height: 18,
          colorFilter: const ColorFilter.mode(
            Color(0xFF002D6C),
            BlendMode.srcIn,
          ),
        ),
        grades: const [
          _GradeOption(name: 'Grade 9', chapters: '8 Chapters'),
          _GradeOption(name: 'Grade 10', chapters: '9 Chapters'),
          _GradeOption(name: 'Grade 11', chapters: '10 Chapters'),
          _GradeOption(name: 'Grade 12', chapters: '12 Chapters'),
        ],
      ),
      const _SubjectItem(
        name: 'Civics & Ethics',
        iconBgColor: Color(0xFFE0C0B1),
        iconColor: AppColors.authBrown,
        iconData: Icons.balance_rounded,
        grades: [
          _GradeOption(name: 'Grade 9', chapters: '5 Chapters'),
          _GradeOption(name: 'Grade 10', chapters: '6 Chapters'),
          _GradeOption(name: 'Grade 11', chapters: '8 Chapters'),
          _GradeOption(name: 'Grade 12', chapters: '10 Chapters'),
        ],
      ),
    ];
  }

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  void _selectGrade(int subjectIndex, String gradeName) {
    setState(() {
      _selectedGrades[subjectIndex] = gradeName;
    });
    // Navigates to Note Detail when Mathematics -> Grade 12 is selected
    if (_subjects[subjectIndex].name == 'Mathematics' && gradeName == 'Grade 12') {
      context.push(RouteNames.noteDetail);
    }
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
              title: 'Notes',
              onBackPressed: () => context.go(RouteNames.grade12MatricExam),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          // Substantial bottom padding creates the prominent gap between Civics & Ethics and the navbar
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 85),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle guide text
              Text(
                'Select a subject and grade to access\nsummarized study guides & cheat sheets.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.38,
                  fontWeight: FontWeight.w400,
                  color: AppColors.authBrown,
                ),
              ),
              const SizedBox(height: 18),

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

              // Curriculum subjects list
              ListView.separated(
                itemCount: _subjects.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 13),
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final isExpanded = _expandedIndices.contains(index);
                  final selectedGrade = _selectedGrades[index];

                  return _SubjectCard(
                    subject: subject,
                    isExpanded: isExpanded,
                    selectedGrade: selectedGrade,
                    onToggle: () => _toggleExpansion(index),
                    onSelectGrade: (gradeName) => _selectGrade(index, gradeName),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GradeBottomNavBar(
        currentIndex: 1, // 'Notes' active tab
      ),
    );
  }
}

/// Typedef alias for alternative import references
typedef GradeNotesScreen = HighSchoolNotesScreen;

class _SubjectItem {
  final String name;
  final Color iconBgColor;
  final Color iconColor;
  final bool isSymbol;
  final String? symbol;
  final IconData? iconData;
  final Widget? customIcon;
  final List<_GradeOption> grades;

  const _SubjectItem({
    required this.name,
    required this.iconBgColor,
    required this.iconColor,
    this.isSymbol = false,
    this.symbol,
    this.iconData,
    this.customIcon,
    required this.grades,
  });
}

class _GradeOption {
  final String name;
  final String chapters;

  const _GradeOption({
    required this.name,
    required this.chapters,
  });
}

class _SubjectCard extends StatelessWidget {
  final _SubjectItem subject;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Tappable to expand / collapse)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onToggle,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Container
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: subject.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: subject.customIcon ??
                        (subject.isSymbol
                            ? Text(
                                subject.symbol ?? '',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: subject.iconColor,
                                  height: 1.0,
                                ),
                              )
                            : Icon(
                                subject.iconData,
                                color: subject.iconColor,
                                size: 21,
                              )),
                  ),
                  const SizedBox(width: 12),

                  // Title & Subtitle (when collapsed)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(height: 1.5),
                          Text(
                            'Tap to choose Grade 9–12',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Chevron circle button
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.inputFill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF334155),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded Section: Grade Grid
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
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 6) / 2;

                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: subject.grades.map((grade) {
                      final isSelected = grade.name == selectedGrade;

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
}

class _GradeTile extends StatelessWidget {
  final _GradeOption grade;
  final bool isSelected;
  final VoidCallback onTap;

  const _GradeTile({
    required this.grade,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Selected state uses warm peach highlight from design
    final bgColor = isSelected ? const Color(0xFFFFDBCA) : AppColors.inputFill;
    final titleColor = isSelected ? AppColors.buttonTextBrown : AppColors.headlineDark;
    final subtitleColor = isSelected ? AppColors.orange900 : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
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
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              grade.chapters,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
