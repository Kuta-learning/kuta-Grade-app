import '../models/learning_progress_model.dart';

/// Service contract for saving and fetching shared learning progress.
abstract class ProgressService {
  Future<LearningProgressModel?> getProgress(String courseOrActivityId);
  Future<void> updateProgress(LearningProgressModel progress);
}
