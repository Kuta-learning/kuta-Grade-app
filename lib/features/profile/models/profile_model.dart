import 'dart:convert';

import '../../../core/constants/academic_stream.dart';
import '../../../core/constants/grade_level.dart';
import '../../authentication/models/user_model.dart';

/// Detailed student profile data model backing the Profile screen.
///
/// Identity fields (name, email, grade, stream, premium flag) come live from
/// `GET /auth/me` (shared with [UserModel]). Performance and subscription
/// statistics are nullable until the backend exposes dedicated endpoints —
/// the UI renders dash placeholders for them in the meantime.
class ProfileModel {
  final String userId;
  final String fullName;
  final String email;
  final GradeLevel? gradeLevel;
  final AcademicStream? academicStream;
  final String? schoolName;
  final String? avatarUrl;
  final bool isPremium;

  // ── Optional statistics (no backend endpoint yet — may be null) ──────────
  final int? totalPoints;
  final int? globalRank;

  // ── Optional subscription details (no backend endpoint yet) ──────────────
  final String? planName;
  final bool? subscriptionActive;
  final DateTime? nextBillingDate;

  const ProfileModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.gradeLevel,
    this.academicStream,
    this.schoolName,
    this.avatarUrl,
    this.isPremium = false,
    this.totalPoints,
    this.globalRank,
    this.planName,
    this.subscriptionActive,
    this.nextBillingDate,
  });

  /// Secondary identity line: stream when available, otherwise school name.
  String? get secondaryLine {
    if (academicStream != null) return academicStream!.displayName;
    final school = schoolName?.trim();
    if (school != null && school.isNotEmpty) return school;
    return null;
  }

  // ── From authenticated user ───────────────────────────────────────────────

  /// Builds a [ProfileModel] from the authenticated [UserModel] (cached or live).
  factory ProfileModel.fromUser(UserModel user) => ProfileModel(
        userId: user.id,
        fullName: user.name,
        email: user.email,
        gradeLevel: user.gradeLevel,
        academicStream: user.academicStream,
        avatarUrl: user.avatarUrl,
        isPremium: user.isPremium,
      );

  // ── Serialization ─────────────────────────────────────────────────────────

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'] as Map<String, dynamic>?;
    final rawBilling = json['nextBillingDate'] as String? ??
        subscription?['nextBillingDate'] as String?;
    return ProfileModel(
      userId: (json['id'] ?? json['_id'] ?? json['userId'] ?? '') as String,
      fullName: (json['name'] ?? json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      gradeLevel: GradeLevel.fromDynamic(json['gradeLevel']),
      academicStream: AcademicStream.fromString(
        json['stream'] as String? ?? json['academicStream'] as String?,
      ),
      schoolName: json['schoolName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      totalPoints: (json['totalPoints'] as num?)?.toInt(),
      globalRank: (json['globalRank'] as num?)?.toInt(),
      planName: (subscription?['planName'] ?? json['planName']) as String?,
      subscriptionActive:
          (subscription?['isActive'] ?? json['subscriptionActive']) as bool? ??
              json['isPremium'] as bool? ??
              false,
      nextBillingDate:
          rawBilling != null && rawBilling.isNotEmpty ? DateTime.tryParse(rawBilling) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': userId,
        'name': fullName,
        'email': email,
        if (gradeLevel != null) 'gradeLevel': gradeLevel!.numericValue,
        if (academicStream != null) 'stream': academicStream!.name.toUpperCase(),
        if (schoolName != null) 'schoolName': schoolName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'isPremium': isPremium,
        if (totalPoints != null) 'totalPoints': totalPoints,
        if (globalRank != null) 'globalRank': globalRank,
        if (planName != null) 'planName': planName,
        if (subscriptionActive != null) 'subscriptionActive': subscriptionActive,
        if (nextBillingDate != null)
          'nextBillingDate': nextBillingDate!.toIso8601String(),
      };

  /// Encode to JSON string for [SharedPreferences] cache.
  String toJsonString() => jsonEncode(toJson());

  /// Decode from JSON string retrieved from [SharedPreferences].
  static ProfileModel? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return ProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── CopyWith ───────────────────────────────────────────────────────────────
  ProfileModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    GradeLevel? gradeLevel,
    AcademicStream? academicStream,
    String? schoolName,
    String? avatarUrl,
    bool? isPremium,
    int? totalPoints,
    int? globalRank,
    String? planName,
    bool? subscriptionActive,
    DateTime? nextBillingDate,
    bool clearStats = false,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      academicStream: academicStream ?? this.academicStream,
      schoolName: schoolName ?? this.schoolName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      totalPoints: clearStats ? null : (totalPoints ?? this.totalPoints),
      globalRank: clearStats ? null : (globalRank ?? this.globalRank),
      planName: planName ?? this.planName,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
    );
  }

  @override
  String toString() =>
      'ProfileModel(id: $userId, name: $fullName, grade: ${gradeLevel?.name}, '
      'stream: ${academicStream?.name}, premium: $isPremium)';
}
