/// Models representing National Exam papers, attempts, questions, and grading results.

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
  final int year;
  final int durationMinutes;
  final int totalQuestions;
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
      title: json['title'] as String? ?? 'National Exam',
      year: json['year'] as int? ?? 2023,
      durationMinutes: json['durationMinutes'] as int? ?? 150,
      totalQuestions: json['totalQuestions'] as int? ?? 100,
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

  const ExamOption({
    required this.id,
    required this.text,
    this.label,
  });

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
  final int order;
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
      order: json['order'] as int? ?? 1,
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

  const ExamAttempt({
    required this.attemptId,
    required this.examId,
    required this.timeRemainingSeconds,
    required this.questions,
  });

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      attemptId: json['attemptId'] as String? ?? json['id'] as String? ?? '',
      examId: json['examId'] as String? ?? '',
      timeRemainingSeconds: json['timeRemainingSeconds'] as int? ?? 5400,
      questions: ((json['questions'] as List<dynamic>?) ?? [])
          .map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExamAnswerSubmission {
  final String questionId;
  final String? selectedOptionId;
  final bool isFlagged;

  const ExamAnswerSubmission({
    required this.questionId,
    this.selectedOptionId,
    this.isFlagged = false,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        if (selectedOptionId != null) 'selectedOptionId': selectedOptionId,
        'isFlagged': isFlagged,
      };
}

class ExamResultReview {
  final String attemptId;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final int timeSpentSeconds;

  const ExamResultReview({
    required this.attemptId,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timeSpentSeconds,
  });

  factory ExamResultReview.fromJson(Map<String, dynamic> json) {
    return ExamResultReview(
      attemptId: json['attemptId'] as String? ?? json['id'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 100,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
    );
  }
}
