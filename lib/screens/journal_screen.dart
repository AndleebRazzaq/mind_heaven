import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../models/cbt_intervention.dart';
import '../presentation/providers/journal_provider.dart';
import '../core/cbt_engine/plant_suggestion_database.dart';

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
  static const int _maxChars = 1200;
  late int _suggestionIndex;

  static const List<String> _suggestionPrompts = [
    'How was your day? Share a moment that made you feel proud, anxious, or upset.',
    'Think about a part of your day that was challenging - what went through your mind?',
    'Write about anything that made you feel frustrated, worried, or stressed today.',
    'Note any thought that keeps replaying in your head, even small ones.',
    'Notice a positive moment and what thought accompanied it.',
    'Write about a situation where you felt anxious - what did you tell yourself?',
    'Describe a challenge you faced and how you reacted.',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _suggestionIndex = (now.year + now.month + now.day) % _suggestionPrompts.length;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    await context.read<JournalProvider>().analyze(content);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final CBTIntervention? lastIntervention = provider.intervention;
    final bool loading = provider.isLoading;
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
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF1A1A1A),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates_outlined, color: Colors.amberAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Here's a suggestion: ${_suggestionPrompts[_suggestionIndex]}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'New suggestion',
                    onPressed: () {
                      setState(() {
                        _suggestionIndex = (_suggestionIndex + 1) % _suggestionPrompts.length;
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _contentController,
            minLines: 8,
            maxLines: null,
            maxLength: _maxChars,
            decoration: const InputDecoration(
              hintText: 'Write the thought that\'s bothering you…',
              counterText: '',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _contentController,
              builder: (_, value, __) => Text(
                '${value.text.length}/$_maxChars',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.blueGrey.shade400),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B7CFA), Color(0xFF8B5CF6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: loading ? null : _onSubmit,
                child: SizedBox(
                  height: 52,
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Reflect on This Thought',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ),
          ),
          if (lastIntervention != null) ...[
            const SizedBox(height: 24),
            _InterventionCard(intervention: lastIntervention),
          ],
          if (provider.error != null) ...[
            const SizedBox(height: 12),
            Text(provider.error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }
}

class _InterventionCard extends StatelessWidget {
  final CBTIntervention intervention;

  const _InterventionCard({required this.intervention});

  @override
  Widget build(BuildContext context) {
    final (plantName, plantDescription) = _splitPlantSuggestion(intervention.plantSuggestion);
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
              if (intervention.distortionDescription != null) ...[
                const SizedBox(height: 4),
                Text(
                  intervention.distortionDescription!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade300),
                ),
              ],
            if (intervention.moodLabel != null) ...[
              const SizedBox(height: 6),
              Text('Detected emotion: ${intervention.moodLabel}', style: Theme.of(context).textTheme.bodySmall),
            ],
            if (intervention.emotionConfidence != null)
              Text('Emotion confidence: ${(intervention.emotionConfidence! * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
            if (intervention.emotionIntensity != null)
              Text('Emotion intensity: ${intervention.emotionIntensity!.toStringAsFixed(1)}/10', style: Theme.of(context).textTheme.bodySmall),
            if (intervention.certainty != null || intervention.feedbackType != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (intervention.certainty != null)
                    Chip(
                      label: Text(intervention.certainty!),
                      backgroundColor: Colors.blueGrey.shade800,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (intervention.feedbackType != null)
                    Chip(
                      label: Text(intervention.feedbackType!),
                      backgroundColor: Colors.deepPurple.shade700,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (intervention.combinedConfidence != null) ...[
              const SizedBox(height: 6),
              Text(
                'Combined confidence: ${(intervention.combinedConfidence! * 100).round()}%'
                '${intervention.confidenceLevel != null ? ' (${intervention.confidenceLevel})' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (intervention.riskLevel != null || intervention.safetyOverride) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: intervention.safetyOverride
                      ? Colors.red.shade900.withOpacity(0.35)
                      : Colors.orange.shade900.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: intervention.safetyOverride ? Colors.redAccent : Colors.orangeAccent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk level: ${intervention.riskLevel ?? "unknown"}'
                      '${intervention.riskScore != null ? " (${intervention.riskScore!.toStringAsFixed(2)})" : ""}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (intervention.safetyMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(intervention.safetyMessage!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueGrey.withOpacity(0.25)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reframe builder template', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Thought: ____________________'),
                  Text('Evidence for: ________________'),
                  Text('Evidence against: _____________'),
                  Text('Balanced thought (your words): ____________________'),
                ],
              ),
            ),
            if (intervention.microInterventionTitle != null ||
                intervention.microInterventionPrompt != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade900.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.cyanAccent.shade100.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intervention.microInterventionTitle ?? 'Micro-intervention',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.cyanAccent.shade100),
                    ),
                    if (intervention.microInterventionPrompt != null) ...[
                      const SizedBox(height: 4),
                      Text(intervention.microInterventionPrompt!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
              const SizedBox(height: 12),
            ],
            Text('Explanation:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.distortionExplanation, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Emotional acknowledgment:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.emotionalAcknowledgment, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Safety mode:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.interventionMode, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orangeAccent)),
            const SizedBox(height: 12),
            Text('CBT technique:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.cbtTechnique, style: Theme.of(context).textTheme.bodyMedium),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plantName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.greenAccent.shade200),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plantDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green.shade300),
                      ),
                      if (intervention.plantReferenceUrl != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Reference: ${intervention.plantReferenceUrl}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade300),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _PlantReferenceImage(
                  assetPath:
                      PlantSuggestionDatabase.assetPathForEmotion(intervention.moodLabel),
                  url: intervention.plantImageUrl,
                ),
              ],
            ),
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

class _PlantReferenceImage extends StatelessWidget {
  final String assetPath;
  final String? url;

  const _PlantReferenceImage({required this.assetPath, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          if (url == null || url!.isEmpty) {
            return const Icon(Icons.local_florist_outlined, color: Colors.greenAccent);
          }
          return Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.local_florist_outlined, color: Colors.greenAccent),
          );
        },
      ),
    );
  }
}

(String, String) _splitPlantSuggestion(String raw) {
  final parts = raw.split(' - ');
  if (parts.length >= 2) {
    final name = parts.first.trim();
    final desc = parts.sublist(1).join(' - ').trim();
    return (name, desc);
  }
  return (raw.trim(), '');
}
