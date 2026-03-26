import '../../models/emotion_type.dart';
import 'emotion_classifier.dart';
import 'voice_stress_detector.dart';

/// Text-based stress estimate from emotion (heuristic until you have a dedicated text-stress model).
double _textStressFromEmotion(EmotionType e) {
  switch (e) {
    case EmotionType.anxiety: return 0.75;
    case EmotionType.sadness: return 0.6;
    case EmotionType.anger: return 0.7;
    case EmotionType.calm: return 0.2;
    case EmotionType.neutral: return 0.4;
    case EmotionType.hope: return 0.35;
    case EmotionType.reflective: return 0.45;
  }
}

/// Fusion result for Check-In: 70% text, 30% voice.
class FusionResult {
  final double stressLevel; // 0-1
  final EmotionType mood;
  final String moodLabel;

  const FusionResult({
    required this.stressLevel,
    required this.mood,
    required this.moodLabel,
  });

  bool get isHighStress => stressLevel >= 0.6;
}

/// Weighted fusion: text = 70%, voice = 30%.
class FusionService {
  final EmotionClassifier _emotionClassifier;
  final VoiceStressDetector _voiceStressDetector;

  FusionService({
    EmotionClassifier? emotionClassifier,
    VoiceStressDetector? voiceStressDetector,
  })  : _emotionClassifier = emotionClassifier ?? MockEmotionClassifier(),
        _voiceStressDetector = voiceStressDetector ?? MockVoiceStressDetector();

  /// Fuse text (emotion → stress) and optional voice stress.
  /// If [voiceStress] is null, uses mock voice value (or 0.3 as default).
  Future<FusionResult> fuse({
    required String text,
    double? voiceStress,
  }) async {
    final emotionResult = await _emotionClassifier.classify(text);
    final textStress = _textStressFromEmotion(emotionResult.emotion);
    final voice = voiceStress ?? await _voiceStressDetector.getStressFromAudio(null);
    final stressLevel = 0.7 * textStress + 0.3 * voice;
    return FusionResult(
      stressLevel: stressLevel.clamp(0.0, 1.0),
      mood: emotionResult.emotion,
      moodLabel: emotionResult.emotion.label,
    );
  }
}
