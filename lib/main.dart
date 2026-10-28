import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/shared_prefs_storage.dart';
import 'features/authentication/services/api_auth_service.dart';
import 'features/authentication/bloc/auth_bloc.dart';

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
  debugPrint('[KUTA] Auth service ready – launching app');

  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(authService)..add(const AuthCheckRequested()),
      child: const KutaApp(),
    ),
  );
}
