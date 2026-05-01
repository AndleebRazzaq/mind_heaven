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
    if (userReportedIntensity != null) {
      body['user_reported_intensity'] = userReportedIntensity;
    }
    
    // Calls the updated /analyze endpoint
    final data = await _apiClient.post('/analyze', body: body);
    
    final emotion = data['emotion'] as Map<String, dynamic>?;
    final distortion = data['distortion'] as Map<String, dynamic>?;
    final aiResponse = data['ai_response'] as Map<String, dynamic>?;

    return CBTIntervention(
      insight: aiResponse?['insight'] as String?,
      pattern: aiResponse?['pattern'] as String?,
      reframe: aiResponse?['reframe'] as String?,
      action: aiResponse?['action'] as String?,
      plantSuggestion: aiResponse?['plant'] as String?,
      moodLabel: emotion?['label'] as String?,
      emotionConfidence: (emotion?['confidence'] as num?)?.toDouble(),
      emotionIntensity: (data['intensity'] as num?)?.toDouble(),
      detectedDistortionLabel: distortion?['label'] as String?,
      confidence: (distortion?['confidence'] as num?)?.toDouble(),
      suggestBreathing: (data['show_breathing'] ?? false) as bool,
    );
  }
}
