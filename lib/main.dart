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
  await RiveNative.init();

  // Initialize local storage once before the app starts
  final storage = await SharedPrefsStorage.getInstance();
  final apiClient = ApiClient();
  final authService = ApiAuthService(apiClient: apiClient, storage: storage);

  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(authService)..add(const AuthCheckRequested()),
      child: const KutaApp(),
    ),
  );
}
