import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kuta_learning_app/core/constants/academic_stream.dart';
import 'package:kuta_learning_app/core/constants/grade_level.dart';
import 'package:kuta_learning_app/core/router/app_router.dart';
import 'package:kuta_learning_app/core/router/route_names.dart';
import 'package:kuta_learning_app/core/storage/shared_prefs_storage.dart';
import 'package:kuta_learning_app/core/storage/storage_keys.dart';
import 'package:kuta_learning_app/features/authentication/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Fresh install (no flags) resolves to RouteNames.onboarding', () async {
    final route = await AppRouter.resolveInitialRoute();
    expect(route, RouteNames.onboarding);
  });

  test('Completed onboarding but not registered resolves to RouteNames.register',
      () async {
    final storage = await SharedPrefsStorage.getInstance();
    await storage.setBool(StorageKeys.hasSeenOnboarding, value: true);

    final route = await AppRouter.resolveInitialRoute();
    expect(route, RouteNames.register);
  });

  test(
      'Registered user who has not selected grade resolves to RouteNames.gradeSelection',
      () async {
    final storage = await SharedPrefsStorage.getInstance();
    await storage.setBool(StorageKeys.hasSeenOnboarding, value: true);

    const user = UserModel(
      id: 'student-123',
      email: 'dawit@kuta.com',
      name: 'Dawit Haile',
      gradeLevel: GradeLevel.grade12,
    );
    await storage.setString(StorageKeys.authUser, user.toJsonString());
    await storage.setBool(StorageKeys.hasSelectedGrade, value: false);

    final route = await AppRouter.resolveInitialRoute();
    expect(route, RouteNames.gradeSelection);
  });

  test(
      'Registered user who completed grade selection resolves to RouteNames.gradeDashboard',
      () async {
    final storage = await SharedPrefsStorage.getInstance();
    await storage.setBool(StorageKeys.hasSeenOnboarding, value: true);

    const user = UserModel(
      id: 'student-123',
      email: 'dawit@kuta.com',
      name: 'Dawit Haile',
      gradeLevel: GradeLevel.grade12,
      academicStream: AcademicStream.natural,
    );
    await storage.setString(StorageKeys.authUser, user.toJsonString());
    await storage.setBool(StorageKeys.hasSelectedGrade, value: true);

    final route = await AppRouter.resolveInitialRoute();
    expect(route, RouteNames.gradeDashboard);
  });

  test('KG student who completed grade selection resolves to RouteNames.kgHome',
      () async {
    final storage = await SharedPrefsStorage.getInstance();
    await storage.setBool(StorageKeys.hasSeenOnboarding, value: true);

    const user = UserModel(
      id: 'kid-123',
      email: 'abebe@kuta.com',
      name: 'Abebe Junior',
      gradeLevel: GradeLevel.kg,
    );
    await storage.setString(StorageKeys.authUser, user.toJsonString());
    await storage.setBool(StorageKeys.hasSelectedGrade, value: true);

    final route = await AppRouter.resolveInitialRoute();
    expect(route, RouteNames.kgHome);
  });
}
