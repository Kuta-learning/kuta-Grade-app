import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API endpoint constants for Kuta Learning backend services.
///
/// Sensitive/environment-specific values (like the base URL) are injected at
/// startup from the local `.env` file — see `.env.example`.
class ApiEndpoints {
  ApiEndpoints._();

  /// Backend base URL, loaded from the `API_BASE_URL` environment entry.
  static String get baseUrl =>
      dotenv.maybeGet('API_BASE_URL', fallback: '') ?? '';

  // ── Authentication ────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  static const String onboarding = '/auth/onboarding';
  static const String profile = '/auth/profile';
  static const String googleAuth = '/auth/google';

  // ── Password Management & OTP ─────────────────────────────────────────────
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // ── National Exams & Exam Simulator ───────────────────────────────────────
  static const String nationalExamsDashboard = '/national-exams/dashboard';
  static const String nationalExamsSubjects = '/national-exams/subjects';
  static String nationalExamsBySubject(String subjectId) =>
      '/national-exams/subjects/$subjectId/exams';
  static String startExam(String examId) => '/national-exams/$examId/start';
  static String saveExamProgress(String attemptId) =>
      '/national-exams/attempts/$attemptId/save-progress';
  static String submitExam(String attemptId) =>
      '/national-exams/attempts/$attemptId/submit';
  static String examAttemptResult(String attemptId) =>
      '/national-exams/attempts/$attemptId';

  // ── Short Notes & Lessons ──────────────────────────────────────────────────
  static const String shortNotesSubjects = '/short-notes/subjects';
  static String shortNotesSubjectDetail(String subjectId) =>
      '/short-notes/subjects/$subjectId';
  static String chapterLessonDetail(String chapterId) =>
      '/short-notes/chapters/$chapterId';
  static String chapterReadingProgress(String chapterId) =>
      '/short-notes/chapters/$chapterId/progress';
  static String downloadChapterPdf(String chapterId) =>
      '/short-notes/chapters/$chapterId/download';

  // ── Grades Courses, Lessons & Quizzes ──────────────────────────────────────
  static String coursesByGrade(dynamic gradeLevel) =>
      '/courses?gradeLevel=$gradeLevel';
  static String courseDetail(String courseId) => '/courses/$courseId';
  static String lessonView(String lessonId) => '/lessons/$lessonId';
  static String completeLesson(String lessonId) =>
      '/progress/lessons/$lessonId/complete';
  static String quizDetail(String quizId) => '/quizzes/$quizId';
  static String submitQuiz(String quizId) => '/quizzes/$quizId/submit';
  static String quizAttemptReview(String attemptId) =>
      '/quizzes/attempts/$attemptId';
}
