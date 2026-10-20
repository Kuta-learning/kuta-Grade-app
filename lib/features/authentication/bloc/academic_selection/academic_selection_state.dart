import '../../../../core/constants/academic_stream.dart';
import '../../../../core/constants/grade_level.dart';

enum AcademicSelectionStatus { initial, submitting, success, failure }

class AcademicSelectionState {
  final GradeLevel? selectedGrade;
  final AcademicStream? selectedStream;
  final int currentStep;
  final AcademicSelectionStatus status;
  final String? errorMessage;

  const AcademicSelectionState({
    this.selectedGrade = GradeLevel.grade12, // Default pre-selection as shown in design
    this.selectedStream = AcademicStream.natural,
    this.currentStep = 1,
    this.status = AcademicSelectionStatus.initial,
    this.errorMessage,
  });

  bool get isGrade12 => selectedGrade == GradeLevel.grade12;

  /// Dynamic step count: Grade 12 has 2 steps (Grade + Stream).
  /// Grade 6 & 8 have 1 step (Grade only).
  int get totalSteps => isGrade12 ? 2 : 1;

  /// Progression percentage displayed in the linear progress bar:
  /// - Grade 12 on Step 1: 50%
  /// - Grade 12 on Step 2: 100%
  /// - Grade 6 or 8 on Step 1: 100%
  double get progressPercentage {
    if (currentStep == 2) return 1.0;
    if (isGrade12) return 0.5;
    return 1.0;
  }

  /// Label for the numbered badge header e.g. "STEP 1 OF 2" or "STEP 1 OF 1".
  String get stepLabel => 'STEP $currentStep OF $totalSteps';

  /// Right-aligned progress text e.g. "50% completed" or "100% completed".
  String get progressPercentText =>
      '${(progressPercentage * 100).toInt()}% completed';

  /// Whether the user can advance or submit from the current step.
  bool get canProceed {
    if (currentStep == 1) return selectedGrade != null;
    if (currentStep == 2) return selectedStream != null;
    return false;
  }

  /// Dynamic CTA button label based on current step and selected grade.
  String get ctaLabel {
    if (currentStep == 1 && isGrade12) {
      return 'Continue';
    }
    return 'Enter Dashboard';
  }

  AcademicSelectionState copyWith({
    GradeLevel? selectedGrade,
    AcademicStream? selectedStream,
    int? currentStep,
    AcademicSelectionStatus? status,
    String? errorMessage,
  }) {
    return AcademicSelectionState(
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedStream: selectedStream ?? this.selectedStream,
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
