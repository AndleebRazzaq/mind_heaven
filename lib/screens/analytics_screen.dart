import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/analytics_service.dart';

/// Analytics: weekly mood trend, stress average, top distortion, improvement (from stored data).
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  List<MoodDataPoint>? _weeklyTrend;
  double? _avgStress;
  String? _topDistortion;
  ImprovementSummary? _improvement;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final trend = await _analytics.getWeeklyMoodTrend();
      final avg = await _analytics.getAverageStress();
      final top = await _analytics.getTopDistortion();
      final improvement = await _analytics.getImprovementSummary();
      setState(() {
        _weeklyTrend = trend;
        _avgStress = avg;
        _topDistortion = top;
        _improvement = improvement;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final trend = _weeklyTrend ?? [];
    final spots = trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (1 - e.value.stressLevel) * 10)).toList();
    final labels = trend.map((m) => DateFormat('EEE').format(m.date)).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Emotion Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Weekly mood trend (higher = better). Data from Check-In & Journal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade300),
            ),
            const SizedBox(height: 24),
            if (trend.isNotEmpty) ...[
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.blueGrey, fontSize: 10)))),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i >= 0 && i < labels.length) return Text(labels[i], style: const TextStyle(color: Colors.blueGrey, fontSize: 10));
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.blue.shade400,
                        barWidth: 2,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ] else
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No data yet. Use Check-In and Journal to build your analytics.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade400),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (_avgStress != null) ...[
              Text('Average stress (7 days)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text('${((_avgStress! * 100).round())}%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blue.shade300)),
              const SizedBox(height: 4),
              LinearProgressIndicator(value: _avgStress, backgroundColor: Colors.blue.shade900),
              const SizedBox(height: 20),
            ],
            if (_topDistortion != null) ...[
              Text('Most frequent distortion (30 days)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(_topDistortion!.replaceAll('_', ' '), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.tealAccent)),
              const SizedBox(height: 20),
            ],
            if (_improvement != null) ...[
              Text('Improvement', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Card(
                color: const Color(0xFF1A1A1A),
                child: ListTile(
                  leading: Icon(_improvement!.stressImproved ? Icons.trending_down : Icons.info_outline, color: _improvement!.stressImproved ? Colors.green : Colors.blueGrey),
                  title: Text(_improvement!.message, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
