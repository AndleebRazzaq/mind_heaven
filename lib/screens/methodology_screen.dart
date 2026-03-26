import 'package:flutter/material.dart';

/// FYP methodology: CBT framework, flow, algorithm, evaluation metrics, confusion matrix.
class MethodologyScreen extends StatelessWidget {
  const MethodologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Methodology & Theory')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: '1. CBT Theoretical Framework',
            child: const Text(
              'Cognitive Behavioral Therapy (CBT) posits that thoughts, emotions, and behaviors are interconnected. '
              'Cognitive distortions (e.g. all-or-nothing thinking, overgeneralization, catastrophizing) maintain negative affect. '
              'The app applies CBT by: (a) detecting distortions in journal text via an NLP/ML classification model, '
              '(b) offering evidence-based reframing prompts, and (c) combining text and voice for emotion/stress estimation '
              'to deliver targeted micro-interventions (e.g. breathing, grounding). Environmental psychology is integrated '
              'via plant recommendations (e.g. snake plant, lavender) linked to mood and stress states.',
            ),
          ),
          _Section(
            title: '2. System Flow',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FlowStep('1', 'Check-In: User inputs text or voice'),
                _FlowStep('2', 'NLP + audio analysis → mood & stress level'),
                _FlowStep('3', 'Calming micro-intervention shown'),
                _FlowStep('4', 'Journal: User writes free text'),
                _FlowStep(
                  '5',
                  'Distortion classifier → cognitive distortion type',
                ),
                _FlowStep('6', 'CBT reframing + plant suggestion'),
                _FlowStep('7', 'Analytics: weekly/monthly mood trends'),
              ],
            ),
          ),
          _Section(
            title: '3. Algorithm Description',
            child: const Text(
              '• Emotion/Stress: Text is vectorized (e.g. TF-IDF or embeddings), fed to a classifier (e.g. SVM, BERT fine-tuned) for mood labels; '
              'voice features (pitch, jitter, energy) are used in a separate or fused model for stress. '
              'Fusion can be late (concatenate label probabilities) or early (shared representation).\n\n'
              '• Distortion: Journal text is classified into distortion categories (e.g. 10 types from Burns). '
              'A trained model (e.g. fine-tuned transformer or keyword + ML hybrid) outputs a label; '
              'rule-based or template-based reframing maps label → CBT response. '
              'Plant suggestion uses mood/distortion or stress level to pick from a predefined list.',
            ),
          ),
          _Section(
            title: '4. Evaluation Metrics',
            child: const Text(
              '• Emotion/distortion classification: Accuracy, macro F1, precision/recall per class. '
              '• Stress regression (if continuous): MAE, RMSE, correlation with self-report. '
              '• User study: Pre/post stress (e.g. perceived stress scale), satisfaction, engagement (check-ins/week, journal entries). '
              '• Ablation: Text-only vs voice-only vs fused for emotion/stress accuracy.',
            ),
          ),
          _Section(
            title: '5. Confusion Matrix (Emotion Detection)',
            child: const Text(
              'A typical confusion matrix rows = true class, columns = predicted. '
              'Example classes: Calm, Anxious, Sad, Neutral, Reflective. '
              'Report per-class precision, recall, F1; highlight misclassifications (e.g. Anxious predicted as Sad) for model improvement. '
              'Use a held-out test set and report metrics after cross-validation.',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.blue.shade300),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String step;
  final String text;

  const _FlowStep(this.step, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
