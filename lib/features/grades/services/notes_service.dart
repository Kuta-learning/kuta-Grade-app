import '../models/note_models.dart';

/// Abstract contract for Grade Short Notes, Lessons, and PDF resources.
abstract class NotesService {
  /// Fetches subjects with their available grade options.
  Future<List<NoteSubjectItem>> getShortNotesSubjects();

  /// Fetches comprehensive details for a specific subject notes view.
  Future<SubjectNotesDetail> getSubjectNotesDetails(String subjectId);

  /// Fetches reader lesson details for an individual chapter.
  Future<LessonDetail> getChapterNoteDetail(String chapterId);

  /// Updates user reading progress for a chapter.
  Future<void> updateChapterReadingProgress(
    String chapterId, {
    required bool isRead,
  });

  /// Requests download link for chapter notes PDF.
  Future<String> downloadChapterPdf(String chapterId);
}

