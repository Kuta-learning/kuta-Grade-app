import '../models/profile_model.dart';

/// Typed exception thrown by [ProfileService] implementations.
/// Mirrors [AuthException] from the authentication module.
class ProfileException implements Exception {
  final String message;
  final String? code;

  const ProfileException(this.message, {this.code});

  @override
  String toString() => 'ProfileException($code): $message';
}

/// Service contract managing user profile data.
/// Mirrors the [AuthService] patterns (live API + cached fallback).
abstract class ProfileService {
  /// Loads the current user's profile from the live API (`GET /auth/me`).
  /// Falls back to the cached profile on network errors.
  Future<ProfileModel> getCurrentProfile();

  /// Persists editable profile fields via `PUT /auth/profile` (name, avatar).
  /// Throws [ProfileException] on failure.
  Future<ProfileModel> updateProfile(ProfileModel profile);

  /// Removes the locally cached profile (called on logout/reset).
  Future<void> clearCache();
}
