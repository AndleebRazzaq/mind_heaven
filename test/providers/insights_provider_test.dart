import 'package:mind_heaven/app/app_providers.dart';
import 'package:mind_heaven/presentation/providers/insights_provider.dart';
import 'package:mind_heaven/services/analytics_models.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

class _FakeAnalyticsServiceSuccess implements AnalyticsReader {
  @override
  Future<WeeklyAnalyticsSnapshot> getWeeklyAnalyticsSnapshot({
    AnalyticsRange range = AnalyticsRange.thisWeek,
  }) async {
    final trend = [
      MoodDataPoint(
        date: DateTime.now(),
        moodLabel: 'Calm',
        stressLevel: 0.2,
        count: 1,
      ),
    ];
    return WeeklyAnalyticsSnapshot(
      moodTrend: trend,
      topEmotion: 'Calm',
      topPattern: 'Magnification',
      aiSummary: 'Steady progress',
      moodInsight: 'Mood increased.',
      emotionPercentages: const {'Calm': 100},
      topPatternCount: 1,
      allPatternCounts: const {'Magnification': 1},
      growthInsight: 'Keep going.',
      triggerInsight: null,
    );
  }

  @override
  Future<double> getAverageStress() async => 0.3;

  @override
  Future<String?> getTopDistortion() async => 'magnification';

  @override
  Future<ImprovementSummary> getImprovementSummary() async {
    return ImprovementSummary(stressImproved: true, message: 'Improved');
  }

  @override
  Future<CBTUsageSummary> getCbtUsageSummary() async {
    return const CBTUsageSummary(
      totalEntries: 3,
      reframeCompletionRate: 1,
      behaviorPromptRate: 0.66,
      structuredReframeRate: 1,
    );
  }

  @override
  Future<CBTUsageSummary> getCbtUsageSummary() async {
    return const CBTUsageSummary(
      totalEntries: 3,
      reframeCompletionRate: 1,
      behaviorPromptRate: 0.66,
      structuredReframeRate: 1,
    );
  }
}

class _FakeAnalyticsServiceError implements AnalyticsReader {
  @override
  Future<WeeklyAnalyticsSnapshot> getWeeklyAnalyticsSnapshot({
    AnalyticsRange range = AnalyticsRange.thisWeek,
  }) async {
    throw Exception('analytics failed');
  }

  @override
  Future<double> getAverageStress() async => 0;

  @override
  Future<String?> getTopDistortion() async => null;

  @override
  Future<ImprovementSummary> getImprovementSummary() async {
    return ImprovementSummary(stressImproved: false, message: '');
  }

  @override
  Future<CBTUsageSummary> getCbtUsageSummary() async {
    return const CBTUsageSummary(
      totalEntries: 0,
      reframeCompletionRate: 0,
      behaviorPromptRate: 0,
      structuredReframeRate: 0,
    );
  }
}

void main() {
  test('InsightsController load success fills fields', () async {
    final container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(
          _FakeAnalyticsServiceSuccess(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(insightsControllerProvider.notifier).load();

    final state = container.read(insightsControllerProvider);
    expect(state.isLoading, false);
    expect(state.error, isNull);
    expect(state.weeklyTrend.isNotEmpty, true);
    expect(state.averageStress, 0.3);
    expect(state.topDistortion, 'magnification');
    expect(state.improvement?.stressImproved, true);
  });

  test('InsightsController load error sets error', () async {
    final container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(
          _FakeAnalyticsServiceError(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(insightsControllerProvider.notifier).load();

    final state = container.read(insightsControllerProvider);
    expect(state.isLoading, false);
    expect(state.error, isNotNull);
  });
}
