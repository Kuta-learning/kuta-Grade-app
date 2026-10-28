import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/features/grades/grade_12/screens/grade_12_matric_exam_screen.dart';

void main() {
  testWidgets('Grade12MatricExamScreen renders all reference design elements', (
    WidgetTester tester,
  ) async {
    // Set a phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: Grade12MatricExamScreen()));
    await tester.pumpAndSettle();

    // 1. App Bar
    expect(find.text('Exam Simulator'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    // 2. Welcome Banner
    expect(find.text('Welcome back, Ruth!'), findsOneWidget);
    expect(find.text('Grade 12 Natural Science'), findsOneWidget);

    // 3. Active Exam Card
    expect(find.text('Physics 2022 National Exam'), findsOneWidget);
    expect(find.text('42 mins remaining'), findsOneWidget);
    expect(find.text('Q 34/100'), findsOneWidget);
    expect(find.text('Paper 1 • General Physics'), findsOneWidget);
    expect(find.text('Resume Exam'), findsOneWidget);

    // 4. Exam Subjects Section
    expect(find.text('Exam Subjects'), findsOneWidget);
    expect(find.text('6 Subjects'), findsOneWidget);
    expect(
      find.text(
        'Tap a subject to practice real past national exam papers by year.',
      ),
      findsOneWidget,
    );

    // 5. Subject Cards (all 6 subjects)
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Natural Science Track'), findsOneWidget);
    expect(find.text('45%'), findsOneWidget);
    expect(find.text('850 Questions'), findsOneWidget);

    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Mechanics, Waves & Modern'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('720 Questions'), findsOneWidget);

    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.text('Organic, Inorganic & Physical'), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);
    expect(find.text('800 Questions'), findsOneWidget);

    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('Genetics, Ecology & Human Bio'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('780 Questions'), findsOneWidget);

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Grammar, Reading & Vocab'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('1,200 Questions'), findsOneWidget);

    expect(find.text('Civics & Ethical Education'), findsOneWidget);
    expect(find.text('Constitution, Ethics & Society'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('640 Questions'), findsOneWidget);

    // 6. Bottom Navigation
    expect(find.text('Exams'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
