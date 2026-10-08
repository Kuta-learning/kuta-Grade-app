/// Shared learning progress data model across learning domains.
class LearningProgressModel {
  final String userId;
  final String courseOrActivityId;
  final double completionPercentage;
  final int pointsEarned;

  const LearningProgressModel({
    required this.userId,
    required this.courseOrActivityId,
    required this.completionPercentage,
    required this.pointsEarned,
  });
}
