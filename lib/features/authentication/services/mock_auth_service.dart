import '../../../core/constants/academic_stream.dart';
import '../../../core/constants/grade_level.dart';
import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

/// Mock implementation of [AuthService] for development and UI testing.
/// Simulates network latency and returns fake user data.
/// Replace with a real Dio-backed implementation when the API is ready.
class MockAuthService implements AuthService {
  final SharedPrefsStorage _storage;

  MockAuthService(this._storage);

  @override
  Future<UserModel?> getCurrentUser() async {
    final raw = await _storage.getString(StorageKeys.authUser);
    final user = UserModel.fromJsonString(raw);
    if (user != null && user.gradeLevel == GradeLevel.kg) {
      final updatedUser = user.copyWith(
        gradeLevel: GradeLevel.grade12,
        name: user.name == 'Mock Student' ? 'Ruth' : user.name,
      );
      await _storage.setString(
        StorageKeys.authUser,
        updatedUser.toJsonString(),
      );
      return updatedUser;
    }
    return user;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.length < 8) {
      throw const AuthException(
        'Invalid email or password.',
        code: 'invalid_credentials',
      );
    }

    final user = UserModel(
      id: 'mock-user-001',
      email: email,
      name: 'Ruth',
      gradeLevel: GradeLevel.grade12,
    );

    await _storage.setString(StorageKeys.authUser, user.toJsonString());
    await _storage.setString(StorageKeys.authToken, 'mock-token-abc123');
    // If user has not explicitly set grade selection yet, default to true for existing logins
    final existingGradeSelected = await _storage.getBool(StorageKeys.hasSelectedGrade);
    if (existingGradeSelected == null) {
      await _storage.setBool(StorageKeys.hasSelectedGrade, value: true);
    }
    return user;
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (request.email.isEmpty || request.password.length < 8) {
      throw const AuthException(
        'Please provide a valid email and a password of at least 8 characters.',
        code: 'invalid_input',
      );
    }

    final user = UserModel(
      id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      email: request.email,
      name: request.name,
      gradeLevel: request.gradeLevel ?? GradeLevel.grade12,
    );

    await _storage.setString(StorageKeys.authUser, user.toJsonString());
    await _storage.setString(StorageKeys.authToken, 'mock-token-${user.id}');
    // Newly registered user has not selected their grade yet
    await _storage.setBool(StorageKeys.hasSelectedGrade, value: false);
    return user;
  }

  @override
  Future<UserModel> updateAcademicProfile({
    required GradeLevel gradeLevel,
    AcademicStream? stream,
  }) async {
    final current = await getCurrentUser();
    final updated = (current ??
            UserModel(
              id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
              email: 'student@kuta.app',
              name: 'Student',
              gradeLevel: gradeLevel,
              academicStream: stream,
            ))
        .copyWith(
      gradeLevel: gradeLevel,
      academicStream: stream,
    );

    await _storage.setString(StorageKeys.authUser, updated.toJsonString());
    // Mark grade selection as completed in local storage
    await _storage.setBool(StorageKeys.hasSelectedGrade, value: true);
    return updated;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isEmpty || !email.contains('@')) {
      throw const AuthException('Invalid email address.', code: 'invalid_email');
    }
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp.length != 6) {
      throw const AuthException('Invalid OTP code. Must be 6 digits.', code: 'invalid_otp');
    }
    return 'mock-reset-token-xyz123';
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (newPassword.length < 8) {
      throw const AuthException('Password must be at least 8 characters.', code: 'invalid_password');
    }
  }

  @override
  Future<void> logout() async {
    // Clear user session and grade selection flag so registration/login is required again
    await _storage.remove(StorageKeys.authUser);
    await _storage.remove(StorageKeys.authToken);
    await _storage.remove(StorageKeys.authRefreshToken);
    await _storage.remove(StorageKeys.hasSelectedGrade);
    await _storage.remove(StorageKeys.hasSeenWelcomeSnackbar);
    // Note: StorageKeys.hasSeenOnboarding is intentionally preserved so onboarding is only seen once
  }
}
