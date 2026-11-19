/// Service handling voice prompts and sound effects for Kindergarten UX.
abstract class KgAudioService {
  Future<void> playAudioPrompt(String assetPath);
  Future<void> playSuccessSound();
  Future<void> stopAudio();
}
