import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/insights_provider.dart';
import '../services/analytics_service.dart';

/// Analytics: journal-driven weekly mood trend, stress average, top distortion, improvement.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _prettyLabel(String raw) {
    return raw
        .split(RegExp(r'[_\s]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  String _patternTip(String? label) {
    final value = (label ?? '').toLowerCase();
    if (value.contains('all') || value.contains('nothing')) {
      return 'Try looking for middle-ground thoughts.';
    }
    if (value.contains('mind') || value.contains('reading')) {
      return 'Check assumptions with evidence, not guesses.';
    }
    if (value.contains('catastroph') || value.contains('magnification')) {
      return 'Ask what is most likely, not worst-case only.';
    }
    if (value.contains('emotional')) {
      return 'Feelings matter, but they are not always facts.';
    }
    return 'Name the pattern, then test it with balanced evidence.';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InsightsProvider>();
    final weeklyTrend = provider.weeklyTrend;
    final topEmotion = provider.topEmotionWeekly;
    final topPattern = provider.topPatternWeekly;
    final aiSummary = provider.aiInsightSummary ?? provider.growthInsight;
    final moodInsight = provider.moodInsight;
    final emotionPercentages = provider.emotionPercentages;
    final topPatternCount = provider.topPatternCount;
    final triggerInsight = provider.triggerInsight;
    final allPatternCounts = provider.allPatternCounts;
    final loading = provider.isLoading;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final trend = weeklyTrend;
    final moodSpots = trend
        .asMap()
        .entries
        .map((e) {
          final stress = e.value.stressLevel.clamp(0, 1);
          final moodScore = (((1 - stress) * 4) + 1).toDouble(); // map to 1..5
          return FlSpot(e.key.toDouble(), moodScore);
        })
        .toList();
    final labels = trend.map((m) => DateFormat('EEE').format(m.date)).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<InsightsProvider>().load(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '📅',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<AnalyticsRange>(
                    value: provider.range,
                    borderRadius: BorderRadius.circular(10),
                    dropdownColor: const Color(0xFF1A1A1A),
                    onChanged: (value) {
                      if (value == null) return;
                      context.read<InsightsProvider>().setRange(value);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: AnalyticsRange.thisWeek,
                        child: Text('This Week'),
                      ),
                      DropdownMenuItem(
                        value: AnalyticsRange.last7Days,
                        child: Text('Last 7 Days'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (trend.isNotEmpty) ...[
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i >= 0 && i < labels.length) {
                              return Text(
                                labels[i],
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 1,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: moodSpots,
                        isCurved: true,
                        color: Colors.blue.shade400,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.withValues(alpha: 0.20),
                              Colors.blue.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${moodInsight ?? 'Your average mood increased slightly this week. Keep going.'} 🌿',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blueGrey.shade300,
                    ),
              ),
            ] else
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No data yet. Write journal entries to build your insights.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Emotional pattern',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (emotionPercentages.isEmpty)
              _MetricTile(
                title: 'No emotional distribution yet',
                value: 'Write reflections this week to see your pattern.',
              )
            else ...[
              for (final entry
                  in (emotionPercentages.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value))
                    ..removeWhere((e) => e.value <= 0)))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EmotionProgressRow(
                    label: _prettyLabel(entry.key),
                    percent: entry.value,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                '${_prettyLabel(topEmotion ?? 'Unknown')} showed up most often this period.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blueGrey.shade300,
                    ),
              ),
            ],
            const SizedBox(height: 18),
            Card(
              color: const Color(0xFF1A1A1A),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most common thinking pattern',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _prettyLabel(topPattern ?? 'Not enough data yet'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF60A5FA),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topPattern == null
                          ? 'Appeared 0 times this period.'
                          : 'Appeared $topPatternCount times this period.',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _patternTip(topPattern),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blueGrey.shade300,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: allPatternCounts.isEmpty
                            ? null
                            : () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  backgroundColor: const Color(0xFF121212),
                                  builder: (ctx) {
                                    final items = allPatternCounts.entries.toList()
                                      ..sort((a, b) => b.value.compareTo(a.value));
                                    return ListView(
                                      padding: const EdgeInsets.all(16),
                                      children: [
                                        const Text(
                                          'All patterns',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        for (final item in items)
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(_prettyLabel(item.key)),
                                            trailing: Text('${item.value}'),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                        child: const Text('View All Patterns'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF1A1A1A),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growth insight',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      aiSummary ??
                          'Keep writing regularly to receive a personalized weekly summary.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (triggerInsight != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        triggerInsight,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blueGrey.shade300,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;

  const _MetricTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF60A5FA),
              ),
        ),
      ),
    );
  }
}

class _EmotionProgressRow extends StatelessWidget {
  final String label;
  final double percent;

  const _EmotionProgressRow({
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: (percent / 100).clamp(0, 1),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF60A5FA)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${percent.toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
