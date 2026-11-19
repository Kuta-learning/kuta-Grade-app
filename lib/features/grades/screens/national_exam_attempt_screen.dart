import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../models/national_exam_models.dart';
import '../services/national_exam_service.dart';

/// Takes a national-exam attempt using the authenticated national-exam API.
/// Matches the live reference screenshot:
/// - Top timer card (remaining bold countdown + elapsed clock).
/// - Progress indicator ("Question X of N", "% Complete", rounded orange progress bar).
/// - Flagged and Pause action pills.
/// - Option cards with peach/orange selection, checkmark, and circular badge.
/// - "Clear Selection" action.
/// - Next & Previous pill navigation.
/// - Question Palette grid with real-time status (Answered green, Flagged peach with flag icon,
///   Current orange, Unanswered grey) and jump-to-question navigation.
class NationalExamAttemptScreen extends StatefulWidget {
  final String examId;
  final String title;
  final NationalExamService? service;

  const NationalExamAttemptScreen({
    super.key,
    required this.examId,
    required this.title,
    this.service,
  });

  @override
  State<NationalExamAttemptScreen> createState() =>
      _NationalExamAttemptScreenState();
}

class _NationalExamAttemptScreenState extends State<NationalExamAttemptScreen> {
  late final NationalExamService _service;
  final Map<String, String> _selectedAnswers = {};
  final Set<String> _flaggedQuestionIds = {};

  Timer? _timer;
  ExamAttempt? _attempt;
  int _currentQuestionIndex = 0;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSubmitting = false;
  bool _isPaused = false;
  bool _paletteExpanded = false;
  String? _errorMessage;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NationalExamService();
    _startOrResumeAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_saveProgress());
    super.dispose();
  }

  Future<void> _startOrResumeAttempt() async {
    _timer?.cancel();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _saveError = null;
      _currentQuestionIndex = 0;
    });

    try {
      final attempt = await _service.startExamAttempt(widget.examId);
      if (attempt.attemptId.isEmpty) {
        throw Exception('The server did not return an exam attempt.');
      }

      final selectedAnswers = <String, String>{};
      final flaggedQuestions = <String>{};
      for (final question in attempt.questions) {
        if (question.id.isEmpty) continue;
        if (question.selectedOptionId != null &&
            question.selectedOptionId!.isNotEmpty) {
          selectedAnswers[question.id] = question.selectedOptionId!;
        }
        if (question.isFlagged) {
          flaggedQuestions.add(question.id);
        }
      }

      // Restore position where the user left off
      int initialIndex = 0;
      if (attempt.currentQuestionIndex != null &&
          attempt.currentQuestionIndex! >= 0 &&
          attempt.currentQuestionIndex! < attempt.questions.length) {
        initialIndex = attempt.currentQuestionIndex!;
      } else {
        try {
          final storage = SharedPrefsStorage.instanceOrNull ??
              await SharedPrefsStorage.getInstance();
          final saved = await storage.getInt(
            StorageKeys.examAttemptQuestionIndex(attempt.attemptId),
          );
          if (saved != null && saved >= 0 && saved < attempt.questions.length) {
            initialIndex = saved;
          } else if (selectedAnswers.isNotEmpty) {
            final firstUnanswered = attempt.questions.indexWhere(
              (q) => !selectedAnswers.containsKey(q.id),
            );
            if (firstUnanswered != -1) {
              initialIndex = firstUnanswered;
            }
          }
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _attempt = attempt;
        _remainingSeconds = attempt.timeRemainingSeconds;
        _initialSeconds = attempt.timeRemainingSeconds > 0
            ? attempt.timeRemainingSeconds
            : 7200; // default 2 hours if unknown
        _selectedAnswers
          ..clear()
          ..addAll(selectedAnswers);
        _flaggedQuestionIds
          ..clear()
          ..addAll(flaggedQuestions);
        _currentQuestionIndex = initialIndex;
        _isLoading = false;
      });
      _startCountdown();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startCountdown() {
    if (_remainingSeconds <= 0) return;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isSubmitting || _isPaused) return;

      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, _remainingSeconds);
      });

      if (_remainingSeconds == 0) {
        _timer?.cancel();
        _submitAttempt();
      } else if (_remainingSeconds % 15 == 0) {
        unawaited(_saveProgress());
      }
    });
  }

  List<ExamAnswerSubmission> get _answerSubmissions {
    return _selectedAnswers.entries
        .map(
          (entry) => ExamAnswerSubmission(
            questionId: entry.key,
            selectedOptionId: entry.value,
            isFlagged: _flaggedQuestionIds.contains(entry.key),
          ),
        )
        .toList();
  }

  Future<void> _saveProgress() async {
    final attempt = _attempt;
    if (attempt == null || attempt.attemptId.isEmpty || _isSaving) return;

    _isSaving = true;
    final didSave = await _service.saveExamProgress(
      attempt.attemptId,
      timeRemainingSeconds: _remainingSeconds,
      answers: _answerSubmissions,
    );
    _isSaving = false;

    if (!mounted) return;
    setState(() {
      _saveError = didSave ? null : 'Progress could not be saved. Retrying…';
    });
  }

  void _selectOption(String questionId, String optionId) {
    setState(() {
      _selectedAnswers[questionId] = optionId;
      _saveError = null;
    });
    unawaited(_saveProgress());
  }

  void _clearSelection(String questionId) {
    setState(() {
      _selectedAnswers.remove(questionId);
      _saveError = null;
    });
    unawaited(_saveProgress());
  }

  void _toggleFlag(String questionId) {
    setState(() {
      if (_flaggedQuestionIds.contains(questionId)) {
        _flaggedQuestionIds.remove(questionId);
      } else {
        _flaggedQuestionIds.add(questionId);
      }
      _saveError = null;
    });
    unawaited(_saveProgress());
  }

  void _togglePause() {
    setState(() {
      _isPaused = true;
    });
    unawaited(_saveProgress());

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pause_circle_filled_rounded,
                color: Color(0xFF2563EB),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Exam Paused',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headlineDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Your answers have been autosaved. Note: National exam timer continues in the background.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _confirmSubmit();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'Submit Now',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              setState(() {
                _isPaused = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: Text(
              'Resume Exam',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSubmit() async {
    final attempt = _attempt;
    if (attempt == null || _isSubmitting) return;

    final unanswered = attempt.questions.length - _selectedAnswers.length;
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Submit exam?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          unanswered > 0
              ? '$unanswered of ${attempt.questions.length} questions remain unanswered. Are you sure you want to finalize and grade your attempt?'
              : 'All questions have been answered. Ready to submit?',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.5,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Keep working',
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (shouldSubmit == true) {
      await _submitAttempt();
    }
  }

  void _setQuestionIndex(int newIndex) {
    if (newIndex < 0 ||
        (_attempt != null && newIndex >= _attempt!.questions.length)) {
      return;
    }
    setState(() {
      _currentQuestionIndex = newIndex;
    });
    if (_attempt != null && _attempt!.attemptId.isNotEmpty) {
      unawaited(_saveQuestionPosition(_attempt!.attemptId, newIndex));
    }
  }

  Future<void> _saveQuestionPosition(String attemptId, int index) async {
    try {
      final storage = SharedPrefsStorage.instanceOrNull ??
          await SharedPrefsStorage.getInstance();
      await storage.setInt(
        StorageKeys.examAttemptQuestionIndex(attemptId),
        value: index,
      );
    } catch (_) {}
  }

  Future<bool?> _showLeaveDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orange500.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.orange500,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Leave Exam?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headlineDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Your timer and answers will continue saving in the background. You can resume at any time from Exam Simulator.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Stay',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Leave',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAttempt() async {
    final attempt = _attempt;
    if (attempt == null || _isSubmitting) return;

    _timer?.cancel();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    await _saveProgress();
    try {
      final result = await _service.submitExamAttempt(
        attempt.attemptId,
        answers: _answerSubmissions,
      );
      await _service.invalidateDashboardCache();
      if (!mounted) return;
      context.pushReplacement(
        '${RouteNames.nationalExamResult}'
        '?attemptId=${Uri.encodeComponent(attempt.attemptId)}'
        '&title=${Uri.encodeComponent(widget.title)}',
        extra: {
          'review': result,
          'questions': attempt.questions,
          'answers': _selectedAnswers,
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
      _startCountdown();
    }
  }

  Future<void> _handleLeaveRequest() async {
    final shouldLeave = await _showLeaveDialog();
    if (shouldLeave != true || !mounted) return;
    await _saveProgress();
    await _service.invalidateDashboardCache();
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleLeaveRequest();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(
                child: KutaLoadingWidget(
                  size: 130,
                  label: 'Loading Exam Questions...',
                ),
              )
            : _errorMessage != null && _attempt == null
                ? _buildErrorState()
                : _buildAttemptContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.brandPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: _handleLeaveRequest,
      ),
      titleSpacing: 0,
      title: Text(
        widget.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16.5,
          color: Colors.white,
        ),
      ),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFC2410C),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to start this exam',
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
              onPressed: _startOrResumeAttempt,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptContent() {
    final attempt = _attempt;
    if (attempt == null || attempt.questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'No questions are available for this exam.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headlineDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentQuestionIndex >= attempt.questions.length) {
      _currentQuestionIndex = attempt.questions.length - 1;
    }
    final question = attempt.questions[_currentQuestionIndex];
    final isLastQuestion =
        _currentQuestionIndex == attempt.questions.length - 1;
    final selectedOptionId = _selectedAnswers[question.id];
    final isFlagged = _flaggedQuestionIds.contains(question.id);

    final totalQuestions = attempt.questions.length;
    final answeredCount = _selectedAnswers.length;
    final flaggedCount = _flaggedQuestionIds.length;
    final unansweredCount = max(0, totalQuestions - answeredCount);
    final percentComplete =
        ((_currentQuestionIndex + 1) / totalQuestions * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Timer Card
          _buildTimerCard(),
          const SizedBox(height: 16),

          // 2. Question Indicator & Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                '$percentComplete% Complete',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / totalQuestions,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF97316),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Action Pills (Flagged & Pause)
          Row(
            children: [
              _buildFlagPill(isFlagged, () => _toggleFlag(question.id)),
              const Spacer(),
              _buildPausePill(_togglePause),
            ],
          ),
          if (_saveError != null) ...[
            const SizedBox(height: 10),
            Text(
              _saveError!,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 16),

          // 4. Question Text & Math formula Box
          _buildQuestionCard(question),
          const SizedBox(height: 16),

          // 5. Option Cards
          for (var index = 0; index < question.options.length; index++) ...[
            _buildOptionCard(
              option: question.options[index],
              fallbackLabel: String.fromCharCode(65 + index),
              isSelected: question.options[index].id == selectedOptionId,
              onTap: () =>
                  _selectOption(question.id, question.options[index].id),
            ),
            const SizedBox(height: 10),
          ],

          // 6. Clear Selection Action
          if (selectedOptionId != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _clearSelection(question.id),
                icon: const Icon(
                  Icons.clear_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                label: Text(
                  'Clear Selection',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 7. Navigation Buttons (Previous & Next Question)
          _buildNavigationRow(isLastQuestion),
          const SizedBox(height: 24),

          // 8. Question Palette Component
          _buildQuestionPalette(
            totalQuestions: totalQuestions,
            answeredCount: answeredCount,
            flaggedCount: flaggedCount,
            unansweredCount: unansweredCount,
            questions: attempt.questions,
          ),
        ],
      ),
    );
  }

  /// Top white timer card showing remaining countdown & secondary elapsed time
  Widget _buildTimerCard() {
    final elapsedSeconds = max(0, _initialSeconds - _remainingSeconds);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppElevation.cardLow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFECE5),
                ),
                child: const Icon(
                  Icons.alarm_rounded,
                  color: Color(0xFFEA580C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    _formatRemainingTime(_remainingSeconds),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 4),
              Text(
                _formatElapsedTime(elapsedSeconds),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Peach Flag pill button
  Widget _buildFlagPill(bool isFlagged, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isFlagged
                ? const Color(0xFFFFECE5)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFlagged
                  ? const Color(0xFFFDBA74)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_rounded,
                size: 16,
                color: isFlagged
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                isFlagged ? 'Flagged' : 'Flag Question',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isFlagged
                      ? const Color(0xFFC2410C)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Deep blue Pause pill button
  Widget _buildPausePill(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.pause,
                  size: 12,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pause',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Question Card with formula box styling
  Widget _buildQuestionCard(ExamQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppElevation.cardLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: GoogleFonts.inter(
              fontSize: 15.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (question.imageUrl != null &&
              question.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Option Card with peach/orange selection, circular badge, and checkmark
  Widget _buildOptionCard({
    required ExamOption option,
    required String fallbackLabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final label = option.label ?? fallbackLabel;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFECE5)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFB923C)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFF97316)
                      : const Color(0xFFE2E8F0),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.text,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFF97316)
                      : Colors.transparent,
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(Icons.check, size: 16, color: Colors.white),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigation row (Previous & Next/Submit buttons)
  Widget _buildNavigationRow(bool isLastQuestion) {
    return Row(
      children: [
        if (_currentQuestionIndex > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _setQuestionIndex(_currentQuestionIndex - 1),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF2563EB),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        if (_currentQuestionIndex > 0) const SizedBox(width: 12),
        Expanded(
          flex: _currentQuestionIndex > 0 ? 1 : 2,
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : isLastQuestion
                    ? _confirmSubmit
                    : () => _setQuestionIndex(_currentQuestionIndex + 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastQuestion ? 'Submit Exam' : 'Next Question',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isLastQuestion
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Question Palette Component with 5-column grid and real-time color coding
  Widget _buildQuestionPalette({
    required int totalQuestions,
    required int answeredCount,
    required int flaggedCount,
    required int unansweredCount,
    required List<ExamQuestion> questions,
  }) {
    final displayCount = _paletteExpanded
        ? totalQuestions
        : min(25, totalQuestions);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppElevation.cardLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Palette Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.apps_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Question Palette',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Text(
                'Section 1 of 1',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Palette Status Legend Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLegendPill(
                  dotColor: Colors.white,
                  backgroundColor: const Color(0xFF00C853),
                  textColor: Colors.white,
                  label: '$answeredCount Answered',
                ),
                const SizedBox(width: 8),
                _buildLegendPill(
                  dotColor: const Color(0xFFEA580C),
                  backgroundColor: const Color(0xFFFFECE5),
                  textColor: const Color(0xFFC2410C),
                  label: '$flaggedCount Flagged',
                ),
                const SizedBox(width: 8),
                _buildLegendPill(
                  dotColor: const Color(0xFF94A3B8),
                  backgroundColor: const Color(0xFFF1F5F9),
                  textColor: const Color(0xFF64748B),
                  label: '$unansweredCount Unanswered',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5-Column Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final qId = questions[index].id;
              final isAnswered = _selectedAnswers.containsKey(qId);
              final isFlagged = _flaggedQuestionIds.contains(qId);
              final isCurrent = _currentQuestionIndex == index;

              Color bgColor;
              Color textColor;
              Border? border;

              if (isCurrent) {
                bgColor = const Color(0xFFF97316);
                textColor = Colors.white;
              } else if (isAnswered) {
                bgColor = const Color(0xFF00C853);
                textColor = Colors.white;
              } else if (isFlagged) {
                bgColor = const Color(0xFFFFECE5);
                textColor = const Color(0xFFC2410C);
                border = Border.all(color: const Color(0xFFFDBA74));
              } else {
                bgColor = const Color(0xFFF1F5F9);
                textColor = const Color(0xFF475569);
              }

              return InkWell(
                onTap: () => _setQuestionIndex(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: border,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (isFlagged && !isCurrent)
                        const Positioned(
                          top: 3,
                          right: 4,
                          child: Icon(
                            Icons.flag_rounded,
                            size: 10,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // View all questions expander
          if (totalQuestions > 25)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () =>
                    setState(() => _paletteExpanded = !_paletteExpanded),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _paletteExpanded
                      ? 'Show fewer questions ⌃'
                      : 'View all $totalQuestions Questions ⌄',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendPill({
    required Color dotColor,
    required Color backgroundColor,
    required Color textColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime(int totalSeconds) {
    final safeSeconds = totalSeconds.clamp(0, 1 << 31);
    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final seconds = safeSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatElapsedTime(int totalSeconds) {
    final safeSeconds = totalSeconds.clamp(0, 1 << 31);
    final minutes = safeSeconds ~/ 60;
    final seconds = safeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
