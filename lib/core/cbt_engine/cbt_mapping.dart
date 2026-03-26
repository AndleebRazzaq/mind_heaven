import '../../models/journal_entry.dart';
import '../../models/cbt_intervention.dart';

/// Layer 2: Rule-based CBT mapping. One distortion → one technique + exercise + plant.
/// Clinically aligned; no free-form AI generation.

class CBTMapping {
  CBTMapping._();

  static const _distortionExplanations = {
    DistortionType.magnification: 'Magnification (or catastrophizing) means seeing the worst possible outcome as certain. It amplifies problems and minimizes your ability to cope.',
    DistortionType.overgeneralization: 'Overgeneralization means taking one event and concluding it always or never happens. One setback becomes "I always fail."',
    DistortionType.allOrNothing: 'All-or-nothing thinking sees only extremes: success or failure, perfect or useless. There is no middle ground.',
    DistortionType.shouldStatements: '"Should" and "must" statements create rigid rules that increase guilt and pressure when reality does not match.',
    DistortionType.labeling: 'Labeling means attaching a fixed, negative identity to yourself or others based on one behavior (e.g. "I am a failure").',
    DistortionType.personalization: 'Personalization means taking excessive blame for events that involve many factors beyond your control.',
    DistortionType.jumpingToConclusions: 'Jumping to conclusions includes mind-reading (assuming others\' thoughts) and fortune-telling (assuming the worst outcome).',
    DistortionType.mentalFilter: 'Mental filter means focusing only on negative details and ignoring positive or neutral information.',
    DistortionType.disqualifyingPositive: 'Disqualifying the positive means dismissing good events or qualities as "not counting."',
    DistortionType.emotionalReasoning: 'Emotional reasoning means assuming that because you feel something, it must be true (e.g. "I feel useless, so I am.").',
  };

  static const _techniques = {
    DistortionType.magnification: 'Evidence examination',
    DistortionType.overgeneralization: 'Reframing',
    DistortionType.allOrNothing: 'Gray-area thinking',
    DistortionType.shouldStatements: 'Flexible language',
    DistortionType.labeling: 'Label the behavior, not the person',
    DistortionType.personalization: 'Shared responsibility',
    DistortionType.jumpingToConclusions: 'Cognitive restructuring',
    DistortionType.mentalFilter: 'Balanced evidence',
    DistortionType.disqualifyingPositive: 'Credit the positive',
    DistortionType.emotionalReasoning: 'Separate feeling from fact',
  };

  static const _reframes = {
    DistortionType.magnification: 'List three more realistic outcomes between "best" and "worst." What would you tell a friend?',
    DistortionType.overgeneralization: 'Replace "always" or "never" with "sometimes" or "this time." Look for one exception.',
    DistortionType.allOrNothing: 'Find one small step between "perfect" and "failure." What is one thing that went okay?',
    DistortionType.shouldStatements: 'Try "I\'d prefer to…" or "It would be nice if…" instead of "should."',
    DistortionType.labeling: 'Describe the action: "I made a mistake" instead of "I am a failure."',
    DistortionType.personalization: 'List other factors that played a role. You are not responsible for everything.',
    DistortionType.jumpingToConclusions: 'What evidence do you have? Ask for proof instead of assuming.',
    DistortionType.mentalFilter: 'List one positive or neutral fact you might be overlooking.',
    DistortionType.disqualifyingPositive: 'Treat good events as real. What would you say if a friend had this good thing?',
    DistortionType.emotionalReasoning: 'Feelings are valid, but not proof. What would an outsider conclude?',
  };

  static const _exerciseTitles = {
    DistortionType.magnification: 'Three outcomes',
    DistortionType.overgeneralization: 'Find exceptions',
    DistortionType.allOrNothing: 'One gray step',
    DistortionType.shouldStatements: 'Softer language',
    DistortionType.labeling: 'Behavior, not identity',
    DistortionType.personalization: 'Other factors',
    DistortionType.jumpingToConclusions: 'Evidence check',
    DistortionType.mentalFilter: 'Balanced entry',
    DistortionType.disqualifyingPositive: 'Count the positive',
    DistortionType.emotionalReasoning: 'Fact vs feeling',
  };

  static const _exerciseDescriptions = {
    DistortionType.magnification: 'Write worst, best, and most realistic outcome. Then one small step toward the realistic one.',
    DistortionType.overgeneralization: 'Write one time when the "always" or "never" was not true.',
    DistortionType.allOrNothing: 'Write one thing you did that was "good enough" today.',
    DistortionType.shouldStatements: 'Rewrite one "should" as "I\'d prefer to…" and notice how it feels.',
    DistortionType.labeling: 'Describe what happened in one sentence without using a label like "failure."',
    DistortionType.personalization: 'List three factors outside of you that could have contributed.',
    DistortionType.jumpingToConclusions: 'Write what you assumed, then one piece of evidence for and against.',
    DistortionType.mentalFilter: 'Write one negative and one positive or neutral fact about the same situation.',
    DistortionType.disqualifyingPositive: 'Write one good thing that happened and why it counts.',
    DistortionType.emotionalReasoning: 'Write "I feel…" and "The facts are…" in two separate sentences.',
  };

  static const _plantSuggestions = {
    DistortionType.magnification: 'Lavender — scent linked to relaxation; good when stress is high.',
    DistortionType.overgeneralization: 'Snake plant — low light, air-purifying; steady presence.',
    DistortionType.allOrNothing: 'Peace lily — gentle; reminds us of middle ground.',
    DistortionType.shouldStatements: 'Jade plant — resilient; less pressure to be perfect.',
    DistortionType.labeling: 'Spider plant — easy to grow; focus on growth, not labels.',
    DistortionType.personalization: 'Aloe vera — soothing; care without over-responsibility.',
    DistortionType.jumpingToConclusions: 'Basil — calming scent; pause before concluding.',
    DistortionType.mentalFilter: 'Pothos — hardy and positive; balance the view.',
    DistortionType.disqualifyingPositive: 'Sunflower — bright; helps the positive count.',
    DistortionType.emotionalReasoning: 'Chamomile — calming; supports stepping back from emotion.',
  };

  static String _distortionLabel(DistortionType t) {
    switch (t) {
      case DistortionType.allOrNothing: return 'All-or-Nothing';
      case DistortionType.overgeneralization: return 'Overgeneralization';
      case DistortionType.mentalFilter: return 'Mental Filter';
      case DistortionType.disqualifyingPositive: return 'Disqualifying the Positive';
      case DistortionType.jumpingToConclusions: return 'Jumping to Conclusions';
      case DistortionType.magnification: return 'Magnification / Catastrophizing';
      case DistortionType.emotionalReasoning: return 'Emotional Reasoning';
      case DistortionType.shouldStatements: return 'Should Statements';
      case DistortionType.labeling: return 'Labeling';
      case DistortionType.personalization: return 'Personalization';
      default: return 'None detected';
    }
  }

  static String _acknowledgeEmotion(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    if (mood.contains('anxiety')) {
      return 'It makes sense that this feels overwhelming right now.';
    }
    if (mood.contains('sad')) {
      return 'Thank you for sharing this. Feeling low can be heavy.';
    }
    if (mood.contains('anger')) {
      return 'Your frustration is valid and worth understanding carefully.';
    }
    if (mood.contains('calm')) {
      return 'You are showing good awareness and regulation.';
    }
    return 'Thank you for expressing your thoughts honestly.';
  }

  static String _plantByEmotion(String? moodLabel) {
    final mood = (moodLabel ?? '').toLowerCase();
    if (mood.contains('anxiety')) {
      return 'Lavender - associated with calming sensory environments.';
    }
    if (mood.contains('sad')) {
      return 'Peace Lily - often linked with soothing indoor ambience.';
    }
    if (mood.contains('anger')) {
      return 'Snake Plant - grounding presence and easy maintenance.';
    }
    if (mood.contains('fatigue') || mood.contains('tired')) {
      return 'Rosemary - associated with alertness support.';
    }
    return 'Pothos - low-maintenance greenery that supports a calm space.';
  }

  /// Returns full CBT intervention with confidence-aware safety logic.
  /// >70% direct CBT correction, 50-70% reflective questioning, <50% emotional validation.
  static CBTIntervention getIntervention(
    DistortionType distortionType, {
    bool highStress = false,
    String? moodLabel,
    double? stressLevel,
    double confidence = 0.0,
  }) {
    final explanation = distortionType == DistortionType.unknown
        ? 'Writing it down is a good first step. Consider one alternative perspective.'
        : (_distortionExplanations[distortionType] ?? 'Reflect on the thought and look for a balanced view.');
    final technique = _techniques[distortionType] ?? 'Reflection';
    final reframe = _reframes[distortionType] ?? 'Consider one alternative perspective.';
    final exerciseTitle = _exerciseTitles[distortionType] ?? 'Reflection';
    final exerciseDesc = _exerciseDescriptions[distortionType] ?? 'Write one alternative way to see the situation.';
    final mode = confidence > 0.70
        ? 'Direct CBT correction'
        : (confidence >= 0.50
            ? 'Reflective questioning'
            : 'Emotional validation');

    var safeReframe = reframe;
    var safeExerciseTitle = exerciseTitle;
    var safeExerciseDesc = exerciseDesc;

    if (mode == 'Reflective questioning') {
      safeReframe =
          'What evidence supports this thought, and what evidence suggests another perspective?';
      safeExerciseTitle = 'Guided reflection';
      safeExerciseDesc =
          'Answer two questions: What am I assuming? What is a balanced alternative?';
    } else if (mode == 'Emotional validation') {
      safeReframe =
          'Your feelings are valid. Let us slow down before challenging thoughts.';
      safeExerciseTitle = 'Validation pause';
      safeExerciseDesc =
          'Name the feeling, breathe for 60 seconds, and write one self-compassionate sentence.';
    }

    return CBTIntervention(
      distortionExplanation: explanation,
      emotionalAcknowledgment: _acknowledgeEmotion(moodLabel),
      interventionMode: mode,
      cbtTechnique: technique,
      reframeGuidance: safeReframe,
      copingExerciseTitle: safeExerciseTitle,
      copingExerciseDescription: safeExerciseDesc,
      plantSuggestion: _plantByEmotion(moodLabel),
      suggestBreathing: highStress,
      breathingTechnique: highStress ? '4-7-8 breathing: inhale 4s, hold 7s, exhale 8s. Repeat twice.' : null,
      moodLabel: moodLabel,
      stressLevel: stressLevel,
      detectedDistortionLabel: distortionType == DistortionType.unknown ? null : _distortionLabel(distortionType),
      confidence: confidence,
    );
  }
}
