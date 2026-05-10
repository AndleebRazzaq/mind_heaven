import '../../core/network/api_client.dart';
import '../../models/cbt_intervention.dart';

class JournalRemoteDataSource {
  final ApiClient _apiClient;

  JournalRemoteDataSource(this._apiClient);

  Future<CBTIntervention> analyzeJournalText(
    String text, {
    double? userReportedIntensity,
  }) async {
    final body = <String, dynamic>{'text': text};
    final data = await _apiClient.post('/analyze', body: body);

    final ai = data['ai_response'] as Map<String, dynamic>? ?? {};
    final emotion = data['emotion'] as Map<String, dynamic>? ?? {};
    final distortion = data['distortion'] as Map<String, dynamic>? ?? {};

    return CBTIntervention(
      insight: ai['insight'],
      pattern: ai['pattern_explanation'] ?? ai['pattern'],
      reframe: ai['reframe'],
      action: ai['action'],
      distortionExplanation: ai['pattern_explanation'] ?? ai['pattern'] ?? '',
      emotionalAcknowledgment: ai['insight'] ?? '',
      interventionMode: 'AI Reframing',
      cbtTechnique: 'Cognitive Reappraisal',
      reframeGuidance: ai['reframe'] ?? '',
      copingExerciseTitle: 'Small Step',
      copingExerciseDescription: ai['action'] ?? '',
      plantSuggestion: ai['plant'] ?? '',
      suggestBreathing: data['show_breathing'] ?? false,
      showBreathing: data['show_breathing'] ?? false,
      showEmergency: data['show_emergency'] ?? false,

      // UPGRADED EMOTIONAL STATE FIELDS
      emotionalState:
          emotion['final_label'] ??
          emotion['label'] ??
          emotion['raw_label'] ??
          'Neutral',
      emotionalStateSubtitle: ai['insight'] ?? '',
      intensityLabel: emotion['intensity_label'] ?? 'Moderate',
      emotionContext: emotion['context'] ?? 'general',

      // Legacy fields
      moodLabel:
          emotion['final_label'] ??
          emotion['label'] ??
          emotion['raw_label'] ??
          'Neutral',
      emotionConfidence: (emotion['confidence'] as num?)?.toDouble() ?? 0.0,
      emotionIntensity: (emotion['intensity'] as num?)?.toDouble() ?? 0.0,
      detectedDistortionLabel: distortion['label'] ?? 'none',
      confidence: (distortion['confidence'] as num?)?.toDouble() ?? 0.0,
      balancedReframeSuggestion: ai['reframe'] ?? '',
      eventSummary: ai['insight'] ?? '',
      distortionLogicLine: ai['pattern_explanation'] ?? ai['pattern'] ?? '',
      behavioralShiftPrompt: ai['action'] ?? '',
    );
  }
}
