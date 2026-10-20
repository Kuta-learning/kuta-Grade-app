import 'dart:convert';
import '../../../core/constants/academic_stream.dart';
import '../../../core/constants/grade_level.dart';

/// User model containing authentication and grade identity.
/// Supports JSON serialization for local storage caching.
class UserModel {
  final String id;
  final String email;
  final String name;
  final GradeLevel gradeLevel;
  final AcademicStream? academicStream;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.gradeLevel,
    this.academicStream,
  });

  bool get isKgStudent => gradeLevel.isKg;
  bool get isGradeStudent => gradeLevel.isGrade;

  // ── Serialization ──────────────────────────────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      gradeLevel: GradeLevel.values.firstWhere(
        (g) => g.name == (json['gradeLevel'] as String),
        orElse: () => GradeLevel.values.first,
      ),
      academicStream: AcademicStream.fromString(json['academicStream'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'gradeLevel': gradeLevel.name,
        if (academicStream != null) 'academicStream': academicStream!.name,
      };

  /// Encode to JSON string for [SharedPreferences] storage.
  String toJsonString() => jsonEncode(toJson());

  /// Decode from JSON string retrieved from [SharedPreferences].
  static UserModel? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── CopyWith ───────────────────────────────────────────────────────────
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    GradeLevel? gradeLevel,
    AcademicStream? academicStream,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      academicStream: academicStream ?? this.academicStream,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          gradeLevel == other.gradeLevel &&
          academicStream == other.academicStream;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      gradeLevel.hashCode ^
      academicStream.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, name: $name, grade: ${gradeLevel.name}, stream: ${academicStream?.name})';
}
