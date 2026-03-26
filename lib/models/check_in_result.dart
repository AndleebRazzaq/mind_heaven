/// Result of check-in (text or voice) analysis.
class CheckInResult {
  final String moodLabel;
  final double stressLevel; // 0–1
  final String microIntervention; // Calming suggestion / coping tip

  const CheckInResult({
    required this.moodLabel,
    required this.stressLevel,
    required this.microIntervention,
  });
}
