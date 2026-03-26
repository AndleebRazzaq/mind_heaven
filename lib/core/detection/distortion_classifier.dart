import '../../models/journal_entry.dart';

/// Result of cognitive distortion classification (Layer 1 — Journal text only).
class DistortionResult {
  final DistortionType distortionType;
  final double confidence; // 0-1

  const DistortionResult({
    required this.distortionType,
    required this.confidence,
  });
}

/// Cognitive distortion classifier interface.
/// Replace mock with fine-tuned DistilBERT (1000–1500 samples); output distortion + confidence.
abstract class DistortionClassifier {
  Future<DistortionResult> classify(String text);
}

/// Mock implementation. Replace with real model (API or on-device).
class MockDistortionClassifier implements DistortionClassifier {
  @override
  Future<DistortionResult> classify(String text) async {
    if (text.isEmpty) {
      return const DistortionResult(distortionType: DistortionType.unknown, confidence: 0.0);
    }
    final lower = text.toLowerCase();
    if (lower.contains('always') || lower.contains('never') || lower.contains('everyone')) {
      return const DistortionResult(distortionType: DistortionType.overgeneralization, confidence: 0.87);
    }
    if (lower.contains('should') || lower.contains('must')) {
      return const DistortionResult(distortionType: DistortionType.shouldStatements, confidence: 0.82);
    }
    if (lower.contains('failure') || lower.contains('stupid') || lower.contains('loser')) {
      return const DistortionResult(distortionType: DistortionType.labeling, confidence: 0.85);
    }
    if (lower.contains('my fault') || lower.contains('because of me')) {
      return const DistortionResult(distortionType: DistortionType.personalization, confidence: 0.84);
    }
    if (lower.contains('disaster') || lower.contains('terrible') || lower.contains('awful') || lower.contains('catastroph')) {
      return const DistortionResult(distortionType: DistortionType.magnification, confidence: 0.88);
    }
    if (lower.contains('either') && lower.contains('or') || lower.contains('all or nothing')) {
      return const DistortionResult(distortionType: DistortionType.allOrNothing, confidence: 0.8);
    }
    if (lower.contains('they think') || lower.contains('assuming') || lower.contains('mind reading')) {
      return const DistortionResult(distortionType: DistortionType.jumpingToConclusions, confidence: 0.79);
    }
    return const DistortionResult(distortionType: DistortionType.unknown, confidence: 0.3);
  }
}
