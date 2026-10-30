/// Models for Quizzes, Questions, Options, Submissions, and Attempt Reviews.
class QuizQuestionOption {
  final String id;
  final String optionText;
  final String? label; // 'A', 'B', 'C', 'D'

  const QuizQuestionOption({
    required this.id,
    required this.optionText,
    this.label,
  });

  factory QuizQuestionOption.fromJson(Map<String, dynamic> json) {
    return QuizQuestionOption(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      optionText: json['optionText'] as String? ??
          json['text'] as String? ??
          json['title'] as String? ??
          '',
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'optionText': optionText,
        if (label != null) 'label': label,
      };
}

class QuizQuestionModel {
  final String id;
  final String questionText;
  final String? explanation;
  final int points;
  final List<QuizQuestionOption> options;

  const QuizQuestionModel({
    required this.id,
    required this.questionText,
    this.explanation,
    this.points = 1,
    this.options = const [],
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return QuizQuestionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      questionText: json['questionText'] as String? ??
          json['text'] as String? ??
          json['prompt'] as String? ??
          '',
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 1,
      options: rawOptions
          .map((o) => QuizQuestionOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'explanation': explanation,
        'points': points,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

/// Full quiz data returned by GET /quizzes/:quizId.
class QuizDetailModel {
  final String id;
  final String title;
  final String? description;
  final String? courseId;
  final String? lessonId;
  final int timeLimitMinutes;
  final int passingScore;
  final int totalQuestions;
  final List<QuizQuestionModel> questions;

  const QuizDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.courseId,
    this.lessonId,
    this.timeLimitMinutes = 15,
    this.passingScore = 70,
    this.totalQuestions = 0,
    this.questions = const [],
  });

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    final questionsList = rawQuestions
        .map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>))
        .toList();

    return QuizDetailModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? 'Quiz',
      description: json['description'] as String?,
      courseId: json['courseId'] as String?,
      lessonId: json['lessonId'] as String?,
      timeLimitMinutes: json['timeLimitMinutes'] as int? ??
          json['durationMinutes'] as int? ??
          15,
      passingScore: json['passingScore'] as int? ?? 70,
      totalQuestions: json['totalQuestions'] as int? ?? questionsList.length,
      questions: questionsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'courseId': courseId,
        'lessonId': lessonId,
        'timeLimitMinutes': timeLimitMinutes,
        'passingScore': passingScore,
        'totalQuestions': totalQuestions,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

/// Answer item for quiz submission.
class QuizAnswerSubmissionItem {
  final String questionId;
  final String selectedOptionId;

  const QuizAnswerSubmissionItem({
    required this.questionId,
    required this.selectedOptionId,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
      };

  factory QuizAnswerSubmissionItem.fromJson(Map<String, dynamic> json) {
    return QuizAnswerSubmissionItem(
      questionId: json['questionId'] as String? ?? '',
      selectedOptionId: json['selectedOptionId'] as String? ?? '',
    );
  }
}

/// Payload for POST /quizzes/:quizId/submit.
class QuizSubmissionRequest {
  final List<QuizAnswerSubmissionItem> answers;

  const QuizSubmissionRequest({required this.answers});

  Map<String, dynamic> toJson() => {
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

/// Response returned by POST /quizzes/:quizId/submit.
class QuizSubmissionResponse {
  final String attemptId;
  final int score;
  final int totalScore;
  final double percentage;
  final bool passed;
  final String? message;

  const QuizSubmissionResponse({
    required this.attemptId,
    required this.score,
    required this.totalScore,
    required this.percentage,
    required this.passed,
    this.message,
  });

  factory QuizSubmissionResponse.fromJson(Map<String, dynamic> json) {
    final s = json['score'] as int? ?? 0;
    final ts = json['totalScore'] as int? ?? json['totalQuestions'] as int? ?? 1;
    double p = 0.0;
    if (json['percentage'] != null) {
      final rawP = json['percentage'];
      p = (rawP is num) ? rawP.toDouble() : 0.0;
    } else if (ts > 0) {
      p = (s / ts) * 100.0;
    }

    return QuizSubmissionResponse(
      attemptId: json['attemptId'] as String? ??
          json['id'] as String? ??
          json['_id'] as String? ??
          '',
      score: s,
      totalScore: ts,
      percentage: p,
      passed: json['passed'] as bool? ?? (p >= 70.0),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'attemptId': attemptId,
        'score': score,
        'totalScore': totalScore,
        'percentage': percentage,
        'passed': passed,
        'message': message,
      };
}

/// Single reviewed question item returned by GET /quizzes/attempts/:attemptId.
class QuizQuestionReviewItem {
  final String questionId;
  final String questionText;
  final String? selectedOptionId;
  final String? correctOptionId;
  final bool isCorrect;
  final String? explanation;
  final List<QuizQuestionOption> options;

  const QuizQuestionReviewItem({
    required this.questionId,
    required this.questionText,
    this.selectedOptionId,
    this.correctOptionId,
    required this.isCorrect,
    this.explanation,
    this.options = const [],
  });

  factory QuizQuestionReviewItem.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return QuizQuestionReviewItem(
      questionId: json['questionId'] as String? ?? json['id'] as String? ?? '',
      questionText: json['questionText'] as String? ??
          json['text'] as String? ??
          json['prompt'] as String? ??
          '',
      selectedOptionId: json['selectedOptionId'] as String? ??
          json['userOptionId'] as String?,
      correctOptionId: json['correctOptionId'] as String?,
      isCorrect: json['isCorrect'] as bool? ?? false,
      explanation: json['explanation'] as String?,
      options: rawOptions
          .map((o) => QuizQuestionOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'questionText': questionText,
        'selectedOptionId': selectedOptionId,
        'correctOptionId': correctOptionId,
        'isCorrect': isCorrect,
        'explanation': explanation,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

/// Full quiz review returned by GET /quizzes/attempts/:attemptId.
class QuizAttemptReviewModel {
  final String id;
  final String quizId;
  final String? quizTitle;
  final int score;
  final int totalScore;
  final double percentage;
  final bool passed;
  final int? timeSpentSeconds;
  final String? completedAt;
  final List<QuizQuestionReviewItem> questions;

  const QuizAttemptReviewModel({
    required this.id,
    required this.quizId,
    this.quizTitle,
    required this.score,
    required this.totalScore,
    required this.percentage,
    required this.passed,
    this.timeSpentSeconds,
    this.completedAt,
    this.questions = const [],
  });

  factory QuizAttemptReviewModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = (json['questions'] ?? json['results']) as List<dynamic>? ?? [];
    final s = json['score'] as int? ?? 0;
    final ts = json['totalScore'] as int? ?? json['totalQuestions'] as int? ?? rawQuestions.length;
    double p = 0.0;
    if (json['percentage'] != null) {
      final rawP = json['percentage'];
      p = (rawP is num) ? rawP.toDouble() : 0.0;
    } else if (ts > 0) {
      p = (s / ts) * 100.0;
    }

    return QuizAttemptReviewModel(
      id: json['id'] as String? ?? json['attemptId'] as String? ?? '',
      quizId: json['quizId'] as String? ?? '',
      quizTitle: json['quizTitle'] as String? ?? json['title'] as String?,
      score: s,
      totalScore: ts,
      percentage: p,
      passed: json['passed'] as bool? ?? (p >= 70.0),
      timeSpentSeconds: json['timeSpentSeconds'] as int?,
      completedAt: json['completedAt'] as String?,
      questions: rawQuestions
          .map((q) => QuizQuestionReviewItem.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quizId': quizId,
        'quizTitle': quizTitle,
        'score': score,
        'totalScore': totalScore,
        'percentage': percentage,
        'passed': passed,
        'timeSpentSeconds': timeSpentSeconds,
        'completedAt': completedAt,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

