/// Cognitive distortion types (CBT framework).
enum DistortionType {
  allOrNothing,
  overgeneralization,
  mentalFilter,
  disqualifyingPositive,
  jumpingToConclusions,
  magnification,
  emotionalReasoning,
  shouldStatements,
  labeling,
  personalization,
  unknown,
}

/// Single journal entry with AI analysis results.
class JournalEntry {
  final String id;
  final DateTime dateTime;
  final String content;
  final DistortionType? detectedDistortion;
  final String? reframe; // CBT-based reframing suggestion
  final String? plantSuggestion; // e.g. "Snake plant", "Lavender"
  final String? moodLabel;

  const JournalEntry({
    required this.id,
    required this.dateTime,
    required this.content,
    this.detectedDistortion,
    this.reframe,
    this.plantSuggestion,
    this.moodLabel,
  });
}
