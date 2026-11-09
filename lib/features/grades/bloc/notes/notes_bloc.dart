import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../models/note_models.dart';
import '../../services/notes_service.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// Manages Short Notes, Chapters, Lessons, and PDF interactions.
/// Backed by [CacheManager] with persistent multi-tier caching,
/// offline support, and grade-isolated storage keys.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesService _notesService;
  final CacheManager _cacheManager;

  List<NoteSubjectItem>? _cachedSubjects;
  Set<int> _cachedExpanded = {0};
  Map<int, String> _cachedSelectedGrades = {0: 'Grade 12'};
  String? _cachedCurriculumType;
  int? _cachedStudentGrade;
  final Map<String, SubjectNotesDetail> _cachedDetails = {};
  final Map<String, LessonDetail> _cachedLessons = {};
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
  List<NoteSubjectItem>? get cachedSubjects => _cachedSubjects;
  Set<int> get cachedExpanded => _cachedExpanded;
  Map<int, String> get cachedSelectedGrades => _cachedSelectedGrades;
  String? get cachedCurriculumType => _cachedCurriculumType;
  int? get cachedStudentGrade => _cachedStudentGrade;
  SubjectNotesDetail? getCachedDetail(String id) => _cachedDetails[id];
  LessonDetail? getCachedLesson(String id) => _cachedLessons[id];

  Future<void> _onLoadNotesSubjects(
    LoadNotesSubjects event,
    Emitter<NotesState> emit,
  ) async {
    // If not force-refreshing, check in-memory cache
    final hasCachedSubjects =
        _cachedSubjects != null && _cachedSubjects!.isNotEmpty;
    final cacheIsValid = !event.forceRefresh &&
        hasCachedSubjects &&
        _cachedStudentGrade != null;

    if (cacheIsValid) {
      emit(NotesSubjectsLoaded(
        subjects: _cachedSubjects!,
        expandedIndices: _cachedExpanded,
        selectedGrades: _cachedSelectedGrades,
        curriculumType: _cachedCurriculumType,
        studentGrade: _cachedStudentGrade,
      ));
      return;
    }

    emit(const NotesLoading());
    try {
      final subjects = await _notesService.getShortNotesSubjects();
      _cachedSubjects = subjects;
      _cachedCurriculumType = subjects.firstOrNull?.curriculumType;
      _cachedStudentGrade = subjects.firstOrNull?.studentGrade;
      if (event.forceRefresh) {
        _cachedExpanded = {0};
        _cachedSelectedGrades = {};
      }

      // Persist to CacheManager with grade-isolated key for disk persistence & offline support
      final grade = _cachedStudentGrade ?? 12;
      final key = '${StorageKeys.notesSubjectsCache}_grade_$grade';
      await _cacheManager.save<List<NoteSubjectItem>>(
        key: key,
        data: subjects,
        toJson: NoteSubjectItem.listToJsonString,
      );

      emit(NotesSubjectsLoaded(
        subjects: subjects,
        expandedIndices: _cachedExpanded,
        selectedGrades: _cachedSelectedGrades,
        curriculumType: _cachedCurriculumType,
        studentGrade: _cachedStudentGrade,
      ));
    } catch (e) {
      // If network fails, attempt to retrieve grade-isolated data from CacheManager
      final grade = _cachedStudentGrade ?? 12;
      final key = '${StorageKeys.notesSubjectsCache}_grade_$grade';
      final offlineCached = await _cacheManager.getCached<List<NoteSubjectItem>>(
        key: key,
        fromJson: NoteSubjectItem.listFromJsonString,
      );
      if (offlineCached != null && offlineCached.isNotEmpty) {
        _cachedSubjects = offlineCached;
        _cachedCurriculumType = offlineCached.firstOrNull?.curriculumType;
        _cachedStudentGrade = offlineCached.firstOrNull?.studentGrade;
        emit(NotesSubjectsLoaded(
          subjects: offlineCached,
          expandedIndices: _cachedExpanded,
          selectedGrades: _cachedSelectedGrades,
          curriculumType: _cachedCurriculumType,
          studentGrade: _cachedStudentGrade,
        ));
      } else {
        emit(NotesError(e.toString()));
      }
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
        curriculumType: _cachedCurriculumType,
        studentGrade: _cachedStudentGrade,
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
        curriculumType: _cachedCurriculumType,
        studentGrade: _cachedStudentGrade,
      ));
    }
  }

  Future<void> _onLoadSubjectNotesDetail(
    LoadSubjectNotesDetail event,
    Emitter<NotesState> emit,
  ) async {
    final cached = _cachedDetails[event.subjectId] ??
        await _cacheManager.getCached<SubjectNotesDetail>(
          key: StorageKeys.notesSubjectDetailCache(event.subjectId),
          fromJson: SubjectNotesDetail.fromJsonString,
        );

    if (cached != null) {
      _cachedDetails[event.subjectId] = cached;
      emit(SubjectNotesDetailLoaded(detail: cached));
      return;
    }

    emit(const NotesLoading());
    try {
      final detail = await _notesService.getSubjectNotesDetails(event.subjectId);
      _cachedDetails[event.subjectId] = detail;
      await _cacheManager.save<SubjectNotesDetail>(
        key: StorageKeys.notesSubjectDetailCache(event.subjectId),
        data: detail,
        toJson: (d) => d.toJsonString(),
      );
      emit(SubjectNotesDetailLoaded(detail: detail));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onLoadChapterLessonDetail(
    LoadChapterLessonDetail event,
    Emitter<NotesState> emit,
  ) async {
    final cached = _cachedLessons[event.chapterId] ??
        await _cacheManager.getCached<LessonDetail>(
          key: StorageKeys.notesChapterLessonCache(event.chapterId),
          fromJson: LessonDetail.fromJsonString,
        );

    if (cached != null) {
      _cachedLessons[event.chapterId] = cached;
      emit(LessonDetailLoaded(lesson: cached));
      return;
    }

    emit(const NotesLoading());
    try {
      final lesson = await _notesService.getChapterNoteDetail(event.chapterId);
      _cachedLessons[event.chapterId] = lesson;
      await _cacheManager.save<LessonDetail>(
        key: StorageKeys.notesChapterLessonCache(event.chapterId),
        data: lesson,
        toJson: (l) => l.toJsonString(),
      );
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
