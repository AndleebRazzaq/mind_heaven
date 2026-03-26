import '../../models/cbt_intervention.dart';
import '../../models/emotion_type.dart';
import '../../models/journal_entry.dart';
import '../cbt_engine/cbt_mapping.dart';
import '../detection/distortion_classifier.dart';
import '../detection/emotion_classifier.dart';
import '../detection/fusion_service.dart';

/// Result of journal pipeline: intervention + raw detection for storage.
class JournalInterventionResult {
  final CBTIntervention intervention;
  final DistortionType distortionType;
  final String emotionLabel;
  JournalInterventionResult({
    required this.intervention,
    required this.distortionType,
    required this.emotionLabel,
  });
}

/// Layer 3: Builds full intervention from detection + CBT engine outputs.
class InterventionBuilder {
  final DistortionClassifier _distortionClassifier;
  final EmotionClassifier _emotionClassifier;
  final FusionService _fusionService;

  InterventionBuilder({
    DistortionClassifier? distortionClassifier,
    EmotionClassifier? emotionClassifier,
    FusionService? fusionService,
  })  : _distortionClassifier = distortionClassifier ?? MockDistortionClassifier(),
        _emotionClassifier = emotionClassifier ?? MockEmotionClassifier(),
        _fusionService = fusionService ?? FusionService();

  /// Journal flow: text → distortion + emotion → CBT engine → full intervention.
  /// Returns intervention and distortion/emotion for storage.
  Future<JournalInterventionResult> buildForJournal(String text) async {
    final distortionResult = await _distortionClassifier.classify(text);
    final emotionResult = await _emotionClassifier.classify(text);
    final highStress = emotionResult.emotion == EmotionType.anxiety ||
        emotionResult.emotion == EmotionType.anger ||
        emotionResult.emotion == EmotionType.sadness;
    final stressLevel = highStress ? 0.65 : 0.4;
    final intervention = CBTMapping.getIntervention(
      distortionResult.distortionType,
      highStress: highStress,
      moodLabel: emotionResult.emotion.label,
      stressLevel: stressLevel,
      confidence: distortionResult.confidence,
    );
    return JournalInterventionResult(
      intervention: intervention,
      distortionType: distortionResult.distortionType,
      emotionLabel: emotionResult.emotion.label,
    );
  }

  /// Check-in flow: text + optional voice stress → fusion → intervention (mood, stress, breathing if high).
  Future<CBTIntervention> buildForCheckIn(String text, {double? voiceStress}) async {
    final fusion = await _fusionService.fuse(text: text, voiceStress: voiceStress);
    final breathing = fusion.isHighStress
        ? '4-7-8 breathing: inhale 4s, hold 7s, exhale 8s. Repeat twice.'
        : null;
    return CBTIntervention(
      distortionExplanation: '',
      emotionalAcknowledgment: fusion.isHighStress
          ? 'Thank you for sharing. Your stress seems elevated right now.'
          : 'Thanks for checking in. Your current state looks relatively stable.',
      interventionMode: fusion.isHighStress
          ? 'Emotional validation'
          : 'Reflective questioning',
      cbtTechnique:
          fusion.isHighStress ? 'Breathing regulation' : 'Self-reflection',
      reframeGuidance: fusion.isHighStress
          ? 'Take a moment. Try the breathing exercise below, then return to your day when you feel a bit calmer.'
          : 'You\'re doing okay. Consider a short journal note to capture what\'s working.',
      copingExerciseTitle: fusion.isHighStress ? 'Breathing' : 'Quick check-in',
      copingExerciseDescription: breathing ?? 'A short journal or walk can help maintain balance.',
      plantSuggestion: fusion.isHighStress
          ? 'Lavender — calming; good when stress is high.'
          : 'Snake plant — low light, air-purifying.',
      suggestBreathing: fusion.isHighStress,
      breathingTechnique: breathing,
      moodLabel: fusion.moodLabel,
      stressLevel: fusion.stressLevel,
    );
  }
}
