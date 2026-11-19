import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/core/router/app_router.dart';
import 'package:kuta_grade/core/router/route_names.dart';
import 'package:kuta_grade/features/grades/bloc/grades_bloc.dart';
import 'package:kuta_grade/features/grades/models/note_models.dart';
import 'package:kuta_grade/features/grades/services/notes_service.dart';

/// Test mock service providing Grade 6 subjects matching live backend response
class FakeGrade6NotesService implements NotesService {
  @override
  Future<List<NoteSubjectItem>> getShortNotesSubjects() async {
    return [
      NoteSubjectItem.fromJson(
        {
          'id': 'math-06-id',
          'name': 'ሒሳብ (Mathematics)',
          'code': 'MATH-06',
          'description': 'Grade 6 Mathematics',
          'gradeBadge': 'Grade 6',
          'curriculumType': 'Primary School Curriculum',
          'totalChapters': 5,
          'availableGrades': [6],
          'studentGrade': 6,
        },
        parentStudentGrade: 6,
        parentCurriculumType: 'Primary School Curriculum',
      ),
      NoteSubjectItem.fromJson(
        {
          'id': 'eng-06-id',
          'name': 'English',
          'code': 'ENG-06',
          'description': 'Grade 6 English',
          'gradeBadge': 'Grade 6',
          'curriculumType': 'Primary School Curriculum',
          'totalChapters': 4,
          'availableGrades': [6],
          'studentGrade': 6,
        },
        parentStudentGrade: 6,
        parentCurriculumType: 'Primary School Curriculum',
      ),
    ];
  }

  @override
  Future<SubjectNotesDetail> getSubjectNotesDetails(String subjectId) async {
    return SubjectNotesDetail.fromJson({
      'subjectId': subjectId,
      'subjectTitle': 'ሒሳብ (Mathematics)',
      'gradeLevel': 'Grade 6',
      'selectedGrade': 6,
      'studentGrade': 6,
      'requiresGradeSelection': false,
      'totalChapters': 2,
      'totalFileSize': '15 MB',
      'downloadAllUrl': 'https://kuta.com/download/all',
      'chapters': [
        {
          'id': 'chap-1',
          'chapterNumber': '1',
          'title': 'Whole Numbers & Decimals',
          'description': 'Place values, operations and rounding decimals',
          'pageCount': '10 Pages',
          'fileSize': '3.2 MB',
          'isCompleted': false,
        },
        {
          'id': 'chap-2',
          'chapterNumber': '2',
          'title': 'Fractions & Ratios',
          'description': 'Adding, subtracting and simplifying fractions',
          'pageCount': '14 Pages',
          'fileSize': '4.1 MB',
          'isCompleted': true,
        },
      ],
    });
  }

  @override
  Future<LessonDetail> getChapterNoteDetail(String chapterId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateChapterReadingProgress(String chapterId, {required bool isRead}) async {}

  @override
  Future<String> downloadChapterPdf(String chapterId) async {
    return 'https://kuta.com/download/pdf';
  }
}

void main() {
  group('Grade 6 & Grade 8 Notes Isolation Tests', () {
    test('NoteSubjectItem correctly parses Grade 6 backend payload without Grade 9-12', () {
      final subject = NoteSubjectItem.fromJson(
        {
          'id': 'bced8e75-88a4-4738-b490-f3d4378e5b3a',
          'name': 'ሒሳብ (Mathematics)',
          'code': 'MATH-06',
          'gradeBadge': 'Grade 6',
          'curriculumType': 'Primary School Curriculum',
          'totalChapters': 6,
          'availableGrades': [6],
        },
        parentStudentGrade: 6,
        parentCurriculumType: 'Primary School Curriculum',
      );

      expect(subject.id, 'bced8e75-88a4-4738-b490-f3d4378e5b3a');
      expect(subject.name, 'ሒሳብ (Mathematics)');
      expect(subject.gradeBadge, 'Grade 6');
      expect(subject.curriculumType, 'Primary School Curriculum');
      expect(subject.studentGrade, 6);
      expect(subject.totalChapters, 6);
      expect(subject.availableGrades, [6]);

      // Ensure NO Grade 9, 10, 11, 12 options exist
      expect(subject.grades.length, 1);
      expect(subject.grades.first.name, 'Grade 6');
      expect(subject.grades.any((g) => g.gradeLevel >= 9), isFalse);
    });

    test('NoteSubjectItem correctly parses Grade 8 backend payload without Grade 9-12', () {
      final subject = NoteSubjectItem.fromJson(
        {
          'id': 'eng-08-id',
          'name': 'English',
          'code': 'ENG-08',
          'gradeBadge': 'Grade 8',
          'curriculumType': 'Primary School Curriculum',
          'totalChapters': 8,
          'availableGrades': [8],
        },
        parentStudentGrade: 8,
        parentCurriculumType: 'Primary School Curriculum',
      );

      expect(subject.gradeBadge, 'Grade 8');
      expect(subject.studentGrade, 8);
      expect(subject.grades.length, 1);
      expect(subject.grades.first.name, 'Grade 8');
      expect(subject.grades.any((g) => g.gradeLevel >= 9), isFalse);
    });

    test('NoteSubjectItem retains Grade 9-12 options for Grade 12 high school students', () {
      final subject = NoteSubjectItem.fromJson(
        {
          'id': 'math-12-id',
          'name': 'Mathematics',
          'code': 'MATH-12',
          'gradeBadge': 'Grades 9-12',
          'curriculumType': 'High School Curriculum',
          'totalChapters': 44,
          'availableGrades': [9, 10, 11, 12],
        },
        parentStudentGrade: 12,
        parentCurriculumType: 'High School Curriculum',
      );

      expect(subject.curriculumType, 'High School Curriculum');
      expect(subject.studentGrade, 12);
      expect(subject.grades.length, 4);
      expect(subject.grades.map((g) => g.gradeLevel).toList(), [9, 10, 11, 12]);
    });

    test('SubjectNotesDetail parses requiresGradeSelection: false for primary grades', () {
      final detail = SubjectNotesDetail.fromJson({
        'subjectId': 'math-06-id',
        'subjectTitle': 'ሒሳብ (Mathematics)',
        'studentGrade': 6,
        'requiresGradeSelection': false,
        'chapters': [],
      });

      expect(detail.requiresGradeSelection, isFalse);
      expect(detail.gradeLevel, 'Grade 6');
    });

    testWidgets('Grade 6 Notes screen: displays Primary School Curriculum and navigates directly',
        (WidgetTester tester) async {
      final fakeService = FakeGrade6NotesService();
      final notesBloc = NotesBloc(fakeService);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<NotesBloc>.value(value: notesBloc),
          ],
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
          ),
        ),
      );

      AppRouter.router.go(RouteNames.highSchoolNotes);
      await tester.pumpAndSettle();

      // 1. Verify Header shows Primary School Curriculum and 2 Subjects
      expect(find.text('Primary School Curriculum'), findsOneWidget);
      expect(find.text('2 Subjects'), findsOneWidget);
      expect(find.text('Select a subject to access\nsummarized study guides & cheat sheets.'), findsOneWidget);

      // 2. Verify subjects list
      expect(find.text('ሒሳብ (Mathematics)'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Grade 6'), findsWidgets);

      // 3. Verify that Grade 9-12 options and "Select grade level:" DO NOT appear
      expect(find.text('Grade 9'), findsNothing);
      expect(find.text('Grade 10'), findsNothing);
      expect(find.text('Grade 11'), findsNothing);
      expect(find.text('Grade 12'), findsNothing);
      expect(find.text('Select  grade level:'), findsNothing);
      expect(find.text('Tap to choose Grade 9–12'), findsNothing);

      // 4. Tap the Grade 6 Mathematics subject card directly
      await tester.tap(find.text('ሒሳብ (Mathematics)'));
      await tester.pumpAndSettle();

      // 5. Verify direct navigation to Note Detail screen for Grade 6
      expect(find.text('Note Detail'), findsOneWidget);
      expect(find.textContaining('ሒሳብ (Mathematics) - Grade 6'), findsOneWidget);
      expect(find.text('Whole Numbers & Decimals'), findsOneWidget);
      expect(find.text('Fractions & Ratios'), findsOneWidget);

      // 6. Verify back navigation returns to Notes screen
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Primary School Curriculum'), findsOneWidget);
    });
  });
}

