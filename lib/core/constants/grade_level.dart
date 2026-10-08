/// Defines all supported grade levels and student tracks in the application.
enum GradeLevel {
  kg,
  grade6,
  grade8,
  grade12;

  bool get isKg => this == GradeLevel.kg;
  bool get isGrade => !isKg;

  String get displayName {
    switch (this) {
      case GradeLevel.kg:
        return 'Kindergarten';
      case GradeLevel.grade6:
        return 'Grade 6';
      case GradeLevel.grade8:
        return 'Grade 8';
      case GradeLevel.grade12:
        return 'Grade 12';
    }
  }
}
