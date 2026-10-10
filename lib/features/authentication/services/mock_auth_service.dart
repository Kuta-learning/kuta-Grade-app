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
    return UserModel.fromJsonString(raw);
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
      name: 'Mock Student',
      gradeLevel: GradeLevel.values.first,
    );

    await _storage.setString(StorageKeys.authUser, user.toJsonString());
    await _storage.setString(StorageKeys.authToken, 'mock-token-abc123');
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
      gradeLevel: request.gradeLevel,
    );

    await _storage.setString(StorageKeys.authUser, user.toJsonString());
    await _storage.setString(StorageKeys.authToken, 'mock-token-${user.id}');
    return user;
  }

  @override
  Future<void> logout() async {
    await _storage.remove(StorageKeys.authUser);
    await _storage.remove(StorageKeys.authToken);
    await _storage.remove(StorageKeys.authRefreshToken);
  }
}
