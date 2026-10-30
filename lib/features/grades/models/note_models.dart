import 'package:flutter/material.dart';

/// Grade level option under an expandable subject card.
class NoteGradeOption {
  final String name;
  final String chapters;
  final int gradeLevel;

  const NoteGradeOption({
    required this.name,
    required this.chapters,
    required this.gradeLevel,
  });

  factory NoteGradeOption.fromJson(Map<String, dynamic> json) {
    return NoteGradeOption(
      name: json['name'] as String? ?? 'Grade 12',
      chapters: json['chapters'] as String? ??
          (json['chapterCount'] != null
              ? '${json['chapterCount']} Chapters'
              : '0 Chapters'),
      gradeLevel: json['gradeLevel'] as int? ?? 12,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'chapters': chapters,
        'gradeLevel': gradeLevel,
      };
}

/// A subject item displayed on HighSchoolNotesScreen.
class NoteSubjectItem {
  final String id;
  final String name;
  final Color iconBgColor;
  final Color iconColor;
  final String? iconDataName;
  final bool isSymbol;
  final String? symbol;
  final List<NoteGradeOption> grades;

  const NoteSubjectItem({
    required this.id,
    required this.name,
    required this.iconBgColor,
    required this.iconColor,
    this.iconDataName,
    this.isSymbol = false,
    this.symbol,
    required this.grades,
  });

  factory NoteSubjectItem.fromJson(Map<String, dynamic> json) {
    Color parseColor(dynamic value, Color fallback) {
      if (value is int) return Color(value);
      if (value is String) {
        final hex = value.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
      return fallback;
    }

    final name = json['name'] as String? ?? json['title'] as String? ?? '';
    final norm = name.toLowerCase();

    Color defaultBg = const Color(0xFFFFDBCA);
    Color defaultColor = const Color(0xFF341100);
    String? defaultIcon = json['iconDataName'] as String?;
    bool defaultIsSymbol = json['isSymbol'] as bool? ?? false;
    String? defaultSymbol = json['symbol'] as String?;
    List<NoteGradeOption> defaultGrades = const [
      NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
      NoteGradeOption(name: 'Grade 10', chapters: '10 Chapters', gradeLevel: 10),
      NoteGradeOption(name: 'Grade 11', chapters: '12 Chapters', gradeLevel: 11),
      NoteGradeOption(name: 'Grade 12', chapters: '14 Chapters', gradeLevel: 12),
    ];

    if (norm.contains('math')) {
      defaultBg = const Color(0xFFFFDBCA);
      defaultColor = const Color(0xFF341100);
      defaultIsSymbol = true;
      defaultSymbol = 'Σ';
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
        NoteGradeOption(name: 'Grade 10', chapters: '10 Chapters', gradeLevel: 10),
        NoteGradeOption(name: 'Grade 11', chapters: '12 Chapters', gradeLevel: 11),
        NoteGradeOption(name: 'Grade 12', chapters: '14 Chapters', gradeLevel: 12),
      ];
    } else if (norm.contains('physic')) {
      defaultBg = const Color(0xFFDBE9FF);
      defaultColor = const Color(0xFF1A56DB);
      defaultIcon = 'offline_bolt_outlined';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '7 Chapters', gradeLevel: 9),
        NoteGradeOption(name: 'Grade 10', chapters: '8 Chapters', gradeLevel: 10),
        NoteGradeOption(name: 'Grade 11', chapters: '10 Chapters', gradeLevel: 11),
        NoteGradeOption(name: 'Grade 12', chapters: '12 Chapters', gradeLevel: 12),
      ];
    } else if (norm.contains('chem')) {
      defaultBg = const Color(0xFF6BFF8F);
      defaultColor = const Color(0xFF003914);
      defaultIcon = 'science_outlined';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '6 Chapters', gradeLevel: 9),
        NoteGradeOption(name: 'Grade 10', chapters: '8 Chapters', gradeLevel: 10),
        NoteGradeOption(name: 'Grade 11', chapters: '10 Chapters', gradeLevel: 11),
        NoteGradeOption(name: 'Grade 12', chapters: '12 Chapters', gradeLevel: 12),
      ];
    } else if (norm.contains('bio')) {
      defaultBg = const Color(0xFFE8ECEF);
      defaultColor = const Color(0xFF9D4300);
      defaultIcon = 'psychology_outlined';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '6 Chapters', gradeLevel: 9),
        NoteGradeOption(name: 'Grade 10', chapters: '7 Chapters', gradeLevel: 10),
        NoteGradeOption(name: 'Grade 11', chapters: '9 Chapters', gradeLevel: 11),
        NoteGradeOption(name: 'Grade 12', chapters: '11 Chapters', gradeLevel: 12),
      ];
    } else if (norm.contains('eng')) {
      defaultBg = const Color(0xFFDBE9FF);
      defaultColor = const Color(0xFF1A56DB);
      defaultIcon = 'menu_book_rounded';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
        NoteGradeOption(name: 'Grade 10', chapters: '9 Chapters', gradeLevel: 10),
        NoteGradeOption(name: 'Grade 11', chapters: '10 Chapters', gradeLevel: 11),
        NoteGradeOption(name: 'Grade 12', chapters: '12 Chapters', gradeLevel: 12),
      ];
    } else if (norm.contains('civic') || norm.contains('ethic')) {
      defaultBg = const Color(0xFFE0C0B1);
      defaultColor = const Color(0xFF584237);
      defaultIcon = 'balance_rounded';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '5 Chapters', gradeLevel: 9),
        NoteGradeOption(name: 'Grade 10', chapters: '6 Chapters', gradeLevel: 10),
        NoteGradeOption(name: 'Grade 11', chapters: '8 Chapters', gradeLevel: 11),
        NoteGradeOption(name: 'Grade 12', chapters: '10 Chapters', gradeLevel: 12),
      ];
    }

    final rawGrades = json['grades'] as List<dynamic>? ?? [];
    final grades = rawGrades.isNotEmpty
        ? rawGrades
            .map((g) => NoteGradeOption.fromJson(g as Map<String, dynamic>))
            .toList()
        : defaultGrades;

    return NoteSubjectItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: name,
      iconBgColor: parseColor(json['iconBgColor'], defaultBg),
      iconColor: parseColor(json['iconColor'], defaultColor),
      iconDataName: defaultIcon,
      isSymbol: defaultIsSymbol,
      symbol: defaultSymbol,
      grades: grades,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconBgColor': iconBgColor.toARGB32(),
        'iconColor': iconColor.toARGB32(),
        'iconDataName': iconDataName,
        'isSymbol': isSymbol,
        'symbol': symbol,
        'grades': grades.map((g) => g.toJson()).toList(),
      };
}

/// Chapter note row item under NoteDetailScreen.
class ChapterNoteItem {
  final String id;
  final String chapterNumber;
  final String title;
  final String description;
  final String pageCount;
  final String fileSize;
  final String? pdfUrl;
  final bool isCompleted;

  const ChapterNoteItem({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.pageCount,
    required this.fileSize,
    this.pdfUrl,
    this.isCompleted = false,
  });

  factory ChapterNoteItem.fromJson(Map<String, dynamic> json) {
    return ChapterNoteItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      chapterNumber: json['chapterNumber']?.toString() ??
          json['order']?.toString() ??
          json['chapterIndex']?.toString() ??
          '1',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ??
          json['subtitle'] as String? ??
          '',
      pageCount: json['pageCount']?.toString() != null
          ? (json['pageCount'].toString().contains('Pages')
              ? json['pageCount'].toString()
              : '${json['pageCount']} Pages')
          : '12 Pages',
      fileSize: json['fileSize'] as String? ?? '2.4 MB',
      pdfUrl: json['pdfUrl'] as String?,
      isCompleted: json['isCompleted'] as bool? ??
          json['isRead'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterNumber': chapterNumber,
        'title': title,
        'description': description,
        'pageCount': pageCount,
        'fileSize': fileSize,
        'pdfUrl': pdfUrl,
        'isCompleted': isCompleted,
      };
}

/// Complete detail payload for a subject + grade in NoteDetailScreen.
class SubjectNotesDetail {
  final String subjectId;
  final String subjectTitle;
  final String gradeLevel;
  final int totalChapters;
  final String totalFileSize;
  final String downloadAllUrl;
  final List<ChapterNoteItem> chapters;

  const SubjectNotesDetail({
    required this.subjectId,
    required this.subjectTitle,
    required this.gradeLevel,
    required this.totalChapters,
    required this.totalFileSize,
    required this.downloadAllUrl,
    required this.chapters,
  });

  factory SubjectNotesDetail.fromJson(Map<String, dynamic> json) {
    final rawChapters = json['chapters'] as List<dynamic>? ?? [];
    final subjectObj = json['subject'] as Map<String, dynamic>?;

    final resolvedId = json['subjectId'] as String? ??
        subjectObj?['id'] as String? ??
        json['id'] as String? ??
        '';

    final resolvedTitle = json['subjectTitle'] as String? ??
        subjectObj?['name'] as String? ??
        json['name'] as String? ??
        json['title'] as String? ??
        'Subject Notes';

    final resolvedGrade = json['gradeLevel']?.toString() ??
        (json['selectedGrade'] != null ? 'Grade ${json['selectedGrade']}' : null) ??
        'Grade 12';

    final resolvedSize = json['totalFileSize'] as String? ??
        json['downloadAllSize'] as String? ??
        '24 MB';

    return SubjectNotesDetail(
      subjectId: resolvedId,
      subjectTitle: resolvedTitle,
      gradeLevel: resolvedGrade,
      totalChapters: json['totalChapters'] as int? ?? rawChapters.length,
      totalFileSize: resolvedSize,
      downloadAllUrl: json['downloadAllUrl'] as String? ?? '',
      chapters: rawChapters
          .map((c) => ChapterNoteItem.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'subjectTitle': subjectTitle,
        'gradeLevel': gradeLevel,
        'totalChapters': totalChapters,
        'totalFileSize': totalFileSize,
        'downloadAllUrl': downloadAllUrl,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };
}

/// Diagram card in lesson detail.
class LessonDiagram {
  final String title;
  final String imageAssetOrUrl;
  final String caption;
  final String? label;
  final String? subtitle;

  const LessonDiagram({
    required this.title,
    required this.imageAssetOrUrl,
    required this.caption,
    this.label,
    this.subtitle,
  });

  String get displayLabel => label ?? 'Diagram';
  String get displaySubtitle => subtitle ?? caption;

  factory LessonDiagram.fromJson(Map<String, dynamic> json) {
    return LessonDiagram(
      title: json['title'] as String? ?? '',
      imageAssetOrUrl: json['imageAssetOrUrl'] as String? ??
          json['imageUrl'] as String? ??
          '',
      caption: json['caption'] as String? ?? '',
      label: json['label'] as String?,
      subtitle: json['subtitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageAssetOrUrl': imageAssetOrUrl,
        'caption': caption,
        'label': label,
        'subtitle': subtitle,
      };
}

/// Numbered step card in lesson detail.
class LessonStep {
  final int number;
  final String title;
  final String text;
  final String? highlightText;

  const LessonStep({
    required this.number,
    required this.title,
    required this.text,
    this.highlightText,
  });

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    return LessonStep(
      number: json['number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      highlightText: json['highlightText'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'text': text,
        'highlightText': highlightText,
      };
}

/// Attached document or worksheet resource.
class LessonResource {
  final String id;
  final String title;
  final String fileSize;
  final String fileType;
  final String downloadUrl;

  const LessonResource({
    required this.id,
    required this.title,
    required this.fileSize,
    required this.fileType,
    required this.downloadUrl,
  });

  factory LessonResource.fromJson(Map<String, dynamic> json) {
    return LessonResource(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      fileSize: json['fileSize'] as String? ?? '1.2 MB',
      fileType: json['fileType'] as String? ?? 'PDF',
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fileSize': fileSize,
        'fileType': fileType,
        'downloadUrl': downloadUrl,
      };
}

/// Complete lesson reader payload for LessonDetailScreen.
class LessonDetail {
  final String chapterId;
  final String chapterTitle;
  final String chapterNumber;
  final String subject;
  final String gradeLevel;
  final List<String> learningObjectives;
  final String sectionHeading;
  final String bodyText;
  final List<LessonDiagram> diagrams;
  final List<LessonStep> steps;
  final List<LessonResource> resources;
  final double progressPercent;

  const LessonDetail({
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.subject,
    required this.gradeLevel,
    required this.learningObjectives,
    required this.sectionHeading,
    required this.bodyText,
    required this.diagrams,
    required this.steps,
    required this.resources,
    required this.progressPercent,
  });

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    final rawObjectives = json['learningObjectives'] as List<dynamic>? ?? [];
    final rawDiagrams = json['diagrams'] as List<dynamic>? ?? [];
    final rawSteps = json['steps'] as List<dynamic>? ?? [];
    final rawResources = json['resources'] as List<dynamic>? ?? [];

    return LessonDetail(
      chapterId: json['chapterId'] as String? ?? '',
      chapterTitle: json['chapterTitle'] as String? ?? '',
      chapterNumber: json['chapterNumber']?.toString() ?? '1',
      subject: json['subject'] as String? ?? '',
      gradeLevel: json['gradeLevel'] as String? ?? '',
      learningObjectives: rawObjectives.map((e) => e.toString()).toList(),
      sectionHeading: json['sectionHeading'] as String? ?? '',
      bodyText: json['bodyText'] as String? ?? '',
      diagrams: rawDiagrams
          .map((d) => LessonDiagram.fromJson(d as Map<String, dynamic>))
          .toList(),
      steps: rawSteps
          .map((s) => LessonStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      resources: rawResources
          .map((r) => LessonResource.fromJson(r as Map<String, dynamic>))
          .toList(),
      progressPercent:
          (json['progressPercent'] as num?)?.toDouble() ?? 0.65,
    );
  }

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'chapterTitle': chapterTitle,
        'chapterNumber': chapterNumber,
        'subject': subject,
        'gradeLevel': gradeLevel,
        'learningObjectives': learningObjectives,
        'sectionHeading': sectionHeading,
        'bodyText': bodyText,
        'diagrams': diagrams.map((d) => d.toJson()).toList(),
        'steps': steps.map((s) => s.toJson()).toList(),
        'resources': resources.map((r) => r.toJson()).toList(),
        'progressPercent': progressPercent,
      };
}

