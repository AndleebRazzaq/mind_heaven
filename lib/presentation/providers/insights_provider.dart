import 'package:riverpod/riverpod.dart';

import '../../app/app_providers.dart';
import '../../services/analytics_models.dart';

const _unset = Object();

final insightsControllerProvider =
    NotifierProvider<InsightsController, InsightsState>(InsightsController.new);

class InsightsState {
  final bool isLoading;
  final String? error;
  final List<MoodDataPoint> weeklyTrend;
  final double? averageStress;
  final String? topDistortion;
  final String? topEmotionWeekly;
  final String? topPatternWeekly;
  final String? aiInsightSummary;
  final String? moodInsight;
  final Map<String, double> emotionPercentages;
  final int topPatternCount;
  final Map<String, int> allPatternCounts;
  final String? growthInsight;
  final String? triggerInsight;
  final AnalyticsRange range;
  final ImprovementSummary? improvement;
  final CBTUsageSummary? cbtUsageSummary;

  const InsightsState({
    this.isLoading = false,
    this.error,
    this.weeklyTrend = const [],
    this.averageStress,
    this.topDistortion,
    this.topEmotionWeekly,
    this.topPatternWeekly,
    this.aiInsightSummary,
    this.moodInsight,
    this.emotionPercentages = const {},
    this.topPatternCount = 0,
    this.allPatternCounts = const {},
    this.growthInsight,
    this.triggerInsight,
    this.range = AnalyticsRange.thisWeek,
    this.improvement,
    this.cbtUsageSummary,
  });

  InsightsState copyWith({
    bool? isLoading,
    Object? error = _unset,
    List<MoodDataPoint>? weeklyTrend,
    Object? averageStress = _unset,
    Object? topDistortion = _unset,
    Object? topEmotionWeekly = _unset,
    Object? topPatternWeekly = _unset,
    Object? aiInsightSummary = _unset,
    Object? moodInsight = _unset,
    Map<String, double>? emotionPercentages,
    int? topPatternCount,
    Map<String, int>? allPatternCounts,
    Object? growthInsight = _unset,
    Object? triggerInsight = _unset,
    AnalyticsRange? range,
    Object? improvement = _unset,
    Object? cbtUsageSummary = _unset,
  }) {
    return InsightsState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      averageStress: identical(averageStress, _unset)
          ? this.averageStress
          : averageStress as double?,
      topDistortion: identical(topDistortion, _unset)
          ? this.topDistortion
          : topDistortion as String?,
      topEmotionWeekly: identical(topEmotionWeekly, _unset)
          ? this.topEmotionWeekly
          : topEmotionWeekly as String?,
      topPatternWeekly: identical(topPatternWeekly, _unset)
          ? this.topPatternWeekly
          : topPatternWeekly as String?,
      aiInsightSummary: identical(aiInsightSummary, _unset)
          ? this.aiInsightSummary
          : aiInsightSummary as String?,
      moodInsight: identical(moodInsight, _unset)
          ? this.moodInsight
          : moodInsight as String?,
      emotionPercentages: emotionPercentages ?? this.emotionPercentages,
      topPatternCount: topPatternCount ?? this.topPatternCount,
      allPatternCounts: allPatternCounts ?? this.allPatternCounts,
      growthInsight: identical(growthInsight, _unset)
          ? this.growthInsight
          : growthInsight as String?,
      triggerInsight: identical(triggerInsight, _unset)
          ? this.triggerInsight
          : triggerInsight as String?,
      range: range ?? this.range,
      improvement: identical(improvement, _unset)
          ? this.improvement
          : improvement as ImprovementSummary?,
      cbtUsageSummary: identical(cbtUsageSummary, _unset)
          ? this.cbtUsageSummary
          : cbtUsageSummary as CBTUsageSummary?,
    );
  }
}

class InsightsController extends Notifier<InsightsState> {
  @override
  InsightsState build() => const InsightsState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      final weeklySnapshot = await analyticsService.getWeeklyAnalyticsSnapshot(
        range: state.range,
      );
      state = state.copyWith(
        weeklyTrend: List.unmodifiable(weeklySnapshot.moodTrend),
        topEmotionWeekly: weeklySnapshot.topEmotion,
        topPatternWeekly: weeklySnapshot.topPattern,
        aiInsightSummary: weeklySnapshot.aiSummary,
        moodInsight: weeklySnapshot.moodInsight,
        emotionPercentages: Map.unmodifiable(weeklySnapshot.emotionPercentages),
        topPatternCount: weeklySnapshot.topPatternCount,
        allPatternCounts: Map.unmodifiable(weeklySnapshot.allPatternCounts),
        growthInsight: weeklySnapshot.growthInsight,
        triggerInsight: weeklySnapshot.triggerInsight,
        averageStress: await analyticsService.getAverageStress(),
        topDistortion: await analyticsService.getTopDistortion(),
        improvement: await analyticsService.getImprovementSummary(),
        cbtUsageSummary: await analyticsService.getCbtUsageSummary(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setRange(AnalyticsRange newRange) async {
    if (state.range == newRange) return;
    state = state.copyWith(range: newRange);
    await load();
  }
}
