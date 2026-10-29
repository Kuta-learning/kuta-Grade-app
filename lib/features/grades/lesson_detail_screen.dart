import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Lesson Detail screen — displays interactive lesson content (objectives, body text,
/// visual diagrams, steps, and resources) for a selected chapter.
/// Matches the design specifications and reference screenshots closely.
class LessonDetailScreen extends StatefulWidget {
  final String chapterTitle;
  final String chapterNumber;
  final String subject;
  final String gradeLevel;

  const LessonDetailScreen({
    super.key,
    this.chapterTitle = 'Equivalence and Simplification',
    this.chapterNumber = '4.2',
    this.subject = 'Fractions',
    this.gradeLevel = 'Grade 8 Math',
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: AppColors.brandBlue,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Back',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/note-detail');
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.subject,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Card
            const _LessonHeroCard(),

            // 2. Learning Objectives Card (Target icon, orange heading, outlined checks)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 16, 14, 0),
              child: _LearningObjectivesCard(),
            ),

            // 3. Middle Section: What are Equivalent Fractions? + 2 Diagram Cards
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeading(
                    text: 'What are Equivalent Fractions?',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Equivalent fractions are fractions that represent the same value, even though they look different. For example, 1/2 and 2/4 are equivalent. You can find equivalent fractions by multiplying or dividing both the numerator and the denominator by the same non-zero number.',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card 1: Visual Representation of 1/2 and 2/4
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppElevation.cardLow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 798 / 555,
                        child: Image.asset(
                          'assets/images/fraction_visual_card.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 2: Simplifying 8/12 using GCF
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppElevation.cardLow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 798 / 555,
                        child: Image.asset(
                          'assets/images/fraction_simplify_card.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Lower Section: Steps to Simplify + Lesson Resources + Progress Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 24, 14, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Steps to Simplify Heading
                  const _SectionHeading(text: 'Steps to Simplify'),
                  const SizedBox(height: 14),

                  // Step 1 Card
                  _StepCard(
                    number: 1,
                    textWidget: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        children: const [
                          TextSpan(text: 'Find the '),
                          TextSpan(
                            text: 'Greatest Common Factor\n(GCF)',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: ' of the numerator and the\ndenominator.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Step 2 Card
                  _StepCard(
                    number: 2,
                    textWidget: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'Divide both the numerator and the\ndenominator by the GCF.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Step 3 Card
                  _StepCard(
                    number: 3,
                    textWidget: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'Rewrite the fraction with the new\nvalues. It is now in its ',
                          ),
                          TextSpan(
                            text: 'simplest\nform!',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Lesson Resources Heading Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Lesson Resources',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.headlineDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '3 Files',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Resource 1: Equation_Worksheet.pdf
                  const _ResourceCard(
                    badgeBgColor: Color(0xFFFDE8E8),
                    iconColor: Color(0xFFE02424),
                    icon: Icons.picture_as_pdf,
                    title: 'Equation_Worksheet.pdf',
                    subtitle: '2.4 MB • Printable',
                  ),
                  const SizedBox(height: 10),

                  // Resource 2: Instructor_Notes.docx
                  const _ResourceCard(
                    badgeBgColor: Color(0xFFE1EFFE),
                    iconColor: Color(0xFF1A56DB),
                    icon: Icons.article_outlined,
                    title: 'Instructor_Notes.docx',
                    subtitle: '1.1 MB • Summary',
                  ),
                  const SizedBox(height: 32),

                  // Lesson Progress Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lesson Progress',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '100% Read',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Solid Green Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B251),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

/// Hero card displaying the fraction illustration matching the screenshot.
class _LessonHeroCard extends StatelessWidget {
  const _LessonHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppElevation.cardLow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 269 / 193,
          child: Image.asset(
            'assets/images/fraction_lesson_hero.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// Learning Objectives Card matching the reference screenshot:
/// - Bullseye / target concentric icon in orange900 (#9D4300)
/// - "Learning Objectives" heading in orange900
/// - Outlined green checkmark icons (Color(0xFF006E2F))
class _LearningObjectivesCard extends StatelessWidget {
  const _LearningObjectivesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderVariant.withValues(alpha: 0.7),
          width: 1.0,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Header Row with Target Icon and Title
          Row(
            children: [
              _TargetIcon(),
              SizedBox(width: 8),
              Text(
                'Learning Objectives',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Objective 1
          _ObjectiveItem(
            text:
                'Define equivalent fractions and recognize them visually using area models.',
          ),
          SizedBox(height: 14),

          // Objective 2
          _ObjectiveItem(
            text:
                'Apply the fundamental property of fractions to create equivalent fractions by multiplication.',
          ),
          SizedBox(height: 14),

          // Objective 3
          _ObjectiveItem(
            text:
                'Master the technique of simplifying fractions to their lowest terms using the GCF (Greatest Common Factor).',
          ),
        ],
      ),
    );
  }
}

/// Concentric rings target / bullseye icon drawn matching the reference screenshot.
class _TargetIcon extends StatelessWidget {
  const _TargetIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _TargetIconPainter(),
    );
  }
}

class _TargetIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final strokePaint = Paint()
      ..color = AppColors.orange900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9;

    // Outer circle
    canvas.drawCircle(center, 8.5, strokePaint);

    // Middle circle
    canvas.drawCircle(center, 5.0, strokePaint..strokeWidth = 1.7);

    // Center filled dot
    final fillPaint = Paint()
      ..color = AppColors.orange900
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A single learning objective row with an outlined green checkmark icon
class _ObjectiveItem extends StatelessWidget {
  final String text;
  const _ObjectiveItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1.0),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 19,
            color: Color(0xFF006E2F), // Emerald green matching screenshot
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bold section heading with a thin soft divider line underneath matching design
class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.brandBlue,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 1.0,
          color: const Color(0xFFFFDBCA).withValues(alpha: 0.7),
        ),
      ],
    );
  }
}

/// Individual step container card matching the reference screenshot.
class _StepCard extends StatelessWidget {
  final int number;
  final Widget textWidget;

  const _StepCard({
    required this.number,
    required this.textWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: const BoxDecoration(
              color: AppColors.orange900,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: textWidget),
        ],
      ),
    );
  }
}

/// Resource file card (PDF/Word) matching the reference screenshot.
class _ResourceCard extends StatelessWidget {
  final Color badgeBgColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;

  const _ResourceCard({
    required this.badgeBgColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderVariant.withValues(alpha: 0.7),
          width: 1.0,
        ),
        boxShadow: AppElevation.cardLow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // File Icon container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),

          // File Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headlineDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Download Action Icon
          const Icon(
            Icons.file_download_outlined,
            size: 20,
            color: Color(0xFF475569),
          ),
        ],
      ),
    );
  }
}
