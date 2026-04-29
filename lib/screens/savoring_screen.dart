import 'package:flutter/material.dart';

class SavoringScreen extends StatefulWidget {
  const SavoringScreen({super.key});

  @override
  State<SavoringScreen> createState() => _SavoringScreenState();
}

class _SavoringScreenState extends State<SavoringScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<String> _prompts = [
    "What's a recent event that inspired you?",
    "What is a small detail you noticed today that brought you joy?",
    "Describe a moment when you felt completely at peace recently.",
  ];
  int _promptIndex = 0;

  void _changePrompt() {
    setState(() {
      _promptIndex = (_promptIndex + 1) % _prompts.length;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(height: 2, color: const Color(0xFF8A6BFF)),
              ),
              Expanded(
                flex: 6,
                child: Container(height: 2, color: const Color(0xFF2C2C30)),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _prompts[_promptIndex],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB4C6FC),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _changePrompt,
                      icon: const Icon(Icons.loop, size: 18),
                      label: const Text('Change prompt'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB4C6FC),
                        side: const BorderSide(color: Color(0xFFB4C6FC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Describe the experience',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      maxLines: 10,
                      style: const TextStyle(color: Colors.white, height: 1.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF14161B),
                        hintText:
                            'In your mind, replay the experiences associated with your answer. What did you see, smell, and taste? What did you think?',
                        hintMaxLines: 4,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2C2C30),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF8A6BFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Summarize your entry with a short title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      maxLength: 60,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF14161B),
                        counterText: '', // Hide default counter
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2C2C30),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF8A6BFF),
                          ),
                        ),
                      ),
                      onChanged: (text) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_titleController.text.length} / 60',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Continue Button at the bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    // Logic to save savoring journal
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8A6BFF), // Purple
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
