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
  final String? coachingTone;
  final double? emotionIntensity;
  final String? intensityBand;
  final String? distortionInsightLine;
  final String? emotionalSupportMessage;
  final String? microInterventionTitle;
  final String? microInterventionPrompt;
  final double? riskScore;
  final String? riskLevel;
  final bool safetyOverride;
  final String? safetyMessage;
  final double? combinedConfidence;
  final String? confidenceLevel;

  /// Layered API copy: validation / pattern prompts (optional for local fallback).
  final String? responseValidation;
  final String? responsePatternAwareness;
  final List<String> cognitivePrompts;
  final String? balancedReframeSuggestion;
  final String? eventSummary;
  final List<String> coreBeliefs;
  final String? distortionLogicLine;
  final String? balancedAlternative;
  final String? behavioralShiftPrompt;
  final String? reframeGenerationMode;
  final List<String> reframeValidationErrors;
  final String? reframeFallbackReason;
  final String? reframePolicyVersion;

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
    this.coachingTone,
    this.emotionIntensity,
    this.intensityBand,
    this.distortionInsightLine,
    this.emotionalSupportMessage,
    this.microInterventionTitle,
    this.microInterventionPrompt,
    this.riskScore,
    this.riskLevel,
    this.safetyOverride = false,
    this.safetyMessage,
    this.combinedConfidence,
    this.confidenceLevel,
    this.responseValidation,
    this.responsePatternAwareness,
    this.cognitivePrompts = const [],
    this.balancedReframeSuggestion,
    this.eventSummary,
    this.coreBeliefs = const [],
    this.distortionLogicLine,
    this.balancedAlternative,
    this.behavioralShiftPrompt,
    this.reframeGenerationMode,
    this.reframeValidationErrors = const [],
    this.reframeFallbackReason,
    this.reframePolicyVersion,
  });
}
