import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuta_grade/features/authentication/bloc/auth_bloc.dart';
import 'package:kuta_grade/features/authentication/models/user_model.dart';
import 'package:kuta_grade/features/authentication/models/register_request.dart';
import 'package:kuta_grade/features/authentication/services/auth_service.dart';
import 'package:kuta_grade/features/authentication/screens/otp_verification_screen.dart';
import 'package:kuta_grade/core/constants/grade_level.dart';
import 'package:kuta_grade/core/constants/academic_stream.dart';

class _FakeAuthService implements AuthService {
  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async => UserModel(
    id: '1',
    email: email,
    name: 'Test',
    gradeLevel: GradeLevel.grade12,
  );

  @override
  Future<UserModel> register(RegisterRequest request) async => UserModel(
    id: '1',
    email: request.email,
    name: request.name,
    gradeLevel: GradeLevel.grade12,
  );

  @override
  Future<UserModel> updateAcademicProfile({
    required GradeLevel gradeLevel,
    AcademicStream? stream,
  }) async => UserModel(
    id: '1',
    email: 'test@kuta.com',
    name: 'Test',
    gradeLevel: gradeLevel,
  );

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async => 'test-reset-token';

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
  testWidgets(
    'OtpVerificationScreen renders all UI elements and 6 digit boxes',
    (WidgetTester tester) async {
      final fakeAuth = _FakeAuthService();
      final authBloc = AuthBloc(fakeAuth);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const OtpVerificationScreen(email: 'student@example.com'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and email display
      expect(find.text('Enter Verification Code'), findsOneWidget);
      expect(find.textContaining('student@example.com'), findsOneWidget);

      // Check 6-digit label and 6 text fields
      expect(find.text('6-DIGIT CODE'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(6));

      // Check Verify Button
      expect(find.text('Verify Code'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    },
  );
}
