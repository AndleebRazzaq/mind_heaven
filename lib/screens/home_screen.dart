import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/journal_provider.dart';
import '../widgets/home_dialogs.dart';
import 'journal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with date
          _DateTimeHeader(),
          const SizedBox(height: 24),

          // Quick action cards
          _QuickActionSection(
            onCheckIn: _showCheckInDialog,
            onSavoring: _showSavoringJournal,
            onBreathe: _showBreathingExercise,
          ),
          const SizedBox(height: 24),

          // Mood grounding & plant suggestions
          _MoodGroundingSection(),
          const SizedBox(height: 24),

          // Emergency support section
          _EmergencySupportSection(),
          const SizedBox(height: 24),

          // Completed entries list
          _CompletedEntriesSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showCheckInDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const CheckInDialog()).then((
      result,
    ) {
      if (result != null && mounted) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Check-in saved!')));
      }
    });
  }

  void _showSavoringJournal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const SavoringJournalDialog(),
    ).then((result) {
      if (result != null && mounted) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Gratitude saved!')));
      }
    });
  }

  void _showBreathingExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const BreathingExerciseDialog(),
    ).then((result) {
      if (result != null && mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Breathing exercise completed!')),
        );
      }
    });
  }
}

class _DateTimeHeader extends StatelessWidget {
  const _DateTimeHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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

    final dayName = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    final dateStr = '$dayName, $month ${now.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade400),
        ),
      ],
    );
  }
}

class _QuickActionSection extends StatelessWidget {
  final Function(BuildContext) onCheckIn;
  final Function(BuildContext) onSavoring;
  final Function(BuildContext) onBreathe;

  const _QuickActionSection({
    required this.onCheckIn,
    required this.onSavoring,
    required this.onBreathe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          title: 'Check-in',
          description: 'Emotion + context',
          icon: Icons.sentiment_satisfied_outlined,
          onTap: () => onCheckIn(context),
        ),
        const SizedBox(height: 10),
        _QuickActionCard(
          title: 'Savoring',
          description: 'Gratitude & joy',
          icon: Icons.favorite_outline,
          onTap: () => onSavoring(context),
        ),
        const SizedBox(height: 10),
        _QuickActionCard(
          title: 'Breathe',
          description: 'Guided breathing',
          icon: Icons.air_outlined,
          onTap: () => onBreathe(context),
        ),
        const SizedBox(height: 10),
        _QuickActionCard(
          title: 'Free Journal',
          description: 'Write freely',
          icon: Icons.edit_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JournalScreen()),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF14161B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF60A5FA), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.blueGrey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodGroundingSection extends StatelessWidget {
  const _MoodGroundingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood grounding',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suggested plant for today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Snake Plant',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: Colors.greenAccent.shade200),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Brings calm, steady structure',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blueGrey.shade400),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          spacing: 10,
                          children: [
                            Text(
                              '☀️ Bright',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '💧 Monthly',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
                      borderRadius: BorderRadius.circular(8),
                      // ignore: deprecated_member_use
                      border: Border.all(color: Colors.green.withOpacity(0.35)),
                    ),
                    child: const Icon(
                      Icons.local_florist_outlined,
                      color: Colors.greenAccent,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencySupportSection extends StatelessWidget {
  const _EmergencySupportSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Need immediate support?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1A1A),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.orange.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Crisis Resources',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'If you\'re in crisis or having thoughts of self-harm, please reach out:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  // ignore: deprecated_member_use
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red.shade300,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Emergency contacts: 988 (US) | Local hotline',
                      ),
                    ),
                  );
                },
                child: const Text('View Crisis Resources'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompletedEntriesSection extends StatelessWidget {
  const _CompletedEntriesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent reflections',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(onPressed: () {}, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<JournalProvider>(
          builder: (context, journalProvider, _) {
            // This would typically load entries from the provider
            // For now, showing placeholder
            return Column(
              children: [
                _EntryCard(
                  date: 'Today',
                  mood: 'Anxious',
                  distortion: 'Catastrophizing',
                  stressBefore: 8.0,
                  stressAfter: 5.0,
                ),
                const SizedBox(height: 10),
                _EntryCard(
                  date: 'Yesterday',
                  mood: 'Frustrated',
                  distortion: 'All-or-nothing',
                  stressBefore: 7.0,
                  stressAfter: 4.0,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14161B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No more entries',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final String date;
  final String mood;
  final String distortion;
  final double stressBefore;
  final double stressAfter;

  const _EntryCard({
    required this.date,
    required this.mood,
    required this.distortion,
    required this.stressBefore,
    required this.stressAfter,
  });

  @override
  Widget build(BuildContext context) {
    final stressReduction = ((stressBefore - stressAfter) / stressBefore * 100)
        .toStringAsFixed(0);

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF14161B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '↓ $stressReduction%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.greenAccent.shade200,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                Chip(
                  label: Text(mood),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade200,
                  ),
                  backgroundColor: const Color(0xFF1A1D25),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                Chip(
                  label: Text(distortion),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade200,
                  ),
                  backgroundColor: const Color(0xFF1A1D25),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stress: $stressBefore → $stressAfter',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.blueGrey.shade500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
