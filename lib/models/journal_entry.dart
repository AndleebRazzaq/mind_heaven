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
  final String? detectedDistortionLabel;
  final String? confidenceLevel;
  final String? reframe; // CBT-based reframing suggestion
  final String? eventSummary;
  final String? coreBelief;
  final String? behavioralShiftPrompt;
  final String? reframeGenerationMode;
  final String? plantSuggestion; // e.g. "Snake plant", "Lavender"
  final String? moodLabel;
  final double? stressBefore;
  final double? stressAfter;
  final List<String> tags;

  const JournalEntry({
    required this.id,
    required this.dateTime,
    required this.content,
    this.detectedDistortion,
    this.detectedDistortionLabel,
    this.confidenceLevel,
    this.reframe,
    this.eventSummary,
    this.coreBelief,
    this.behavioralShiftPrompt,
    this.reframeGenerationMode,
    this.plantSuggestion,
    this.moodLabel,
    this.stressBefore,
    this.stressAfter,
    this.tags = const [],
  });

  JournalEntry copyWith({
    String? id,
    DateTime? dateTime,
    String? content,
    DistortionType? detectedDistortion,
    String? detectedDistortionLabel,
    String? confidenceLevel,
    String? reframe,
    String? eventSummary,
    String? coreBelief,
    String? behavioralShiftPrompt,
    String? reframeGenerationMode,
    String? plantSuggestion,
    String? moodLabel,
    double? stressBefore,
    double? stressAfter,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      content: content ?? this.content,
      detectedDistortion: detectedDistortion ?? this.detectedDistortion,
      detectedDistortionLabel:
          detectedDistortionLabel ?? this.detectedDistortionLabel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      reframe: reframe ?? this.reframe,
      eventSummary: eventSummary ?? this.eventSummary,
      coreBelief: coreBelief ?? this.coreBelief,
      behavioralShiftPrompt:
          behavioralShiftPrompt ?? this.behavioralShiftPrompt,
      reframeGenerationMode:
          reframeGenerationMode ?? this.reframeGenerationMode,
      plantSuggestion: plantSuggestion ?? this.plantSuggestion,
      moodLabel: moodLabel ?? this.moodLabel,
      stressBefore: stressBefore ?? this.stressBefore,
      stressAfter: stressAfter ?? this.stressAfter,
      tags: tags ?? this.tags,
    );
  }
}
