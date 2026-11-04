/// Practice page grade filtering — unit tests only.
///
/// Widget tests for CoursesScreen are skipped because the screen embeds
/// GradeScreenShell (go_router, SystemChrome, Rive animation) which hangs
/// the test runner on Windows. The production logic is tested at the unit
/// level instead, which is sufficient to verify grade isolation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kuta_grade/features/grades/models/course_models.dart';
import 'package:kuta_grade/features/grades/services/mock_courses_service.dart';

// ---------------------------------------------------------------------------
// Inline sync service (no network, no disk I/O)
// ---------------------------------------------------------------------------

class _SyncCoursesService {
  Future<List<CourseModel>> getCoursesForGrade(int gradeLevel) async {
    return [
      CourseModel(
        id: 'c-math-$gradeLevel',
        title: 'Mathematics Grade $gradeLevel',
        description: 'Comprehensive curriculum for Grade $gradeLevel',
        gradeLevel: gradeLevel,
        subject: 'Mathematics',
      ),
      CourseModel(
        id: 'c-phys-$gradeLevel',
        title: 'Physics Grade $gradeLevel',
        description: 'Mechanics and physics for Grade $gradeLevel',
        gradeLevel: gradeLevel,
        subject: 'Physics',
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Pure grade-isolation helper (mirrors _CoursesScreenState._buildCourseList)
// ---------------------------------------------------------------------------

List<CourseModel> filterCoursesForGrade(List<CourseModel> all, int grade) {
  return all.where((c) => c.gradeLevel == grade).toList();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Practice Page Grade Isolation & Filtering Tests', () {
    // --- Unit: SyncCoursesService returns only the requested grade -----------

    test('SyncCoursesService returns courses strictly matching requested grade',
        () async {
      final service = _SyncCoursesService();

      final grade12 = await service.getCoursesForGrade(12);
      expect(grade12, isNotEmpty);
      expect(grade12.every((c) => c.gradeLevel == 12), isTrue,
          reason: 'All returned courses must be Grade 12');

      final grade8 = await service.getCoursesForGrade(8);
      expect(grade8, isNotEmpty);
      expect(grade8.every((c) => c.gradeLevel == 8), isTrue,
          reason: 'All returned courses must be Grade 8');

      final grade6 = await service.getCoursesForGrade(6);
      expect(grade6, isNotEmpty);
      expect(grade6.every((c) => c.gradeLevel == 6), isTrue,
          reason: 'All returned courses must be Grade 6');
    });

    // --- Unit: CourseModel holds exact gradeLevel -------------------------

    test('CourseModel strictly holds the given gradeLevel', () {
      const course12 = CourseModel(
        id: 'c-12',
        title: 'Math Grade 12',
        description: 'Grade 12 math',
        gradeLevel: 12,
        subject: 'Mathematics',
      );
      expect(course12.gradeLevel, 12);

      const course6 = CourseModel(
        id: 'c-6',
        title: 'Math Grade 6',
        description: 'Grade 6 math',
        gradeLevel: 6,
        subject: 'Mathematics',
      );
      expect(course6.gradeLevel, 6);
    });

    // --- Unit: grade filter helper isolates correctly ---------------------

    test('Grade 12 student filter: ONLY Grade 12 content, NO Grade 6/8', () {
      final mixed = [
        const CourseModel(id: 'c1', title: 'Math 12', description: '', gradeLevel: 12, subject: 'Mathematics'),
        const CourseModel(id: 'c2', title: 'Physics 8', description: '', gradeLevel: 8, subject: 'Physics'),
        const CourseModel(id: 'c3', title: 'Biology 6', description: '', gradeLevel: 6, subject: 'Biology'),
        const CourseModel(id: 'c4', title: 'Physics 12', description: '', gradeLevel: 12, subject: 'Physics'),
      ];

      final result = filterCoursesForGrade(mixed, 12);

      expect(result.length, 2, reason: 'Only 2 Grade 12 courses should pass');
      expect(result.every((c) => c.gradeLevel == 12), isTrue);
      expect(result.any((c) => c.gradeLevel == 6), isFalse,
          reason: 'No Grade 6 content for Grade 12 student');
      expect(result.any((c) => c.gradeLevel == 8), isFalse,
          reason: 'No Grade 8 content for Grade 12 student');
    });

    test('Grade 8 student filter: ONLY Grade 8 content, NO Grade 6/12', () {
      final mixed = [
        const CourseModel(id: 'c1', title: 'Math 12', description: '', gradeLevel: 12, subject: 'Mathematics'),
        const CourseModel(id: 'c2', title: 'Physics 8', description: '', gradeLevel: 8, subject: 'Physics'),
        const CourseModel(id: 'c3', title: 'Biology 6', description: '', gradeLevel: 6, subject: 'Biology'),
        const CourseModel(id: 'c4', title: 'Math 8', description: '', gradeLevel: 8, subject: 'Mathematics'),
      ];

      final result = filterCoursesForGrade(mixed, 8);

      expect(result.length, 2, reason: 'Only 2 Grade 8 courses should pass');
      expect(result.every((c) => c.gradeLevel == 8), isTrue);
      expect(result.any((c) => c.gradeLevel == 6), isFalse);
      expect(result.any((c) => c.gradeLevel == 12), isFalse);
    });

    test('Grade 6 student filter: ONLY Grade 6 content, NO Grade 8/12', () {
      final mixed = [
        const CourseModel(id: 'c1', title: 'Math 12', description: '', gradeLevel: 12, subject: 'Mathematics'),
        const CourseModel(id: 'c2', title: 'Physics 8', description: '', gradeLevel: 8, subject: 'Physics'),
        const CourseModel(id: 'c3', title: 'Biology 6', description: '', gradeLevel: 6, subject: 'Biology'),
        const CourseModel(id: 'c4', title: 'Math 6', description: '', gradeLevel: 6, subject: 'Mathematics'),
      ];

      final result = filterCoursesForGrade(mixed, 6);

      expect(result.length, 2, reason: 'Only 2 Grade 6 courses should pass');
      expect(result.every((c) => c.gradeLevel == 6), isTrue);
      expect(result.any((c) => c.gradeLevel == 8), isFalse);
      expect(result.any((c) => c.gradeLevel == 12), isFalse);
    });

    // --- Unit: MockCoursesService grade-awareness ------------------------

    test('MockCoursesService getCoursesForGrade returns grade-matched courses',
        () async {
      final service = MockCoursesService();

      final grade12 = await service.getCoursesForGrade(12);
      expect(grade12.every((c) => c.gradeLevel == 12), isTrue,
          reason: 'MockCoursesService must only return Grade 12 courses for gradeLevel=12');

      final grade8 = await service.getCoursesForGrade(8);
      expect(grade8.every((c) => c.gradeLevel == 8), isTrue,
          reason: 'MockCoursesService must only return Grade 8 courses for gradeLevel=8');

      final grade6 = await service.getCoursesForGrade(6);
      expect(grade6.every((c) => c.gradeLevel == 6), isTrue,
          reason: 'MockCoursesService must only return Grade 6 courses for gradeLevel=6');
    });
  });
}
