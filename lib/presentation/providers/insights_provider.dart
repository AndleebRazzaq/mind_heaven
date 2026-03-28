import 'package:flutter/foundation.dart';
import '../../services/analytics_service.dart';

class InsightsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService;

  InsightsProvider(this._analyticsService);

  bool isLoading = false;
  String? error;
  List<MoodDataPoint> weeklyTrend = [];
  double? averageStress;
  String? topDistortion;
  ImprovementSummary? improvement;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      weeklyTrend = await _analyticsService.getWeeklyMoodTrend();
      averageStress = await _analyticsService.getAverageStress();
      topDistortion = await _analyticsService.getTopDistortion();
      improvement = await _analyticsService.getImprovementSummary();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
