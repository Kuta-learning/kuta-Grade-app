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
}
