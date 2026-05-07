import 'package:flutter_test/flutter_test.dart';
import 'package:mind_heaven/presentation/providers/insights_provider.dart';
import 'package:mind_heaven/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAnalyticsServiceSuccess extends AnalyticsService {
  _FakeAnalyticsServiceSuccess() : super();

  @override
  Future<WeeklyAnalyticsSnapshot> getWeeklyAnalyticsSnapshot({
    AnalyticsRange range = AnalyticsRange.thisWeek,
  }) async {
    return WeeklyAnalyticsSnapshot(
      moodTrend: await getWeeklyMoodTrend(),
      topEmotion: 'Calm',
      topPattern: 'magnification',
      aiSummary: 'Improved',
      moodInsight: 'Mood is stable',
      emotionPercentages: const {'Calm': 1},
      topPatternCount: 1,
      allPatternCounts: const {'magnification': 1},
      growthInsight: 'Growth is visible',
      triggerInsight: null,
    );
  }

  @override
  Future<List<MoodDataPoint>> getWeeklyMoodTrend() async {
    return [
      MoodDataPoint(
        date: DateTime.now(),
        moodLabel: 'Calm',
        stressLevel: 0.2,
        count: 1,
      ),
    ];
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
}

class _FakeAnalyticsServiceError extends AnalyticsService {
  _FakeAnalyticsServiceError() : super();

  @override
  Future<WeeklyAnalyticsSnapshot> getWeeklyAnalyticsSnapshot({
    AnalyticsRange range = AnalyticsRange.thisWeek,
  }) async {
    throw Exception('analytics failed');
  }

  @override
  Future<List<MoodDataPoint>> getWeeklyMoodTrend() async {
    throw Exception('analytics failed');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('InsightsProvider load success fills fields', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = InsightsProvider(_FakeAnalyticsServiceSuccess());
    await provider.load();

    expect(provider.isLoading, false);
    expect(provider.error, isNull);
    expect(provider.weeklyTrend.isNotEmpty, true);
    expect(provider.averageStress, 0.3);
    expect(provider.topDistortion, 'magnification');
    expect(provider.improvement?.stressImproved, true);
  });

  test('InsightsProvider load error sets error', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = InsightsProvider(_FakeAnalyticsServiceError());
    await provider.load();

    expect(provider.isLoading, false);
    expect(provider.error, isNotNull);
  });
}
