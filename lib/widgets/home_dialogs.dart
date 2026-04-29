import 'package:flutter/material.dart';
import 'dart:math' as math;

class CheckInDialog extends StatefulWidget {
  const CheckInDialog({super.key});

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  String? selectedEmotion;
  final TextEditingController _contextController = TextEditingController();

  final emotions = [
    ('😊', 'Happy'),
    ('😔', 'Sad'),
    ('😰', 'Anxious'),
    ('😤', 'Frustrated'),
    ('😴', 'Tired'),
    ('😌', 'Calm'),
  ];

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Check-in'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How are you feeling right now?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions.map((e) {
              final (emoji, label) = e;
              return FilterChip(
                label: Text('$emoji $label'),
                selected: selectedEmotion == label,
                onSelected: (selected) {
                  setState(() {
                    selectedEmotion = selected ? label : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('What\'s the context?'),
          const SizedBox(height: 8),
          TextField(
            controller: _contextController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'People, places, activities...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: selectedEmotion == null
              ? null
              : () {
                  Navigator.pop(context, {
                    'emotion': selectedEmotion,
                    'context': _contextController.text,
                  });
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class SavoringJournalDialog extends StatefulWidget {
  const SavoringJournalDialog({super.key});

  @override
  State<SavoringJournalDialog> createState() => _SavoringJournalDialogState();
}

class _SavoringJournalDialogState extends State<SavoringJournalDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Savoring Journal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What are you grateful for today?'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Write about moments of joy, gratitude, or beauty...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () {
                  Navigator.pop(context, _controller.text);
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class BreathingExerciseDialog extends StatefulWidget {
  const BreathingExerciseDialog({super.key});

  @override
  State<BreathingExerciseDialog> createState() =>
      _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<BreathingExerciseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
    setState(() => _isAnimating = _controller.isAnimating);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Breathing Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Take a calm breath', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(
            'Inhale 4s • Hold 2s • Exhale 6s',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = _controller.value;
              final scale =
                  0.75 + (math.sin(value * 2 * math.pi) + 1) / 2 * 0.45;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4C93D8).withValues(alpha: 0.2),
                    border: Border.all(
                      color: const Color(0xFF60A5FA).withValues(alpha: 0.75),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '60s',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: _toggleAnimation,
          child: Text(_isAnimating ? 'Stop' : 'Start'),
        ),
      ],
    );
  }
}
