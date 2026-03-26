import 'package:flutter/material.dart';

/// Simple AI Companion: light chatbot for emotional check-in.
class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<_ChatBubble> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatBubble(isUser: false, text: 'Hi. How are you feeling right now? You can type a short message.'));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Placeholder: replace with real NLU/API for responses.
  String _getReply(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('stress') || lower.contains('anxious')) return 'Stress is tough. Try a 4-7-8 breath: breathe in 4, hold 7, out 8. Want to try a quick journal note?';
    if (lower.contains('sad') || lower.contains('down')) return 'Thanks for sharing. It\'s okay to feel low. One small kind thing you can do for yourself today?';
    if (lower.contains('good') || lower.contains('fine') || lower.contains('ok')) return 'Good to hear. If you\'d like to capture the moment, the Journal tab is a great place.';
    if (lower.contains('help')) return 'You can use Check-In for quick mood & stress, Journal for CBT-style reflection, and here for a short chat.';
    return 'I hear you. Writing in the Journal or doing a Check-In can help clarify how you\'re doing.';
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    setState(() {
      _messages.add(_ChatBubble(isUser: true, text: text));
      _messages.add(_ChatBubble(isUser: false, text: _getReply(text)));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final m = _messages[i];
              return Align(
                alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: m.isUser ? Colors.blue.shade700 : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  child: Text(m.text, style: Theme.of(context).textTheme.bodyMedium),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(hintText: 'Type a message...'),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBubble {
  final bool isUser;
  final String text;
  _ChatBubble({required this.isUser, required this.text});
}
