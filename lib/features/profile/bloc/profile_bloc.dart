import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Manages the Profile screen lifecycle: loading the current user's profile,
/// persisting edits, and resetting state on logout.
///
/// Injected via [BlocProvider] at the app root (alongside [AuthBloc]);
/// injection mirrors the authentication module's patterns.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _profileService;

  ProfileBloc(this._profileService) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileResetRequested>(_onResetRequested);
  }

  // ── Load ────────────────────────────────────────────────────────────────
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Keep previously loaded data visible during a refresh.
    final previous = state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
    if (previous != null) {
      emit(ProfileLoading(previous: previous));
    } else {
      emit(const ProfileLoading());
    }

    try {
      final profile = await _profileService.getCurrentProfile();
      emit(ProfileLoaded(profile));
    } on ProfileException catch (e) {
      emit(ProfileError(e.message, lastProfile: previous));
    } catch (_) {
      emit(const ProfileError(
        'Failed to load your profile. Please try again.',
      ));
    }
  }

  // ── Update ──────────────────────────────────────────────────────────────
  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final previous = state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
    if (previous != null) {
      emit(ProfileLoading(previous: previous));
    } else {
      emit(const ProfileLoading());
    }

    try {
      final updated = await _profileService.updateProfile(event.profile);
      emit(ProfileLoaded(updated));
    } on ProfileException catch (e) {
      emit(ProfileError(e.message, lastProfile: previous));
    } catch (_) {
      emit(ProfileError(
        'Failed to update your profile. Please try again.',
        lastProfile: previous,
      ));
    }
  }

  // ── Reset (logout) ──────────────────────────────────────────────────────
  Future<void> _onResetRequested(
    ProfileResetRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Clear the cached profile so no stale data survives into the next session.
    await _profileService.clearCache();
    emit(const ProfileInitial());
  }
}
