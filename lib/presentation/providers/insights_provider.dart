import 'package:riverpod/riverpod.dart';

import '../../app/app_providers.dart';
import '../../services/analytics_models.dart';

const _unset = Object();

  bool isLoading = false;
  String? error;
  List<MoodDataPoint> weeklyTrend = [];
  double? averageStress;
  String? topDistortion;
  String? topEmotionWeekly;
  String? topPatternWeekly;
  String? aiInsightSummary;
  String? moodInsight;
  Map<String, double> emotionPercentages = {};
  int topPatternCount = 0;
  Map<String, int> allPatternCounts = {};
  String? growthInsight;
  String? triggerInsight;
  AnalyticsRange range = AnalyticsRange.thisWeek;
  ImprovementSummary? improvement;
  CBTUsageSummary? cbtUsageSummary;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final weeklySnapshot =
          await _analyticsService.getWeeklyAnalyticsSnapshot(range: range);
      weeklyTrend = weeklySnapshot.moodTrend;
      topEmotionWeekly = weeklySnapshot.topEmotion;
      topPatternWeekly = weeklySnapshot.topPattern;
      aiInsightSummary = weeklySnapshot.aiSummary;
      moodInsight = weeklySnapshot.moodInsight;
      emotionPercentages = weeklySnapshot.emotionPercentages;
      topPatternCount = weeklySnapshot.topPatternCount;
      allPatternCounts = weeklySnapshot.allPatternCounts;
      growthInsight = weeklySnapshot.growthInsight;
      triggerInsight = weeklySnapshot.triggerInsight;
      averageStress = await _analyticsService.getAverageStress();
      topDistortion = await _analyticsService.getTopDistortion();
      improvement = await _analyticsService.getImprovementSummary();
      cbtUsageSummary = await _analyticsService.getCbtUsageSummary();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRange(AnalyticsRange newRange) async {
    if (range == newRange) return;
    range = newRange;
    await load();
  }
}
