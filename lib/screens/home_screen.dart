import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/journal_provider.dart';
import '../widgets/home_dialogs.dart';
import 'journal_screen.dart';
import 'check_in_screen.dart';
import 'savoring_screen.dart';

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
          const _HomeCalendarHeader(),
          _SectionTitle('Quick entries'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickEntryCard(
                  title: 'Check-in',
                  icon: Icons.published_with_changes,
                  onTap: () => _showCheckInDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickEntryCard(
                  title: 'Savoring',
                  icon: Icons.local_florist_outlined,
                  onTap: () => _showSavoringJournal(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionTitle('Deep-dive journals'),
          const SizedBox(height: 12),
          _DeepDiveCard(
            title: 'Thought journal',
            description: 'Overcome unhelpful patterns.',
            icon: Icons.draw_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _DeepDiveCard(
            title: 'Exposure journal',
            description: 'Fight your fears by facing them.',
            icon: Icons.person_pin_circle_outlined,
            onTap: () {},
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
                  onTap: () {},
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

  void _showCheckInDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckInScreen()),
    );
  }

  void _showSavoringJournal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavoringScreen()),
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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: Colors.white,
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFB4C6FC), size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFB4C6FC),
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB4C6FC), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFB4C6FC),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              _CompletedEntryItem(
                icon: Icons.local_florist_outlined,
                title: 'Savoring Journal',
                subtitle: 'Not feeling best at this moment...',
              ),
              Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
              _CompletedEntryItem(
                icon: Icons.published_with_changes,
                title: 'Check-in',
                subtitle: 'Anxious, Tired...',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompletedEntryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CompletedEntryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFB4C6FC)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {},
    );
  }
}

class _HomeCalendarHeader extends StatelessWidget {
  const _HomeCalendarHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date and dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Today, 29 April',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
          ],
        ),
        const SizedBox(height: 24),

        // Days Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDayBox(context, 'Mon', isFirstEntry: true),
              _buildDayBox(context, 'Tue'),
              _buildDayBox(context, 'Wed', isSelected: true),
              _buildDayBox(context, 'Thu'),
              _buildDayBox(context, 'Fri'),
              _buildDayBox(context, 'Sat'),
              _buildDayBox(context, 'Sun'),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Personalized Text
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
              height: 1.5,
            ),
            children: const [
              TextSpan(
                text: 'Looking ahead: ',
                style: TextStyle(
                  color: Color(0xFFB4C6FC),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text:
                    'It could be a lot positive and calm Peaceful...I thought I would able to think in gray',
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
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
      width: isFirstEntry ? 88 : 52,
      height: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? Colors.white
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
              fontSize: 14,
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
