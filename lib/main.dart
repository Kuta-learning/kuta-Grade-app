import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/shared_prefs_storage.dart';
import 'features/authentication/services/api_auth_service.dart';
import 'features/authentication/bloc/auth_bloc.dart';
import 'features/grades/bloc/grades_bloc.dart';
import 'features/grades/services/api_courses_service.dart';
import 'features/grades/services/api_notes_service.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/profile/services/api_profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[KUTA] WidgetsBinding initialized');

  // Safely initialize Rive Native runtime with a timeout to prevent hangs
  try {
    final riveOk = await RiveNative.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('[KUTA] RiveNative.init() timed out after 5s – skipping');
        return false;
      },
    );
    debugPrint('[KUTA] RiveNative.init() completed: $riveOk');
  } catch (e, st) {
    debugPrint('[KUTA] RiveNative.init warning: $e\n$st');
  }

  // Initialize local storage once before the app starts
  debugPrint('[KUTA] Initializing SharedPrefsStorage...');
  final storage = await SharedPrefsStorage.getInstance();
  debugPrint('[KUTA] Storage ready');

  final apiClient = ApiClient();
  final authService = ApiAuthService(apiClient: apiClient, storage: storage);
  final notesService = ApiNotesService(apiClient: apiClient);
  final coursesService = ApiCoursesService(apiClient: apiClient);
  final profileService = ApiProfileService(apiClient: apiClient, storage: storage);
  debugPrint('[KUTA] Services ready – launching app');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authService)..add(const AuthCheckRequested()),
        ),
        BlocProvider<NotesBloc>(
          create: (_) => NotesBloc(notesService),
        ),
        BlocProvider<CoursesBloc>(
          create: (_) => CoursesBloc(coursesService),
        ),
        BlocProvider<ProfileBloc>(
          // Lazy: no profile fetch until the Profile screen requests it.
          create: (_) => ProfileBloc(profileService),
        ),
      ],
      child: const KutaApp(),
    ),
  );
}
