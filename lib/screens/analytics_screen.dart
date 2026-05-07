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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB4C6FC)),
      );
    }
    final trend = weeklyTrend;
    final moodSpots = trend.asMap().entries.map((e) {
      final stress = e.value.stressLevel.clamp(0, 1);
      final moodScore = (((1 - stress) * 4) + 1).toDouble(); // map to 1..5
      return FlSpot(e.key.toDouble(), moodScore);
    }).toList();
    final labels = trend.map((m) => DateFormat('EEE').format(m.date)).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<InsightsProvider>().load(),
      color: const Color(0xFFB4C6FC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Color(0xFFB4C6FC), size: 20),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<AnalyticsRange>(
                        value: provider.range,
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: const Color(0xFF1E1E22),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
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
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (trend.isNotEmpty) ...[
              Container(
                height: 240,
                padding: const EdgeInsets.only(right: 16, top: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16171B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => const Color(0xFF2C2D31),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = trend[spot.x.toInt()].date;
                            final mood = trend[spot.x.toInt()].moodLabel;
                            return LineTooltipItem(
                              '${DateFormat('MMM d').format(date)}\n$mood',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1,
                          getTitlesWidget: (v, _) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              v.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i >= 0 && i < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[i],
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 1,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: moodSpots,
                        isCurved: true,
                        color: const Color(0xFFB4C6FC),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFFB4C6FC),
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF16171B),
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFB4C6FC).withValues(alpha: 0.2),
                              const Color(0xFFB4C6FC).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${moodInsight ?? 'Your average mood increased slightly this week. Keep going.'} 🌿',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ] else
              _EmptyDataCard(
                message: 'No entries found for this period. Start journaling to see your trend.',
              ),
            const SizedBox(height: 32),
            const Text(
              'Emotional pattern',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (emotionPercentages.isEmpty)
              const _EmptyDataCard(message: 'No emotional data yet.')
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (final entry
                        in (emotionPercentages.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value))
                          ..removeWhere((e) => e.value <= 0)))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EmotionProgressRow(
                          label: _prettyLabel(entry.key),
                          percent: entry.value,
                        ),
                      ),
                    const Divider(color: Colors.white10, height: 32),
                    Text(
                      '${_prettyLabel(topEmotion ?? 'Unknown')} was your dominant emotion.',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _InteractivePatternCard(
              topPattern: topPattern,
              topPatternCount: topPatternCount,
              allPatternCounts: allPatternCounts,
              patternTip: _patternTip(topPattern),
              prettyLabel: _prettyLabel,
            ),
            const SizedBox(height: 24),
            _ThemedInsightCard(
              title: 'Growth Insight',
              content: aiSummary ?? 'Keep writing regularly to receive personalized insights.',
              subtitle: triggerInsight,
              icon: Icons.auto_awesome,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SummaryStatCard(
                    title: 'Total reflections',
                    value: '${provider.cbtUsageSummary?.totalEntries ?? 0}',
                    icon: Icons.history_edu,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E2F33), Color(0xFF1E1E22)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryStatCard(
                    title: 'CBT completion',
                    value: '${((provider.cbtUsageSummary?.reframeCompletionRate ?? 0) * 100).toInt()}%',
                    icon: Icons.verified_user,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E2F33), Color(0xFF1E1E22)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _EmptyDataCard extends StatelessWidget {
  final String message;
  const _EmptyDataCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _InteractivePatternCard extends StatelessWidget {
  final String? topPattern;
  final int topPatternCount;
  final Map<String, int> allPatternCounts;
  final String patternTip;
  final String Function(String) prettyLabel;

  const _InteractivePatternCard({
    required this.topPattern,
    required this.topPatternCount,
    required this.allPatternCounts,
    required this.patternTip,
    required this.prettyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: allPatternCounts.isEmpty ? null : () => _showAllPatterns(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2B30), Color(0xFF16171B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thinking pattern',
                  style: TextStyle(color: Color(0xFFB4C6FC), fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prettyLabel(topPattern ?? 'No Distortion'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Appeared $topPatternCount times this period',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white10),
            ),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patternTip,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAllPatterns(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final items = allPatternCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Patterns Detected',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ...items.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(prettyLabel(item.key), style: const TextStyle(color: Colors.white)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4C6FC).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.value}',
                        style: const TextStyle(color: Color(0xFFB4C6FC), fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ThemedInsightCard extends StatelessWidget {
  final String title;
  final String content;
  final String? subtitle;
  final IconData icon;

  const _ThemedInsightCard({
    required this.title,
    required this.content,
    this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE4A4C1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE4A4C1),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmotionProgressRow extends StatelessWidget {
  final String label;
  final double percent;

  const _EmotionProgressRow({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (percent / 100).clamp(0, 1),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A6BFF), Color(0xFFB4C6FC)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '${percent.toInt()}%',
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _SummaryStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFB4C6FC), size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
