import '../../models/cbt_intervention.dart';
import '../../models/emotion_type.dart';
import '../../models/journal_entry.dart';
import '../cbt_engine/cbt_mapping.dart';
import '../detection/distortion_classifier.dart';
import '../detection/emotion_classifier.dart';

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

  InterventionBuilder({
    DistortionClassifier? distortionClassifier,
    EmotionClassifier? emotionClassifier,
  })  : _distortionClassifier = distortionClassifier ?? MockDistortionClassifier(),
        _emotionClassifier = emotionClassifier ?? MockEmotionClassifier();

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

}
