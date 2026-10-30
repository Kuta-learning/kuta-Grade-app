import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/note_models.dart';
import '../../services/notes_service.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// Manages Short Notes, Chapters, Lessons, and PDF interactions.
/// Caches loaded data across navigation transitions between Notes,
/// Note Detail, and Lesson Detail screens.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesService _notesService;

  List<NoteSubjectItem>? _cachedSubjects;
  Set<int> _cachedExpanded = {0};
  Map<int, String> _cachedSelectedGrades = {0: 'Grade 12'};
  final Map<String, SubjectNotesDetail> _cachedDetails = {};
  final Map<String, LessonDetail> _cachedLessons = {};

  NotesBloc(this._notesService) : super(const NotesInitial()) {
    on<LoadNotesSubjects>(_onLoadNotesSubjects);
    on<ToggleSubjectExpand>(_onToggleSubjectExpand);
    on<SelectGradeLevel>(_onSelectGradeLevel);
    on<LoadSubjectNotesDetail>(_onLoadSubjectNotesDetail);
    on<LoadChapterLessonDetail>(_onLoadChapterLessonDetail);
    on<UpdateChapterProgressEvent>(_onUpdateChapterProgress);
    on<DownloadChapterPdfEvent>(_onDownloadChapterPdf);
  }

  NotesService get notesService => _notesService;
  List<NoteSubjectItem>? get cachedSubjects => _cachedSubjects;
  Set<int> get cachedExpanded => _cachedExpanded;
  Map<int, String> get cachedSelectedGrades => _cachedSelectedGrades;
  SubjectNotesDetail? getCachedDetail(String id) => _cachedDetails[id];
  LessonDetail? getCachedLesson(String id) => _cachedLessons[id];

  Future<void> _onLoadNotesSubjects(
    LoadNotesSubjects event,
    Emitter<NotesState> emit,
  ) async {
    if (_cachedSubjects != null && _cachedSubjects!.isNotEmpty) {
      emit(NotesSubjectsLoaded(
        subjects: _cachedSubjects!,
        expandedIndices: _cachedExpanded,
        selectedGrades: _cachedSelectedGrades,
      ));
      return;
    }

    emit(const NotesLoading());
    try {
      final subjects = await _notesService.getShortNotesSubjects();
      _cachedSubjects = subjects;
      emit(NotesSubjectsLoaded(
        subjects: subjects,
        expandedIndices: _cachedExpanded,
        selectedGrades: _cachedSelectedGrades,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  void _onToggleSubjectExpand(
    ToggleSubjectExpand event,
    Emitter<NotesState> emit,
  ) {
    final newIndices = Set<int>.from(_cachedExpanded);
    if (newIndices.contains(event.index)) {
      newIndices.remove(event.index);
    } else {
      newIndices.add(event.index);
    }
    _cachedExpanded = newIndices;

    if (_cachedSubjects != null) {
      emit(NotesSubjectsLoaded(
        subjects: _cachedSubjects!,
        expandedIndices: _cachedExpanded,
        selectedGrades: _cachedSelectedGrades,
      ));
    }
  }

  void _onSelectGradeLevel(
    SelectGradeLevel event,
    Emitter<NotesState> emit,
  ) {
    final newMap = Map<int, String>.from(_cachedSelectedGrades);
    newMap[event.subjectIndex] = event.gradeName;
    _cachedSelectedGrades = newMap;

    if (_cachedSubjects != null) {
      emit(NotesSubjectsLoaded(
        subjects: _cachedSubjects!,
        expandedIndices: _cachedExpanded,
        selectedGrades: _cachedSelectedGrades,
      ));
    }
  }

  Future<void> _onLoadSubjectNotesDetail(
    LoadSubjectNotesDetail event,
    Emitter<NotesState> emit,
  ) async {
    final cached = _cachedDetails[event.subjectId];
    if (cached != null) {
      emit(SubjectNotesDetailLoaded(detail: cached));
      return;
    }

    emit(const NotesLoading());
    try {
      final detail = await _notesService.getSubjectNotesDetails(event.subjectId);
      _cachedDetails[event.subjectId] = detail;
      emit(SubjectNotesDetailLoaded(detail: detail));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onLoadChapterLessonDetail(
    LoadChapterLessonDetail event,
    Emitter<NotesState> emit,
  ) async {
    final cached = _cachedLessons[event.chapterId];
    if (cached != null) {
      emit(LessonDetailLoaded(lesson: cached));
      return;
    }

    emit(const NotesLoading());
    try {
      final lesson = await _notesService.getChapterNoteDetail(event.chapterId);
      _cachedLessons[event.chapterId] = lesson;
      emit(LessonDetailLoaded(lesson: lesson));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onUpdateChapterProgress(
    UpdateChapterProgressEvent event,
    Emitter<NotesState> emit,
  ) async {
    if (state is LessonDetailLoaded) {
      final current = state as LessonDetailLoaded;
      emit(current.copyWith(isProgressSaving: true));
      try {
        await _notesService.updateChapterReadingProgress(
          event.chapterId,
          isRead: event.isRead,
        );
        emit(current.copyWith(isProgressSaving: false));
      } catch (_) {
        emit(current.copyWith(isProgressSaving: false));
      }
    }
  }

  Future<void> _onDownloadChapterPdf(
    DownloadChapterPdfEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final url = await _notesService.downloadChapterPdf(event.chapterId);
      if (state is SubjectNotesDetailLoaded) {
        final current = state as SubjectNotesDetailLoaded;
        emit(current.copyWith(
          activeDownloadMessage: 'Downloading: $url',
        ));
      }
    } catch (_) {}
  }
}

