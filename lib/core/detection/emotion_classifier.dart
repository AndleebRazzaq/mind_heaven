import '../../models/emotion_type.dart';

/// Result of emotion classification (Layer 1 — Journal & Check-In text).
class EmotionResult {
  final EmotionType emotion;
  final double confidence; // 0-1

  const EmotionResult({required this.emotion, required this.confidence});
}

/// Emotion classifier interface.
/// Replace mock with API or on-device model (e.g. fine-tuned DistilBERT).
abstract class EmotionClassifier {
  Future<EmotionResult> classify(String text);
}

/// Mock implementation using heuristics. Replace with real model call.
class MockEmotionClassifier implements EmotionClassifier {
  @override
  Future<EmotionResult> classify(String text) async {
    if (text.isEmpty) {
      return const EmotionResult(emotion: EmotionType.neutral, confidence: 0.5);
    }
    final lower = text.toLowerCase();
    if (lower.contains('anxious') || lower.contains('worried') || lower.contains('stress')) {
      return const EmotionResult(emotion: EmotionType.anxiety, confidence: 0.85);
    }
    if (lower.contains('sad') || lower.contains('down') || lower.contains('hopeless')) {
      return const EmotionResult(emotion: EmotionType.sadness, confidence: 0.82);
    }
    if (lower.contains('calm') || lower.contains('peaceful') || lower.contains('good')) {
      return const EmotionResult(emotion: EmotionType.calm, confidence: 0.8);
    }
    if (lower.contains('angry') || lower.contains('frustrated')) {
      return const EmotionResult(emotion: EmotionType.anger, confidence: 0.75);
    }
    if (lower.contains('hope') || lower.contains('better')) {
      return const EmotionResult(emotion: EmotionType.hope, confidence: 0.7);
    }
    return const EmotionResult(emotion: EmotionType.reflective, confidence: 0.65);
  }
}
