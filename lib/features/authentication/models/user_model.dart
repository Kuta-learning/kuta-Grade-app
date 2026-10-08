import '../../../core/constants/grade_level.dart';

/// User model containing authentication and grade identity.
class UserModel {
  final String id;
  final String email;
  final String name;
  final GradeLevel gradeLevel;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.gradeLevel,
  });

  bool get isKgStudent => gradeLevel.isKg;
  bool get isGradeStudent => gradeLevel.isGrade;
}
