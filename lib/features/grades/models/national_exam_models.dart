// Models representing National Exam papers, attempts, questions, and grading results.

enum ExamUserStatus {
  notStarted,
  inProgress,
  submitted;

  static ExamUserStatus fromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'IN_PROGRESS':
        return ExamUserStatus.inProgress;
      case 'SUBMITTED':
      case 'COMPLETED':
        return ExamUserStatus.submitted;
      default:
        return ExamUserStatus.notStarted;
    }
  }
}

class ExamPaperItem {
  final String id;
  final String title;
  final int? year;
  final int? durationMinutes;
  final int? totalQuestions;
  final ExamUserStatus userStatus;
  final int? latestScore;
  final String? attemptId;

  const ExamPaperItem({
    required this.id,
    required this.title,
    required this.year,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.userStatus,
    this.latestScore,
    this.attemptId,
  });

  factory ExamPaperItem.fromJson(Map<String, dynamic> json) {
    return ExamPaperItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      year: json['year'] as int?,
      durationMinutes: json['durationMinutes'] as int?,
      totalQuestions: json['totalQuestions'] as int?,
      userStatus: ExamUserStatus.fromString(json['userStatus'] as String?),
      latestScore: json['latestScore'] as int?,
      attemptId: json['attemptId'] as String?,
    );
  }
}

class ExamOption {
  final String id;
  final String text;
  final String? label; // A, B, C, D

  const ExamOption({required this.id, required this.text, this.label});

  factory ExamOption.fromJson(Map<String, dynamic> json) {
    return ExamOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      label: json['label'] as String?,
    );
  }
}

class ExamQuestion {
  final String id;
  final int? order;
  final String text;
  final String? imageUrl;
  final List<ExamOption> options;
  final String? selectedOptionId;
  final bool isFlagged;

  const ExamQuestion({
    required this.id,
    required this.order,
    required this.text,
    this.imageUrl,
    required this.options,
    this.selectedOptionId,
    this.isFlagged = false,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id'] as String? ?? '',
      order: json['order'] as int?,
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      options: ((json['options'] as List<dynamic>?) ?? [])
          .map((opt) => ExamOption.fromJson(opt as Map<String, dynamic>))
          .toList(),
      selectedOptionId: json['selectedOptionId'] as String?,
      isFlagged: json['isFlagged'] as bool? ?? false,
    );
  }
}

class ExamAttempt {
  final String attemptId;
  final String examId;
  final int timeRemainingSeconds;
  final List<ExamQuestion> questions;
  final int? currentQuestionIndex;

  const ExamAttempt({
    required this.attemptId,
    required this.examId,
    required this.timeRemainingSeconds,
    required this.questions,
    this.currentQuestionIndex,
  });

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      attemptId: json['attemptId'] as String? ?? json['id'] as String? ?? '',
      examId: json['examId'] as String? ?? '',
      timeRemainingSeconds: json['timeRemainingSeconds'] as int? ?? 0,
      currentQuestionIndex: json['currentQuestionIndex'] as int? ??
          json['lastQuestionIndex'] as int?,
      questions: ((json['questions'] as List<dynamic>?) ?? [])
          .map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExamAnswerSubmission {
  final String questionId;
  final String selectedOptionId;
  final bool isFlagged;

  const ExamAnswerSubmission({
    required this.questionId,
    required this.selectedOptionId,
    this.isFlagged = false,
  });

  /// Payload used only by PUT /national-exams/attempts/{attemptId}/save-progress.
  Map<String, dynamic> toSaveProgressJson() => {
    'questionId': questionId,
    'selectedOptionId': selectedOptionId,
    'isFlagged': isFlagged,
  };

  /// Payload used only by POST /national-exams/attempts/{attemptId}/submit.
  /// The Postman contract for submission intentionally does not include
  /// progress-only fields such as `isFlagged`.
  Map<String, dynamic> toSubmitJson() => {
    'questionId': questionId,
    'selectedOptionId': selectedOptionId,
  };
}

class ExamQuestionReviewItem {
  final String questionId;
  final int? order;
  final String questionText;
  final String? selectedOptionId;
  final String? selectedOptionText;
  final String? selectedOptionLabel;
  final String? correctOptionId;
  final String? correctOptionText;
  final String? correctOptionLabel;
  final bool isCorrect;
  final String? explanation;

  const ExamQuestionReviewItem({
    required this.questionId,
    this.order,
    required this.questionText,
    this.selectedOptionId,
    this.selectedOptionText,
    this.selectedOptionLabel,
    this.correctOptionId,
    this.correctOptionText,
    this.correctOptionLabel,
    required this.isCorrect,
    this.explanation,
  });

  factory ExamQuestionReviewItem.fromJson(Map<String, dynamic> json) {
    final qObj = json['question'] is Map<String, dynamic>
        ? json['question'] as Map<String, dynamic>
        : null;

    final questionId = json['questionId'] as String? ??
        qObj?['id'] as String? ??
        json['id'] as String? ??
        '';

    final order = json['order'] as int? ?? qObj?['order'] as int?;

    final questionText = json['questionText'] as String? ??
        qObj?['text'] as String? ??
        qObj?['prompt'] as String? ??
        json['text'] as String? ??
        json['prompt'] as String? ??
        '';

    String? selectedOptId = json['selectedOptionId'] as String? ??
        json['userOptionId'] as String?;
    String? selectedOptText = json['selectedOptionText'] as String? ??
        json['userOptionText'] as String?;
    String? selectedOptLabel = json['selectedOptionLabel'] as String? ??
        json['userOptionLabel'] as String?;

    if (json['selectedOption'] is Map<String, dynamic>) {
      final so = json['selectedOption'] as Map<String, dynamic>;
      selectedOptId ??= so['id'] as String?;
      selectedOptText ??= so['text'] as String?;
      selectedOptLabel ??= so['label'] as String?;
    } else if (json['userOption'] is Map<String, dynamic>) {
      final uo = json['userOption'] as Map<String, dynamic>;
      selectedOptId ??= uo['id'] as String?;
      selectedOptText ??= uo['text'] as String?;
      selectedOptLabel ??= uo['label'] as String?;
    }

    String? correctOptId = json['correctOptionId'] as String?;
    String? correctOptText = json['correctOptionText'] as String? ??
        json['correctAnswer'] as String? ??
        json['answer'] as String? ??
        json['correct_answer'] as String?;
    String? correctOptLabel = json['correctOptionLabel'] as String?;

    if (json['correctOption'] is Map<String, dynamic>) {
      final co = json['correctOption'] as Map<String, dynamic>;
      correctOptId ??= co['id'] as String?;
      correctOptText ??= co['text'] as String?;
      correctOptLabel ??= co['label'] as String?;
    } else if (json['correctOption'] is String) {
      correctOptText ??= json['correctOption'] as String;
    }

    // Inspect nested options array if present (in json or in qObj)
    final rawOptions = (json['options'] ?? qObj?['options']);
    if (rawOptions is List) {
      for (final opt in rawOptions) {
        if (opt is Map<String, dynamic>) {
          final optId = opt['id'] as String?;
          final optText = opt['text'] as String?;
          final optLabel = opt['label'] as String?;
          final optIsCorrect = opt['isCorrect'] == true;

          if (optIsCorrect || (correctOptId != null && optId == correctOptId)) {
            correctOptId ??= optId;
            correctOptText ??= optText;
            correctOptLabel ??= optLabel;
          }
          if (selectedOptId != null && optId == selectedOptId) {
            selectedOptText ??= optText;
            selectedOptLabel ??= optLabel;
          }
        }
      }
    }

    bool isCorrect = json['isCorrect'] as bool? ??
        json['is_correct'] as bool? ??
        (json['status'] == 'CORRECT');

    // If both IDs are known and identical, it's definitively correct
    if (selectedOptId != null &&
        correctOptId != null &&
        selectedOptId.isNotEmpty &&
        selectedOptId == correctOptId) {
      isCorrect = true;
    }

    return ExamQuestionReviewItem(
      questionId: questionId,
      order: order,
      questionText: questionText,
      selectedOptionId: selectedOptId,
      selectedOptionText: selectedOptText,
      selectedOptionLabel: selectedOptLabel,
      correctOptionId: correctOptId,
      correctOptionText: correctOptText,
      correctOptionLabel: correctOptLabel,
      isCorrect: isCorrect,
      explanation: json['explanation'] as String? ??
          qObj?['explanation'] as String?,
    );
  }
}

class ExamResultReview {
  final String attemptId;
  final String? examTitle;
  final String? category;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final int timeSpentSeconds;
  final int? totalDurationSeconds;
  final DateTime? submittedAt;
  final List<ExamQuestionReviewItem> questions;

  const ExamResultReview({
    required this.attemptId,
    this.examTitle,
    this.category,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timeSpentSeconds,
    this.totalDurationSeconds,
    this.submittedAt,
    this.questions = const [],
  });

  factory ExamResultReview.fromJson(Map<String, dynamic> json) {
    final target = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : (json['attempt'] is Map<String, dynamic>)
            ? json['attempt'] as Map<String, dynamic>
            : (json['result'] is Map<String, dynamic>)
                ? json['result'] as Map<String, dynamic>
                : json;

    final rawQuestions = (target['questions'] ??
            target['questionBreakdown'] ??
            target['breakdown'] ??
            target['answers'] ??
            target['results'] ??
            target['review'] ??
            target['items'] ??
            target['gradedAnswers']) as List<dynamic>? ??
        [];

    final parsedQuestions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map((q) => ExamQuestionReviewItem.fromJson(q))
        .toList();

    final score = target['score'] as int? ?? 0;
    final totalQuestions = target['totalQuestions'] as int? ??
        (parsedQuestions.isNotEmpty ? parsedQuestions.length : 0);

    double accuracy = (target['accuracy'] as num?)?.toDouble() ?? 0.0;
    if (accuracy == 0.0 && totalQuestions > 0 && score > 0) {
      accuracy = (score / totalQuestions) * 100.0;
    }

    return ExamResultReview(
      attemptId: target['attemptId'] as String? ??
          target['id'] as String? ??
          json['attemptId'] as String? ??
          '',
      examTitle: target['examTitle'] as String? ??
          target['title'] as String? ??
          json['title'] as String?,
      category: target['category'] as String? ??
          target['subject'] as String? ??
          json['category'] as String?,
      score: score,
      totalQuestions: totalQuestions,
      accuracy: accuracy,
      timeSpentSeconds: target['timeSpentSeconds'] as int? ?? 0,
      totalDurationSeconds: target['totalDurationSeconds'] as int? ??
          target['durationSeconds'] as int?,
      submittedAt: target['submittedAt'] != null
          ? DateTime.tryParse(target['submittedAt'] as String)
          : null,
      questions: parsedQuestions,
    );
  }

  ExamResultReview copyWith({
    String? attemptId,
    String? examTitle,
    String? category,
    int? score,
    int? totalQuestions,
    double? accuracy,
    int? timeSpentSeconds,
    int? totalDurationSeconds,
    DateTime? submittedAt,
    List<ExamQuestionReviewItem>? questions,
  }) {
    return ExamResultReview(
      attemptId: attemptId ?? this.attemptId,
      examTitle: examTitle ?? this.examTitle,
      category: category ?? this.category,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      accuracy: accuracy ?? this.accuracy,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      submittedAt: submittedAt ?? this.submittedAt,
      questions: questions ?? this.questions,
    );
  }
}
