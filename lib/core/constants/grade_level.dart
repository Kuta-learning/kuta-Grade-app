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

  int get numericValue {
    switch (this) {
      case GradeLevel.grade12:
        return 12;
      case GradeLevel.grade8:
        return 8;
      case GradeLevel.grade6:
        return 6;
      case GradeLevel.kg:
        return 0;
    }
  }

  static GradeLevel? fromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      if (value == 12) return GradeLevel.grade12;
      if (value == 8) return GradeLevel.grade8;
      if (value == 6) return GradeLevel.grade6;
      if (value <= 0) return GradeLevel.kg;
    }
    final str = value.toString().toLowerCase().trim();
    if (str == '12' || str == 'grade12' || str == 'grade_12') {
      return GradeLevel.grade12;
    }
    if (str == '8' || str == 'grade8' || str == 'grade_8') {
      return GradeLevel.grade8;
    }
    if (str == '6' || str == 'grade6' || str == 'grade_6') {
      return GradeLevel.grade6;
    }
    if (str == 'kg') return GradeLevel.kg;
    return null;
  }
}
