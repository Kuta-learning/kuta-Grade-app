import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/app.dart';
import 'package:kuta_grade/features/common/screens/splash_screen.dart';

void main() {
  testWidgets('App smoke test builds KutaApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KutaApp());

    // Verify that the splash screen widget renders
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
