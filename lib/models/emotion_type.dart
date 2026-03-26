/// Emotion labels for classification (Layer 1 output).
enum EmotionType {
  anxiety,
  sadness,
  calm,
  neutral,
  anger,
  hope,
  reflective,
}

extension EmotionTypeX on EmotionType {
  String get label {
    switch (this) {
      case EmotionType.anxiety: return 'Anxiety';
      case EmotionType.sadness: return 'Sadness';
      case EmotionType.calm: return 'Calm';
      case EmotionType.neutral: return 'Neutral';
      case EmotionType.anger: return 'Anger';
      case EmotionType.hope: return 'Hope';
      case EmotionType.reflective: return 'Reflective';
    }
  }
}
