import '../../../../core/constants/grade_level.dart';

/// Subject curriculum model (e.g. Mathematics, Physics, Biology, English).
class SubjectModel {
  final String id;
  final String name;
  final String iconAsset;
  final GradeLevel gradeLevel;
  final int totalChapters;
  final int completedChapters;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.gradeLevel,
    required this.totalChapters,
    this.completedChapters = 0,
  });
}
