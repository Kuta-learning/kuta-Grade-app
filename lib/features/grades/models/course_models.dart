/// Data models for Courses, Chapters, Topics, and Lessons.
class CourseModel {
  final String id;
  final String title;
  final String description;
  final int gradeLevel;
  final String subject;
  final String? icon;
  final String? thumbnailUrl;
  final int totalChapters;
  final int totalLessons;
  final int completedLessons;
  final double progressPercent;
  final bool isEnrolled;
  final List<CourseChapterModel> chapters;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.gradeLevel,
    required this.subject,
    this.icon,
    this.thumbnailUrl,
    this.totalChapters = 0,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.progressPercent = 0.0,
    this.isEnrolled = true,
    this.chapters = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final rawChapters = json['chapters'] as List<dynamic>? ?? [];
    final chaptersList = rawChapters
        .map((c) => CourseChapterModel.fromJson(c as Map<String, dynamic>))
        .toList();

    int parseGrade(dynamic val) {
      if (val is int) return val;
      if (val is String) {
        final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsed != null) return parsed;
      }
      return 12;
    }

    double parseProgress(dynamic val) {
      if (val is num) {
        return val > 1.0 ? val / 100.0 : val.toDouble();
      }
      return 0.0;
    }

    final totalChaps = json['totalChapters'] as int? ??
        json['chapterCount'] as int? ??
        chaptersList.length;

    int totalL = json['totalLessons'] as int? ?? json['lessonCount'] as int? ?? 0;
    if (totalL == 0 && chaptersList.isNotEmpty) {
      for (final ch in chaptersList) {
        totalL += ch.lessons.length;
      }
    }

    return CourseModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      gradeLevel: parseGrade(json['gradeLevel']),
      subject: json['subject'] as String? ??
          json['subjectName'] as String? ??
          'General',
      icon: json['icon'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String? ??
          json['coverImage'] as String? ??
          json['imageUrl'] as String?,
      totalChapters: totalChaps,
      totalLessons: totalL,
      completedLessons: json['completedLessons'] as int? ?? 0,
      progressPercent: parseProgress(json['progress'] ?? json['progressPercent']),
      isEnrolled: json['isEnrolled'] as bool? ?? true,
      chapters: chaptersList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'gradeLevel': gradeLevel,
        'subject': subject,
        'icon': icon,
        'thumbnailUrl': thumbnailUrl,
        'totalChapters': totalChapters,
        'totalLessons': totalLessons,
        'completedLessons': completedLessons,
        'progressPercent': progressPercent,
        'isEnrolled': isEnrolled,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };
}

/// Chapter/Unit in a Course containing lessons and optional quiz.
class CourseChapterModel {
  final String id;
  final String? courseId;
  final int chapterNumber;
  final String title;
  final String? description;
  final bool isCompleted;
  final List<CourseLessonItemModel> lessons;

  const CourseChapterModel({
    required this.id,
    this.courseId,
    required this.chapterNumber,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.lessons = const [],
  });

  factory CourseChapterModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = (json['lessons'] ?? json['topics']) as List<dynamic>? ?? [];
    return CourseChapterModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      courseId: json['courseId'] as String?,
      chapterNumber: json['chapterNumber'] as int? ??
          json['order'] as int? ??
          json['number'] as int? ??
          1,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      lessons: rawLessons
          .map((l) => CourseLessonItemModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'chapterNumber': chapterNumber,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'lessons': lessons.map((l) => l.toJson()).toList(),
      };
}

/// Individual lesson row under a chapter.
class CourseLessonItemModel {
  final String id;
  final String? chapterId;
  final int lessonNumber;
  final String title;
  final String? duration;
  final bool isLocked;
  final bool isCompleted;
  final String? quizId;
  final String? type;

  const CourseLessonItemModel({
    required this.id,
    this.chapterId,
    required this.lessonNumber,
    required this.title,
    this.duration,
    this.isLocked = false,
    this.isCompleted = false,
    this.quizId,
    this.type = 'lesson',
  });

  factory CourseLessonItemModel.fromJson(Map<String, dynamic> json) {
    return CourseLessonItemModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      chapterId: json['chapterId'] as String?,
      lessonNumber: json['lessonNumber'] as int? ??
          json['order'] as int? ??
          json['number'] as int? ??
          1,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      duration: json['duration'] as String? ??
          (json['durationMinutes'] != null
              ? '${json['durationMinutes']} mins'
              : '15 mins'),
      isLocked: json['isLocked'] as bool? ??
          (json['isUnlocked'] != null ? !(json['isUnlocked'] as bool) : false),
      isCompleted: json['isCompleted'] as bool? ?? false,
      quizId: json['quizId'] as String? ?? json['quiz'] as String?,
      type: json['type'] as String? ?? 'lesson',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterId': chapterId,
        'lessonNumber': lessonNumber,
        'title': title,
        'duration': duration,
        'isLocked': isLocked,
        'isCompleted': isCompleted,
        'quizId': quizId,
        'type': type,
      };
}

/// Detailed lesson view model returned by GET /lessons/:lessonId.
class LessonDetailContentModel {
  final String id;
  final String title;
  final String? courseId;
  final String? courseTitle;
  final String? chapterId;
  final String? chapterTitle;
  final int lessonNumber;
  final String content;
  final String? videoUrl;
  final int? durationMinutes;
  final bool isLocked;
  final bool isCompleted;
  final List<String> learningObjectives;
  final String? quizId;
  final List<LessonResourceItemModel> resources;

  const LessonDetailContentModel({
    required this.id,
    required this.title,
    this.courseId,
    this.courseTitle,
    this.chapterId,
    this.chapterTitle,
    this.lessonNumber = 1,
    required this.content,
    this.videoUrl,
    this.durationMinutes,
    this.isLocked = false,
    this.isCompleted = false,
    this.learningObjectives = const [],
    this.quizId,
    this.resources = const [],
  });

  factory LessonDetailContentModel.fromJson(Map<String, dynamic> json) {
    final rawObjectives = json['learningObjectives'] as List<dynamic>? ??
        json['objectives'] as List<dynamic>? ??
        [];
    final rawResources = json['resources'] as List<dynamic>? ??
        json['attachments'] as List<dynamic>? ??
        [];

    return LessonDetailContentModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      courseId: json['courseId'] as String?,
      courseTitle: json['courseTitle'] as String?,
      chapterId: json['chapterId'] as String?,
      chapterTitle: json['chapterTitle'] as String?,
      lessonNumber: json['lessonNumber'] as int? ??
          json['order'] as int? ??
          1,
      content: json['content'] as String? ??
          json['body'] as String? ??
          json['bodyText'] as String? ??
          json['description'] as String? ??
          '',
      videoUrl: json['videoUrl'] as String? ?? json['mediaUrl'] as String?,
      durationMinutes: json['durationMinutes'] as int? ??
          json['estimatedMinutes'] as int? ??
          15,
      isLocked: json['isLocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      learningObjectives: rawObjectives.map((o) => o.toString()).toList(),
      quizId: json['quizId'] as String?,
      resources: rawResources
          .map((r) => LessonResourceItemModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'chapterId': chapterId,
        'chapterTitle': chapterTitle,
        'lessonNumber': lessonNumber,
        'content': content,
        'videoUrl': videoUrl,
        'durationMinutes': durationMinutes,
        'isLocked': isLocked,
        'isCompleted': isCompleted,
        'learningObjectives': learningObjectives,
        'quizId': quizId,
        'resources': resources.map((r) => r.toJson()).toList(),
      };

  LessonDetailContentModel copyWith({
    bool? isCompleted,
    bool? isLocked,
  }) {
    return LessonDetailContentModel(
      id: id,
      title: title,
      courseId: courseId,
      courseTitle: courseTitle,
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      lessonNumber: lessonNumber,
      content: content,
      videoUrl: videoUrl,
      durationMinutes: durationMinutes,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
      learningObjectives: learningObjectives,
      quizId: quizId,
      resources: resources,
    );
  }
}

/// Downloadable resource attached to a lesson.
class LessonResourceItemModel {
  final String id;
  final String title;
  final String? fileUrl;
  final String? fileType;
  final String? fileSize;

  const LessonResourceItemModel({
    required this.id,
    required this.title,
    this.fileUrl,
    this.fileType,
    this.fileSize,
  });

  factory LessonResourceItemModel.fromJson(Map<String, dynamic> json) {
    return LessonResourceItemModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? 'Document',
      fileUrl: json['fileUrl'] as String? ??
          json['url'] as String? ??
          json['downloadUrl'] as String?,
      fileType: json['fileType'] as String? ?? 'PDF',
      fileSize: json['fileSize'] as String? ?? '1.5 MB',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'fileSize': fileSize,
      };
}

