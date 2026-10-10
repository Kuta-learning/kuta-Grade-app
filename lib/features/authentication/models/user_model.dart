import 'dart:convert';
import '../../../core/constants/grade_level.dart';

/// User model containing authentication and grade identity.
/// Supports JSON serialization for local storage caching.
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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'gradeLevel': gradeLevel.name,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name, grade: $gradeLevel)';
}
