import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_learning_app/core/constants/academic_stream.dart';
import 'package:kuta_learning_app/core/constants/grade_level.dart';
import 'package:kuta_learning_app/features/authentication/bloc/academic_selection/academic_selection_bloc.dart';
import 'package:kuta_learning_app/features/authentication/models/register_request.dart';
import 'package:kuta_learning_app/features/authentication/models/user_model.dart';
import 'package:kuta_learning_app/features/authentication/screens/grade_selection_screen.dart';
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
      gradeLevel: request.gradeLevel ?? GradeLevel.grade6,
    );
  }

  @override
  Future<UserModel> updateAcademicProfile({
    required GradeLevel gradeLevel,
    AcademicStream? stream,
  }) async {
    return UserModel(
      id: 'test-123',
      email: 'student@kuta.app',
      name: 'Test Student',
      gradeLevel: gradeLevel,
      academicStream: stream,
    );
  }

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<String> verifyOtp({required String email, required String otp}) async =>
      'fake-reset-token';

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
  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<AcademicSelectionBloc>(
        create: (_) => AcademicSelectionBloc(
          authService: _FakeAuthService(),
        ),
        child: const GradeSelectionScreen(),
      ),
    );
  }

  testWidgets('GradeSelectionScreen renders Step 1 with default Grade 12',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Which grade are you in?'), findsOneWidget);
    expect(
      find.text('Select your current level to personalize your learning path.'),
      findsOneWidget,
    );

    // Verify Step Header for Grade 12: Step 1 of 2, 50% completed
    expect(find.text('STEP 1 OF 2'), findsOneWidget);
    expect(find.text('50% completed'), findsOneWidget);

    // Verify Grade options
    expect(find.text('Grade 6'), findsOneWidget);
    expect(find.text('Grade 8'), findsOneWidget);
    expect(find.text('Grade 12'), findsOneWidget);

    // Verify CTA button says Continue for Grade 12
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets(
      'Selecting Grade 6 dynamically updates to STEP 1 OF 1, 100% completed, and Enter Dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap Grade 6
    await tester.tap(find.text('Grade 6'));
    await tester.pumpAndSettle();

    // Progression should dynamically update to 1 of 1 and 100% completed
    expect(find.text('STEP 1 OF 1'), findsOneWidget);
    expect(find.text('100% completed'), findsOneWidget);

    // CTA button should dynamically switch to Enter Dashboard
    expect(find.text('Enter Dashboard'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets(
      'Transitioning to Step 2 for Grade 12 displays stream selection and back button',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Grade 12 is selected by default, tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify Step 2 header
    expect(find.text('STEP 2 OF 2'), findsOneWidget);
    expect(find.text('100% completed'), findsOneWidget);
    expect(find.text('Select your stream'), findsOneWidget);
    expect(find.text('Grade 12 academic track'), findsOneWidget);

    // Verify Stream options and subject chips
    expect(find.text('Natural Science'), findsOneWidget);
    expect(find.text('Social Science'), findsOneWidget);
    expect(find.text('Mathematics (Natural)'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);

    // Verify CTA button on Step 2 says Enter Dashboard
    expect(find.text('Enter Dashboard'), findsOneWidget);

    // Verify back button is present and works
    final backButton = find.byIcon(Icons.arrow_back_rounded);
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Returns to Step 1
    expect(find.text('Which grade are you in?'), findsOneWidget);
  });
}
