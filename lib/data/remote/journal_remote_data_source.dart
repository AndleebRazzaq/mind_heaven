import '../../core/network/api_client.dart';
import '../../models/cbt_intervention.dart';

class JournalRemoteDataSource {
  final ApiClient _apiClient;

  JournalRemoteDataSource(this._apiClient);

  Future<CBTIntervention> analyzeJournalText(String text) async {
    final data = await _apiClient.post('/analyze/journal', body: {'text': text});
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
      suggestBreathing: (data['suggest_breathing'] ?? false) as bool,
      breathingTechnique: data['breathing_technique'] as String?,
      moodLabel: data['mood_label'] as String?,
      emotionConfidence: (data['emotion_confidence'] as num?)?.toDouble(),
      stressLevel: (data['stress_level'] as num?)?.toDouble(),
      detectedDistortionLabel: data['detected_distortion_label'] as String?,
      confidence: (data['confidence'] as num?)?.toDouble(),
    );
  }
}
