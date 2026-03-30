import '../../core/network/api_client.dart';
import '../../models/cbt_intervention.dart';

class JournalRemoteDataSource {
  final ApiClient _apiClient;

  JournalRemoteDataSource(this._apiClient);

  Future<CBTIntervention> analyzeJournalText(String text) async {
    final data = await _apiClient.post('/analyze/journal', body: {'text': text});
    final emotionAnalysis = data['emotion_analysis'] as Map<String, dynamic>?;
    final distortionAnalysis = data['distortion_analysis'] as Map<String, dynamic>?;
    final riskAssessment = data['risk_assessment'] as Map<String, dynamic>?;
    final responseLayers = data['response_layers'] as Map<String, dynamic>?;
    return CBTIntervention(
      distortionExplanation: (data['distortion_explanation'] ?? '') as String,
      emotionalAcknowledgment:
          (data['emotional_acknowledgment'] ?? '') as String,
      interventionMode: (data['intervention_mode'] ?? '') as String,
      cbtTechnique: (data['cbt_technique'] ?? '') as String,
      reframeGuidance: (data['reframe_guidance'] ?? '') as String,
      copingExerciseTitle: (data['coping_exercise_title'] ?? '') as String,
      copingExerciseDescription:
          (data['coping_exercise_description'] ?? '') as String,
      plantSuggestion: (data['plant_suggestion'] ?? '') as String,
      plantImageUrl: data['plant_image_url'] as String?,
      plantReferenceUrl: data['plant_reference_url'] as String?,
      suggestBreathing: (data['suggest_breathing'] ?? false) as bool,
      breathingTechnique: data['breathing_technique'] as String?,
      moodLabel:
          (data['mood_label'] as String?) ??
          (emotionAnalysis?['detected_emotion'] as String?),
      emotionConfidence:
          (data['emotion_confidence'] as num?)?.toDouble() ??
          (emotionAnalysis?['confidence'] as num?)?.toDouble(),
      emotionIntensity:
          (data['emotion_intensity'] as num?)?.toDouble() ??
          (emotionAnalysis?['intensity_estimate'] as num?)?.toDouble(),
      stressLevel: (data['stress_level'] as num?)?.toDouble(),
      detectedDistortionLabel:
          (data['detected_distortion_label'] as String?) ??
          (distortionAnalysis?['detected_pattern'] as String?),
      distortionDescription: data['distortion_description'] as String?,
      confidence:
          (data['confidence'] as num?)?.toDouble() ??
          (distortionAnalysis?['confidence'] as num?)?.toDouble(),
      distortionLabelId: (data['distortion_label_id'] as num?)?.toInt(),
      certainty:
          (data['certainty'] as String?) ??
          (distortionAnalysis?['confidence_level'] as String?),
      feedbackType: data['feedback_type'] as String?,
      microInterventionTitle: data['micro_intervention_title'] as String?,
      microInterventionPrompt:
          (data['micro_intervention_prompt'] as String?) ??
          (responseLayers?['regulation_suggestion'] as String?),
      riskScore: (data['risk_score'] as num?)?.toDouble(),
      riskLevel:
          (data['risk_level'] as String?) ??
          (riskAssessment?['risk_level'] as String?),
      safetyOverride:
          (data['safety_override'] as bool?) ??
          (riskAssessment?['escalation_required'] as bool?) ??
          false,
      safetyMessage: data['safety_message'] as String?,
      combinedConfidence:
          (distortionAnalysis?['combined_confidence'] as num?)?.toDouble(),
      confidenceLevel: distortionAnalysis?['confidence_level'] as String?,
    );
  }
}
