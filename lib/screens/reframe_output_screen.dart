import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cbt_intervention.dart';
import '../core/cbt_engine/plant_suggestion_database.dart';

class ReframeOutputScreen extends StatelessWidget {
  final CBTIntervention intervention;

  const ReframeOutputScreen({super.key, required this.intervention});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intensity = intervention.emotionIntensity ?? 0;
    final showBreathing = intervention.suggestBreathing || intensity >= 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reframe your thought by CBT',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Insight Card
            _OutputCard(
              icon: Icons.psychology_outlined,
              iconColor: const Color(0xFFB4C6FC),
              title: 'Insight',
              content: (intervention.insight?.isNotEmpty == true)
                  ? intervention.insight!
                  : 'Your feelings are valid and worth exploring.',
            ),
            const SizedBox(height: 16),

            // Pattern Card
            _OutputCard(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFFF7B8A),
              title: 'Pattern',
              content: '',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (intervention.detectedDistortionLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7B8A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF7B8A).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        intervention.detectedDistortionLabel!,
                        style: const TextStyle(
                          color: Color(0xFFFF7B8A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    intervention.pattern ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Breathing Card (Conditional)
            if (showBreathing) ...[
              _OutputCard(
                icon: Icons.self_improvement,
                iconColor: const Color(0xFF60A5FA),
                title: 'Breathing',
                content: '',
                child: _BreathingWidget(
                  title: intervention.microInterventionTitle,
                  instructions: intervention.breathingTechnique,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Reframe Card (Important Highlight)
            _OutputCard(
              icon: Icons.repeat_rounded,
              iconColor: const Color(0xFF8A6BFF),
              title: 'Reframe',
              content: (intervention.reframe?.isNotEmpty == true)
                  ? intervention.reframe!
                  : 'Try to look at this situation from a more balanced perspective.',
              isHighlighted: true,
            ),
            const SizedBox(height: 16),

            // Action Card
            _OutputCard(
              icon: Icons.spa_outlined,
              iconColor: const Color(0xFF4ADE80),
              title: 'Action',
              content: intervention.action ?? '',
              child: intervention.plantSuggestion?.isNotEmpty == true ? Column(
                children: [
                  if (intervention.action?.isNotEmpty == true) const SizedBox(height: 12),
                  _PlantActionCard(
                    plantSuggestion: intervention.plantSuggestion ?? '',
                    moodLabel: intervention.moodLabel,
                    imageUrl: intervention.plantImageUrl,
                  ),
                ],
              ) : null,
            ),
            
            const SizedBox(height: 32),
            
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check),
              label: const Text('I feel better now'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF8A6BFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final Widget? child;
  final bool isHighlighted;

  const _OutputCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.child,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF1E1B2E) : const Color(0xFF14161B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted 
            ? const Color(0xFF8A6BFF).withValues(alpha: 0.4) 
            : Colors.white.withValues(alpha: 0.08),
          width: isHighlighted ? 1.5 : 1,
        ),
        boxShadow: isHighlighted ? [
          BoxShadow(
            color: const Color(0xFF8A6BFF).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 12),
            child!,
          ],
        ],
      ),
    );
  }
}

class _BreathingWidget extends StatefulWidget {
  final String? title;
  final String? instructions;

  const _BreathingWidget({this.title, this.instructions});

  @override
  State<_BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<_BreathingWidget> with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 60;
  late final AnimationController _controller;
  Timer? _timer;
  int _secondsLeft = _totalSeconds;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _secondsLeft = _totalSeconds;
    });
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _stop();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _running = false;
      _secondsLeft = _totalSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.instructions ?? 'Inhale deeply as the circle expands, and exhale as it shrinks.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _controller.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF60A5FA).withValues(alpha: 0.6),
                        const Color(0xFF60A5FA).withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.5), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${_secondsLeft}s',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _running ? _stop : _start,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF60A5FA),
              side: const BorderSide(color: Color(0xFF60A5FA)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_running ? 'Stop' : 'Start Breathing'),
          ),
        ),
      ],
    );
  }
}

class _PlantActionCard extends StatelessWidget {
  final String plantSuggestion;
  final String? moodLabel;
  final String? imageUrl;

  const _PlantActionCard({
    required this.plantSuggestion,
    this.moodLabel,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final (name, desc) = _splitPlant(plantSuggestion);
    final assetPath = PlantSuggestionDatabase.assetPathForEmotion(moodLabel);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.local_florist, color: Color(0xFF4ADE80)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF4ADE80),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (String, String) _splitPlant(String raw) {
    final parts = raw.split(' - ');
    if (parts.length >= 2) {
      return (parts[0].trim(), parts.sublist(1).join(' - ').trim());
    }
    return (raw.trim(), '');
  }
}
