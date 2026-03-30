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
  final String? plantImageUrl;
  final String? plantReferenceUrl;
  final bool suggestBreathing;
  final String? breathingTechnique;
  final String? moodLabel;
  final double? emotionConfidence;
  final double? stressLevel;
  final String? detectedDistortionLabel;
  final String? distortionDescription;
  final double? confidence;
  /// Numeric class id from the distortion classifier when using the remote API.
  final int? distortionLabelId;
  final String? certainty;
  final String? feedbackType;
  final double? emotionIntensity;
  final String? microInterventionTitle;
  final String? microInterventionPrompt;
  final double? riskScore;
  final String? riskLevel;
  final bool safetyOverride;
  final String? safetyMessage;
  final double? combinedConfidence;
  final String? confidenceLevel;

  const CBTIntervention({
    required this.distortionExplanation,
    required this.emotionalAcknowledgment,
    required this.interventionMode,
    required this.cbtTechnique,
    required this.reframeGuidance,
    required this.copingExerciseTitle,
    required this.copingExerciseDescription,
    required this.plantSuggestion,
    this.plantImageUrl,
    this.plantReferenceUrl,
    this.suggestBreathing = false,
    this.breathingTechnique,
    this.moodLabel,
    this.emotionConfidence,
    this.stressLevel,
    this.detectedDistortionLabel,
    this.distortionDescription,
    this.confidence,
    this.distortionLabelId,
    this.certainty,
    this.feedbackType,
    this.emotionIntensity,
    this.microInterventionTitle,
    this.microInterventionPrompt,
    this.riskScore,
    this.riskLevel,
    this.safetyOverride = false,
    this.safetyMessage,
    this.combinedConfidence,
    this.confidenceLevel,
  });
}
