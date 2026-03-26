import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/mood_entry.dart';
import '../models/cbt_intervention.dart';
import '../core/intervention/intervention_builder.dart';
import '../services/storage_service.dart';

/// Check-In: text + voice → Layer 1 (fusion 70% text, 30% voice) → Layer 3 intervention.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final InterventionBuilder _interventionBuilder = InterventionBuilder();
  final StorageService _storage = StorageService();
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _loading = false;
  CBTIntervention? _result;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _startListening() async {
    if (!_speechAvailable) return;
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) => setState(() {
        _textController.text = result.recognizedWords;
      }),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _onSubmit() async {
    final text = _textController.text.trim();
    setState(() => _loading = true);
    try {
      final intervention = await _interventionBuilder.buildForCheckIn(text);
      final moodEntry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        moodLabel: intervention.moodLabel ?? 'Neutral',
        stressLevel: intervention.stressLevel ?? 0.4,
      );
      await _storage.addCheckIn(moodEntry);
      setState(() {
        _result = intervention;
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
            'How are you feeling right now?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Type or use voice. We use 70% text + 30% voice for stress; mood from text.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'e.g. I feel a bit stressed about work...',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_speechAvailable)
                FilledButton.icon(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  label: Text(_isListening ? 'Stop' : 'Voice'),
                ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _loading ? null : _onSubmit,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Check In'),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 28),
            _ResultCard(intervention: _result!),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final CBTIntervention intervention;

  const _ResultCard({required this.intervention});

  @override
  Widget build(BuildContext context) {
    final stress = intervention.stressLevel ?? 0.0;
    final stressPercent = (stress * 100).round();
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Mood: ', style: Theme.of(context).textTheme.titleSmall),
                Text(intervention.moodLabel ?? '—', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blue.shade300)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Stress level: $stressPercent%', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: stress, backgroundColor: Colors.blue.shade900),
            const SizedBox(height: 16),
            Text('Suggestion:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(intervention.reframeGuidance, style: Theme.of(context).textTheme.bodyMedium),
            if (intervention.suggestBreathing && intervention.breathingTechnique != null) ...[
              const SizedBox(height: 12),
              Text('Breathing:', style: Theme.of(context).textTheme.titleSmall),
              Text(intervention.breathingTechnique!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.tealAccent)),
            ],
            const SizedBox(height: 8),
            Text('Plant: ${intervention.plantSuggestion}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green.shade300)),
          ],
        ),
      ),
    );
  }
}
