class PlantSuggestionDatabase {
  PlantSuggestionDatabase._();

  static const Map<String, String> _emotionToPlant = {
    'anxiety': 'Lavender - associated with calming sensory environments.',
    'sadness': 'Peace Lily - often linked with soothing indoor ambience.',
    'anger': 'Snake Plant - grounding presence and easy maintenance.',
    'fatigue': 'Rosemary - associated with alertness support.',
    'reflective': 'Pothos - low-maintenance greenery that supports a calm space.',
    'calm': 'Aloe Vera - soothing and simple to care for.',
  };

  static String suggestionForEmotion(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    for (final entry in _emotionToPlant.entries) {
      if (mood.contains(entry.key)) return entry.value;
    }
    return 'Pothos - low-maintenance greenery that supports a calm space.';
  }
}
