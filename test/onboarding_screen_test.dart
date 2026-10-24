import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_learning_app/features/common/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders slide 1 with Skip button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Skip button IS visible on slide 1 (not the last slide)
    expect(find.text('Skip'), findsOneWidget);

    // Verify Slide 1 text
    expect(find.text('Excel in Your Exams'), findsOneWidget);
    expect(
      find.text(
        'Personalized learning paths for Grade 6 to 8. Master complex topics with interactive practice and expert guidance.',
      ),
      findsOneWidget,
    );

    // Verify Next CTA button exists
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Skip button is hidden on the last onboarding slide',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(initialPage: 2),
      ),
    );
    await tester.pumpAndSettle();

    // On the last slide (index 2) Skip should not be shown
    expect(find.text('Skip'), findsNothing);
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
    expect(find.text('Next'), findsOneWidget);

    // Tap Next to go to Slide 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Slide 2 text
    expect(find.text('Learn at Your Pace'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(
      find.text(
        'Interactive lessons with videos, audio and quizzes designed to keep you engaged and motivated every day.',
      ),
      findsOneWidget,
    );

    // Tap Next to go to Slide 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Slide 3 text
    expect(find.text('Track Your Progress'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(
      find.text(
        'See how far you\'ve come. Complete lessons, earn badges and show your achievements to the world!',
      ),
      findsOneWidget,
    );
  });
}
