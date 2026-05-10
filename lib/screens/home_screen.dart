import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/journal_provider.dart';
import '../widgets/home_dialogs.dart';
import 'journal_screen.dart';
import 'check_in_screen.dart';
import 'savoring_screen.dart';
import '../models/journal_entry.dart';
import '../routes/app_routes.dart';
import 'emergency_resources_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HomeCalendarHeader(),
          _SectionTitle('Quick entries'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickEntryCard(
                  title: 'Check-in',
                  icon: Icons.published_with_changes,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckInScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickEntryCard(
                  title: 'Savoring',
                  icon: Icons.local_florist_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavoringScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionTitle('AI Support'),
          const SizedBox(height: 12),
          _DeepDiveCard(
            title: 'AI Journal',
            description: 'Reframe thoughts with AI-powered CBT support.',
            icon: Icons.auto_awesome,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalScreen()),
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle('Other tools'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ToolCard(
                  title: 'Breathe',
                  icon: Icons.air,
                  onTap: _showBreathingExercise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  title: 'Free-form',
                  icon: Icons.note_alt_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JournalScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  title: 'Emergency',
                  icon: Icons.support,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyResourcesScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  title: 'Plant',
                  icon: Icons.local_florist_rounded,
                  onTap: () => _showPlantSuggestion(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionTitle('Completed entries'),
          const SizedBox(height: 12),
          _CompletedEntriesList(),
        ],
      ),
    );
  }

  Future<void> _showBreathingExercise() async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => const BreathingExerciseDialog(),
    );
    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Breathing exercise completed!')),
    );
  }

  void _showPlantSuggestion(BuildContext context) {
    final provider = context.read<JournalProvider>();
    final lastEntry = provider.entries.isNotEmpty ? provider.entries.first : null;
    
    // Default to Spider Plant if no data
    String plantType = 'spider plant';
    String moodFound = 'neutral';
    
    if (lastEntry != null) {
      final mood = (lastEntry.moodLabel ?? '').toLowerCase();
      if (mood.contains('anxiety')) {
        plantType = 'peace lily';
        moodFound = 'anxiety';
      } else if (mood.contains('stress')) {
        plantType = 'jasmine plant';
        moodFound = 'stress';
      } else if (mood.contains('low') || mood.contains('sad')) {
        plantType = 'aloe vera plant';
        moodFound = 'low mood';
      } else if (mood.contains('pos') || mood.contains('happy')) {
        plantType = 'bright sunflower';
        moodFound = 'positivity';
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PlantSuggestionSheet(plantType: plantType, mood: moodFound),
    );
  }
}

class _PlantSuggestionSheet extends StatelessWidget {
  final String plantType;
  final String mood;

  const _PlantSuggestionSheet({required this.plantType, required this.mood});

  @override
  Widget build(BuildContext context) {
    final info = _getPlantInfo(plantType);
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Color(0xFF14161B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(info['icon'] as IconData, color: const Color(0xFF4ADE80), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info['name'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suggested for your $mood',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Benefits & Awareness',
            style: TextStyle(color: Color(0xFFB4C6FC), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            info['benefits'] as String,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'How to Use',
            style: TextStyle(color: Color(0xFFB4C6FC), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            info['use'] as String,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.fromStyle(
                backgroundColor: const Color(0xFF4ADE80).withOpacity(0.2),
                foregroundColor: const Color(0xFF4ADE80),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPlantInfo(String type) {
    switch (type) {
      case 'peace lily':
        return {
          'name': 'Peace Lily',
          'benefits': 'Purifies air and promotes a sense of calm. Its lush green leaves help reduce anxiety levels by creating a serene environment.',
          'use': 'Keep in a shaded corner of your bedroom or office. It prefers indirect light.',
          'icon': Icons.spa_rounded,
        };
      case 'jasmine plant':
        return {
          'name': 'Jasmine',
          'benefits': 'The scent of Jasmine is known to reduce stress and improve sleep quality. It acts as a natural relaxant for the nervous system.',
          'use': 'Place near a window where you can enjoy its fragrance, especially in the evening.',
          'icon': Icons.local_florist,
        };
      case 'aloe vera plant':
        return {
          'name': 'Aloe Vera',
          'benefits': 'Known as the "Plant of Immortality," it clears indoor toxins and emits oxygen at night, helping with renewal and healing.',
          'use': 'Needs bright, indirect sunlight and minimal watering. Perfect for a bedside table.',
          'icon': Icons.healing_rounded,
        };
      case 'bright sunflower':
        return {
          'name': 'Sunflower',
          'benefits': 'Sunflowers symbolize positivity and happiness. Their bright yellow color can boost your mood and energy levels.',
          'use': 'Best kept in sunny spots to maintain its vibrant energy and bring cheer to your room.',
          'icon': Icons.wb_sunny_rounded,
        };
      default:
        return {
          'name': 'Spider Plant',
          'benefits': 'One of the easiest plants to grow, it represents resilience and steady growth. It helps in maintaining a grounded perspective.',
          'use': 'Great for hanging baskets or shelves in moderate light. It thrives with little maintenance.',
          'icon': Icons.eco_rounded,
        };
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFB4C6FC),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _QuickEntryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickEntryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF14161B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE4A4C1), size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeepDiveCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _DeepDiveCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF14161B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFB4C6FC).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFB4C6FC), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF14161B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFB4C6FC), size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFB4C6FC),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedEntriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, _) {
        if (journalProvider.isLoading && journalProvider.entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF8A6BFF)),
              ),
            ),
          );
        }

        final entries = journalProvider.entries;
        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF14161B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Center(
              child: Text(
                'No entries yet. Start journaling to see them here!',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final displayEntries = entries.take(3).toList();

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayEntries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = displayEntries[index];
                IconData icon = Icons.note_alt_outlined;
                Color iconColor = const Color(0xFFB4C6FC);

                if (entry.tags.contains('savoring')) {
                  icon = Icons.local_florist_outlined;
                  iconColor = const Color(0xFFE4A4C1);
                } else if (entry.tags.contains('ai-journal')) {
                  icon = Icons.auto_awesome;
                  iconColor = const Color(0xFF8A6BFF);
                } else if (entry.tags.contains('check-in')) {
                  icon = Icons.published_with_changes;
                  iconColor = const Color(0xFFB4C6FC);
                }

                String displayTitle = 'Journal Entry';
                if (entry.tags.contains('savoring')) {
                  displayTitle = 'Savoring';
                } else if (entry.tags.contains('ai-journal')) {
                  displayTitle = 'AI Journal';
                } else if (entry.tags.contains('check-in')) {
                  displayTitle = 'Check-in';
                }

                return _CompletedEntryItem(
                  entry: entry,
                  icon: icon,
                  iconColor: iconColor,
                  title: displayTitle,
                  subtitle: entry.content,
                );
              },
            ),
            if (entries.length > 3) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.allEntries),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A6BFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF8A6BFF).withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All Entries',
                        style: TextStyle(
                          color: Color(0xFF8A6BFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF8A6BFF), size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CompletedEntryItem extends StatelessWidget {
  final JournalEntry entry;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _CompletedEntryItem({
    required this.entry,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
            height: 1.4,
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${entry.dateTime.day}/${entry.dateTime.month}',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade700, size: 16),
        ],
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _EntryDetailSheet(
            entry: entry,
            title: title,
            icon: icon,
            iconColor: iconColor,
          ),
        );
      },
    ));
  }
}

class _EntryDetailSheet extends StatelessWidget {
  final JournalEntry entry;
  final String title;
  final IconData icon;
  final Color iconColor;

  const _EntryDetailSheet({
    required this.entry,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d - h:mm a');
    final isAiJournal = entry.tags.contains('ai-journal');
    final isCheckIn = entry.tags.contains('check-in');
    final isSavoring = entry.tags.contains('savoring');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF14161B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(entry.dateTime),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAiJournal || isCheckIn) ...[
                      if (entry.moodLabel != null && entry.moodLabel!.isNotEmpty) ...[
                        _DetailSectionTitle('Mood', color: const Color(0xFFB4C6FC)),
                        const SizedBox(height: 8),
                        Text(
                          entry.moodLabel!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (isAiJournal) ...[
                      if (entry.detectedDistortionLabel != null && entry.detectedDistortionLabel!.isNotEmpty) ...[
                        _DetailSectionTitle('Pattern', color: const Color(0xFF8A6BFF)),
                        const SizedBox(height: 8),
                        Text(
                          entry.detectedDistortionLabel!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (entry.reframe != null && entry.reframe!.isNotEmpty) ...[
                        _DetailSectionTitle('Reframe', color: const Color(0xFF8A6BFF)),
                        const SizedBox(height: 8),
                        Text(
                          entry.reframe!,
                          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (isSavoring && entry.eventSummary != null) ...[
                        _DetailSectionTitle('Contextual factor', color: const Color(0xFFE4A4C1)),
                      const SizedBox(height: 8),
                      Text(
                        entry.eventSummary!,
                        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _DetailSectionTitle('Entry', color: iconColor),
                    const SizedBox(height: 8),
                    Text(
                      entry.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _DetailSectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _DetailSectionTitle(this.title, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _HomeCalendarHeader extends StatefulWidget {
  const _HomeCalendarHeader();

  @override
  State<_HomeCalendarHeader> createState() => _HomeCalendarHeaderState();
}

class _HomeCalendarHeaderState extends State<_HomeCalendarHeader> {
  final ScrollController _scrollController = ScrollController();
  late DateTime _today;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _weekDays = _getWeekDays(_today);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  List<DateTime> _getWeekDays(DateTime date) {
    int currentDay = date.weekday;
    DateTime startOfWeek = date.subtract(Duration(days: currentDay - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _scrollToToday() {
    if (!_scrollController.hasClients) return;
    int todayIndex = _weekDays.indexWhere((d) => d.day == _today.day && d.month == _today.month);
    if (todayIndex == -1) return;
    
    final double screenWidth = MediaQuery.of(context).size.width;
    double offset = (todayIndex * 64.0) - (screenWidth / 2) + 32;
    if (offset < 0) offset = 0;
    
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM');
    final dayFormat = DateFormat('EEE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date and dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Today, ${dateFormat.format(_today)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Days Row
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _weekDays.map((date) {
              bool isToday = date.day == _today.day && date.month == _today.month && date.year == _today.year;
              return _buildDayBox(
                context, 
                dayFormat.format(date), 
                isSelected: isToday,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDayBox(
    BuildContext context,
    String day, {
    bool isSelected = false,
    bool isFirstEntry = false,
  }) {
    return Container(
      width: isFirstEntry ? 76 : 46,
      height: 52,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFE4A4C1)
              : (isFirstEntry ? Colors.grey.shade700 : const Color(0xFF2C2C30)),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected || isFirstEntry
                  ? Colors.white
                  : Colors.grey.shade600,
              fontWeight: isSelected || isFirstEntry
                  ? FontWeight.w600
                  : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          if (isFirstEntry) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'First entry ',
                  style: TextStyle(
                    color: Color(0xFFE4A4C1),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.check, color: Color(0xFFE4A4C1), size: 12),
                Text(
                  '2',
                  style: TextStyle(color: Color(0xFFE4A4C1), fontSize: 10),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
