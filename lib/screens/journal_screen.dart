import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../models/cbt_intervention.dart';
import '../core/intervention/intervention_builder.dart';
import '../services/storage_service.dart';

/// CBT Journal: Layer 1 (distortion + emotion) → Layer 2 (CBT mapping) → Layer 3 (intervention).
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  static String distortionLabel(DistortionType type) {
    switch (type) {
      case DistortionType.allOrNothing: return 'All-or-Nothing';
      case DistortionType.overgeneralization: return 'Overgeneralization';
      case DistortionType.shouldStatements: return 'Should Statements';
      case DistortionType.labeling: return 'Labeling';
      case DistortionType.personalization: return 'Personalization';
      case DistortionType.magnification: return 'Magnification';
      default: return 'None detected';
    }
  }

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _contentController = TextEditingController();
  final InterventionBuilder _interventionBuilder = InterventionBuilder();
  final StorageService _storage = StorageService();
  CBTIntervention? _lastIntervention;
  DistortionType? _lastDistortion;
  bool _loading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _loading = true);
    try {
      final result = await _interventionBuilder.buildForJournal(content);
      final entry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        content: content,
        detectedDistortion: result.distortionType,
        reframe: result.intervention.reframeGuidance,
        plantSuggestion: result.intervention.plantSuggestion,
        moodLabel: result.emotionLabel,
      );
      await _storage.addJournalEntry(entry);
      setState(() {
        _lastIntervention = result.intervention;
        _lastDistortion = result.distortionType;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'CBT Journal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Write freely. We detect cognitive distortions and suggest CBT reframes, coping exercises, and plant tips.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade300),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind? e.g. I always mess things up...',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _onSubmit,
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Analyze & Get Feedback'),
          ),
          if (_lastIntervention != null) ...[
            const SizedBox(height: 24),
            _InterventionCard(intervention: _lastIntervention!, distortionType: _lastDistortion),
          ],
        ],
      ),
    );
  }
}

class _InterventionCard extends StatelessWidget {
  final CBTIntervention intervention;
  final DistortionType? distortionType;

  const _InterventionCard({required this.intervention, this.distortionType});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (intervention.detectedDistortionLabel != null) ...[
              Text('Detected distortion:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                intervention.detectedDistortionLabel!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blue.shade300),
              ),
              if (intervention.confidence != null)
                Text('Confidence: ${(intervention.confidence! * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
            ],
            Text('Explanation:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.distortionExplanation, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('CBT reframe:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.reframeGuidance, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Coping exercise:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.copingExerciseTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.tealAccent)),
            Text(intervention.copingExerciseDescription, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Plant suggestion:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.plantSuggestion, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green.shade300)),
            if (intervention.suggestBreathing && intervention.breathingTechnique != null) ...[
              const SizedBox(height: 12),
              Text('Breathing:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(intervention.breathingTechnique!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue.shade200)),
            ],
          ],
        ),
      ),
    );
  }
}
