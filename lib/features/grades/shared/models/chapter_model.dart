/// Chapter / Unit model within a subject.
class ChapterModel {
  final String id;
  final String subjectId;
  final int chapterNumber;
  final String title;
  final bool isCompleted;

  const ChapterModel({
    required this.id,
    required this.subjectId,
    required this.chapterNumber,
    required this.title,
    this.isCompleted = false,
  });
}
