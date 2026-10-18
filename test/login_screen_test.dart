import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_learning_app/core/constants/grade_level.dart';
import 'package:kuta_learning_app/features/authentication/bloc/auth_bloc.dart';
import 'package:kuta_learning_app/features/authentication/models/register_request.dart';
import 'package:kuta_learning_app/features/authentication/models/user_model.dart';
import 'package:kuta_learning_app/features/authentication/screens/login_screen.dart';
import 'package:kuta_learning_app/features/authentication/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return UserModel(
      id: 'test-123',
      email: email,
      name: 'Test Student',
      gradeLevel: GradeLevel.grade6,
    );
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    return UserModel(
      id: 'test-123',
      email: request.email,
      name: request.name,
      gradeLevel: request.gradeLevel,
    );
  }

  @override
  Future<void> logout() async {}
}

void main() {
  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(_FakeAuthService()),
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen renders all visual elements matching design',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue your journey to mastery'), findsOneWidget);

    // Verify Input Labels
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify Placeholder / Hint text
    expect(find.text('student@example.com'), findsOneWidget);
    expect(find.text('••••••••'), findsOneWidget);

    // Verify Helper text
    expect(
      find.text('Minimum 8 characters with a mix of letters and numbers.'),
      findsOneWidget,
    );

    // Verify Links and Buttons
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('or continue with'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(find.text('Sign up for free'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation errors for empty fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap Login button without entering anything
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('LoginScreen toggles password visibility',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final visibilityFinder = find.byIcon(Icons.visibility_outlined);
    expect(visibilityFinder, findsOneWidget);

    await tester.tap(visibilityFinder);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
