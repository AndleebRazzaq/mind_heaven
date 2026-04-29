import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/journal_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _getUserName() {
    // In a real app, this would come from auth service
    return 'Andleeb';
  }

  String _getFormattedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Today, ${months[date.month - 1]} ${date.day}';
  }

  String _getDayLabel(int dayIndex) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[dayIndex % 7];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = _getUserName();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header with Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getFormattedDate(_selectedDate),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.blueGrey.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day Calendar Selector
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = _selectedDate.subtract(
                  Duration(days: _selectedDate.weekday - 1 - index),
                );
                final isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;

                return Padding(
                  padding: EdgeInsets.only(right: index < 6 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0A0E14)
                            : const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white.withValues(alpha: 0.06),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayLabel(date.weekday - 1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.blueGrey.shade300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.blueGrey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Personalized Greeting
          Text(
            'How are you feeling today, $userName?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Quick Entries (2 columns)
          Text(
            'Quick entries',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickEntryButton(
                  label: 'Check-in',
                  emoji: '✓',
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickEntryButton(
                  label: 'Savoring',
                  emoji: '🌿',
                  icon: Icons.eco_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Deep-dive Journals
          Text(
            'Deep-dive journals',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _DeepDiveJournalCard(
            title: 'Thought journal',
            description: 'Overcome unhelpful patterns.',
            icon: Icons.edit_outlined,
          ),
          const SizedBox(height: 12),
          _DeepDiveJournalCard(
            title: 'Exposure journal',
            description: 'Fight your fears by facing them.',
            icon: Icons.psychology_outlined,
          ),
          const SizedBox(height: 24),

          // Other Tools
          Text(
            'Other tools',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _OtherToolCard(label: 'Breathe', icon: Icons.air_outlined),
              _OtherToolCard(label: 'Free-form', icon: Icons.note_outlined),
              _OtherToolCard(label: 'Emergency', icon: Icons.warning_outlined),
            ],
          ),
          const SizedBox(height: 24),

          // Completed Entries
          Text(
            'Completed entries',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _RecentEntriesList(),
        ],
      ),
    );
  }
}

class _QuickEntryButton extends StatelessWidget {
  final String label;
  final String emoji;
  final IconData icon;

  const _QuickEntryButton({
    required this.label,
    required this.emoji,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeepDiveJournalCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _DeepDiveJournalCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blueGrey.shade300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherToolCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const _OtherToolCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEntriesList extends StatelessWidget {
  const _RecentEntriesList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer(
      builder: (context, ref, _) {
        ref.watch(journalControllerProvider);
        // Placeholder entries for demo
        final entries = [
          {
            'date': 'Today',
            'mood': '😌',
            'preview': 'Feeling better after the session...',
          },
          {
            'date': 'Yesterday',
            'mood': '😰',
            'preview': 'Anxiety about upcoming presentation...',
          },
          {
            'date': '2 days ago',
            'mood': '😊',
            'preview': 'Great day with friends at the park...',
          },
        ];

        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Text(
              'No entries yet. Start journaling to see your history here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blueGrey.shade300,
              ),
            ),
          );
        }

        return Column(
          children: entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      entry['mood'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['date'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blueGrey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry['preview'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blueGrey.shade300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.blueGrey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
