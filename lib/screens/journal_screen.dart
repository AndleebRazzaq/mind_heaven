import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cbt_intervention.dart';
import '../presentation/providers/journal_provider.dart';
import 'reframe_output_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  static const int _maxChars = 1200;
  static const List<String> _writingSuggestions = [
    'What felt heavy today, and what thought stayed with you?',
    'Which moment today shifted your mood the most?',
    'What are you telling yourself about this situation right now?',
    'If your mind feels crowded, write the loudest thought first.',
    'What is one event you keep replaying in your head?',
  ];

  final TextEditingController _contentController = TextEditingController();
  final Random _random = Random();
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
    super.dispose();
  }

  Future<void> _onAnalyze() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      setState(() => _inputError = 'Share a few lines first so I can support you meaningfully.');
      return;
    }
    if (text.length < 20) {
      setState(() => _inputError = 'Write at least 20 characters so the reflection can be more accurate.');
      return;
    }
    setState(() => _inputError = null);

    await context.read<JournalProvider>().analyze(text, stressBefore: null);
    if (!mounted) return;

    final provider = context.read<JournalProvider>();
    final intervention = provider.intervention;
    if (intervention == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReframeOutputScreen(
          intervention: intervention, 
          entry: provider.lastEntry!,
        ),
      ),
    );
  }

  String _todayLabel() {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  String _pickSuggestion() => _writingSuggestions[_random.nextInt(_writingSuggestions.length)];

  void _refreshSuggestion() => setState(() => _currentSuggestion = _pickSuggestion());

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "What's on your mind today?",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(_todayLabel(), style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade400)),
                const SizedBox(height: 10),
                Text(
                  'Write freely. Gain clarity. Reframe with support.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade300),
                ),
                const SizedBox(height: 16),
                
                // Suggestion Box
                GestureDetector(
                  onTap: _refreshSuggestion,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14161B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentSuggestion,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade200),
                          ),
                        ),
                        const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF60A5FA)),
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
                    builder: (_, value, __) => Text(
                      '${value.text.length}/$_maxChars',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                if (_inputError != null) ...[
                  Text(_inputError!, style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 12),
                ],

                // Gradient Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFF8A6BFF), Color(0xFFE4A4C1)]),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF8A6BFF).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: provider.isLoading ? null : _onAnalyze,
                      child: Center(
                        child: provider.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF101216)))
                            : const Text('Analyze thoughts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101216))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Supportive insights only. This app does not provide medical diagnosis.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade400, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 12),
                  Text(provider.error!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          if (provider.isLoading) const _AnalyzingOverlay(),
        ],
      ),
    );
  }
}

class _AnalyzingOverlay extends StatelessWidget {
  const _AnalyzingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          color: const Color(0xFF14161B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF8A6BFF))),
                const SizedBox(height: 20),
                Text(
                  'Reframing your thoughts...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our AI is finding a balanced perspective for you.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
