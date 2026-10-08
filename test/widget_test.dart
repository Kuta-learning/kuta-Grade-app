import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_learning_app/app.dart';

void main() {
  testWidgets('App smoke test builds KutaApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KutaApp());

    // Verify that the splash screen text renders
    expect(find.text('Splash Screen'), findsOneWidget);
  });
}
