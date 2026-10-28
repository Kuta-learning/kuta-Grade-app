import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/features/grades/models/national_exam_dashboard_model.dart';
import 'package:kuta_grade/features/grades/screens/exam_simulator_screen.dart';

void main() {
  testWidgets('ExamSimulatorScreen renders all reference design elements without back button', (
    WidgetTester tester,
  ) async {
    // Set a phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const testDashboardData = NationalExamDashboardModel(
      student: StudentInfo(
        name: 'Ruth',
        gradeLevel: 12,
        stream: 'NATURAL',
        isPremium: true,
      ),
      bannerExam: BannerExamInfo(
        title: '2022 National Exam',
        subjectName: 'Physics',
        action: 'Resume Exam',
        timeRemainingSeconds: 2520, // 42 mins
      ),
      subjectsCount: 6,
      subjects: [
        NationalExamSubjectModel(
          id: 'sub-1',
          name: 'Mathematics',
          code: 'MATH',
          stream: 'NATURAL',
          description: 'Natural Science Track',
          subcategories: 'Natural Science Track',
          iconKey: 'calculator',
          hexColor: '#3B82F6',
          totalExams: 10,
          totalQuestions: 850,
          completedExams: 4,
          progressPercentage: 0.45,
        ),
        NationalExamSubjectModel(
          id: 'sub-2',
          name: 'Physics',
          code: 'PHYS',
          stream: 'NATURAL',
          description: 'Mechanics, Waves & Modern',
          subcategories: 'Mechanics, Waves & Modern',
          iconKey: 'bolt',
          hexColor: '#F59E0B',
          totalExams: 8,
          totalQuestions: 720,
          completedExams: 2,
          progressPercentage: 0.30,
        ),
        NationalExamSubjectModel(
          id: 'sub-3',
          name: 'Chemistry',
          code: 'CHEM',
          stream: 'NATURAL',
          description: 'Organic, Inorganic & Physical',
          subcategories: 'Organic, Inorganic & Physical',
          iconKey: 'chemistry',
          hexColor: '#10B981',
          totalExams: 8,
          totalQuestions: 800,
          completedExams: 1,
          progressPercentage: 0.20,
        ),
        NationalExamSubjectModel(
          id: 'sub-4',
          name: 'Biology',
          code: 'BIO',
          stream: 'NATURAL',
          description: 'Genetics, Ecology & Human Bio',
          subcategories: 'Genetics, Ecology & Human Bio',
          iconKey: 'biology',
          hexColor: '#8B5CF6',
          totalExams: 9,
          totalQuestions: 780,
          completedExams: 5,
          progressPercentage: 0.60,
        ),
        NationalExamSubjectModel(
          id: 'sub-5',
          name: 'English',
          code: 'ENG',
          stream: 'NATURAL',
          description: 'Grammar, Reading & Vocab',
          subcategories: 'Grammar, Reading & Vocab',
          iconKey: 'book',
          hexColor: '#EC4899',
          totalExams: 12,
          totalQuestions: 1200,
          completedExams: 9,
          progressPercentage: 0.75,
        ),
        NationalExamSubjectModel(
          id: 'sub-6',
          name: 'Civics & Ethical Education',
          code: 'CIV',
          stream: 'NATURAL',
          description: 'Constitution, Ethics & Society',
          subcategories: 'Constitution, Ethics & Society',
          iconKey: 'shield',
          hexColor: '#06B6D4',
          totalExams: 6,
          totalQuestions: 640,
          completedExams: 3,
          progressPercentage: 0.50,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ExamSimulatorScreen(
          initialDashboardData: testDashboardData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. App Bar - Must have title, bookmarks, profile, but NO back button
    expect(find.text('Exam Simulator'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    // 2. Welcome Banner
    expect(find.text('Welcome back, Ruth!'), findsOneWidget);
    expect(find.text('Grade 12 Natural Science'), findsOneWidget);

    // 3. Active Exam Card
    expect(find.text('Physics 2022 National Exam'), findsOneWidget);
    expect(find.text('42 mins remaining'), findsOneWidget);
    expect(find.text('Q 34/100'), findsOneWidget);
    expect(find.text('Paper 1 • Physics'), findsOneWidget);
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
    expect(find.text('1200 Questions'), findsOneWidget);

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
