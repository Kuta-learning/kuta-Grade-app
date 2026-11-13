import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../models/national_exam_models.dart';
import '../services/national_exam_service.dart';

/// Displays the server-graded result for a submitted national-exam attempt.
/// Matches the Results screen design: header card, score/accuracy card,
/// 3-column stats, question breakdown list, and a sticky "Done" button.
class NationalExamResultScreen extends StatefulWidget {
  final String attemptId;
  final String title;

  /// Passed directly from the submit response so the screen renders instantly.
  final ExamResultReview? initialReview;

  /// Original question list from the attempt (used for breakdown fallback).
  final List<ExamQuestion>? fallbackQuestions;

  /// User's selected answers keyed by questionId (used for breakdown fallback).
  final Map<String, String>? fallbackAnswers;

  /// Injectable service for testing.
  final NationalExamService? service;

  const NationalExamResultScreen({
    super.key,
    required this.attemptId,
    required this.title,
    this.initialReview,
    this.fallbackQuestions,
    this.fallbackAnswers,
    this.service,
  });

  @override
  State<NationalExamResultScreen> createState() =>
      _NationalExamResultScreenState();
}

class _NationalExamResultScreenState extends State<NationalExamResultScreen> {
  late final NationalExamService _service;
  ExamResultReview? _result;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isLoadingBreakdown = false;

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const _cardBg = Colors.white;
  static const _statsBg = Color(0xFFF8FAFC);
  static const _borderColor = Color(0xFFE2E8F0);
  static const _correctGreen = Color(0xFF22C55E);
  static const _wrongRed = Color(0xFFEF4444);
  static const _correctBg = Color(0xFFDCFCE7);
  static const _wrongBg = Color(0xFFFEE2E2);
  static const _passedGreen = Color(0xFF16A34A);
  static const _passedBg = Color(0xFFDCFCE7);
  static const _failedRed = Color(0xFFDC2626);
  static const _failedBg = Color(0xFFFEE2E2);

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NationalExamService();

    // If we already have a full review (with question breakdown), render immediately.
    if (widget.initialReview != null &&
        widget.initialReview!.questions.isNotEmpty) {
      _result = widget.initialReview;
      _isLoading = false;
    } else if (widget.initialReview != null) {
      // We have basic result data but no question breakdown — populate from fallback if present
      // and fetch the full breakdown in the background.
      _result = _populateWithFallbackQuestions(widget.initialReview!);
      _isLoading = false;
      _fetchFullReview();
    } else {
      _loadResult();
    }
  }

  ExamResultReview _populateWithFallbackQuestions(ExamResultReview review) {
    if (review.questions.isNotEmpty) return review;
    final fallback = widget.fallbackQuestions;
    if (fallback == null || fallback.isEmpty) return review;

    final generated = <ExamQuestionReviewItem>[];
    for (var i = 0; i < fallback.length; i++) {
      final q = fallback[i];
      final selectedId = widget.fallbackAnswers?[q.id] ?? q.selectedOptionId;

      String? selectedText;
      String? selectedLabel;
      String? correctId;
      String? correctText;
      String? correctLabel;

      for (final opt in q.options) {
        if (opt.id == selectedId) {
          selectedText = opt.text;
          selectedLabel = opt.label;
        }
      }

      generated.add(
        ExamQuestionReviewItem(
          questionId: q.id,
          order: q.order ?? (i + 1),
          questionText: q.text,
          selectedOptionId: selectedId,
          selectedOptionText: selectedText,
          selectedOptionLabel: selectedLabel,
          correctOptionId: correctId,
          correctOptionText: correctText,
          correctOptionLabel: correctLabel,
          isCorrect: false, // will be resolved via _resolveItem if needed
        ),
      );
    }

    return review.copyWith(questions: generated);
  }

  Future<void> _loadResult() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      var result = await _service.getExamAttemptResult(widget.attemptId);
      if (result.questions.isEmpty) {
        result = _populateWithFallbackQuestions(result);
      }
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Silently fetches the full review (with question breakdown) and merges it
  /// with the already-displayed basic result.
  Future<void> _fetchFullReview() async {
    setState(() => _isLoadingBreakdown = true);
    try {
      final full = await _service.getExamAttemptResult(widget.attemptId);
      if (!mounted) return;
      if (full.questions.isNotEmpty) {
        setState(() => _result = full);
      } else if (_result != null && _result!.questions.isEmpty) {
        setState(() => _result = _populateWithFallbackQuestions(_result!));
      }
    } catch (_) {
      // Swallow — the basic result is already shown; breakdown is optional.
    } finally {
      if (mounted) {
        setState(() => _isLoadingBreakdown = false);
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String _submittedLabel(DateTime? dt) {
    if (dt == null) return 'Submitted';
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$hour:$minute $period';
    if (isToday) return 'Submitted today at $timeStr';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Submitted on ${months[dt.month - 1]} ${dt.day} at $timeStr';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: KutaLoadingWidget(
                size: 130,
                label: 'Loading Exam Results...',
              ),
            )
          : _result != null
          ? _buildBody(_result!)
          : _buildError(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.brandPrimary,
      foregroundColor: Colors.white,
      leading: const BackButton(),
      title: Text(
        'Results',
        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load exam results',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.headlineDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadResult,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ExamResultReview result) {
    final totalCount = result.totalQuestions > 0
        ? result.totalQuestions
        : (result.questions.isNotEmpty
            ? result.questions.length
            : (widget.fallbackQuestions?.length ?? 0));

    double accuracy = result.accuracy;
    if ((accuracy == 0.0 || accuracy.isNaN) && totalCount > 0 && result.score > 0) {
      accuracy = (result.score / totalCount) * 100;
    } else if (accuracy <= 1.0 && accuracy > 0.0) {
      accuracy = accuracy * 100;
    }

    final hasAnyQuestionsMarkedCorrect =
        result.questions.any((q) => q.isCorrect);
    final correctCount = hasAnyQuestionsMarkedCorrect
        ? result.questions.where((q) => q.isCorrect).length
        : result.score;
    final wrongCount = hasAnyQuestionsMarkedCorrect
        ? result.questions.where((q) => !q.isCorrect).length
        : (totalCount - result.score).clamp(0, totalCount);

    final passed = accuracy >= 50;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ──────────────────────────────────────────────
              _buildHeaderCard(result, passed),
              const SizedBox(height: 12),

              // ── Score & Accuracy Card ────────────────────────────────────
              _buildScoreCard(
                result,
                accuracy,
                passed,
                totalCount,
                correctCount,
                wrongCount,
              ),
              const SizedBox(height: 20),

              // ── Question Breakdown ───────────────────────────────────────
              Text(
                'Question Breakdown',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headlineDark,
                ),
              ),
              const SizedBox(height: 10),
              if (result.questions.isNotEmpty) ...[
                ...result.questions.asMap().entries.map(
                  (entry) => _buildQuestionBreakdownCard(
                    entry.value,
                    entry.key,
                  ),
                ),
              ] else if (_isLoadingBreakdown) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.brandPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading question breakdown…',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Detailed question breakdown is not available for this exam attempt.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Sticky Done Button ───────────────────────────────────────────────
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.go(RouteNames.examSimulator),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.done_all_rounded, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Header Card ─────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(ExamResultReview result, bool passed) {
    final examTitle = result.examTitle ?? widget.title;
    final category = result.category ?? '';
    final submittedLabel = _submittedLabel(result.submittedAt);
    final durationLabel = result.totalDurationSeconds != null
        ? _formatDuration(result.totalDurationSeconds!)
        : null;
    final spentLabel = _formatDuration(result.timeSpentSeconds);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category + Passed/Failed badge
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: passed ? _passedBg : _failedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      passed
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 13,
                      color: passed ? _passedGreen : _failedRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      passed ? 'PASSED' : 'FAILED',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: passed ? _passedGreen : _failedRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Exam title
          Text(
            examTitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.headlineDark,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),

          // Submitted label
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                submittedLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (durationLabel != null) ...[
                const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  'Duration: $spentLabel / $durationLabel',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  'Time spent: $spentLabel',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Score & Accuracy Card ───────────────────────────────────────────────────

  Widget _buildScoreCard(
    ExamResultReview result,
    double accuracy,
    bool passed,
    int totalCount,
    int correctCount,
    int wrongCount,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Total Score | Overall Accuracy
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Total Score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Score',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${result.score}',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.headlineDark,
                              ),
                            ),
                            TextSpan(
                              text: ' / $totalCount',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical divider
                Container(
                  width: 1,
                  height: 52,
                  color: _borderColor,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),

                // Overall Accuracy
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Accuracy',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${accuracy.round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.orange500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: _borderColor),

          // Bottom row: Total | Correct | Wrong
          Container(
            color: _statsBg,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                _buildStatColumn('Total', '$totalCount', AppColors.headlineDark),
                _buildStatDivider(),
                _buildStatColumn('Correct', '$correctCount', _correctGreen),
                _buildStatDivider(),
                _buildStatColumn('Wrong', '$wrongCount', _wrongRed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: _borderColor,
    );
  }

  // ── Question Breakdown Card ─────────────────────────────────────────────────

  ExamQuestionReviewItem _resolveItem(ExamQuestionReviewItem item, int index) {
    ExamQuestion? originalQ;
    if (widget.fallbackQuestions != null) {
      try {
        originalQ = widget.fallbackQuestions!.firstWhere(
          (q) =>
              q.id == item.questionId ||
              (item.order != null && q.order == item.order),
        );
      } catch (_) {}
    }

    String? selectedId = item.selectedOptionId;
    if ((selectedId == null || selectedId.isEmpty) &&
        widget.fallbackAnswers != null) {
      selectedId = widget.fallbackAnswers![item.questionId];
    }
    selectedId ??= originalQ?.selectedOptionId;

    String? selectedText = item.selectedOptionText;
    String? selectedLabel = item.selectedOptionLabel;
    String? correctId = item.correctOptionId;
    String? correctText = item.correctOptionText;
    String? correctLabel = item.correctOptionLabel;

    if (originalQ != null && originalQ.options.isNotEmpty) {
      // Look up user selected option details
      if (selectedId != null && selectedId.isNotEmpty) {
        for (final opt in originalQ.options) {
          if (opt.id == selectedId) {
            selectedText ??= opt.text;
            selectedLabel ??= opt.label;
            break;
          }
        }
      }

      // Look up correct option details
      if (correctId != null && correctId.isNotEmpty) {
        for (final opt in originalQ.options) {
          if (opt.id == correctId) {
            correctText ??= opt.text;
            correctLabel ??= opt.label;
            break;
          }
        }
      }
    }

    bool isCorrect = item.isCorrect;
    if (selectedId != null &&
        correctId != null &&
        selectedId.isNotEmpty &&
        selectedId == correctId) {
      isCorrect = true;
    }

    if (isCorrect) {
      correctId ??= selectedId;
      correctText ??= selectedText;
      correctLabel ??= selectedLabel;
    }

    return ExamQuestionReviewItem(
      questionId: item.questionId.isNotEmpty
          ? item.questionId
          : (originalQ?.id ?? ''),
      order: item.order ?? originalQ?.order ?? (index + 1),
      questionText: item.questionText.isNotEmpty
          ? item.questionText
          : (originalQ?.text ?? ''),
      selectedOptionId: selectedId,
      selectedOptionText: selectedText,
      selectedOptionLabel: selectedLabel,
      correctOptionId: correctId,
      correctOptionText: correctText,
      correctOptionLabel: correctLabel,
      isCorrect: isCorrect,
      explanation: item.explanation,
    );
  }

  Widget _buildQuestionBreakdownCard(
    ExamQuestionReviewItem rawQuestion,
    int index,
  ) {
    final question = _resolveItem(rawQuestion, index);
    final qNumber = question.order ?? (index + 1);
    final hasSelectedAnswer = (question.selectedOptionText != null &&
            question.selectedOptionText!.trim().isNotEmpty) ||
        (question.selectedOptionLabel != null &&
            question.selectedOptionLabel!.trim().isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q number label
          Text(
            'Q$qNumber',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statsBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Text(
              question.questionText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Wrong answer row (only if user got it wrong and made a selection)
          if (!question.isCorrect && hasSelectedAnswer) ...[
            _buildAnswerRow(
              isCorrect: false,
              label: question.selectedOptionLabel,
              text: question.selectedOptionText ?? '',
            ),
            const SizedBox(height: 6),
          ],

          // Correct answer row
          _buildAnswerRow(
            isCorrect: true,
            label: question.correctOptionLabel,
            text: question.correctOptionText ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow({
    required bool isCorrect,
    String? label,
    required String text,
  }) {
    final bg = isCorrect ? _correctBg : _wrongBg;
    final textColor = isCorrect ? _correctGreen : _wrongRed;
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final prefix = isCorrect ? 'Correct answer' : 'Your answer';

    String answerText;
    if (label != null && label.isNotEmpty && text.trim().isNotEmpty) {
      answerText = '$label. $text';
    } else if (label != null && label.isNotEmpty) {
      answerText = 'Option $label';
    } else if (text.trim().isNotEmpty) {
      answerText = text;
    } else {
      answerText = isCorrect ? 'Correct answer verified' : 'Selected';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: textColor),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$prefix: ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  TextSpan(
                    text: answerText,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
