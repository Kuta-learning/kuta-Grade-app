import '../../../core/constants/grade_level.dart';

/// Detailed student profile data model.
class ProfileModel {
  final String userId;
  final String fullName;
  final String email;
  final GradeLevel gradeLevel;
  final String? schoolName;
  final String? avatarUrl;

  const ProfileModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.gradeLevel,
    this.schoolName,
    this.avatarUrl,
  });
}
