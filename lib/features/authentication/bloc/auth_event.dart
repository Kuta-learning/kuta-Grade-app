part of 'auth_bloc.dart';

/// Base class for all authentication events.
sealed class AuthEvent {
  const AuthEvent();
}

/// Dispatched on app startup to check if a session exists in local storage.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Dispatched when the user submits the registration form.
final class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final GradeLevel gradeLevel;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.gradeLevel,
  });
}

/// Dispatched when the user submits the login form.
final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

/// Dispatched when the user taps the logout button.
final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
