/// Full intervention output (Layer 3) for UI.
class CBTIntervention {
  final String? insight;
  final String? pattern;
  final String? reframe;
  final String? action;
  final String? plantSuggestion;

  final String? moodLabel;
  final double? emotionConfidence;
  final double? emotionIntensity;
  final double? stressLevel;

  final String? detectedDistortionLabel;
  final String? distortionDescription;
  final double? confidence;

  final bool suggestBreathing;
  final String? breathingTechnique;
  final String? microInterventionTitle;
  
  final String? plantImageUrl;

  const CBTIntervention({
    this.insight,
    this.pattern,
    this.reframe,
    this.action,
    this.plantSuggestion,
    this.moodLabel,
    this.emotionConfidence,
    this.emotionIntensity,
    this.stressLevel,
    this.detectedDistortionLabel,
    this.distortionDescription,
    this.confidence,
    this.suggestBreathing = false,
    this.breathingTechnique,
    this.microInterventionTitle,
    this.plantImageUrl,
  });
}
