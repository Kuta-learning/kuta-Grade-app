import '../../../../core/constants/academic_stream.dart';
import '../../../../core/constants/grade_level.dart';

abstract class AcademicSelectionEvent {
  const AcademicSelectionEvent();
}

/// Dispatched when the user taps on a grade option (Grade 6, 8, 12).
class SelectGrade extends AcademicSelectionEvent {
  final GradeLevel grade;

  const SelectGrade(this.grade);
}

/// Dispatched when the user taps on a stream option (Natural Science, Social Science).
class SelectStream extends AcademicSelectionEvent {
  final AcademicStream stream;

  const SelectStream(this.stream);
}

/// Dispatched when navigating between Step 1 and Step 2.
class ChangeStep extends AcademicSelectionEvent {
  final int step;

  const ChangeStep(this.step);
}

/// Dispatched when the user taps the primary CTA to complete their selection.
class SubmitAcademicSelection extends AcademicSelectionEvent {
  const SubmitAcademicSelection();
}
