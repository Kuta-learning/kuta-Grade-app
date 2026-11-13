import 'dart:convert';

/// Domain model representing a saved bookmark (exam, question, note chapter, course lesson).
class BookmarkItem {
  final String id;
  final String? studentId;
  final String type; // EXAM_QUESTION, NOTE_CHAPTER, COURSE_LESSON, QUIZ_QUESTION
  final String itemId;
  final String title;
  final String? subjectId;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  const BookmarkItem({
    required this.id,
    this.studentId,
    required this.type,
    required this.itemId,
    required this.title,
    this.subjectId,
    this.metadata,
    this.createdAt,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString());
    }

    return BookmarkItem(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String?,
      type: json['type'] as String? ?? 'EXAM_QUESTION',
      itemId: json['itemId'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Bookmark',
      subjectId: json['subjectId'] as String?,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': ?studentId,
        'type': type,
        'itemId': itemId,
        'title': title,
        'subjectId': ?subjectId,
        'metadata': ?metadata,
        'createdAt': ?createdAt?.toIso8601String(),
      };

  static String encodeList(List<BookmarkItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<BookmarkItem> decodeList(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is List) {
      return decoded
          .map((e) => BookmarkItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

/// Response returned when toggling bookmark status via POST /bookmarks/toggle.
class BookmarkToggleResponse {
  final bool isBookmarked;
  final String message;
  final BookmarkItem? bookmark;
  final String? bookmarkId;

  const BookmarkToggleResponse({
    required this.isBookmarked,
    required this.message,
    this.bookmark,
    this.bookmarkId,
  });

  factory BookmarkToggleResponse.fromJson(Map<String, dynamic> json) {
    BookmarkItem? item;
    if (json['bookmark'] is Map<String, dynamic>) {
      item = BookmarkItem.fromJson(json['bookmark'] as Map<String, dynamic>);
    }

    return BookmarkToggleResponse(
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      bookmark: item,
      bookmarkId: json['bookmarkId'] as String?,
    );
  }
}
