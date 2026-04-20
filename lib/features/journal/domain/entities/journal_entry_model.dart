import '../../../../models/journal_entry.dart';

class JournalEntryModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final String? emotion;
  final String? distortion;
  final String? reframe;
  final List<String> tags;

  const JournalEntryModel({
    required this.id,
    required this.content,
    required this.createdAt,
    this.emotion,
    this.distortion,
    this.reframe,
    this.tags = const [],
  });

  factory JournalEntryModel.fromLegacy(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      content: entry.content,
      createdAt: entry.dateTime,
      emotion: entry.moodLabel,
      distortion: entry.detectedDistortionLabel,
      reframe: entry.reframe,
      tags: entry.tags,
    );
  }
}
