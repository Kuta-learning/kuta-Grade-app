import '../models/register_request.dart';
import '../models/user_model.dart';

/// Authentication service contract.
/// Handles login, registration, logout, and session resolution.
/// To be implemented with a real HTTP client (e.g. Dio) when the
/// backend is ready.
abstract class AuthService {
  /// Returns the currently authenticated user from local cache, or null.
  Future<UserModel?> getCurrentUser();

  /// Authenticates an existing user with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<UserModel> login({required String email, required String password});

  /// Registers a new user using the provided [request].
  /// Throws [AuthException] on failure.
  Future<UserModel> register(RegisterRequest request);

  /// Signs out the current user and clears the local session.
  Future<void> logout();
}

/// Typed exception thrown by [AuthService] implementations.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException($code): $message';
}
