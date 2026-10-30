part of 'profile_bloc.dart';

/// Base class for all profile states.
sealed class ProfileState {
  const ProfileState();
}

/// Initial state before the profile has been loaded.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// The profile is being fetched or updated. Carries [previous] data so the
/// screen can render a silent refresh instead of a bare spinner.
final class ProfileLoading extends ProfileState {
  final ProfileModel? previous;
  const ProfileLoading({this.previous});
}

/// The profile has been loaded successfully.
/// Nullable stats (points, rank, billing date) render as dash placeholders.
final class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  const ProfileLoaded(this.profile);
}

/// A profile operation failed with a user-facing [message].
/// Carries [lastProfile] so the screen can still render known data.
final class ProfileError extends ProfileState {
  final String message;
  final ProfileModel? lastProfile;
  const ProfileError(this.message, {this.lastProfile});
}
