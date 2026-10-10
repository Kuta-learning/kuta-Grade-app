import '../../../core/constants/grade_level.dart';

/// Data Transfer Object for a new user registration request.
/// Passed from the UI layer to [AuthService.register].
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final GradeLevel gradeLevel;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.gradeLevel,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'gradeLevel': gradeLevel.name,
      };

  @override
  String toString() =>
      'RegisterRequest(name: $name, email: $email, grade: $gradeLevel)';
}
