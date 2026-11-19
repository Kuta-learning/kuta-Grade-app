import 'dart:convert';
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
      chapters:
          json['chapters'] as String? ??
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
  final int? studentGrade;
  final String? curriculumType;
  final String? gradeBadge;
  final int totalChapters;
  final List<int> availableGrades;

  const NoteSubjectItem({
    required this.id,
    required this.name,
    required this.iconBgColor,
    required this.iconColor,
    this.iconDataName,
    this.isSymbol = false,
    this.symbol,
    required this.grades,
    this.studentGrade,
    this.curriculumType,
    this.gradeBadge,
    this.totalChapters = 0,
    this.availableGrades = const [],
  });

  factory NoteSubjectItem.fromJson(
    Map<String, dynamic> json, {
    int? parentStudentGrade,
    String? parentCurriculumType,
  }) {
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

    final availableGrades = (json['availableGrades'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const <int>[];
    final totalChapters = (json['totalChapters'] as num?)?.toInt() ?? 0;
    final gradeBadge = json['gradeBadge'] as String?;
    final studentGrade =
        (json['studentGrade'] as num?)?.toInt() ?? parentStudentGrade;
    final curriculumType =
        json['curriculumType'] as String? ?? parentCurriculumType;

    Color defaultBg = const Color(0xFFFFDBCA);
    Color defaultColor = const Color(0xFF341100);
    String? defaultIcon = json['iconDataName'] as String?;
    bool defaultIsSymbol = json['isSymbol'] as bool? ?? false;
    String? defaultSymbol = json['symbol'] as String?;
    List<NoteGradeOption> defaultGrades = const [
      NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
      NoteGradeOption(
        name: 'Grade 10',
        chapters: '10 Chapters',
        gradeLevel: 10,
      ),
      NoteGradeOption(
        name: 'Grade 11',
        chapters: '12 Chapters',
        gradeLevel: 11,
      ),
      NoteGradeOption(
        name: 'Grade 12',
        chapters: '14 Chapters',
        gradeLevel: 12,
      ),
    ];

    if (norm.contains('math')) {
      defaultBg = const Color(0xFFFFDBCA);
      defaultColor = const Color(0xFF341100);
      defaultIsSymbol = true;
      defaultSymbol = 'Σ';
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
        NoteGradeOption(
          name: 'Grade 10',
          chapters: '10 Chapters',
          gradeLevel: 10,
        ),
        NoteGradeOption(
          name: 'Grade 11',
          chapters: '12 Chapters',
          gradeLevel: 11,
        ),
        NoteGradeOption(
          name: 'Grade 12',
          chapters: '14 Chapters',
          gradeLevel: 12,
        ),
      ];
    } else if (norm.contains('physic')) {
      defaultBg = const Color(0xFFDBE9FF);
      defaultColor = const Color(0xFF1A56DB);
      defaultIcon = 'offline_bolt_outlined';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '7 Chapters', gradeLevel: 9),
        NoteGradeOption(
          name: 'Grade 10',
          chapters: '8 Chapters',
          gradeLevel: 10,
        ),
        NoteGradeOption(
          name: 'Grade 11',
          chapters: '10 Chapters',
          gradeLevel: 11,
        ),
        NoteGradeOption(
          name: 'Grade 12',
          chapters: '12 Chapters',
          gradeLevel: 12,
        ),
      ];
    } else if (norm.contains('chem')) {
      defaultBg = const Color(0xFF6BFF8F);
      defaultColor = const Color(0xFF003914);
      defaultIcon = 'science_outlined';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '6 Chapters', gradeLevel: 9),
        NoteGradeOption(
          name: 'Grade 10',
          chapters: '8 Chapters',
          gradeLevel: 10,
        ),
        NoteGradeOption(
          name: 'Grade 11',
          chapters: '10 Chapters',
          gradeLevel: 11,
        ),
        NoteGradeOption(
          name: 'Grade 12',
          chapters: '12 Chapters',
          gradeLevel: 12,
        ),
      ];
    } else if (norm.contains('bio')) {
      defaultBg = const Color(0xFFE8ECEF);
      defaultColor = const Color(0xFF9D4300);
      defaultIcon = 'psychology_outlined';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '6 Chapters', gradeLevel: 9),
        NoteGradeOption(
          name: 'Grade 10',
          chapters: '7 Chapters',
          gradeLevel: 10,
        ),
        NoteGradeOption(
          name: 'Grade 11',
          chapters: '9 Chapters',
          gradeLevel: 11,
        ),
        NoteGradeOption(
          name: 'Grade 12',
          chapters: '11 Chapters',
          gradeLevel: 12,
        ),
      ];
    } else if (norm.contains('eng')) {
      defaultBg = const Color(0xFFDBE9FF);
      defaultColor = const Color(0xFF1A56DB);
      defaultIcon = 'menu_book_rounded';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '8 Chapters', gradeLevel: 9),
        NoteGradeOption(
          name: 'Grade 10',
          chapters: '9 Chapters',
          gradeLevel: 10,
        ),
        NoteGradeOption(
          name: 'Grade 11',
          chapters: '10 Chapters',
          gradeLevel: 11,
        ),
        NoteGradeOption(
          name: 'Grade 12',
          chapters: '12 Chapters',
          gradeLevel: 12,
        ),
      ];
    } else if (norm.contains('civic') || norm.contains('ethic')) {
      defaultBg = const Color(0xFFE0C0B1);
      defaultColor = const Color(0xFF584237);
      defaultIcon = 'balance_rounded';
      defaultIsSymbol = false;
      defaultGrades = const [
        NoteGradeOption(name: 'Grade 9', chapters: '5 Chapters', gradeLevel: 9),
        NoteGradeOption(
          name: 'Grade 10',
          chapters: '6 Chapters',
          gradeLevel: 10,
        ),
        NoteGradeOption(
          name: 'Grade 11',
          chapters: '8 Chapters',
          gradeLevel: 11,
        ),
        NoteGradeOption(
          name: 'Grade 12',
          chapters: '10 Chapters',
          gradeLevel: 12,
        ),
      ];
    }

    final rawGrades = json['grades'] as List<dynamic>? ?? [];
    List<NoteGradeOption> grades;
    if (rawGrades.isNotEmpty) {
      grades = rawGrades
          .map((g) => NoteGradeOption.fromJson(g as Map<String, dynamic>))
          .toList();
    } else if (availableGrades.isNotEmpty && !availableGrades.any((g) => g >= 9)) {
      // Primary grades (e.g. Grade 6 or Grade 8)
      grades = availableGrades
          .map((g) => NoteGradeOption(
                name: 'Grade $g',
                chapters: '$totalChapters Chapters',
                gradeLevel: g,
              ))
          .toList();
    } else if (studentGrade != null && studentGrade <= 8) {
      // Single primary grade fallback
      grades = [
        NoteGradeOption(
          name: 'Grade $studentGrade',
          chapters: '$totalChapters Chapters',
          gradeLevel: studentGrade,
        ),
      ];
    } else {
      // High school (Grade 9-12)
      grades = defaultGrades;
    }

    return NoteSubjectItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: name,
      iconBgColor: parseColor(json['iconBgColor'], defaultBg),
      iconColor: parseColor(json['iconColor'], defaultColor),
      iconDataName: defaultIcon,
      isSymbol: defaultIsSymbol,
      symbol: defaultSymbol,
      grades: grades,
      studentGrade: studentGrade,
      curriculumType: curriculumType,
      gradeBadge: gradeBadge,
      totalChapters: totalChapters,
      availableGrades: availableGrades,
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
    if (studentGrade != null) 'studentGrade': studentGrade,
    if (curriculumType != null) 'curriculumType': curriculumType,
    if (gradeBadge != null) 'gradeBadge': gradeBadge,
    'totalChapters': totalChapters,
    'availableGrades': availableGrades,
  };

  String toJsonString() => jsonEncode(toJson());

  static NoteSubjectItem fromJsonString(String raw) =>
      NoteSubjectItem.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  static String listToJsonString(List<NoteSubjectItem> list) =>
      jsonEncode(list.map((item) => item.toJson()).toList());

  static List<NoteSubjectItem> listFromJsonString(String raw) =>
      (jsonDecode(raw) as List)
          .map((item) => NoteSubjectItem.fromJson(item as Map<String, dynamic>))
          .toList();
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
      chapterNumber:
          json['chapterNumber']?.toString() ??
          json['order']?.toString() ??
          json['chapterIndex']?.toString() ??
          '1',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description:
          json['description'] as String? ?? json['subtitle'] as String? ?? '',
      pageCount: json['pageCount']?.toString() != null
          ? (json['pageCount'].toString().contains('Pages')
                ? json['pageCount'].toString()
                : '${json['pageCount']} Pages')
          : '12 Pages',
      fileSize: json['fileSize'] as String? ?? '2.4 MB',
      pdfUrl: json['pdfUrl'] as String?,
      isCompleted:
          json['isCompleted'] as bool? ?? json['isRead'] as bool? ?? false,
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
  final bool requiresGradeSelection;
  final int? studentGrade;
  final String? curriculumType;

  const SubjectNotesDetail({
    required this.subjectId,
    required this.subjectTitle,
    required this.gradeLevel,
    required this.totalChapters,
    required this.totalFileSize,
    required this.downloadAllUrl,
    required this.chapters,
    this.requiresGradeSelection = true,
    this.studentGrade,
    this.curriculumType,
  });

  factory SubjectNotesDetail.fromJson(Map<String, dynamic> json) {
    final rawChapters = json['chapters'] as List<dynamic>? ?? [];
    final subjectObj = json['subject'] as Map<String, dynamic>?;

    final resolvedId =
        json['subjectId'] as String? ??
        subjectObj?['id'] as String? ??
        json['id'] as String? ??
        '';

    final resolvedTitle =
        json['subjectTitle'] as String? ??
        subjectObj?['name'] as String? ??
        json['name'] as String? ??
        json['title'] as String? ??
        'Subject Notes';

    final studentGrade = (json['studentGrade'] as num?)?.toInt();
    final selectedGradeInt = (json['selectedGrade'] as num?)?.toInt();
    final requiresGradeSelection = json['requiresGradeSelection'] as bool? ??
        ((studentGrade != null && studentGrade <= 8) ? false : true);
    final curriculumType = json['curriculumType'] as String?;

    final resolvedGrade =
        json['gradeLevel']?.toString() ??
        (selectedGradeInt != null
            ? 'Grade $selectedGradeInt'
            : null) ??
        (studentGrade != null
            ? 'Grade $studentGrade'
            : null) ??
        'Grade 12';

    final resolvedSize =
        json['totalFileSize'] as String? ??
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
      requiresGradeSelection: requiresGradeSelection,
      studentGrade: studentGrade,
      curriculumType: curriculumType,
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
    'requiresGradeSelection': requiresGradeSelection,
    if (studentGrade != null) 'studentGrade': studentGrade,
    if (curriculumType != null) 'curriculumType': curriculumType,
  };

  String toJsonString() => jsonEncode(toJson());

  static SubjectNotesDetail fromJsonString(String raw) =>
      SubjectNotesDetail.fromJson(jsonDecode(raw) as Map<String, dynamic>);
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
      imageAssetOrUrl:
          json['imageAssetOrUrl'] as String? ??
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
      id:
          json['id'] as String? ??
          json['url'] as String? ??
          json['name'] as String? ??
          '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      fileSize: json['fileSize'] as String? ?? json['size'] as String? ?? '',
      fileType: json['fileType'] as String? ?? json['type'] as String? ?? 'PDF',
      downloadUrl:
          json['downloadUrl'] as String? ?? json['url'] as String? ?? '',
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
  final String chapterSubtitle;
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
    this.chapterSubtitle = '',
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

    final subtitle =
        json['subtitle'] as String? ?? json['chapterSubtitle'] as String? ?? '';

    final rawNumber = json['chapterNumber'] ?? json['order'];
    String chapterNumber;
    if (rawNumber != null) {
      chapterNumber = rawNumber.toString();
    } else {
      final match = RegExp(
        r'chapter\s*(\d+(?:\.\d+)?)',
        caseSensitive: false,
      ).firstMatch(subtitle);
      chapterNumber = match?.group(1) ?? '';
    }

    final rawSubject = json['subject'];
    String subject = '';
    if (rawSubject is Map) {
      subject = rawSubject['name']?.toString() ?? '';
    } else if (rawSubject is String) {
      subject = rawSubject;
    }

    final rawGrade = json['gradeLevel'];
    String gradeLevel;
    if (rawGrade is num) {
      gradeLevel = 'Grade $rawGrade';
    } else if (rawGrade is String) {
      gradeLevel = rawGrade;
    } else {
      gradeLevel = '';
    }

    final rawProgress = json['progressPercent'];
    final rawReadProgress = json['readProgress'];
    double progressPercent;
    if (rawProgress is num) {
      progressPercent = rawProgress.toDouble();
    } else if (rawReadProgress is Map &&
        rawReadProgress['readPercentage'] is num) {
      progressPercent =
          (rawReadProgress['readPercentage'] as num).toDouble() / 100;
    } else if (rawReadProgress is Map && rawReadProgress['isRead'] == true) {
      progressPercent = 1.0;
    } else {
      progressPercent = 0.0;
    }

    return LessonDetail(
      chapterId: json['chapterId'] as String? ?? json['id'] as String? ?? '',
      chapterTitle:
          json['chapterTitle'] as String? ??
          json['title'] as String? ??
          json['name'] as String? ??
          '',
      chapterSubtitle: subtitle,
      chapterNumber: chapterNumber,
      subject: subject,
      gradeLevel: gradeLevel,
      learningObjectives: rawObjectives.map((e) => e.toString()).toList(),
      sectionHeading: json['sectionHeading'] as String? ?? '',
      bodyText: json['bodyText'] as String? ?? json['content'] as String? ?? '',
      diagrams: rawDiagrams
          .map((d) => LessonDiagram.fromJson(d as Map<String, dynamic>))
          .toList(),
      steps: rawSteps
          .map((s) => LessonStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      resources: rawResources
          .map((r) => LessonResource.fromJson(r as Map<String, dynamic>))
          .toList(),
      progressPercent: progressPercent,
    );
  }

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'chapterTitle': chapterTitle,
    'chapterSubtitle': chapterSubtitle,
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

  String toJsonString() => jsonEncode(toJson());

  static LessonDetail fromJsonString(String raw) =>
      LessonDetail.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
