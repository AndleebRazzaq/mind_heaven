import '../entities/analytics_model.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsModel> getWeeklySnapshot();
}
