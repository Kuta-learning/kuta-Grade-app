import '../../../core/constants/academic_stream.dart';
import '../../../core/constants/grade_level.dart';
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

  /// Updates the academic profile (grade level and optional stream) of the current user.
  Future<UserModel> updateAcademicProfile({
    required GradeLevel gradeLevel,
    AcademicStream? stream,
  });

  /// Requests a 6-digit OTP code sent to [email] for password recovery.
  Future<void> requestPasswordReset(String email);

  /// Verifies the 6-digit OTP code sent to [email].
  /// Returns a signed resetToken to authorize password update.
  Future<String> verifyOtp({
    required String email,
    required String otp,
  });

  /// Updates the password using the signed [resetToken] returned from [verifyOtp].
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });

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
