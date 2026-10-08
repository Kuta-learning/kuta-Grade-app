/// Backend API route definitions and endpoint constants.
class ApiEndpoints {
  static const String baseUrl = 'https://api.kuta.app/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Curriculum & Learning endpoints
  static const String subjects = '/curriculum/subjects';
  static const String kgActivities = '/kg/activities';
  static const String progress = '/progress/update';

  // Prevent instantiation
  ApiEndpoints._();
}
