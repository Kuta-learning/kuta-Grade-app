import '../models/user_model.dart';

/// Authentication service contract handling login, logout, and user resolution.
abstract class AuthService {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}
