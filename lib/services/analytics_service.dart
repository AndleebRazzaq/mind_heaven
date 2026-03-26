import '../models/journal_entry.dart';
import 'storage_service.dart';

/// Analytics: weekly mood trend, stress average, top distortion, improvement.
class AnalyticsService {
  final StorageService _storage = StorageService();

  Future<List<JournalEntry>> getJournalEntries() => _storage.getJournalEntries();

  double _stressFromMoodLabel(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    if (mood.contains('anxiety')) return 0.75;
    if (mood.contains('sad')) return 0.65;
    if (mood.contains('anger')) return 0.7;
    if (mood.contains('calm')) return 0.2;
    if (mood.contains('hope')) return 0.35;
    if (mood.contains('reflective')) return 0.45;
    return 0.5;
  }

  /// Last 7 days mood labels from journal entries only.
  Future<List<MoodDataPoint>> getWeeklyMoodTrend() async {
    final journal = await getJournalEntries();
    final now = DateTime.now();
    final list = <MoodDataPoint>[];
    for (var i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      double stressSum = 0;
      int count = 0;
      String mood = 'Neutral';
      for (final j in journal) {
        if (j.dateTime.isAfter(dayStart) &&
            j.dateTime.isBefore(dayEnd) &&
            j.moodLabel != null) {
          stressSum += _stressFromMoodLabel(j.moodLabel);
          count++;
          mood = j.moodLabel!;
        }
      }
      final avgStress = count > 0 ? stressSum / count : 0.4;
      list.add(MoodDataPoint(
        date: dayStart,
        moodLabel: mood,
        stressLevel: avgStress,
        count: count,
      ));
    }
    return list;
  }

  /// Average stress over last 7 days (0-1), derived from journal mood labels.
  Future<double> getAverageStress() async {
    final journal = await getJournalEntries();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = journal.where((j) => j.dateTime.isAfter(weekAgo)).toList();
    if (recent.isEmpty) return 0.0;
    final values = recent.map((e) => _stressFromMoodLabel(e.moodLabel));
    return values.reduce((a, b) => a + b) / recent.length;
  }

  /// Most frequent distortion in journal entries (last 30 days).
  Future<String?> getTopDistortion() async {
    final entries = await getJournalEntries();
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final withDistortion = entries
        .where((e) => e.dateTime.isAfter(monthAgo) && e.detectedDistortion != null && e.detectedDistortion != DistortionType.unknown)
        .toList();
    if (withDistortion.isEmpty) return null;
    final counts = <DistortionType, int>{};
    for (final e in withDistortion) {
      counts[e.detectedDistortion!] = (counts[e.detectedDistortion!] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key.name;
  }

  /// Improvement: compare first half vs second half of last 14 days using journal-derived stress.
  Future<ImprovementSummary> getImprovementSummary() async {
    final journal = await getJournalEntries();
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final recent = journal.where((j) => j.dateTime.isAfter(twoWeeksAgo)).toList();
    if (recent.length < 2) {
      return ImprovementSummary(
        stressImproved: false,
        message: 'Keep writing journal entries to see improvement trends.',
      );
    }
    final mid = recent.length ~/ 2;
    final firstHalf = recent.sublist(0, mid);
    final secondHalf = recent.sublist(mid);
    final avgFirst = firstHalf
            .map((e) => _stressFromMoodLabel(e.moodLabel))
            .reduce((a, b) => a + b) /
        firstHalf.length;
    final avgSecond = secondHalf
            .map((e) => _stressFromMoodLabel(e.moodLabel))
            .reduce((a, b) => a + b) /
        secondHalf.length;
    final stressImproved = avgSecond < avgFirst;
    return ImprovementSummary(
      stressImproved: stressImproved,
      message: stressImproved
          ? 'Your average stress has decreased over the last 2 weeks.'
          : 'Keep journaling consistently; small steps matter.',
    );
  }
}

class MoodDataPoint {
  final DateTime date;
  final String moodLabel;
  final double stressLevel;
  final int count;
  MoodDataPoint({
    required this.date,
    required this.moodLabel,
    required this.stressLevel,
    required this.count,
  });
}

class ImprovementSummary {
  final bool stressImproved;
  final String message;
  ImprovementSummary({required this.stressImproved, required this.message});
}
