/// Quiz and assessment model shared across grade levels.
class QuizModel {
  final String id;
  final String chapterId;
  final String title;
  final int totalQuestions;
  final int timeLimitMinutes;

  const QuizModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.totalQuestions,
    required this.timeLimitMinutes,
  });
}
