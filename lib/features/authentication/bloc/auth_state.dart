part of 'auth_bloc.dart';

/// Base class for all authentication states.
sealed class AuthState {
  const AuthState();
}

/// Initial state before any auth check has been performed.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An auth operation is in progress (login, register, or session check).
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Registration completed successfully; user should now log in.
/// Carries [userName] for a personalised success message.
final class AuthRegisterSuccess extends AuthState {
  final String userName;
  const AuthRegisterSuccess(this.userName);
}

/// A user is fully authenticated with a valid session.
final class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}

/// No authenticated user; show login/register flow.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed with a user-facing [message].
final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}
