import '../models/journal_entry.dart';
import 'auth_service.dart';
import 'firestore_journal_service.dart';
import 'storage_service.dart';

/// Analytics: weekly mood trend, stress average, top distortion, improvement.
class AnalyticsService implements AnalyticsReader {
  final StorageService _storage;
  final AuthService _authService;
  final FirestoreJournalService _cloudService;

  AnalyticsService({
    StorageService? storage,
    AuthService? authService,
    FirestoreJournalService? cloudService,
  })  : _storage = storage ?? StorageService(),
        _authService = authService ?? AuthService(),
        _cloudService = cloudService ?? FirestoreJournalService();

  Future<List<JournalEntry>> getJournalEntries() async {
    final local = await _storage.getJournalEntries();
    final user = await _authService.getCurrentUser();
    if (user == null) return local;
    final cloud = await _cloudService.getEntries(uid: user.uid);
    if (cloud.isEmpty) return local;
    return cloud;
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

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
      list.add(
        MoodDataPoint(
          date: dayStart,
          moodLabel: mood,
          stressLevel: avgStress,
          count: count,
        ),
      );
    }
    return list;
  }

  /// Average stress over last 7 days (0-1), derived from journal mood labels.
  @override
  Future<double> getAverageStress() async {
    final journal = await getJournalEntries();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = journal.where((j) => j.dateTime.isAfter(weekAgo)).toList();
    if (recent.isEmpty) return 0.0;
    final values = recent.map((e) => _stressFromMoodLabel(e.moodLabel));
    return values.reduce((a, b) => a + b) / recent.length;
  }

  /// Most frequent distortion in journal entries (last 30 days).
  @override
  Future<String?> getTopDistortion() async {
    final entries = await getJournalEntries();
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final withDistortion = entries
        .where(
          (e) =>
              e.dateTime.isAfter(monthAgo) &&
              e.detectedDistortion != null &&
              e.detectedDistortion != DistortionType.unknown,
        )
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
  @override
  Future<ImprovementSummary> getImprovementSummary() async {
    final journal = await getJournalEntries();
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final recent = journal
        .where((j) => j.dateTime.isAfter(twoWeeksAgo))
        .toList();
    if (recent.length < 2) {
      return ImprovementSummary(
        stressImproved: false,
        message: 'Keep writing journal entries to see improvement trends.',
      );
    }
    final mid = recent.length ~/ 2;
    final firstHalf = recent.sublist(0, mid);
    final secondHalf = recent.sublist(mid);
    final avgFirst =
        firstHalf
            .map((e) => _stressFromMoodLabel(e.moodLabel))
            .reduce((a, b) => a + b) /
        firstHalf.length;
    final avgSecond =
        secondHalf
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

  Future<CBTUsageSummary> getCbtUsageSummary() async {
    final entries = await getJournalEntries();
    if (entries.isEmpty) {
      return const CBTUsageSummary(
        totalEntries: 0,
        reframeCompletionRate: 0,
        behaviorPromptRate: 0,
        structuredReframeRate: 0,
      );
    }
    var withReframe = 0;
    var withBehaviorPrompt = 0;
    var structured = 0;
    final confidenceCounts = <String, int>{};
    final generationModeCounts = <String, int>{};
    final distortionCounts = <String, int>{};

    double stressBeforeSum = 0;
    int stressBeforeCount = 0;
    double stressAfterSum = 0;
    int stressAfterCount = 0;
    final emotionCounts = <String, int>{};

    for (final entry in entries) {
      if (_hasText(entry.reframe)) withReframe++;
      if (_hasText(entry.behavioralShiftPrompt)) withBehaviorPrompt++;
      if ((entry.reframeGenerationMode ?? '').contains('template')) structured++;
      final confidence = (entry.confidenceLevel ?? 'unknown').toLowerCase();
      confidenceCounts[confidence] = (confidenceCounts[confidence] ?? 0) + 1;
      final mode = (entry.reframeGenerationMode ?? 'unknown').toLowerCase();
      generationModeCounts[mode] = (generationModeCounts[mode] ?? 0) + 1;
      final label = (entry.detectedDistortionLabel ?? 'unknown').toLowerCase();
      distortionCounts[label] = (distortionCounts[label] ?? 0) + 1;
      final mood = (entry.moodLabel ?? 'unknown').toLowerCase();
      emotionCounts[mood] = (emotionCounts[mood] ?? 0) + 1;
      if (entry.stressBefore != null) {
        stressBeforeSum += entry.stressBefore!;
        stressBeforeCount++;
      }
      if (entry.stressAfter != null) {
        stressAfterSum += entry.stressAfter!;
        stressAfterCount++;
      }
    }

    return CBTUsageSummary(
      totalEntries: entries.length,
      reframeCompletionRate: withReframe / entries.length,
      behaviorPromptRate: withBehaviorPrompt / entries.length,
      structuredReframeRate: structured / entries.length,
      confidenceBandCounts: confidenceCounts,
      generationModeCounts: generationModeCounts,
      distortionCounts: distortionCounts,
      topEmotion: _topKey(emotionCounts),
      averageStressBefore:
          stressBeforeCount == 0 ? null : (stressBeforeSum / stressBeforeCount),
      averageStressAfter:
          stressAfterCount == 0 ? null : (stressAfterSum / stressAfterCount),
    );
  }

  String? _topKey(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _normalizedLabel(String raw) {
    final cleaned = raw.trim().toLowerCase();
    if (cleaned.isEmpty || cleaned == 'unknown') return 'Unknown';
    return cleaned
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _startOfWeek(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  Future<WeeklyAnalyticsSnapshot> getWeeklyAnalyticsSnapshot({
    AnalyticsRange range = AnalyticsRange.thisWeek,
  }) async {
    final entries = await getJournalEntries();
    final now = DateTime.now();
    late final DateTime currentWeekStart;
    late final DateTime currentWeekEnd;
    late final DateTime previousWeekStart;
    late final DateTime previousWeekEnd;
    if (range == AnalyticsRange.last7Days) {
      currentWeekEnd = _startOfDay(now).add(const Duration(days: 1));
      currentWeekStart = currentWeekEnd.subtract(const Duration(days: 7));
      previousWeekEnd = currentWeekStart;
      previousWeekStart = previousWeekEnd.subtract(const Duration(days: 7));
    } else {
      currentWeekStart = _startOfWeek(now);
      previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
      currentWeekEnd = currentWeekStart.add(const Duration(days: 7));
      previousWeekEnd = currentWeekStart;
    }

    final thisWeek = entries
        .where((e) =>
            !e.dateTime.isBefore(currentWeekStart) &&
            e.dateTime.isBefore(currentWeekEnd))
        .toList();
    final lastWeek = entries
        .where((e) =>
            !e.dateTime.isBefore(previousWeekStart) &&
            e.dateTime.isBefore(previousWeekEnd))
        .toList();

    final moodTrend = <MoodDataPoint>[];
    for (var i = 0; i < 7; i++) {
      final dayStart = _startOfDay(currentWeekStart.add(Duration(days: i)));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final sameDay = thisWeek
          .where((e) => !e.dateTime.isBefore(dayStart) && e.dateTime.isBefore(dayEnd))
          .toList();
      if (sameDay.isEmpty) {
        moodTrend.add(
          MoodDataPoint(
            date: dayStart,
            moodLabel: 'No entry',
            stressLevel: 0.5,
            count: 0,
          ),
        );
        continue;
      }
      final stressValues = sameDay
          .map((e) => e.stressAfter ?? e.stressBefore ?? (_stressFromMoodLabel(e.moodLabel) * 10))
          .toList();
      final avgStress = stressValues.reduce((a, b) => a + b) / stressValues.length;
      final mood = sameDay.last.moodLabel ?? 'Unknown';
      moodTrend.add(
        MoodDataPoint(
          date: dayStart,
          moodLabel: mood,
          stressLevel: (avgStress / 10).clamp(0, 1),
          count: sameDay.length,
        ),
      );
    }

    final emotionCounts = <String, int>{};
    for (final entry in thisWeek) {
      final key = _normalizedLabel(entry.moodLabel ?? 'Unknown');
      emotionCounts[key] = (emotionCounts[key] ?? 0) + 1;
    }
    final topEmotion = emotionCounts.isEmpty
        ? null
        : emotionCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final distortionCounts = <String, int>{};
    for (final entry in thisWeek) {
      final label = entry.detectedDistortionLabel ??
          (entry.detectedDistortion?.name.replaceAll('_', ' ') ?? 'Unknown');
      final key = _normalizedLabel(label);
      if (key == 'Unknown') continue;
      distortionCounts[key] = (distortionCounts[key] ?? 0) + 1;
    }
    final topPattern = distortionCounts.isEmpty
        ? null
        : distortionCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final topPatternCount = topPattern == null ? 0 : (distortionCounts[topPattern] ?? 0);

    final totalEmotionCount = emotionCounts.values.fold<int>(0, (a, b) => a + b);
    final emotionPercentages = <String, double>{};
    if (totalEmotionCount > 0) {
      for (final e in emotionCounts.entries) {
        emotionPercentages[e.key] = (e.value / totalEmotionCount) * 100;
      }
    }

    double? weekMoodScore(List<JournalEntry> list) {
      if (list.isEmpty) return null;
      final scores = list
          .map((e) => e.stressAfter ?? e.stressBefore ?? (_stressFromMoodLabel(e.moodLabel) * 10))
          .map((stress) => (11 - stress).clamp(1, 10) / 2)
          .toList();
      return scores.reduce((a, b) => a + b) / scores.length;
    }

    final currentMood = weekMoodScore(thisWeek);
    final previousMood = weekMoodScore(lastWeek);
    String summary;
    if (currentMood == null) {
      summary = 'Add a few reflections this week to unlock your personalized insight summary.';
    } else if (previousMood == null) {
      summary =
          'You are building momentum. Keep journaling to compare your progress week to week.';
    } else {
      final deltaPct = (((currentMood - previousMood) / previousMood) * 100);
      if (deltaPct >= 4) {
        summary =
            'Your mood improved ${deltaPct.toStringAsFixed(0)}% compared to last week. You are showing more balanced thinking.';
      } else if (deltaPct <= -4) {
        summary =
            'This week looks heavier than last week. Try short, consistent reflections and gentle regulation resets.';
      } else {
        summary =
            'Your mood remained steady compared to last week. Consistency is helping you build emotional awareness.';
      }
    }

    final streakDays = thisWeek.map((e) => _startOfDay(e.dateTime)).toSet().length;
    final thisWeekTags = <String, int>{};
    for (final entry in thisWeek) {
      final tags = entry.tags.isNotEmpty ? entry.tags : _extractTagsFromText(entry.content);
      for (final t in tags) {
        final key = t.toLowerCase();
        thisWeekTags[key] = (thisWeekTags[key] ?? 0) + 1;
      }
    }
    String? triggerInsight;
    if (thisWeekTags.isNotEmpty) {
      final topTag = thisWeekTags.entries.reduce((a, b) => a.value >= b.value ? a : b);
      triggerInsight = '#${topTag.key} appears most often in your recent reflections.';
      if (thisWeekTags.containsKey('exam') || thisWeekTags.containsKey('work')) {
        final examCount = thisWeekTags['exam'] ?? 0;
        final workCount = thisWeekTags['work'] ?? 0;
        final total = thisWeekTags.values.fold<int>(0, (a, b) => a + b);
        if (total > 0 && (examCount > 0 || workCount > 0)) {
          final examPct = ((examCount / total) * 100).round();
          final workPct = ((workCount / total) * 100).round();
          triggerInsight = 'Common triggers this week: exam $examPct%, work $workPct%.';
        }
      }
    }

    final moodDelta = previousMood == null || currentMood == null
        ? null
        : (((currentMood - previousMood) / previousMood) * 100);
    String moodInsight;
    if (moodDelta == null) {
      moodInsight = 'Your mood trend is building. Keep going.';
    } else if (moodDelta >= 3) {
      moodInsight = 'Your average mood increased slightly this week. Keep going.';
    } else if (moodDelta <= -3) {
      moodInsight = 'This week felt heavier. Gentle consistency can help.';
    } else {
      moodInsight = 'Your mood stayed stable this week. Consistency is helping.';
    }

    final growthInsight = streakDays >= 3
        ? 'You are journaling more consistently than last week. That is real progress.'
        : 'Small consistent check-ins will strengthen your progress over time.';

    return WeeklyAnalyticsSnapshot(
      moodTrend: moodTrend,
      topEmotion: topEmotion,
      topPattern: topPattern,
      aiSummary: summary,
      moodInsight: moodInsight,
      emotionPercentages: emotionPercentages,
      topPatternCount: topPatternCount,
      allPatternCounts: distortionCounts,
      growthInsight: growthInsight,
      triggerInsight: triggerInsight,
    );
  }

  List<String> _extractTagsFromText(String text) {
    final matches = RegExp(r'#([a-zA-Z][a-zA-Z0-9_-]*)').allMatches(text);
    final set = <String>{};
    for (final m in matches) {
      final tag = (m.group(1) ?? '').trim().toLowerCase();
      if (tag.isNotEmpty) set.add(tag);
    }
    return set.toList();
  }
}

  @override
  Future<CBTUsageSummary> getCbtUsageSummary() async {
    final entries = await getJournalEntries();
    if (entries.isEmpty) {
      return const CBTUsageSummary(
        totalEntries: 0,
        reframeCompletionRate: 0,
        behaviorPromptRate: 0,
        structuredReframeRate: 0,
      );
    }
    var withReframe = 0;
    var withBehaviorPrompt = 0;
    var structured = 0;
    final confidenceCounts = <String, int>{};
    final generationModeCounts = <String, int>{};
    final distortionCounts = <String, int>{};

    double stressBeforeSum = 0;
    int stressBeforeCount = 0;
    double stressAfterSum = 0;
    int stressAfterCount = 0;
    final emotionCounts = <String, int>{};

    for (final entry in entries) {
      if (_hasText(entry.reframe)) {
        withReframe++;
      }
      if (_hasText(entry.behavioralShiftPrompt)) {
        withBehaviorPrompt++;
      }
      if ((entry.reframeGenerationMode ?? '').contains('template')) {
        structured++;
      }
      final confidence = (entry.confidenceLevel ?? 'unknown').toLowerCase();
      confidenceCounts[confidence] = (confidenceCounts[confidence] ?? 0) + 1;
      final mode = (entry.reframeGenerationMode ?? 'unknown').toLowerCase();
      generationModeCounts[mode] = (generationModeCounts[mode] ?? 0) + 1;
      final label = (entry.detectedDistortionLabel ?? 'unknown').toLowerCase();
      distortionCounts[label] = (distortionCounts[label] ?? 0) + 1;
      final mood = (entry.moodLabel ?? 'unknown').toLowerCase();
      emotionCounts[mood] = (emotionCounts[mood] ?? 0) + 1;
      if (entry.stressBefore != null) {
        stressBeforeSum += entry.stressBefore!;
        stressBeforeCount++;
      }
      if (entry.stressAfter != null) {
        stressAfterSum += entry.stressAfter!;
        stressAfterCount++;
      }
    }

    return CBTUsageSummary(
      totalEntries: entries.length,
      reframeCompletionRate: withReframe / entries.length,
      behaviorPromptRate: withBehaviorPrompt / entries.length,
      structuredReframeRate: structured / entries.length,
      confidenceBandCounts: confidenceCounts,
      generationModeCounts: generationModeCounts,
      distortionCounts: distortionCounts,
      topEmotion: _topKey(emotionCounts),
      averageStressBefore: stressBeforeCount == 0
          ? null
          : (stressBeforeSum / stressBeforeCount),
      averageStressAfter: stressAfterCount == 0
          ? null
          : (stressAfterSum / stressAfterCount),
    );
  }

  String? _topKey(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _normalizedLabel(String raw) {
    final cleaned = raw.trim().toLowerCase();
    if (cleaned.isEmpty || cleaned == 'unknown') return 'Unknown';
    return cleaned
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _startOfWeek(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  @override
  Future<WeeklyAnalyticsSnapshot> getWeeklyAnalyticsSnapshot({
    AnalyticsRange range = AnalyticsRange.thisWeek,
  }) async {
    final entries = await getJournalEntries();
    final now = DateTime.now();
    late final DateTime currentWeekStart;
    late final DateTime currentWeekEnd;
    late final DateTime previousWeekStart;
    late final DateTime previousWeekEnd;
    if (range == AnalyticsRange.last7Days) {
      currentWeekEnd = _startOfDay(now).add(const Duration(days: 1));
      currentWeekStart = currentWeekEnd.subtract(const Duration(days: 7));
      previousWeekEnd = currentWeekStart;
      previousWeekStart = previousWeekEnd.subtract(const Duration(days: 7));
    } else {
      currentWeekStart = _startOfWeek(now);
      previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
      currentWeekEnd = currentWeekStart.add(const Duration(days: 7));
      previousWeekEnd = currentWeekStart;
    }

    final thisWeek = entries
        .where(
          (e) =>
              !e.dateTime.isBefore(currentWeekStart) &&
              e.dateTime.isBefore(currentWeekEnd),
        )
        .toList();
    final lastWeek = entries
        .where(
          (e) =>
              !e.dateTime.isBefore(previousWeekStart) &&
              e.dateTime.isBefore(previousWeekEnd),
        )
        .toList();

    final moodTrend = <MoodDataPoint>[];
    for (var i = 0; i < 7; i++) {
      final dayStart = _startOfDay(currentWeekStart.add(Duration(days: i)));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final sameDay = thisWeek
          .where(
            (e) =>
                !e.dateTime.isBefore(dayStart) && e.dateTime.isBefore(dayEnd),
          )
          .toList();
      if (sameDay.isEmpty) {
        moodTrend.add(
          MoodDataPoint(
            date: dayStart,
            moodLabel: 'No entry',
            stressLevel: 0.5,
            count: 0,
          ),
        );
        continue;
      }
      final stressValues = sameDay
          .map(
            (e) =>
                e.stressAfter ??
                e.stressBefore ??
                (_stressFromMoodLabel(e.moodLabel) * 10),
          )
          .toList();
      final avgStress =
          stressValues.reduce((a, b) => a + b) / stressValues.length;
      final mood = sameDay.last.moodLabel ?? 'Unknown';
      moodTrend.add(
        MoodDataPoint(
          date: dayStart,
          moodLabel: mood,
          stressLevel: (avgStress / 10).clamp(0, 1),
          count: sameDay.length,
        ),
      );
    }

    final emotionCounts = <String, int>{};
    for (final entry in thisWeek) {
      final key = _normalizedLabel(entry.moodLabel ?? 'Unknown');
      emotionCounts[key] = (emotionCounts[key] ?? 0) + 1;
    }
    final topEmotion = emotionCounts.isEmpty
        ? null
        : emotionCounts.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;

    final distortionCounts = <String, int>{};
    for (final entry in thisWeek) {
      final label =
          entry.detectedDistortionLabel ??
          (entry.detectedDistortion?.name.replaceAll('_', ' ') ?? 'Unknown');
      final key = _normalizedLabel(label);
      if (key == 'Unknown') continue;
      distortionCounts[key] = (distortionCounts[key] ?? 0) + 1;
    }
    final topPattern = distortionCounts.isEmpty
        ? null
        : distortionCounts.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
    final topPatternCount = topPattern == null
        ? 0
        : (distortionCounts[topPattern] ?? 0);

    final totalEmotionCount = emotionCounts.values.fold<int>(
      0,
      (a, b) => a + b,
    );
    final emotionPercentages = <String, double>{};
    if (totalEmotionCount > 0) {
      for (final e in emotionCounts.entries) {
        emotionPercentages[e.key] = (e.value / totalEmotionCount) * 100;
      }
    }

    double? weekMoodScore(List<JournalEntry> list) {
      if (list.isEmpty) return null;
      final scores = list
          .map(
            (e) =>
                e.stressAfter ??
                e.stressBefore ??
                (_stressFromMoodLabel(e.moodLabel) * 10),
          )
          .map((stress) => (11 - stress).clamp(1, 10) / 2)
          .toList();
      return scores.reduce((a, b) => a + b) / scores.length;
    }

    final currentMood = weekMoodScore(thisWeek);
    final previousMood = weekMoodScore(lastWeek);
    String summary;
    if (currentMood == null) {
      summary =
          'Add a few reflections this week to unlock your personalized insight summary.';
    } else if (previousMood == null) {
      summary =
          'You are building momentum. Keep journaling to compare your progress week to week.';
    } else {
      final deltaPct = (((currentMood - previousMood) / previousMood) * 100);
      if (deltaPct >= 4) {
        summary =
            'Your mood improved ${deltaPct.toStringAsFixed(0)}% compared to last week. You are showing more balanced thinking.';
      } else if (deltaPct <= -4) {
        summary =
            'This week looks heavier than last week. Try short, consistent reflections and gentle regulation resets.';
      } else {
        summary =
            'Your mood remained steady compared to last week. Consistency is helping you build emotional awareness.';
      }
    }

    final streakDays = thisWeek
        .map((e) => _startOfDay(e.dateTime))
        .toSet()
        .length;
    final thisWeekTags = <String, int>{};
    for (final entry in thisWeek) {
      final tags = entry.tags.isNotEmpty
          ? entry.tags
          : _extractTagsFromText(entry.content);
      for (final t in tags) {
        final key = t.toLowerCase();
        thisWeekTags[key] = (thisWeekTags[key] ?? 0) + 1;
      }
    }
    String? triggerInsight;
    if (thisWeekTags.isNotEmpty) {
      final topTag = thisWeekTags.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      triggerInsight =
          '#${topTag.key} appears most often in your recent reflections.';
      if (thisWeekTags.containsKey('exam') ||
          thisWeekTags.containsKey('work')) {
        final examCount = thisWeekTags['exam'] ?? 0;
        final workCount = thisWeekTags['work'] ?? 0;
        final total = thisWeekTags.values.fold<int>(0, (a, b) => a + b);
        if (total > 0 && (examCount > 0 || workCount > 0)) {
          final examPct = ((examCount / total) * 100).round();
          final workPct = ((workCount / total) * 100).round();
          triggerInsight =
              'Common triggers this week: exam $examPct%, work $workPct%.';
        }
      }
    }

    final moodDelta = previousMood == null || currentMood == null
        ? null
        : (((currentMood - previousMood) / previousMood) * 100);
    String moodInsight;
    if (moodDelta == null) {
      moodInsight = 'Your mood trend is building. Keep going.';
    } else if (moodDelta >= 3) {
      moodInsight =
          'Your average mood increased slightly this week. Keep going.';
    } else if (moodDelta <= -3) {
      moodInsight = 'This week felt heavier. Gentle consistency can help.';
    } else {
      moodInsight =
          'Your mood stayed stable this week. Consistency is helping.';
    }

    final growthInsight = streakDays >= 3
        ? 'You are journaling more consistently than last week. That is real progress.'
        : 'Small consistent check-ins will strengthen your progress over time.';

    return WeeklyAnalyticsSnapshot(
      moodTrend: moodTrend,
      topEmotion: topEmotion,
      topPattern: topPattern,
      aiSummary: summary,
      moodInsight: moodInsight,
      emotionPercentages: emotionPercentages,
      topPatternCount: topPatternCount,
      allPatternCounts: distortionCounts,
      growthInsight: growthInsight,
      triggerInsight: triggerInsight,
    );
  }

  List<String> _extractTagsFromText(String text) {
    final matches = RegExp(r'#([a-zA-Z][a-zA-Z0-9_-]*)').allMatches(text);
    final set = <String>{};
    for (final m in matches) {
      final tag = (m.group(1) ?? '').trim().toLowerCase();
      if (tag.isNotEmpty) set.add(tag);
    }
    return set.toList();
  }
}

class CBTUsageSummary {
  final int totalEntries;
  final double reframeCompletionRate;
  final double behaviorPromptRate;
  final double structuredReframeRate;
  final Map<String, int> confidenceBandCounts;
  final Map<String, int> generationModeCounts;
  final Map<String, int> distortionCounts;
  final String? topEmotion;
  final double? averageStressBefore;
  final double? averageStressAfter;

  const CBTUsageSummary({
    required this.totalEntries,
    required this.reframeCompletionRate,
    required this.behaviorPromptRate,
    required this.structuredReframeRate,
    this.confidenceBandCounts = const {},
    this.generationModeCounts = const {},
    this.distortionCounts = const {},
    this.topEmotion,
    this.averageStressBefore,
    this.averageStressAfter,
  });
}

class WeeklyAnalyticsSnapshot {
  final List<MoodDataPoint> moodTrend;
  final String? topEmotion;
  final String? topPattern;
  final String aiSummary;
  final String moodInsight;
  final Map<String, double> emotionPercentages;
  final int topPatternCount;
  final Map<String, int> allPatternCounts;
  final String growthInsight;
  final String? triggerInsight;

  const WeeklyAnalyticsSnapshot({
    required this.moodTrend,
    required this.topEmotion,
    required this.topPattern,
    required this.aiSummary,
    required this.moodInsight,
    required this.emotionPercentages,
    required this.topPatternCount,
    required this.allPatternCounts,
    required this.growthInsight,
    required this.triggerInsight,
  });
}

enum AnalyticsRange { thisWeek, last7Days }
