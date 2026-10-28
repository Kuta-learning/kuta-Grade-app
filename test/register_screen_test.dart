import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuta_grade/core/constants/academic_stream.dart';
import 'package:kuta_grade/core/constants/grade_level.dart';
import 'package:kuta_grade/core/router/route_names.dart';
import 'package:kuta_grade/features/authentication/bloc/auth_bloc.dart';
import 'package:kuta_grade/features/authentication/models/register_request.dart';
import 'package:kuta_grade/features/authentication/models/user_model.dart';
import 'package:kuta_grade/features/authentication/screens/register_screen.dart';
import 'package:kuta_grade/features/authentication/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  RegisterRequest? lastRegisterRequest;

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
      gradeLevel: GradeLevel.grade12,
    );
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    lastRegisterRequest = request;
    return UserModel(
      id: 'test-user-123',
      email: request.email,
      name: request.name,
      gradeLevel: request.gradeLevel,
    );
  }

  @override
  Future<UserModel> updateAcademicProfile({
    required GradeLevel gradeLevel,
    AcademicStream? stream,
  }) async {
    return UserModel(
      id: 'test-user-123',
      email: 'student@kuta.app',
      name: 'Test Student',
      gradeLevel: gradeLevel,
      academicStream: stream,
    );
  }

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async =>
      'test-token';

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  late _FakeAuthService fakeAuthService;
  late AuthBloc authBloc;

  setUp(() {
    fakeAuthService = _FakeAuthService();
    authBloc = AuthBloc(fakeAuthService);
  });

  tearDown(() {
    authBloc.close();
  });

  Widget buildTestWidget() {
    final router = GoRouter(
      initialLocation: RouteNames.register,
      routes: [
        GoRoute(
          path: RouteNames.register,
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.gradeSelection,
          builder: (context, state) =>
              const Scaffold(body: Text('GradeSelectionScreen')),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) =>
              const Scaffold(body: Text('LoginScreen')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('RegisterScreen renders all primary UI elements',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Continue your journey to mastery'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
  });

  testWidgets('RegisterScreen validates empty fields and displays errors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Sign Up with empty fields
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
  });

  testWidgets('RegisterScreen validates improper format and weak password',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter invalid name (1 character)
    await tester.enterText(find.byType(TextFormField).at(0), 'A');
    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
    // Enter weak password (no numbers)
    await tester.enterText(find.byType(TextFormField).at(2), 'short');

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    expect(
      find.text('Please enter a valid email address'),
      findsOneWidget,
    );
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets(
      'RegisterScreen sanitizes input and dispatches RegisterRequested with clean data',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter name with extra whitespace
    await tester.enterText(find.byType(TextFormField).at(0), '  Abel   Abebe  ');
    // Enter email with mixed case and leading/trailing spaces
    await tester.enterText(
        find.byType(TextFormField).at(1), '  Abel.Student@Kuta.COM  ');
    // Enter valid password
    await tester.enterText(find.byType(TextFormField).at(2), 'Password123');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(fakeAuthService.lastRegisterRequest, isNotNull);
    // Name should be trimmed and multiple spaces collapsed
    expect(fakeAuthService.lastRegisterRequest!.name, 'Abel Abebe');
    // Email should be trimmed and lowercased
    expect(fakeAuthService.lastRegisterRequest!.email, 'abel.student@kuta.com');
    expect(fakeAuthService.lastRegisterRequest!.password, 'Password123');
  });
}
