class AnalyticsModel {
  final String aiSummary;
  final String moodInsight;
  final String? topEmotion;
  final String? topPattern;
  final Map<String, double> emotionDistribution;

  const AnalyticsModel({
    required this.aiSummary,
    required this.moodInsight,
    required this.topEmotion,
    required this.topPattern,
    required this.emotionDistribution,
  });
}
