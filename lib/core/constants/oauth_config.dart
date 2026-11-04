/// OAuth / third-party identity configuration for the Kuta Learning app.
///
/// These values are public client identifiers (not secrets) issued by the
/// backend team's Google Cloud project. The Web Client ID is used as the
/// [GoogleSignIn] `serverClientId` on Android so that Google issues an ID
/// token audienced for the backend's verification logic.
class OAuthConfig {
  OAuthConfig._();

  /// Google OAuth 2.0 Web Client ID (from the backend team).
  static const String googleWebClientId =
      '790287125626-75n8rd3ijqpmdguihi381uku7l6r2t69.apps.googleusercontent.com';
}
