part of 'profile_bloc.dart';

/// Base class for all profile events.
sealed class ProfileEvent {
  const ProfileEvent();
}

/// Dispatched when the Profile screen opens (first entry or refresh).
final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Dispatched when the user submits profile edits (Edit Profile phase).
final class ProfileUpdateRequested extends ProfileEvent {
  final ProfileModel profile;

  const ProfileUpdateRequested(this.profile);
}

/// Dispatched on logout to clear profile data and cached storage.
final class ProfileResetRequested extends ProfileEvent {
  const ProfileResetRequested();
}
