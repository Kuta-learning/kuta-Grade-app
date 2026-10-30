import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/core/router/app_router.dart';
import 'package:kuta_grade/core/router/route_names.dart';
import 'package:kuta_grade/features/grades/bloc/grades_bloc.dart';
import 'package:kuta_grade/features/grades/services/mock_notes_service.dart';

void main() {
  testWidgets('Notes flow: Notes -> Note Detail (Grade 12) -> Lesson Detail (Read) -> Back navigation',
      (WidgetTester tester) async {
    // Provide NotesBloc with MockNotesService
    final mockService = MockNotesService();
    final notesBloc = NotesBloc(mockService);

    // Pump app router starting at highSchoolNotes
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

    // 1. Verify Notes screen
    expect(find.text('High School Curriculum'), findsOneWidget);
    expect(find.text('6 Subjects'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Grade 12'), findsOneWidget);

    // 2. Tap Grade 12 tile to navigate to NoteDetailScreen
    await tester.tap(find.text('Grade 12').first);
    await tester.pumpAndSettle();

    // 3. Verify Note Detail screen
    expect(find.text('Note Detail'), findsOneWidget);
    expect(find.textContaining('Mathematics - Grade 12'), findsOneWidget);
    expect(find.text('Read'), findsWidgets);

    // 4. Tap 'Read' on the first chapter to navigate to LessonDetailScreen
    await tester.tap(find.text('Read').first);
    await tester.pumpAndSettle();

    // 5. Verify Lesson Detail screen
    expect(find.text('Learning Objectives'), findsOneWidget);
    expect(find.text('Steps to Simplify'), findsOneWidget);

    // 6. Tap Back button on Lesson Detail screen
    final lessonBackButton = find.byTooltip('Back');
    expect(lessonBackButton, findsOneWidget);
    await tester.tap(lessonBackButton);
    await tester.pumpAndSettle();

    // 7. Verify we are back on Note Detail screen
    expect(find.text('Note Detail'), findsOneWidget);
    expect(find.textContaining('Mathematics - Grade 12'), findsOneWidget);

    // 8. Tap Back button on Note Detail screen
    final noteBackButton = find.byTooltip('Back');
    expect(noteBackButton, findsOneWidget);
    await tester.tap(noteBackButton);
    await tester.pumpAndSettle();

    // 9. Verify we are back on Notes screen
    expect(find.text('High School Curriculum'), findsOneWidget);
  });
}
