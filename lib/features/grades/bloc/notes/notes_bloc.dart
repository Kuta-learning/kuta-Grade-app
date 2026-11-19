import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/cache/cache_response.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../models/note_models.dart';
import '../../services/notes_service.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// Manages Short Notes, Chapters, Lessons, and PDF interactions.
/// Backed exclusively by [CacheManager] with persistent multi-tier caching (L1 memory + L2 disk),
/// Stale-While-Revalidate (SWR) streaming, and grade-isolated storage keys.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesService _notesService;
  final CacheManager _cacheManager;

  Set<int> _cachedExpanded = {0};
  Map<int, String> _cachedSelectedGrades = {0: 'Grade 12'};
  String? _cachedCurriculumType;
  int? _cachedStudentGrade;
  final Set<String> _inProgressDownloads = {};

  NotesBloc(this._notesService, {CacheManager? cacheManager})
      : _cacheManager = cacheManager ?? CacheManager.instance,
        super(const NotesInitial()) {
    on<LoadNotesSubjects>(_onLoadNotesSubjects);
    on<ToggleSubjectExpand>(_onToggleSubjectExpand);
    on<SelectGradeLevel>(_onSelectGradeLevel);
    on<LoadSubjectNotesDetail>(_onLoadSubjectNotesDetail);
    on<LoadChapterLessonDetail>(_onLoadChapterLessonDetail);
    on<UpdateChapterProgressEvent>(_onUpdateChapterProgress);
    on<DownloadChapterPdfEvent>(_onDownloadChapterPdf);
  }

  NotesService get notesService => _notesService;
  CacheManager get cacheManager => _cacheManager;

  List<NoteSubjectItem>? get cachedSubjects {
    if (state is NotesSubjectsLoaded) {
      return (state as NotesSubjectsLoaded).subjects;
    }
    final grade = _cachedStudentGrade ?? 12;
    return _cacheManager.getMemoryCached<List<NoteSubjectItem>>(
      '${StorageKeys.notesSubjectsCache}_grade_$grade',
    );
  }

  Set<int> get cachedExpanded => _cachedExpanded;
  Map<int, String> get cachedSelectedGrades => _cachedSelectedGrades;
  String? get cachedCurriculumType => _cachedCurriculumType;
  int? get cachedStudentGrade => _cachedStudentGrade;

  /// Retrieves cached SubjectNotesDetail directly from [CacheManager]'s L1 memory.
  SubjectNotesDetail? getCachedDetail(String id) =>
      _cacheManager.getMemoryCached<SubjectNotesDetail>(
        StorageKeys.notesSubjectDetailCache(id),
      );

  /// Retrieves cached LessonDetail directly from [CacheManager]'s L1 memory.
  LessonDetail? getCachedLesson(String id) =>
      _cacheManager.getMemoryCached<LessonDetail>(
        StorageKeys.notesChapterLessonCache(id),
      );

  Future<void> _onLoadNotesSubjects(
    LoadNotesSubjects event,
    Emitter<NotesState> emit,
  ) async {
    if (event.studentGrade != null) {
      _cachedStudentGrade = event.studentGrade;
    }
    final grade = _cachedStudentGrade ?? 12;
    final key = '${StorageKeys.notesSubjectsCache}_grade_$grade';

    final hasMemory =
        _cacheManager.getMemoryCached<List<NoteSubjectItem>>(key) != null;
    if (!hasMemory && !event.forceRefresh) {
      emit(const NotesLoading());
    }

    try {
      await emit.forEach<CacheResponse<List<NoteSubjectItem>>>(
        _cacheManager.watch<List<NoteSubjectItem>>(
          key: key,
          ttl: const Duration(minutes: 5),
          networkFetch: () => _notesService.getShortNotesSubjects(),
          fromJson: NoteSubjectItem.listFromJsonString,
          toJson: NoteSubjectItem.listToJsonString,
          guard: (subjects) {
            if (_cachedStudentGrade == null) return true;
            final firstGrade = subjects.firstOrNull?.studentGrade;
            return firstGrade == null || firstGrade == _cachedStudentGrade;
          },
          forceRefresh: event.forceRefresh,
        ),
        onData: (response) {
          final subjects = response.data;
          _cachedCurriculumType = subjects.firstOrNull?.curriculumType;
          _cachedStudentGrade =
              subjects.firstOrNull?.studentGrade ?? _cachedStudentGrade;
          if (event.forceRefresh) {
            _cachedExpanded = {0};
            _cachedSelectedGrades = {};
          }
          return NotesSubjectsLoaded(
            subjects: subjects,
            expandedIndices: _cachedExpanded,
            selectedGrades: _cachedSelectedGrades,
            curriculumType: _cachedCurriculumType,
            studentGrade: _cachedStudentGrade,
          );
        },
        onError: (e, _) => NotesError(e.toString()),
      );
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

    if (state is NotesSubjectsLoaded) {
      final current = state as NotesSubjectsLoaded;
      emit(current.copyWith(expandedIndices: _cachedExpanded));
    }
  }

  void _onSelectGradeLevel(
    SelectGradeLevel event,
    Emitter<NotesState> emit,
  ) {
    final newMap = Map<int, String>.from(_cachedSelectedGrades);
    newMap[event.subjectIndex] = event.gradeName;
    _cachedSelectedGrades = newMap;

    if (state is NotesSubjectsLoaded) {
      final current = state as NotesSubjectsLoaded;
      emit(current.copyWith(selectedGrades: _cachedSelectedGrades));
    }
  }

  Future<void> _onLoadSubjectNotesDetail(
    LoadSubjectNotesDetail event,
    Emitter<NotesState> emit,
  ) async {
    final key = StorageKeys.notesSubjectDetailCache(event.subjectId);
    final hasMemory =
        _cacheManager.getMemoryCached<SubjectNotesDetail>(key) != null;
    if (!hasMemory) {
      emit(const NotesLoading());
    }

    try {
      await emit.forEach<CacheResponse<SubjectNotesDetail>>(
        _cacheManager.watch<SubjectNotesDetail>(
          key: key,
          ttl: const Duration(minutes: 10),
          networkFetch: () =>
              _notesService.getSubjectNotesDetails(event.subjectId),
          fromJson: SubjectNotesDetail.fromJsonString,
          toJson: (d) => d.toJsonString(),
        ),
        onData: (response) => SubjectNotesDetailLoaded(detail: response.data),
        onError: (e, _) => NotesError(e.toString()),
      );
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onLoadChapterLessonDetail(
    LoadChapterLessonDetail event,
    Emitter<NotesState> emit,
  ) async {
    final key = StorageKeys.notesChapterLessonCache(event.chapterId);
    final hasMemory =
        _cacheManager.getMemoryCached<LessonDetail>(key) != null;
    if (!hasMemory) {
      emit(const NotesLoading());
    }

    try {
      await emit.forEach<CacheResponse<LessonDetail>>(
        _cacheManager.watch<LessonDetail>(
          key: key,
          ttl: const Duration(minutes: 10),
          networkFetch: () =>
              _notesService.getChapterNoteDetail(event.chapterId),
          fromJson: LessonDetail.fromJsonString,
          toJson: (l) => l.toJsonString(),
        ),
        onData: (response) => LessonDetailLoaded(lesson: response.data),
        onError: (e, _) => NotesError(e.toString()),
      );
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
    }
    try {
      await _notesService.updateChapterReadingProgress(
        event.chapterId,
        isRead: event.isRead,
      );
      if (state is LessonDetailLoaded) {
        emit((state as LessonDetailLoaded).copyWith(isProgressSaving: false));
      }
    } catch (_) {
      if (state is LessonDetailLoaded) {
        emit((state as LessonDetailLoaded).copyWith(isProgressSaving: false));
      }
    }
  }

  Future<void> _onDownloadChapterPdf(
    DownloadChapterPdfEvent event,
    Emitter<NotesState> emit,
  ) async {
    if (_inProgressDownloads.contains(event.chapterId)) return;
    _inProgressDownloads.add(event.chapterId);

    try {
      final url = await _notesService.downloadChapterPdf(event.chapterId);
      if (state is SubjectNotesDetailLoaded) {
        final current = state as SubjectNotesDetailLoaded;
        emit(current.copyWith(
          activeDownloadMessage: 'Opening download: $url',
        ));
      }
      if (url.isNotEmpty) {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
    } finally {
      _inProgressDownloads.remove(event.chapterId);
    }
  }
}
