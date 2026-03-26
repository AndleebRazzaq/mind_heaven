/// Represents a single check-in or mood record for analytics.
class MoodEntry {
  final String id;
  final DateTime dateTime;
  final String moodLabel; // e.g. anxious, calm, stressed, happy
  final double stressLevel; // 0–1 or 1–10 scale
  final String? inputText;
  final bool fromVoice;

  const MoodEntry({
    required this.id,
    required this.dateTime,
    required this.moodLabel,
    required this.stressLevel,
    this.inputText,
    this.fromVoice = false,
  });
}
