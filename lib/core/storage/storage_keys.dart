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

  // ── User Preferences ─────────────────────────────────────────────────────
  /// App locale code (e.g. "en", "am").
  static const String preferredLocale = 'preferred_locale';

  /// Theme mode: "light", "dark", or "system".
  static const String themeMode = 'theme_mode';
}
