import 'user_model.dart';

/// Response payload returned by `/auth/register` and `/auth/login`.
class AuthResponse {
  final String token;
  final String? refreshToken;
  final String? role;
  final UserModel user;

  const AuthResponse({
    required this.token,
    this.refreshToken,
    this.role,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final profileData = json['profile'] ?? json['user'] ?? json;
    return AuthResponse(
      token: (json['token'] ?? '') as String,
      refreshToken: json['refreshToken'] as String?,
      role: json['role'] as String?,
      user: UserModel.fromJson(profileData as Map<String, dynamic>),
    );
  }
}
