import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/features/grades/bloc/grades_bloc.dart';
import 'package:kuta_grade/features/grades/services/mock_notes_service.dart';

void main() {
  group('Civic and Ethical Education Notes & Exam Navigation Verification', () {
    late MockNotesService mockNotesService;
    late NotesBloc notesBloc;

    setUp(() {
      mockNotesService = MockNotesService();
      notesBloc = NotesBloc(mockNotesService);
    });

    tearDown(() {
      notesBloc.close();
    });

    test('Civics & Ethical Education chapters load successfully with non-empty list', () async {
      final detail = await mockNotesService.getSubjectNotesDetails('civics');
      expect(detail.subjectTitle, 'Civics & Ethical Education');
      expect(detail.chapters, isNotEmpty);
      expect(detail.chapters.length, 6);
      expect(detail.chapters.first.title, contains('Building a Democratic System'));
    });

    test('Civics & Ethical Education by backend UUID loads chapters', () async {
      final detail = await mockNotesService
          .getSubjectNotesDetails('d389bc5e-8f77-45c4-8a3b-36b22a817cf8');
      expect(detail.subjectTitle, 'Civics & Ethical Education');
      expect(detail.chapters, isNotEmpty);
    });

    test('NotesBloc emits SubjectNotesDetailLoaded for civics', () async {
      notesBloc.add(const LoadSubjectNotesDetail('civics'));

      await expectLater(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<SubjectNotesDetailLoaded>(),
        ]),
      );

      final state = notesBloc.state as SubjectNotesDetailLoaded;
      expect(state.detail.subjectTitle, 'Civics & Ethical Education');
      expect(state.detail.chapters, isNotEmpty);
    });
  });
}

