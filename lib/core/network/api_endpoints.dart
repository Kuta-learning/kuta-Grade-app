/// API endpoint constants for Kuta Learning backend services.
class ApiEndpoints {
  ApiEndpoints._();

  /// Production backend hosted on Render.
  static const String baseUrl = 'https://kuta-learning.onrender.com/api';

  // ── Authentication ────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';
  static const String onboarding = '/auth/onboarding';
  static const String profile = '/auth/profile';

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
