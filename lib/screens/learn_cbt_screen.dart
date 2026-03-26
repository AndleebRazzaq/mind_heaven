import 'package:flutter/material.dart';

class LearnCbtScreen extends StatelessWidget {
  const LearnCbtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _TopicCard(
          title: 'What are cognitive distortions?',
          body:
              'Cognitive distortions are thinking patterns that can intensify emotional distress. Common examples include catastrophizing, overgeneralization, and mind reading.',
        ),
        _TopicCard(
          title: 'How CBT works',
          body:
              'CBT helps identify unhelpful thought patterns, test them against evidence, and build balanced alternatives that support healthier emotions and behaviors.',
        ),
        _TopicCard(
          title: 'Example reframing',
          body:
              'From: "I always fail"\nTo: "This was difficult, but I can learn from it and improve next time."',
        ),
        _TopicCard(
          title: 'Self-help guidance',
          body:
              '1) Notice the thought\n2) Name the distortion\n3) Ask for evidence\n4) Create a balanced thought\n5) Take one practical step.',
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String body;

  const _TopicCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
