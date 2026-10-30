part of 'notes_bloc.dart';

/// Base event for Short Notes flow.
sealed class NotesEvent {
  const NotesEvent();
}

/// Request to fetch the high school subjects list.
final class LoadNotesSubjects extends NotesEvent {
  const LoadNotesSubjects();
}

/// Toggles accordion expansion for a subject index.
final class ToggleSubjectExpand extends NotesEvent {
  final int index;
  const ToggleSubjectExpand(this.index);
}

/// Selects a grade pill inside an expanded subject card.
final class SelectGradeLevel extends NotesEvent {
  final int subjectIndex;
  final String gradeName;
  const SelectGradeLevel(this.subjectIndex, this.gradeName);
}

/// Requests full notes summary and chapters list for a subject view.
final class LoadSubjectNotesDetail extends NotesEvent {
  final String subjectId;
  const LoadSubjectNotesDetail(this.subjectId);
}

/// Requests reader lesson details for an individual chapter.
final class LoadChapterLessonDetail extends NotesEvent {
  final String chapterId;
  const LoadChapterLessonDetail(this.chapterId);
}

/// Updates progress state when a user finishes reading a chapter.
final class UpdateChapterProgressEvent extends NotesEvent {
  final String chapterId;
  final bool isRead;
  const UpdateChapterProgressEvent(this.chapterId, {this.isRead = true});
}

/// Requests download URL for chapter notes PDF.
final class DownloadChapterPdfEvent extends NotesEvent {
  final String chapterId;
  const DownloadChapterPdfEvent(this.chapterId);
}

