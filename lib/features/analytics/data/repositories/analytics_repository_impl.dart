import '../../../../services/analytics_service.dart';
import '../../domain/entities/analytics_model.dart';
import '../../domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsService _service;

  AnalyticsRepositoryImpl(this._service);

  @override
  Future<AnalyticsModel> getWeeklySnapshot() async {
    final snapshot = await _service.getWeeklyAnalyticsSnapshot();
    return AnalyticsModel(
      aiSummary: snapshot.aiSummary,
      moodInsight: snapshot.moodInsight,
      topEmotion: snapshot.topEmotion,
      topPattern: snapshot.topPattern,
      emotionDistribution: snapshot.emotionPercentages,
    );
  }
}
