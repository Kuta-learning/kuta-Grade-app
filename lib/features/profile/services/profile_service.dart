import '../models/profile_model.dart';

/// Service contract managing user profile data and preferences.
abstract class ProfileService {
  Future<ProfileModel> getProfile(String userId);
  Future<void> updateProfile(ProfileModel profile);
}
