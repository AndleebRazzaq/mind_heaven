import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/cbt_engine/plant_suggestion_database.dart';
import '../models/cbt_intervention.dart';
import '../presentation/providers/journal_provider.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

enum _OutputStep { emotion, pattern, prompts, calmReset, reframe, plant }

class _JournalScreenState extends State<JournalScreen> {
  static const int _maxChars = 1200;
  static const List<String> _writingSuggestions = [
    'What felt heavy today, and what thought stayed with you?',
    'Which moment today shifted your mood the most?',
    'What are you telling yourself about this situation right now?',
    'If your mind feels crowded, write the loudest thought first.',
    'What is one event you keep replaying in your head?',
  ];

  static const Map<String, String> _plantMoodLineByName = {
    'lavender':
        'Lavender is often associated with relaxation and gentle focus.',
    'snake plant':
        'Snake Plant can make your space feel steadier and grounded.',
    'zz plant': 'ZZ Plant adds calm visual structure with very low upkeep.',
    'pothos': 'Pothos can make a room feel softer and more alive.',
    'peace lily': 'Peace Lily is often used to create a gentler atmosphere.',
    'aloe vera': 'Aloe Vera brings a clean, simple calming feel to a desk.',
  };

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _balancedController = TextEditingController();
  List<TextEditingController> _promptAnswerControllers = [];
  final Random _random = Random();

  _OutputStep? _currentStep;
  double _stressAfter = 5;
  String? _inputError;
  late String _currentSuggestion;

  @override
  void initState() {
    super.initState();
    _currentSuggestion = _pickSuggestion();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _balancedController.dispose();
    for (final c in _promptAnswerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onAnalyze() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _inputError =
            'Share a few lines first so I can support you meaningfully.';
      });
      return;
    }
    if (text.length < 20) {
      setState(() {
        _inputError =
            'Write at least 20 characters so the reflection can be more accurate.';
      });
      return;
    }
    setState(() => _inputError = null);

    await context.read<JournalProvider>().analyze(text, stressBefore: null);
    if (!mounted) return;

    final intervention = context.read<JournalProvider>().intervention;
    if (intervention == null) return;

    setState(() {
      _balancedController.text = _balancedSuggestion(intervention);
      final prompts = _prompts(intervention);
      for (final c in _promptAnswerControllers) {
        c.dispose();
      }
      _promptAnswerControllers = List.generate(
        prompts.length,
        (_) => TextEditingController(),
      );
      _currentStep = _OutputStep.emotion;
    });
  }

  String _todayLabel() {
    const weekdays = [
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
    final now = DateTime.now();
    final dayName = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$dayName, $month ${now.day}';
  }

  String _pickSuggestion() {
    return _writingSuggestions[_random.nextInt(_writingSuggestions.length)];
  }

  void _refreshSuggestion() {
    setState(() => _currentSuggestion = _pickSuggestion());
  }

  void _resetSession() {
    context.read<JournalProvider>().clearSession();
    setState(() {
      _contentController.clear();
      _balancedController.clear();
      for (final c in _promptAnswerControllers) {
        c.dispose();
      }
      _promptAnswerControllers = [];
      _currentStep = null;
      _inputError = null;
    });
  }

  void _savePerspective() {
    context.read<JournalProvider>().savePostRating(_stressAfter);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Balanced perspective and post-rating saved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isHighDistress(CBTIntervention i) {
    final intensity = i.emotionIntensity ?? 0;
    return i.suggestBreathing || intensity >= 7;
  }

  bool _showCalm(CBTIntervention i) {
    return i.suggestBreathing || (i.emotionIntensity ?? 0) >= 7;
  }

  String _resolvedTone(CBTIntervention i) {
    final incoming = (i.coachingTone ?? '').trim().toLowerCase();
    if (incoming == 'gentle' ||
        incoming == 'balanced' ||
        incoming == 'direct') {
      return incoming;
    }
    final intensity = i.emotionIntensity ?? 5;
    if (intensity >= 7) return 'gentle';
    if (intensity <= 4) return 'direct';
    return 'balanced';
  }

  String _emotionValidationText(CBTIntervention i) {
    final tone = _resolvedTone(i);
    final emotion = (i.moodLabel?.trim().isNotEmpty ?? false)
        ? i.moodLabel!.trim().toLowerCase()
        : 'a lot at once';

    if (tone == 'direct') {
      return 'You seem to be feeling $emotion. Let us work through this clearly.';
    }
    return 'You seem to be feeling $emotion. That can feel intense and overwhelming.';
  }

  String _distortionInsight(CBTIntervention i) {
    final line =
        i.distortionLogicLine?.trim() ?? i.distortionInsightLine?.trim();
    if (line != null && line.isNotEmpty) return line;

    final label = i.detectedDistortionLabel?.trim();
    if (label == null || label.isEmpty) {
      return 'This pattern can increase emotional pressure by making one moment define everything.';
    }
    return 'This pattern may resemble "$label".';
  }

  String _intensityLine(CBTIntervention i) {
    final value = i.emotionIntensity;
    final band = (i.intensityBand ?? _bandFromValue(value)).toLowerCase();
    if (value == null) {
      return 'Emotion intensity: ${_prettyBand(band)}';
    }
    return 'Emotion intensity: ${_prettyBand(band)} (${value.toStringAsFixed(1)}/10)';
  }

  String _bandFromValue(double? value) {
    if (value == null) return 'moderate';
    if (value >= 7) return 'high';
    if (value >= 4) return 'moderate';
    return 'low';
  }

  String _prettyBand(String band) {
    switch (band) {
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      default:
        return 'Moderate';
    }
  }

  List<String> _prompts(CBTIntervention i) {
    if (i.cognitivePrompts.isNotEmpty) return i.cognitivePrompts;
    return const [
      'What evidence supports this thought?',
      'What evidence challenges it?',
      'Is there another possible explanation?',
    ];
  }

  String _balancedSuggestion(CBTIntervention i) {
    final tone = _resolvedTone(i);
    final balanced = i.balancedAlternative?.trim();
    if (balanced != null && balanced.isNotEmpty) return balanced;
    final base = i.balancedReframeSuggestion?.trim();
    if (base != null && base.isNotEmpty) {
      if (tone == 'gentle') {
        return '$base I can take one small step after I calm my body.';
      }
      return base;
    }
    if (tone == 'gentle') {
      return 'This is stressful, but I can slow down and take one manageable next step.';
    }
    if (tone == 'direct') {
      return 'There is more than one possible outcome, and I can respond with a balanced plan.';
    }
    return 'This is difficult, but it may not turn out as badly as I fear.';
  }

  String _plantMoodLine(String plantName) {
    final key = plantName.toLowerCase();
    for (final entry in _plantMoodLineByName.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return 'A calmer space can gently support emotional reset and focus.';
  }

  _OutputStep? _nextStep(CBTIntervention i) {
    final step = _currentStep;
    if (step == null) return null;

    final highDistress = _isHighDistress(i);
    final showCalm = _showCalm(i);

    switch (step) {
      case _OutputStep.emotion:
        return _OutputStep.pattern;
      case _OutputStep.pattern:
        return _OutputStep.prompts;
      case _OutputStep.prompts:
        if (highDistress && showCalm) return _OutputStep.calmReset;
        return _OutputStep.reframe;
      case _OutputStep.calmReset:
        return _OutputStep.reframe;
      case _OutputStep.reframe:
        return _OutputStep.plant;
      case _OutputStep.plant:
        return null;
    }
  }

  void _onContinue(CBTIntervention i) {
    if (_currentStep == _OutputStep.prompts) {
      final refined = _buildGuidedBalanced(i);
      if (refined.isNotEmpty) {
        _balancedController.text = refined;
      }
    }
    final next = _nextStep(i);
    if (next == null) return;
    setState(() => _currentStep = next);
  }

  String _buildGuidedBalanced(CBTIntervention i) {
    final base = _balancedSuggestion(i);
    final insights = <String>[];
    for (final c in _promptAnswerControllers) {
      final text = c.text.trim();
      if (text.isNotEmpty) insights.add(text);
    }
    if (insights.isEmpty) return base;
    final brief = insights.take(2).join(' ');
    final emotion = (i.moodLabel?.trim().isNotEmpty ?? false)
        ? i.moodLabel!.toLowerCase()
        : 'this way';
    final distortion = i.detectedDistortionLabel?.trim();
    final awareness = (distortion != null && distortion.isNotEmpty)
        ? 'I notice a possible $distortion pattern here.'
        : 'I notice this thought pattern may be amplifying stress.';
    return 'I feel $emotion, and that feeling is valid. $awareness '
        'Based on what I wrote ($brief), a balanced view is: $base';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final intervention = provider.intervention;
    final theme = Theme.of(context);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What\'s on your mind today?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _todayLabel(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade400,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Write freely. Gain clarity. Reframe with support.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _refreshSuggestion,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14161B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentSuggestion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: Color(0xFF60A5FA),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                minLines: 9,
                maxLines: null,
                maxLength: _maxChars,
                decoration: const InputDecoration(
                  hintText: 'Write anything that feels important right now...',
                  counterText: '',
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _contentController,
                  builder: (_, value, _) => Text(
                    '${value.text.length}/$_maxChars',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_inputError != null) ...[
                Text(
                  _inputError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: provider.isLoading ? null : _onAnalyze,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4C93D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Analyze thoughts'),
              ),
              const SizedBox(height: 8),
              Text(
                'Supportive insights only. This app does not provide medical diagnosis.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade400,
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  provider.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              if (intervention != null) ...[
                const SizedBox(height: 24),
                if (intervention.safetyOverride)
                  _SafetySupportCard(message: intervention.safetyMessage)
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: _buildStepCard(
                      key: ValueKey(_currentStep),
                      intervention: intervention,
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _resetSession,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Start a new reflection'),
                ),
              ],
            ],
          ),
        ),
        if (provider.isLoading) const _AnalyzingOverlay(),
      ],
    );
  }

  Widget _buildStepCard({
    required Key key,
    required CBTIntervention intervention,
  }) {
    final step = _currentStep ?? _OutputStep.emotion;
    final hasNext = _nextStep(intervention) != null;

    switch (step) {
      case _OutputStep.emotion:
        final emotionLabel = intervention.moodLabel?.trim().isNotEmpty == true
            ? intervention.moodLabel!.trim()
            : (intervention.emotionConfidence != null
                  ? 'Detected'
                  : 'Not available');
        return _StepCard(
          key: key,
          title: 'Emotion insight',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsightValueCard(
                title: 'Detected emotion',
                value: emotionLabel,
                confidence: intervention.emotionConfidence,
                intensity: intervention.emotionIntensity,
              ),
              const SizedBox(height: 10),
              Text(_emotionValidationText(intervention)),
              const SizedBox(height: 8),
              Text(
                'Noticing and naming emotions is often the first step toward clearer thinking.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              if (intervention.emotionalSupportMessage?.trim().isNotEmpty ??
                  false) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    intervention.emotionalSupportMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blueGrey.shade200,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _intensityLine(intervention),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade200,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          buttonLabel: hasNext ? 'Continue' : null,
          onContinue: hasNext ? () => _onContinue(intervention) : null,
        );
      case _OutputStep.pattern:
        final pattern =
            intervention.detectedDistortionLabel?.trim().isNotEmpty == true
            ? intervention.detectedDistortionLabel!.trim()
            : 'Not available';
        return _StepCard(
          key: key,
          title: 'Thinking pattern identified',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsightValueCard(title: 'Detected distortion', value: pattern),
              const SizedBox(height: 10),
              Text(_distortionInsight(intervention)),
              if (intervention.eventSummary?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  'Event: ${intervention.eventSummary}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade300,
                  ),
                ),
              ],
              if (intervention.coreBeliefs.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Core belief: "${intervention.coreBeliefs.first}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade300,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                intervention.distortionDescription?.trim().isNotEmpty == true
                    ? intervention.distortionDescription!.trim()
                    : intervention.distortionExplanation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
            ],
          ),
          buttonLabel: hasNext ? 'Continue' : null,
          onContinue: hasNext ? () => _onContinue(intervention) : null,
        );
      case _OutputStep.prompts:
        final prompts = _prompts(intervention);
        return _StepCard(
          key: key,
          title: 'Reflect & reframe',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Take your time with these prompts. There are no wrong answers.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.extension_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Consider:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (var idx = 0; idx < prompts.length; idx++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('? ${prompts[idx]}'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _promptAnswerControllers.length > idx
                            ? _promptAnswerControllers[idx]
                            : null,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Write your answer...',
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          buttonLabel: hasNext ? 'Continue' : null,
          onContinue: hasNext ? () => _onContinue(intervention) : null,
        );
      case _OutputStep.calmReset:
        return _StepCard(
          key: key,
          title: 'Regulation support',
          body: _BreathingExerciseCard(
            techniqueTitle: intervention.microInterventionTitle,
            techniqueInstructions: intervention.breathingTechnique,
            emotionalSupportMessage: intervention.emotionalSupportMessage,
          ),
          buttonLabel: hasNext ? 'Continue' : null,
          onContinue: hasNext ? () => _onContinue(intervention) : null,
        );
      case _OutputStep.reframe:
        return _StepCard(
          key: key,
          title: 'Balanced perspective',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'A more balanced way to think about this could be:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _balancedController,
                minLines: 3,
                maxLines: 7,
                decoration: const InputDecoration(
                  hintText: 'Suggested balanced conclusion...',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'After reflecting, how intense is this now? (${_stressAfter.toStringAsFixed(1)}/10)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              Slider(
                value: _stressAfter,
                min: 1,
                max: 10,
                divisions: 18,
                label: _stressAfter.toStringAsFixed(1),
                onChanged: (v) => setState(() => _stressAfter = v),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: _savePerspective,
                    child: const Text('Save reflection'),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      final current = _balancedController.text.trim();
                      if (current.isEmpty) {
                        _balancedController.text =
                            'This situation is difficult, but there is a balanced way to respond.';
                      }
                    },
                    child: const Text('Create balanced thought'),
                  ),
                ],
              ),
            ],
          ),
          buttonLabel: hasNext ? 'Continue' : null,
          onContinue: hasNext ? () => _onContinue(intervention) : null,
        );
      case _OutputStep.plant:
        final (plantName, plantDescription) = _splitPlantSuggestion(
          intervention.plantSuggestion,
        );
        final care = PlantSuggestionDatabase.careMetaForPlantName(plantName);
        return _StepCard(
          key: key,
          title: 'Environmental support for calm',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Validated plant support based on current mood pattern.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _plantMoodLine(plantName),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade300,
                ),
              ),
              const SizedBox(height: 12),
              _PlantSummaryCard(
                plantName: plantName,
                plantDescription: plantDescription,
                care: care,
                imageUrl: intervention.plantImageUrl,
                moodLabel: intervention.moodLabel,
              ),
            ],
          ),
          buttonLabel: null,
        );
    }
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final Widget body;
  final String? buttonLabel;
  final VoidCallback? onContinue;

  const _StepCard({
    super.key,
    required this.title,
    required this.body,
    this.buttonLabel,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          body,
          if (buttonLabel != null && onContinue != null) ...[
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4C93D8),
                foregroundColor: Colors.white,
              ),
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightValueCard extends StatelessWidget {
  final String title;
  final String value;
  final double? confidence;
  final double? intensity;

  const _InsightValueCard({
    required this.title,
    required this.value,
    this.confidence,
    this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D25),
        borderRadius: BorderRadius.circular(10),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade300),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (confidence != null) ...[
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(confidence! * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (intensity != null) ...[
            const SizedBox(height: 2),
            Text(
              'Intensity: ${intensity!.toStringAsFixed(1)}/10',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _BreathingExerciseCard extends StatefulWidget {
  final String? techniqueTitle;
  final String? techniqueInstructions;
  final String? emotionalSupportMessage;

  const _BreathingExerciseCard({
    this.techniqueTitle,
    this.techniqueInstructions,
    this.emotionalSupportMessage,
  });

  @override
  State<_BreathingExerciseCard> createState() => _BreathingExerciseCardState();
}

class _BreathingExerciseCardState extends State<_BreathingExerciseCard>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 60;
  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 2;
  static const int _exhaleSeconds = 6;
  static const int _cycleSeconds =
      _inhaleSeconds + _holdSeconds + _exhaleSeconds;

  late final AnimationController _controller;
  Timer? _timer;
  int _secondsLeft = _totalSeconds;
  bool _running = false;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _inhaleSeconds),
      lowerBound: 0.75,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _totalSeconds;
      _running = true;
      _paused = false;
    });
    _animateForCurrentPhase();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _controller.stop();
        setState(() {
          _secondsLeft = 0;
          _running = false;
          _paused = false;
        });
        return;
      }

      final next = _secondsLeft - 1;
      final previousPhase = _phaseAt(_secondsLeft);
      final nextPhase = _phaseAt(next);
      if (previousPhase != nextPhase) _animateForPhase(nextPhase);

      setState(() => _secondsLeft = next);
    });
  }

  void _togglePause() {
    if (!_running) return;
    setState(() => _paused = !_paused);
    if (_paused) {
      _timer?.cancel();
      _controller.stop();
      return;
    }
    _animateForCurrentPhase();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _controller.stop();
        setState(() {
          _secondsLeft = 0;
          _running = false;
          _paused = false;
        });
        return;
      }
      final next = _secondsLeft - 1;
      final previousPhase = _phaseAt(_secondsLeft);
      final nextPhase = _phaseAt(next);
      if (previousPhase != nextPhase) _animateForPhase(nextPhase);
      setState(() => _secondsLeft = next);
    });
  }

  void _restart() {
    _timer?.cancel();
    _controller.value = 0.75;
    setState(() {
      _secondsLeft = _totalSeconds;
      _running = false;
      _paused = false;
    });
  }

  String _phaseAt(int secondsLeft) {
    final progress = _totalSeconds - secondsLeft;
    final inCycle = progress % _cycleSeconds;
    if (inCycle < _inhaleSeconds) return 'Inhale';
    if (inCycle < _inhaleSeconds + _holdSeconds) return 'Hold';
    return 'Exhale';
  }

  void _animateForCurrentPhase() => _animateForPhase(_phaseAt(_secondsLeft));

  void _animateForPhase(String phase) {
    if (phase == 'Inhale') {
      _controller.animateTo(
        1.2,
        duration: const Duration(seconds: _inhaleSeconds),
      );
    } else if (phase == 'Exhale') {
      _controller.animateTo(
        0.75,
        duration: const Duration(seconds: _exhaleSeconds),
      );
    } else {
      _controller.stop();
    }
  }

  String get _phaseLabel {
    if (!_running && _secondsLeft == 0) return 'Complete';
    if (_paused) return 'Paused';
    if (!_running) return 'Ready to start';
    return '${_phaseAt(_secondsLeft)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.techniqueTitle ?? 'Take a 60-second pause to calm your body.',
        ),
        const SizedBox(height: 6),
        Text(
          'Inhale 4s, hold 2s, exhale 6s.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade300),
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => Transform.scale(
              scale: _controller.value,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: const Color(0xFF4C93D8).withOpacity(0.2),
                  // ignore: deprecated_member_use
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF60A5FA).withOpacity(0.75),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _running || _secondsLeft == 0
                        ? '${_secondsLeft}s'
                        : '${_totalSeconds}s',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            _phaseLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade300),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: _running ? null : _start,
              child: const Text('Start regulation'),
            ),
            FilledButton.tonal(
              onPressed: _running ? _togglePause : null,
              child: Text(_paused ? 'Resume' : 'Pause'),
            ),
            FilledButton.tonal(
              onPressed: _restart,
              child: const Text('Restart'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlantSummaryCard extends StatelessWidget {
  final String plantName;
  final String plantDescription;
  final PlantCareMeta care;
  final String? imageUrl;
  final String? moodLabel;

  const _PlantSummaryCard({
    required this.plantName,
    required this.plantDescription,
    required this.care,
    required this.imageUrl,
    required this.moodLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plantName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.greenAccent.shade200,
                ),
              ),
              const SizedBox(height: 6),
              Text('Light: ${care.lightLabel}'),
              const SizedBox(height: 2),
              Text('Water: ${care.waterLabel}'),
              const SizedBox(height: 8),
              Text(plantDescription),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _PlantReferenceImage(
          assetPath: PlantSuggestionDatabase.assetPathForEmotion(moodLabel),
          url: imageUrl,
        ),
      ],
    );
  }
}

class _SafetySupportCard extends StatelessWidget {
  final String? message;

  const _SafetySupportCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      title: 'Additional support recommended',
      body: Text(
        message ??
            'Your reflection suggests significant emotional distress. Consider reaching out to a licensed professional or someone you trust.',
      ),
    );
  }
}

class _AnalyzingOverlay extends StatelessWidget {
  const _AnalyzingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(height: 14),
                Text('Analyzing your reflection...'),
              ],
            ),
          ),
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
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(8),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.green.withOpacity(0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          if (url == null || url!.isEmpty) {
            return const Icon(
              Icons.local_florist_outlined,
              color: Colors.greenAccent,
            );
          }
          return Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(
              Icons.local_florist_outlined,
              color: Colors.greenAccent,
            ),
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
