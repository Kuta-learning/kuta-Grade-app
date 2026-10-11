import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_learning_app/features/common/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders slide 1 without Skip button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Skip button does NOT exist
    expect(find.text('Skip'), findsNothing);

    // Verify Slide 1 text
    expect(find.text('Excel in Your Exams'), findsOneWidget);
    expect(
      find.text(
        'Personalized learning paths for Grade 6 to 8. Master complex topics with interactive practice and expert guidance.',
      ),
      findsOneWidget,
    );

    // Verify Get Started CTA button exists
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('OnboardingScreen transitions through all 3 slides',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Slide 1
    expect(find.text('Excel in Your Exams'), findsOneWidget);

    // Tap Get Started to go to Slide 2
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Slide 2 text
    expect(find.text('Learn at Your Pace'), findsOneWidget);
    expect(
      find.text(
        'Interactive lessons with videos, audio and quizzes designed to keep you engaged and motivated every day.',
      ),
      findsOneWidget,
    );

    // Tap Get Started to go to Slide 3
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Slide 3 text
    expect(find.text('Track Your Progress'), findsOneWidget);
    expect(
      find.text(
        'See how far you\'ve come. Complete lessons, earn badges and show your achievements to the world!',
      ),
      findsOneWidget,
    );
  });
}
