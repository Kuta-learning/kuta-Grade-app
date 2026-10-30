import '../../../core/storage/shared_prefs_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../authentication/models/user_model.dart';
import '../models/profile_model.dart';
import 'profile_service.dart';

/// Mock implementation of [ProfileService] for development and UI testing.
/// Simulates network latency and derives the profile from the locally cached
/// auth user. Performance/subscription stats stay null so the UI shows the
/// real dash placeholders until backend endpoints exist.
/// Replace with [ApiProfileService] wiring when the API is ready.
class MockProfileService implements ProfileService {
  final SharedPrefsStorage _storage;

  MockProfileService(this._storage);

  @override
  Future<ProfileModel> getCurrentProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final raw = await _storage.getString(StorageKeys.authUser);
    final user = UserModel.fromJsonString(raw);
    if (user == null) {
      throw const ProfileException(
        'No active session. Please log in again.',
        code: 'not_authenticated',
      );
    }
    return ProfileModel.fromUser(user);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _storage.setString(
      StorageKeys.profileCache,
      profile.toJsonString(),
    );
    return profile;
  }

  @override
  Future<void> clearCache() async {
    await _storage.remove(StorageKeys.profileCache);
  }
}
