/// App localization placeholder.
/// Manages language translations (e.g., English, Amharic, Afaan Oromoo).
class AppLocalization {
  final String locale;

  const AppLocalization(this.locale);

  static const List<String> supportedLocales = ['en', 'am', 'om'];
}
