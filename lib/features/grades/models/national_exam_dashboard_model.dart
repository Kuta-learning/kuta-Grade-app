import 'package:flutter/material.dart';

/// Top-level model representing response from GET /national-exams/dashboard.
class NationalExamDashboardModel {
  final StudentInfo student;
  final BannerExamInfo? bannerExam;
  final int subjectsCount;
  final List<NationalExamSubjectModel> subjects;

  const NationalExamDashboardModel({
    required this.student,
    this.bannerExam,
    required this.subjectsCount,
    required this.subjects,
  });

  factory NationalExamDashboardModel.fromJson(Map<String, dynamic> json) {
    return NationalExamDashboardModel(
      student: StudentInfo.fromJson(
        (json['student'] as Map<String, dynamic>?) ?? {},
      ),
      bannerExam: json['bannerExam'] != null && json['bannerExam'] is Map<String, dynamic>
          ? BannerExamInfo.fromJson(json['bannerExam'] as Map<String, dynamic>)
          : null,
      subjectsCount: json['subjectsCount'] as int? ??
          (json['subjects'] as List<dynamic>?)?.length ??
          0,
      subjects: ((json['subjects'] as List<dynamic>?) ?? [])
          .map((item) =>
              NationalExamSubjectModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StudentInfo {
  final String name;
  final int gradeLevel;
  final String stream;
  final bool isPremium;

  const StudentInfo({
    required this.name,
    required this.gradeLevel,
    required this.stream,
    required this.isPremium,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      name: json['name'] as String? ?? 'Student',
      gradeLevel: json['gradeLevel'] as int? ?? 12,
      stream: json['stream'] as String? ?? 'NATURAL',
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
}

class BannerExamInfo {
  final String? attemptId;
  final String? examId;
  final String title;
  final String subjectName;
  final int? year;
  final String? status;
  final String action;
  final int timeRemainingSeconds;

  const BannerExamInfo({
    this.attemptId,
    this.examId,
    required this.title,
    required this.subjectName,
    this.year,
    this.status,
    required this.action,
    required this.timeRemainingSeconds,
  });

  factory BannerExamInfo.fromJson(Map<String, dynamic> json) {
    return BannerExamInfo(
      attemptId: json['attemptId'] as String?,
      examId: json['examId'] as String?,
      title: json['title'] as String? ?? 'National Exam',
      subjectName: json['subjectName'] as String? ?? 'Subject',
      year: json['year'] as int?,
      status: json['status'] as String?,
      action: json['action'] as String? ?? 'Resume Exam',
      timeRemainingSeconds: json['timeRemainingSeconds'] as int? ?? 0,
    );
  }

  String get formattedRemainingTime {
    if (timeRemainingSeconds <= 0) return 'Ready to start';
    final minutes = (timeRemainingSeconds / 60).round();
    return '$minutes mins remaining';
  }
}

class NationalExamSubjectModel {
  final String id;
  final String name;
  final String code;
  final String stream;
  final String description;
  final String subcategories;
  final String iconKey;
  final String hexColor;
  final int totalExams;
  final int totalQuestions;
  final int completedExams;
  final double progressPercentage;

  const NationalExamSubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.stream,
    required this.description,
    required this.subcategories,
    required this.iconKey,
    required this.hexColor,
    required this.totalExams,
    required this.totalQuestions,
    required this.completedExams,
    required this.progressPercentage,
  });

  factory NationalExamSubjectModel.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['progressPercentage'];
    final double progress = rawProgress is num
        ? rawProgress.toDouble()
        : double.tryParse(rawProgress?.toString() ?? '0') ?? 0.0;

    return NationalExamSubjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      stream: json['stream'] as String? ?? 'NATURAL',
      description: json['description'] as String? ?? '',
      subcategories: json['subcategories'] as String? ?? '',
      iconKey: json['icon'] as String? ?? 'book',
      hexColor: json['color'] as String? ?? '#3B82F6',
      totalExams: json['totalExams'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      completedExams: json['completedExams'] as int? ?? 0,
      progressPercentage: progress,
    );
  }

  Color get parsedColor {
    try {
      final clean = hexColor.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      }
    } catch (_) {}
    return const Color(0xFF2563EB);
  }

  IconData get iconData {
    switch (iconKey.toLowerCase()) {
      case 'calculator':
        return Icons.calculate_outlined;
      case 'atom':
      case 'bolt':
        return Icons.bolt_rounded;
      case 'flask':
      case 'chemistry':
        return Icons.science_outlined;
      case 'dna':
      case 'biology':
        return Icons.psychology_outlined;
      case 'book-open':
      case 'book':
        return Icons.translate_rounded;
      case 'shield-check':
      case 'shield':
        return Icons.balance_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color get iconBackgroundColor {
    return parsedColor.withValues(alpha: 0.12);
  }
}
