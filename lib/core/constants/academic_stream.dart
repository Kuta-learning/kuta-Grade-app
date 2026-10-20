/// Academic stream specialization for Grade 12 students.
enum AcademicStream {
  natural,
  social;

  String get displayName {
    switch (this) {
      case AcademicStream.natural:
        return 'Natural Science';
      case AcademicStream.social:
        return 'Social Science';
    }
  }

  String get description {
    switch (this) {
      case AcademicStream.natural:
        return 'Engineering, Medicine, Computing, Pure Science';
      case AcademicStream.social:
        return 'Business, Economics, Law, Humanities';
    }
  }

  List<String> get subjects {
    switch (this) {
      case AcademicStream.natural:
        return const [
          'Mathematics (Natural)',
          'Physics',
          'Chemistry',
          'Biology',
          'English',
          'SAT',
        ];
      case AcademicStream.social:
        return const [
          'Mathematics (Social)',
          'Economics',
          'Geography',
          'History',
          'English',
          'SAT',
        ];
    }
  }

  static AcademicStream? fromString(String? value) {
    if (value == null) return null;
    return AcademicStream.values.cast<AcademicStream?>().firstWhere(
          (s) => s?.name == value || s?.displayName.toLowerCase() == value.toLowerCase(),
          orElse: () => null,
        );
  }
}
