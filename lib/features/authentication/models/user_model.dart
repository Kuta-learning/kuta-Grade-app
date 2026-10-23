import 'dart:convert';
import '../../../core/constants/academic_stream.dart';
import '../../../core/constants/grade_level.dart';

/// User model containing authentication, profile, and academic identity.
/// Supports JSON serialization matching both the backend API and local cache.
class UserModel {
  final String id;
  final String email;
  final String name;
  final GradeLevel? gradeLevel;
  final AcademicStream? academicStream;
  final bool onboardingCompleted;
  final String? role;
  final bool isPremium;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.gradeLevel,
    this.academicStream,
    this.onboardingCompleted = false,
    this.role,
    this.isPremium = false,
    this.avatarUrl,
  });

  bool get isKgStudent => gradeLevel?.isKg ?? false;
  bool get isGradeStudent => gradeLevel?.isGrade ?? true;

  // ── Serialization ──────────────────────────────────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      gradeLevel: GradeLevel.fromDynamic(json['gradeLevel']),
      academicStream: AcademicStream.fromString(
        json['stream'] as String? ?? json['academicStream'] as String?,
      ),
      onboardingCompleted: json['onboardingCompleted'] as bool? ??
          (json['gradeLevel'] != null),
      role: json['role'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        if (gradeLevel != null) 'gradeLevel': gradeLevel!.numericValue,
        if (academicStream != null) 'stream': academicStream!.name.toUpperCase(),
        'onboardingCompleted': onboardingCompleted,
        if (role != null) 'role': role,
        'isPremium': isPremium,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
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

  // ── CopyWith ───────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    GradeLevel? gradeLevel,
    AcademicStream? academicStream,
    bool? onboardingCompleted,
    String? role,
    bool? isPremium,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      academicStream: academicStream ?? this.academicStream,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      role: role ?? this.role,
      isPremium: isPremium ?? this.isPremium,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
          academicStream == other.academicStream &&
          onboardingCompleted == other.onboardingCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      (gradeLevel?.hashCode ?? 0) ^
      (academicStream?.hashCode ?? 0) ^
      onboardingCompleted.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, name: $name, grade: ${gradeLevel?.name}, stream: ${academicStream?.name}, onboarded: $onboardingCompleted)';
}
