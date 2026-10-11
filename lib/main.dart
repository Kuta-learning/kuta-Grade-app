import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/storage/shared_prefs_storage.dart';
import 'features/authentication/services/mock_auth_service.dart';
import 'features/authentication/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage once before the app starts
  final storage = await SharedPrefsStorage.getInstance();
  final authService = MockAuthService(storage);

  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(authService)..add(const AuthCheckRequested()),
      child: const KutaApp(),
    ),
  );
}
