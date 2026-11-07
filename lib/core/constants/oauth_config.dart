import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OAuth / third-party identity configuration for the Kuta Learning app.
///
/// Values are injected at startup from the local `.env` file — see
/// `.env.example`. The Web Client ID is used as the [GoogleSignIn]
/// `serverClientId` on Android so Google issues an ID token audienced for the
/// backend's verification logic.
class OAuthConfig {
  OAuthConfig._();

  /// Google OAuth 2.0 Web Client ID, loaded from the
  /// `GOOGLE_WEB_CLIENT_ID` environment entry.
  static String get googleWebClientId =>
      dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID', fallback: '') ?? '';
}
