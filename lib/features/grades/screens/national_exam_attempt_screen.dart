import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/rive_loading_widget.dart';
import '../models/national_exam_models.dart';
import '../services/national_exam_service.dart';

/// Takes a national-exam attempt using the authenticated national-exam API.
///
/// This screen deliberately does not share the course-quiz BLoC or its mock
/// fallback: its questions, answers, progress, and submission all belong to a
/// national-exam attempt returned by POST /national-exams/{examId}/start.
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
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSubmitting = false;
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
    // The latest selection is already autosaved immediately. A final save is
    // also queued on navigation away without blocking disposal.
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

      if (!mounted) return;
      setState(() {
        _attempt = attempt;
        _remainingSeconds = attempt.timeRemainingSeconds;
        _selectedAnswers
          ..clear()
          ..addAll(selectedAnswers);
        _flaggedQuestionIds
          ..clear()
          ..addAll(flaggedQuestions);
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

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isSubmitting) return;

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

  Future<void> _confirmSubmit() async {
    final attempt = _attempt;
    if (attempt == null || _isSubmitting) return;

    final unanswered = attempt.questions.length - _selectedAnswers.length;
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit exam?'),
        content: Text(
          unanswered > 0
              ? '$unanswered question${unanswered == 1 ? '' : 's'} remain unanswered.'
              : 'All questions have an answer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep working'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange500,
              foregroundColor: Colors.white,
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
      await _service.submitExamAttempt(
        attempt.attemptId,
        answers: _answerSubmissions,
      );
      if (!mounted) return;
      context.pushReplacement(
        '${RouteNames.nationalExamResult}'
        '?attemptId=${Uri.encodeComponent(attempt.attemptId)}'
        '&title=${Uri.encodeComponent(widget.title)}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.brandPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Text(
        widget.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusPill(
                'Question ${_currentQuestionIndex + 1} of ${attempt.questions.length}',
                AppColors.brandPrimary,
              ),
              const Spacer(),
              const Icon(
                Icons.timer_outlined,
                size: 17,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatRemainingTime(_remainingSeconds),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / attempt.questions.length,
              minHeight: 5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(AppColors.accentHover),
            ),
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
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderVariant.withValues(alpha: 0.6),
              ),
              boxShadow: AppElevation.cardLow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.text,
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headlineDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleFlag(question.id),
                      tooltip: isFlagged ? 'Unflag question' : 'Flag question',
                      icon: Icon(
                        isFlagged
                            ? Icons.flag_rounded
                            : Icons.outlined_flag_rounded,
                        color: isFlagged
                            ? AppColors.orange500
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
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
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentQuestionIndex > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentQuestionIndex--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : isLastQuestion
                      ? _confirmSubmit
                      : () => setState(() => _currentQuestionIndex++),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion
                        ? AppColors.orange500
                        : AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                      : Text(isLastQuestion ? 'Submit Exam' : 'Next Question'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required ExamOption option,
    required String fallbackLabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandPrimary
                  : AppColors.borderVariant.withValues(alpha: 0.6),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: AppElevation.cardLow,
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.brandPrimary
                      : const Color(0xFFF1F5F9),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          option.label ?? fallbackLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.text,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.brandPrimary
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRemainingTime(int totalSeconds) {
    final safeSeconds = totalSeconds.clamp(0, 1 << 31);
    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final seconds = safeSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
