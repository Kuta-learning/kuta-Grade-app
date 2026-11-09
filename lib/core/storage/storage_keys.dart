/// Central registry of all local storage keys used across the application.
/// Always use these constants instead of raw strings to avoid typos and collisions.
abstract class StorageKeys {
  StorageKeys._();

  // ── Authentication ────────────────────────────────────────────────────────
  /// Serialized JSON string of the authenticated [UserModel].
  static const String authUser = 'auth_user';

  /// Bearer token returned by the auth API (store in secure storage in prod).
  static const String authToken = 'auth_token';

  /// Refresh token for silent re-authentication.
  static const String authRefreshToken = 'auth_refresh_token';

  // ── Onboarding & Academic Selection ───────────────────────────────────────
  /// Set to `"true"` once the user completes the introductory onboarding slides.
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  /// Set to `"true"` once the user completes grade & academic stream selection.
  static const String hasSelectedGrade = 'has_selected_grade';

  /// Set to `"true"` once the welcome SnackBar has been shown on the dashboard.
  /// Cleared on logout so the user sees it again on next login.
  static const String hasSeenWelcomeSnackbar = 'has_seen_welcome_snackbar';

  // ── Profile ───────────────────────────────────────────────────────────────
  /// Serialized JSON cache of the user's [ProfileModel] for the Profile screen.
  /// Cleared on logout via [ProfileBloc]'s reset flow.
  static const String profileCache = 'profile_cache';

  // ── National Exam Dashboard Cache ─────────────────────────────────────────
  /// Serialized JSON string of [NationalExamDashboardModel].
  static const String examDashboardCache = 'exam_dashboard_cache';

  /// Epoch timestamp (milliseconds) when [examDashboardCache] was last updated.
  static const String examDashboardCacheTime = 'exam_dashboard_cache_time';

  // ── Short Notes & Chapters Cache ──────────────────────────────────────────
  /// Serialized JSON cache of short notes subjects list.
  static const String notesSubjectsCache = 'notes_subjects_cache';

  /// Generates the cache key for a specific subject's chapters detail.
  static String notesSubjectDetailCache(String subjectId) =>
      'notes_subject_detail_$subjectId';

  /// Generates the cache key for a specific chapter lesson detail.
  static String notesChapterLessonCache(String chapterId) =>
      'notes_chapter_lesson_$chapterId';

  // ── User Preferences ─────────────────────────────────────────────────────
  /// App locale code (e.g. "en", "am").
  static const String preferredLocale = 'preferred_locale';

  /// Theme mode: "light", "dark", or "system".
  static const String themeMode = 'theme_mode';
}
