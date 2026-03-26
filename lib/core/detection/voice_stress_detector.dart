/// Voice stress detector interface (Layer 1 — Check-In voice only).
/// Replace mock with MFCC + CNN/LSTM pipeline; returns 0-1 stress score.
abstract class VoiceStressDetector {
  /// [audioPathOrBytes]: path to recorded file or raw bytes.
  /// Returns stress level 0.0 (low) to 1.0 (high).
  Future<double> getStressFromAudio(dynamic audioPathOrBytes);
}

/// Mock: no real audio processing. In production, send audio to backend or run on-device model.
class MockVoiceStressDetector implements VoiceStressDetector {
  @override
  Future<double> getStressFromAudio(dynamic audioPathOrBytes) async {
    // Placeholder: return mid-range. Real impl: extract MFCC, run CNN/LSTM.
    return 0.45;
  }
}
