part of 'notes_bloc.dart';

/// Base state for Short Notes flow.
sealed class NotesState {
  const NotesState();
}

/// Initial state before any notes data is requested.
final class NotesInitial extends NotesState {
  const NotesInitial();
}

/// Asynchronous loading state.
final class NotesLoading extends NotesState {
  const NotesLoading();
}

/// Loaded state for HighSchoolNotesScreen containing subjects, active grades, and expansions.
final class NotesSubjectsLoaded extends NotesState {
  final List<NoteSubjectItem> subjects;
  final Set<int> expandedIndices;
  final Map<int, String> selectedGrades;

  const NotesSubjectsLoaded({
    required this.subjects,
    this.expandedIndices = const {0},
    this.selectedGrades = const {0: 'Grade 12'},
  });

  NotesSubjectsLoaded copyWith({
    List<NoteSubjectItem>? subjects,
    Set<int>? expandedIndices,
    Map<int, String>? selectedGrades,
  }) {
    return NotesSubjectsLoaded(
      subjects: subjects ?? this.subjects,
      expandedIndices: expandedIndices ?? this.expandedIndices,
      selectedGrades: selectedGrades ?? this.selectedGrades,
    );
  }
}

/// Loaded state for NoteDetailScreen containing chapters, pages, and download URL.
final class SubjectNotesDetailLoaded extends NotesState {
  final SubjectNotesDetail detail;
  final String? activeDownloadMessage;

  const SubjectNotesDetailLoaded({
    required this.detail,
    this.activeDownloadMessage,
  });

  SubjectNotesDetailLoaded copyWith({
    SubjectNotesDetail? detail,
    String? activeDownloadMessage,
  }) {
    return SubjectNotesDetailLoaded(
      detail: detail ?? this.detail,
      activeDownloadMessage: activeDownloadMessage ?? this.activeDownloadMessage,
    );
  }
}

/// Loaded state for LessonDetailScreen containing interactive lesson objectives, diagrams, and steps.
final class LessonDetailLoaded extends NotesState {
  final LessonDetail lesson;
  final bool isProgressSaving;

  const LessonDetailLoaded({
    required this.lesson,
    this.isProgressSaving = false,
  });

  LessonDetailLoaded copyWith({
    LessonDetail? lesson,
    bool? isProgressSaving,
  }) {
    return LessonDetailLoaded(
      lesson: lesson ?? this.lesson,
      isProgressSaving: isProgressSaving ?? this.isProgressSaving,
    );
  }
}

/// Failure state carrying user-facing error message.
final class NotesError extends NotesState {
  final String message;
  const NotesError(this.message);
}

