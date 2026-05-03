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

  final double _stressAfter = 5;
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

    setState(() {});
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
      _inputError = null;
    });
  }

  Widget _buildConsolidatedOutput(CBTIntervention intervention) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (intervention.insight?.isNotEmpty ?? false)
          _StepCard(
            title: '🧠 Insight',
            body: Text(
              intervention.insight!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey.shade100,
                  ),
            ),
          ),
        if (intervention.pattern?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _StepCard(
            title: '⚠️ Pattern',
            body: Text(
              intervention.pattern!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey.shade100,
                  ),
            ),
          ),
        ],
        if (intervention.suggestBreathing) ...[
          const SizedBox(height: 12),
          _StepCard(
            title: '🧘 Breathing',
            body: _BreathingExerciseCard(
              techniqueTitle: intervention.microInterventionTitle,
              techniqueInstructions: intervention.breathingTechnique,
            ),
          ),
        ],
        if (intervention.reframe?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _StepCard(
            title: '🔁 Reframe',
            body: Text(
              intervention.reframe!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey.shade100,
                  ),
            ),
          ),
        ],
        if (intervention.action?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _StepCard(
            title: '🌱 Action',
            body: Text(
              intervention.action!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey.shade100,
                  ),
            ),
          ),
        ],
        if (intervention.plantSuggestion?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _StepCard(
            title: '🪴 Plant Suggestion',
            body: Text(
              intervention.plantSuggestion!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey.shade100,
                  ),
            ),
          ),
        ],
      ],
    );
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
                  _buildConsolidatedOutput(intervention),
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

}

class _StepCard extends StatelessWidget {
  final String title;
  final Widget body;

  const _StepCard({
    required this.title,
    required this.body,
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
        ],
      ),
    );
  }
}


class _BreathingExerciseCard extends StatefulWidget {
  final String? techniqueTitle;
  final String? techniqueInstructions;
  const _BreathingExerciseCard({
    this.techniqueTitle,
    this.techniqueInstructions,
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


