/// Full intervention output (Layer 3) for UI, storage, local CBT, and remote API flows.
class CBTIntervention {
  /// Compact remote-API aliases used by the current `/analyze` endpoint.
  final String? insight;
  final String? pattern;
  final String? reframe;
  final String? action;

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

  /// NEW UPGRADED FIELDS
  final String? emotionalState; // e.g., "Decision Anxiety"
  final String?
  emotionalStateSubtitle; // e.g., "You seem mentally overwhelmed..."
  final String? intensityLabel; // Low, Moderate, High, Very High
  final String? emotionContext; // social, performance, health, general
  final bool showBreathing; // Show breathing card if true
  final bool showEmergency; // Show emergency card if true

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
    this.insight,
    this.pattern,
    this.reframe,
    this.action,
    this.distortionExplanation = '',
    this.emotionalAcknowledgment = '',
    this.interventionMode = '',
    this.cbtTechnique = '',
    this.reframeGuidance = '',
    this.copingExerciseTitle = '',
    this.copingExerciseDescription = '',
    this.plantSuggestion = '',
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
    // NEW UPGRADED FIELDS
    this.emotionalState,
    this.emotionalStateSubtitle,
    this.intensityLabel,
    this.emotionContext,
    this.showBreathing = false,
    this.showEmergency = false,
  });
}
