import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/core/widgets/app_snackbar.dart';

void main() {
  testWidgets(
    'AppSnackBar.showWelcome displays animated card with title and subtitle',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppSnackBar.showWelcome(context, name: 'Dawit');
                  },
                  child: const Text('Show Welcome'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to trigger SnackBar
      await tester.tap(find.text('Show Welcome'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 500)); // Complete entrance

      expect(find.text('Welcome, Dawit!'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    },
  );

  testWidgets('AppSnackBar.showError displays error card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppSnackBar.showError(context, 'Invalid email or password.');
                },
                child: const Text('Show Error'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Invalid email or password.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}
