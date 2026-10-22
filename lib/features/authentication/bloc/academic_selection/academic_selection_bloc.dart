import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/academic_stream.dart';
import '../../../../core/constants/grade_level.dart';
import '../../services/auth_service.dart';
import '../auth_bloc.dart';
import 'academic_selection_event.dart';
import 'academic_selection_state.dart';

export 'academic_selection_event.dart';
export 'academic_selection_state.dart';

/// Manages student academic level (Grade 6, 8, 12) and specialization stream (Natural / Social)
/// selection with dynamic progression and integration with [AuthService] & [AuthBloc].
class AcademicSelectionBloc
    extends Bloc<AcademicSelectionEvent, AcademicSelectionState> {
  final AuthService _authService;
  final AuthBloc? _authBloc;

  AcademicSelectionBloc({
    required AuthService authService,
    AuthBloc? authBloc,
    GradeLevel initialGrade = GradeLevel.grade12,
    AcademicStream? initialStream = AcademicStream.natural,
    int initialStep = 1,
  })  : _authService = authService,
        _authBloc = authBloc,
        super(AcademicSelectionState(
          selectedGrade: initialGrade,
          selectedStream: initialStream,
          currentStep: initialStep,
        )) {
    on<SelectGrade>(_onSelectGrade);
    on<SelectStream>(_onSelectStream);
    on<ChangeStep>(_onChangeStep);
    on<SubmitAcademicSelection>(_onSubmitAcademicSelection);
  }

  void _onSelectGrade(
    SelectGrade event,
    Emitter<AcademicSelectionState> emit,
  ) {
    emit(state.copyWith(
      selectedGrade: event.grade,
      // If student is switching away from Grade 12, reset stream and step to 1
      selectedStream: event.grade == GradeLevel.grade12
          ? (state.selectedStream ?? AcademicStream.natural)
          : null,
      currentStep: 1,
    ));
  }

  void _onSelectStream(
    SelectStream event,
    Emitter<AcademicSelectionState> emit,
  ) {
    emit(state.copyWith(selectedStream: event.stream));
  }

  void _onChangeStep(
    ChangeStep event,
    Emitter<AcademicSelectionState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  Future<void> _onSubmitAcademicSelection(
    SubmitAcademicSelection event,
    Emitter<AcademicSelectionState> emit,
  ) async {
    final grade = state.selectedGrade;
    if (grade == null) return;

    emit(state.copyWith(status: AcademicSelectionStatus.submitting));

    try {
      await _authService.updateAcademicProfile(
        gradeLevel: grade,
        stream: state.isGrade12 ? state.selectedStream : null,
      );

      // Notify parent AuthBloc if available so global session stays updated
      _authBloc?.add(AcademicProfileUpdated(
        gradeLevel: grade,
        stream: state.isGrade12 ? state.selectedStream : null,
      ));

      emit(state.copyWith(status: AcademicSelectionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AcademicSelectionStatus.failure,
        errorMessage: 'Failed to save academic profile. Please try again.',
      ));
    }
  }
}
