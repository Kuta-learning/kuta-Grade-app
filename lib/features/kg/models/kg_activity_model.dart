/// Kindergarten activity / mini-game data model.
class KgActivityModel {
  final String id;
  final String title;
  final String iconAsset;
  final String audioPromptAsset;
  final bool isCompleted;

  const KgActivityModel({
    required this.id,
    required this.title,
    required this.iconAsset,
    required this.audioPromptAsset,
    this.isCompleted = false,
  });
}
