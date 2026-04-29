abstract class AnalyticsReader {
  Future<WeeklyAnalyticsSnapshot> getWeeklyAnalyticsSnapshot({
    AnalyticsRange range = AnalyticsRange.thisWeek,
  });

  Future<double> getAverageStress();

  Future<String?> getTopDistortion();

  Future<ImprovementSummary> getImprovementSummary();

  Future<CBTUsageSummary> getCbtUsageSummary();
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
