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

  // ── Onboarding ────────────────────────────────────────────────────────────
  /// Set to `"true"` once the user completes the onboarding flow.
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // ── User Preferences ─────────────────────────────────────────────────────
  /// App locale code (e.g. "en", "am").
  static const String preferredLocale = 'preferred_locale';

  /// Theme mode: "light", "dark", or "system".
  static const String themeMode = 'theme_mode';
}
