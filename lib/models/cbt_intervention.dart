/// Full intervention output (Layer 3) for UI.
class CBTIntervention {
  final String distortionExplanation;
  final String emotionalAcknowledgment;
  final String interventionMode;
  final String cbtTechnique;
  final String reframeGuidance;
  final String copingExerciseTitle;
  final String copingExerciseDescription;
  final String plantSuggestion;
  final bool suggestBreathing;
  final String? breathingTechnique;
  final String? moodLabel;
  final double? emotionConfidence;
  final double? stressLevel;
  final String? detectedDistortionLabel;
  final double? confidence;

  const CBTIntervention({
    required this.distortionExplanation,
    required this.emotionalAcknowledgment,
    required this.interventionMode,
    required this.cbtTechnique,
    required this.reframeGuidance,
    required this.copingExerciseTitle,
    required this.copingExerciseDescription,
    required this.plantSuggestion,
    this.suggestBreathing = false,
    this.breathingTechnique,
    this.moodLabel,
    this.emotionConfidence,
    this.stressLevel,
    this.detectedDistortionLabel,
    this.confidence,
  });
}
