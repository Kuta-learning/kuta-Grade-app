import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/core/router/app_router.dart';
import 'package:kuta_grade/core/storage/shared_prefs_storage.dart';
import 'package:kuta_grade/core/storage/storage_keys.dart';
import 'package:kuta_grade/features/grades/widgets/intro_overlay/coach_mark_step.dart';
import 'package:kuta_grade/features/grades/widgets/intro_overlay/dashboard_intro_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds the dashboard shell under a plain MaterialApp and advances past
/// the initial frame + intro dialog entrance.
///
/// Note: the tour's connector dashes repeat forever, so fixed-duration pumps
/// are used instead of `pumpAndSettle` (which would time out).
Future<void> pumpShell(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MainGradeAppShell(
        location: '/grade12-matric-exam',
        child: const Scaffold(body: Center(child: Text('Dashboard body'))),
      ),
    ),
  );
  await settle(tester);
}

/// Advances time past the entrance animation (220ms) and the post-animation
/// card measurement frame.
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // The SharedPrefsStorage singleton caches its SharedPreferences, so we
    // reset just the key under test instead of re-mocking initial values.
    final storage = SharedPrefsStorage.instanceOrNull;
    if (storage == null) {
      SharedPreferences.setMockInitialValues({});
      await SharedPrefsStorage.getInstance();
    } else {
      await storage.remove(StorageKeys.hasSeenDashboardIntro);
    }
  });

  group('DashboardIntroOverlay (once-ever coach marks tour)', () {
    test('defaultSteps has 5 steps: 1 welcome + 4 targeted nav steps', () {
      final steps = DashboardIntroOverlay.defaultSteps(
        List.generate(4, (_) => GlobalKey()),
      );

      expect(steps.length, 5);
      expect(steps.first.targetKey, isNull, reason: 'Welcome step is full-screen');
      expect(
        steps.skip(1).every((CoachMarkStep s) => s.targetKey != null),
        isTrue,
        reason: 'The 4 nav steps each spotlight a tab',
      );
    });

    testWidgets('shows the tour on first dashboard visit', (tester) async {
      await pumpShell(tester);

      expect(find.text('Welcome to Kuta!'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      // Dashboard is behind the blocking dialog, but its content exists.
      expect(find.text('Dashboard body'), findsOneWidget);
    });

    testWidgets('Next walks through all steps, Get Started closes and persists',
        (tester) async {
      await pumpShell(tester);

      // Welcome -> Exams -> Notes -> Practice -> Profile
      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text('Exams'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text('Notes'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text('Practice'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await settle(tester);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await settle(tester);

      // Tour is gone and the once-ever flag is set.
      expect(find.text('Welcome to Kuta!'), findsNothing);
      expect(
        await SharedPrefsStorage.instance
            .getBool(StorageKeys.hasSeenDashboardIntro),
        isTrue,
      );

      // Rebuilding the shell must NOT show the tour again.
      await pumpShell(tester);
      expect(find.text('Welcome to Kuta!'), findsNothing);
      expect(find.text('Dashboard body'), findsOneWidget);
    });

    testWidgets('Skip closes the tour and persists the flag', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Skip'));
      await settle(tester);

      expect(find.text('Welcome to Kuta!'), findsNothing);
      expect(
        await SharedPrefsStorage.instance
            .getBool(StorageKeys.hasSeenDashboardIntro),
        isTrue,
      );

      // Second visit: no tour.
      await pumpShell(tester);
      expect(find.text('Welcome to Kuta!'), findsNothing);
    });
  });
}
