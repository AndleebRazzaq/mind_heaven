import 'package:flutter/material.dart';
import 'check_in_screen.dart';

/// Home/Dashboard: greeting, mood prompt, AI insights, mood flow, session CTA.
/// Session button uses teal accent (reference style).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const sessionAccent = Color(0xFF4ECDC4);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
          ),
          const SizedBox(height: 24),
          _MoodFlowCard(),
          const SizedBox(height: 20),
          Text(
            'AI Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          _InsightCard(
            title: 'Weekly pattern',
            body: 'Your check-ins show more calm moments in the evening.',
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 10),
          _InsightCard(
            title: 'Coping tip',
            body: 'When stress rises, try 4-7-8 breathing before replying.',
            icon: Icons.self_improvement_rounded,
          ),
          const SizedBox(height: 24),
          Text(
            'Start a session',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          _SessionCtaCard(),
        ],
      ),
    );
  }
}

class _MoodFlowCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moods = ['Calm', 'Reflective', 'Anxious', 'Calm', 'Low', 'Reflective'];
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart_rounded, color: DashboardScreen.sessionAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Mood flow',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: moods.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DashboardScreen.sessionAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DashboardScreen.sessionAccent.withOpacity(0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        moods[i],
                        style: TextStyle(
                          color: DashboardScreen.sessionAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _InsightCard({required this.title, required this.body, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade900,
          child: Icon(icon, color: Colors.blue.shade300, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(body, style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13)),
      ),
    );
  }
}

class _SessionCtaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CheckInScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: DashboardScreen.sessionAccent.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: DashboardScreen.sessionAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in session',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Voice or text — we detect stress & mood and suggest a calming step.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blueGrey.shade400,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DashboardScreen.sessionAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
