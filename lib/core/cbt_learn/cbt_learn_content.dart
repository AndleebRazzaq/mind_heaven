class CbtLearnCategory {
  final String id;
  final String title;
  final String subtitle;
  final String icon;

  const CbtLearnCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class CbtLearnSection {
  final String heading;
  final String body;

  const CbtLearnSection({required this.heading, required this.body});
}

class CbtLearnArticle {
  final String id;
  final String categoryId;
  final String title;
  final String summary;
  final int readMinutes;
  final String difficulty;
  final List<CbtLearnSection> sections;

  const CbtLearnArticle({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.summary,
    required this.readMinutes,
    required this.difficulty,
    required this.sections,
  });
}

class CbtLearnContent {
  CbtLearnContent._();

  static const categories = <CbtLearnCategory>[
    CbtLearnCategory(
      id: 'thoughts',
      title: 'Understanding Thoughts',
      subtitle: 'How thoughts shape stress and behavior',
      icon: '📘',
    ),
    CbtLearnCategory(
      id: 'emotions',
      title: 'Understanding Emotions',
      subtitle: 'Name and regulate emotional intensity',
      icon: '📙',
    ),
    CbtLearnCategory(
      id: 'distortions',
      title: 'Cognitive Distortions',
      subtitle: 'Common thinking patterns that increase stress',
      icon: '📗',
    ),
    CbtLearnCategory(
      id: 'tools',
      title: 'Practical CBT Tools',
      subtitle: 'Short methods for real-life situations',
      icon: '🌿',
    ),
  ];

  static final articles = <CbtLearnArticle>[
    // Understanding thoughts (1-5)
    CbtLearnArticle(
      id: 'what-are-cognitive-distortions',
      categoryId: 'thoughts',
      title: 'What Are Cognitive Distortions?',
      summary: 'Learn what distortions are and why they intensify stress.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation:
            'Cognitive distortions are automatic thinking patterns that can make situations feel more extreme than they are.',
        example:
            'After one mistake, the mind may jump to: "I always fail."',
        stressImpact:
            'These patterns increase emotional intensity and reduce flexible problem-solving.',
        reflection:
            'Which distortion do you notice most often in your own thinking?',
        reframe:
            'A thought can feel true without being fully accurate.',
      ),
    ),
    CbtLearnArticle(
      id: 'thoughts-vs-facts',
      categoryId: 'thoughts',
      title: 'Thoughts vs Facts: How to Tell the Difference',
      summary: 'Separate interpretations from objective evidence.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'Thoughts are interpretations; facts are verifiable details.',
        example: 'Thought: "They dislike me." Fact: "They have not replied yet."',
        stressImpact:
            'When thoughts are treated as facts, anxiety rises quickly.',
        reflection: 'What evidence supports this thought? What evidence challenges it?',
        reframe: 'I can hold uncertainty without assuming the worst.',
      ),
    ),
    CbtLearnArticle(
      id: 'negativity-bias',
      categoryId: 'thoughts',
      title: 'Why the Mind Focuses on Negatives',
      summary: 'Understand negativity bias and how to rebalance attention.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation:
            'The brain naturally scans for threat, so negatives often feel louder than positives.',
        example:
            'You receive 10 good comments and 1 criticism, but only remember the criticism.',
        stressImpact: 'This focus can distort perspective and maintain stress.',
        reflection: 'What neutral or positive detail might you be missing?',
        reframe: 'Both difficult and supportive details can be true at the same time.',
      ),
    ),
    CbtLearnArticle(
      id: 'stress-and-thinking',
      categoryId: 'thoughts',
      title: 'How Stress Changes Thinking Patterns',
      summary: 'See how physiological stress shapes your thought style.',
      readMinutes: 4,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation:
            'High arousal narrows attention and can trigger rigid or catastrophic thinking.',
        example: 'Under pressure, minor uncertainty can feel like immediate danger.',
        stressImpact: 'This loop keeps both body and mind in threat mode.',
        reflection: 'Do your thoughts become more extreme when your body is tense?',
        reframe: 'Regulate body first, then challenge the thought.',
      ),
    ),
    CbtLearnArticle(
      id: 'thought-emotion-behavior-cycle',
      categoryId: 'thoughts',
      title: 'The Thought → Emotion → Behavior Cycle',
      summary: 'Understand the core CBT loop and where to intervene.',
      readMinutes: 4,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'Thoughts influence feelings, which influence actions and outcomes.',
        example:
            'Thought: "I will fail" → Emotion: anxiety → Behavior: avoidance.',
        stressImpact: 'Avoidance reinforces fear and keeps the cycle active.',
        reflection: 'Which step in the cycle is easiest for you to change first?',
        reframe: 'A small behavior shift can weaken an unhelpful cycle.',
      ),
    ),

    // Emotions (6-10)
    CbtLearnArticle(
      id: 'naming-emotions-reduces-stress',
      categoryId: 'emotions',
      title: 'Why Naming Emotions Reduces Stress',
      summary: 'Emotion labeling helps shift the brain toward regulation.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'Naming emotions increases clarity and lowers overwhelm.',
        example: '“I feel fear and pressure,” instead of “Everything is wrong.”',
        stressImpact: 'Labeling interrupts emotional escalation.',
        reflection: 'What emotion is most present right now?',
        reframe: 'I can name this feeling and still choose my next step.',
      ),
    ),
    CbtLearnArticle(
      id: 'emotional-intensity',
      categoryId: 'emotions',
      title: 'Emotional Intensity: Why Feelings Feel Overwhelming',
      summary: 'Learn why emotions can feel bigger than the situation.',
      readMinutes: 4,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation:
            'Intensity rises when stress load, uncertainty, and cognitive distortions combine.',
        example:
            'A neutral delay can feel like rejection when arousal is high.',
        stressImpact: 'High intensity reduces cognitive flexibility.',
        reflection: 'What helps your intensity shift from high to moderate?',
        reframe: 'Strong feelings are valid, and they can pass with regulation.',
      ),
    ),
    CbtLearnArticle(
      id: 'anxiety-vs-fear',
      categoryId: 'emotions',
      title: 'Anxiety vs Fear: What Is the Difference?',
      summary: 'Differentiate present threat from future-oriented worry.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'Fear responds to immediate threat; anxiety anticipates future threat.',
        example: 'Fear: loud crash now. Anxiety: “What if tomorrow goes badly?”',
        stressImpact: 'Future-focused worry can sustain chronic tension.',
        reflection: 'Is this a current danger or a prediction?',
        reframe: 'I can prepare for uncertainty without assuming disaster.',
      ),
    ),
    CbtLearnArticle(
      id: 'sadness-vs-depression-spectrum',
      categoryId: 'emotions',
      title: 'Sadness vs Depression: Understanding the Spectrum',
      summary: 'A gentle psychoeducation guide without diagnosing.',
      readMinutes: 4,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation:
            'Sadness is a common emotion; persistent low mood with broad impact may require support.',
        example: 'Feeling down after stress is common; persistent hopelessness deserves care.',
        stressImpact: 'Low mood can bias thinking toward negatives and withdrawal.',
        reflection: 'How long has this mood pattern been present?',
        reframe: 'Seeking support is a strength, not a failure.',
      ),
    ),
    CbtLearnArticle(
      id: 'avoidance-and-anxiety',
      categoryId: 'emotions',
      title: 'How Avoidance Increases Anxiety',
      summary: 'Why short-term relief can worsen long-term stress.',
      readMinutes: 4,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation:
            'Avoidance reduces stress briefly but teaches the brain the situation is dangerous.',
        example: 'Avoiding one call brings relief, but next call feels even harder.',
        stressImpact: 'Anxiety grows as confidence shrinks.',
        reflection: 'What is one tiny approach step you can take?',
        reframe: 'Small approach steps build safety and confidence over time.',
      ),
    ),

    // Distortions (11-21)
    CbtLearnArticle(
      id: 'all-or-nothing-thinking',
      categoryId: 'distortions',
      title: 'What Is All-or-Nothing Thinking?',
      summary: 'Black-and-white thinking that ignores the middle ground.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'This pattern views outcomes as total success or total failure.',
        example: '“If I am not perfect, I am useless.”',
        stressImpact: 'Extremes increase pressure and shame.',
        reflection: 'What does “good enough” look like here?',
        reframe: 'This may be imperfect and still meaningful progress.',
      ),
    ),
    CbtLearnArticle(
      id: 'overgeneralization',
      categoryId: 'distortions',
      title: 'What Is Overgeneralization?',
      summary: 'Turning one event into a global pattern.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'One setback becomes “always” or “never.”',
        example: '“I failed this once, so I always fail.”',
        stressImpact: 'It blocks learning and fuels hopelessness.',
        reflection: 'Can you name one exception?',
        reframe: 'This is one event, not my whole story.',
      ),
    ),
    CbtLearnArticle(
      id: 'mental-filter',
      categoryId: 'distortions',
      title: 'What Is Mental Filter?',
      summary: 'Seeing only negatives and filtering out positives.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'Attention locks onto what went wrong and ignores what went right.',
        example: 'You focus on one criticism and forget nine compliments.',
        stressImpact: 'Mood drops as perspective narrows.',
        reflection: 'What supportive detail am I overlooking?',
        reframe: 'The negative detail matters, and it is not the full picture.',
      ),
    ),
    CbtLearnArticle(
      id: 'disqualifying-the-positive',
      categoryId: 'distortions',
      title: 'What Is Disqualifying the Positive?',
      summary: 'Rejecting good outcomes as invalid or accidental.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'Positive evidence is dismissed before it can help perspective.',
        example: '“They were just being nice; it does not count.”',
        stressImpact: 'Confidence stays low despite real progress.',
        reflection: 'What if this positive outcome truly counts?',
        reframe: 'It is fair to acknowledge this positive result.',
      ),
    ),
    CbtLearnArticle(
      id: 'jumping-to-conclusions',
      categoryId: 'distortions',
      title: 'What Is Jumping to Conclusions?',
      summary: 'Assuming outcomes without enough evidence.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'The mind fills in missing information too quickly.',
        example: '“No reply means they are upset with me.”',
        stressImpact: 'Assumptions increase anxiety and conflict.',
        reflection: 'What facts do I actually have?',
        reframe: 'I may not have enough evidence to be certain.',
      ),
    ),
    CbtLearnArticle(
      id: 'mind-reading',
      categoryId: 'distortions',
      title: 'What Is Mind Reading?',
      summary: 'Assuming you know what others think.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'You infer negative judgments without direct proof.',
        example: '“They think I am incompetent.”',
        stressImpact: 'Social anxiety and self-criticism intensify.',
        reflection: 'Have they explicitly said this?',
        reframe: 'I do not truly know what others are thinking.',
      ),
    ),
    CbtLearnArticle(
      id: 'catastrophizing',
      categoryId: 'distortions',
      title: 'What Is Catastrophizing? (And How to Gently Shift It)',
      summary: 'Why the mind predicts disaster and how to rebalance perspective.',
      readMinutes: 5,
      difficulty: 'Beginner',
      sections: [
        CbtLearnSection(
          heading: 'Simple Explanation',
          body:
              'Catastrophizing happens when the mind predicts the worst possible outcome - even when evidence is limited. It turns uncertainty into disaster and can feel very convincing.',
        ),
        CbtLearnSection(
          heading: 'Real-Life Example',
          body:
              'You make a small mistake and the mind says, “This will ruin everything.” A balanced alternative is: “This is stressful, but I can repair and recover.”',
        ),
        CbtLearnSection(
          heading: 'Why It Increases Stress',
          body:
              'When worst-case images feel real, the body shifts into threat mode: heart rate rises, tension increases, and problem-solving narrows.',
        ),
        CbtLearnSection(
          heading: 'Reflection Questions',
          body:
              'What is the realistic probability of the worst outcome? If it happened, how would I cope? What is more likely? Have I handled similar situations before?',
        ),
        CbtLearnSection(
          heading: 'Balanced Reframe',
          body:
              '“This situation is stressful, but the worst-case scenario is not guaranteed. Even if things are hard, I can handle them step by step.”',
        ),
      ],
    ),
    CbtLearnArticle(
      id: 'emotional-reasoning',
      categoryId: 'distortions',
      title: 'What Is Emotional Reasoning?',
      summary: 'Believing feelings are proof of facts.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'If I feel it strongly, it must be true.',
        example: '“I feel useless, so I am useless.”',
        stressImpact: 'Emotion and evidence become fused.',
        reflection: 'What are the facts separate from my feelings?',
        reframe: 'Feelings are real, but they are not always facts.',
      ),
    ),
    CbtLearnArticle(
      id: 'should-statements',
      categoryId: 'distortions',
      title: 'What Are Should Statements?',
      summary: 'Rigid inner rules that increase guilt and pressure.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: '“Should” and “must” can become harsh, inflexible demands.',
        example: '“I should never make mistakes.”',
        stressImpact: 'Rigidity increases shame and frustration.',
        reflection: 'Can I turn this demand into a preference?',
        reframe: 'I prefer this outcome, but I can tolerate imperfection.',
      ),
    ),
    CbtLearnArticle(
      id: 'labeling',
      categoryId: 'distortions',
      title: 'What Is Labeling?',
      summary: 'Defining identity by one mistake or event.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'A single behavior is turned into a global identity label.',
        example: '“I failed once, so I am a failure.”',
        stressImpact: 'Identity-level shame keeps stress high.',
        reflection: 'What specific behavior happened instead?',
        reframe: 'One mistake does not define who I am.',
      ),
    ),
    CbtLearnArticle(
      id: 'personalization',
      categoryId: 'distortions',
      title: 'What Is Personalization?',
      summary: 'Taking too much responsibility for complex outcomes.',
      readMinutes: 3,
      difficulty: 'Beginner',
      sections: _genericSections(
        explanation: 'You assume blame for events shaped by many factors.',
        example: '“They are upset, so it must be my fault.”',
        stressImpact: 'Excessive guilt and rumination increase stress.',
        reflection: 'What factors were outside my control?',
        reframe: 'I may not be solely responsible for this outcome.',
      ),
    ),

    // Practical tools (22-30)
    CbtLearnArticle(
      id: 'three-question-thought-challenge',
      categoryId: 'tools',
      title: 'The 3-Question Thought Challenge',
      summary: 'A quick method for reframing unhelpful thoughts.',
      readMinutes: 3,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'Use three questions: evidence for, evidence against, likely outcome.',
        example: 'Write each answer in one sentence.',
        stressImpact: 'This quickly reduces cognitive rigidity.',
        reflection: 'Which of the three questions helps you most?',
        reframe: 'I can challenge this thought with evidence.',
      ),
    ),
    CbtLearnArticle(
      id: 'build-balanced-reframe',
      categoryId: 'tools',
      title: 'How to Build a Balanced Reframe',
      summary: 'Turn extreme thoughts into realistic, supportive alternatives.',
      readMinutes: 4,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'A balanced reframe is realistic, not fake positivity.',
        example: 'From “I will fail” to “I may struggle, but I can prepare and adapt.”',
        stressImpact: 'Balanced thoughts reduce panic and improve action.',
        reflection: 'Does your reframe feel believable?',
        reframe: 'This is hard, and I can still respond effectively.',
      ),
    ),
    CbtLearnArticle(
      id: 'sixty-second-reset',
      categoryId: 'tools',
      title: '60-Second Nervous System Reset',
      summary: 'Use breath to lower arousal before cognitive reframing.',
      readMinutes: 3,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'Slow exhale breathing signals safety to the nervous system.',
        example: 'Inhale 4s, exhale 6s for 60 seconds.',
        stressImpact: 'Lower arousal improves cognitive flexibility.',
        reflection: 'What changed in your body after one minute?',
        reframe: 'I can calm my body before I challenge my thoughts.',
      ),
    ),
    CbtLearnArticle(
      id: 'respond-instead-of-react',
      categoryId: 'tools',
      title: 'How to Respond Instead of React',
      summary: 'Pause-based strategy for emotionally loaded moments.',
      readMinutes: 3,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'A pause creates space between trigger and action.',
        example: 'Take one breath, label emotion, choose one value-based action.',
        stressImpact: 'Reduces impulsive choices driven by stress.',
        reflection: 'What pause cue can you use in daily life?',
        reframe: 'I can choose response over reflex.',
      ),
    ),
    CbtLearnArticle(
      id: 'reduce-rumination',
      categoryId: 'tools',
      title: 'How to Reduce Rumination',
      summary: 'Shift from repetitive thinking to grounded action.',
      readMinutes: 4,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'Rumination repeats problems without moving to solutions.',
        example: 'Set a 5-minute worry window, then do one actionable step.',
        stressImpact: 'Rumination sustains anxiety and low mood.',
        reflection: 'What action can replace another rumination loop?',
        reframe: 'I can move from replaying to responding.',
      ),
    ),
    CbtLearnArticle(
      id: 'behavioral-activation',
      categoryId: 'tools',
      title: 'Behavioral Activation for Low Mood',
      summary: 'Small actions that help lift mood over time.',
      readMinutes: 4,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation:
            'Motivation often follows action; waiting for motivation can prolong low mood.',
        example: 'Do one 5-minute meaningful action now.',
        stressImpact: 'Action interrupts withdrawal loops.',
        reflection: 'What tiny action feels realistic today?',
        reframe: 'Small steps still count as progress.',
      ),
    ),
    CbtLearnArticle(
      id: 'environmental-mood-boosters',
      categoryId: 'tools',
      title: 'Environmental Mood Boosters (Plants & Space)',
      summary: 'Use your space to support calm and focus.',
      readMinutes: 3,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'Environmental cues can support emotional regulation habits.',
        example: 'Add one calming visual anchor, like a low-maintenance plant.',
        stressImpact: 'A soothing environment reduces baseline tension.',
        reflection: 'What one change makes your space feel calmer?',
        reframe: 'Small environment shifts can support big emotional shifts.',
      ),
    ),
    CbtLearnArticle(
      id: 'digital-boundaries',
      categoryId: 'tools',
      title: 'Digital Boundaries for Emotional Health',
      summary: 'Protect attention and mood from digital overload.',
      readMinutes: 4,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'Constant alerts keep the nervous system in reactive mode.',
        example: 'Batch notifications at set times instead of all day.',
        stressImpact: 'Lower interruption load improves emotional stability.',
        reflection: 'Which digital boundary would help most this week?',
        reframe: 'I can design my environment to support regulation.',
      ),
    ),
    CbtLearnArticle(
      id: 'personal-coping-plan',
      categoryId: 'tools',
      title: 'Creating a Personal Coping Plan',
      summary: 'Build a simple plan for stress spikes and low mood days.',
      readMinutes: 5,
      difficulty: 'Practical',
      sections: _genericSections(
        explanation: 'A coping plan lists early signs, supports, and first actions.',
        example: 'My first 3 steps: breathe, text support, write balanced thought.',
        stressImpact: 'Pre-planning reduces panic and decision fatigue.',
        reflection: 'What three steps belong in your plan?',
        reframe: 'I can prepare for hard moments without fearing them.',
      ),
    ),
  ];

  static List<CbtLearnArticle> byCategory(String categoryId) {
    return articles.where((a) => a.categoryId == categoryId).toList();
  }

  static CbtLearnArticle? byId(String id) {
    for (final article in articles) {
      if (article.id == id) return article;
    }
    return null;
  }

  static String? articleIdForDistortionLabel(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    final l = label.toLowerCase();
    if (l.contains('all-or-nothing')) return 'all-or-nothing-thinking';
    if (l.contains('overgeneral')) return 'overgeneralization';
    if (l.contains('mental filter')) return 'mental-filter';
    if (l.contains('disqualifying')) return 'disqualifying-the-positive';
    if (l.contains('jumping')) return 'jumping-to-conclusions';
    if (l.contains('mind reading')) return 'mind-reading';
    if (l.contains('catastroph') || l.contains('magnification')) return 'catastrophizing';
    if (l.contains('emotional reasoning')) return 'emotional-reasoning';
    if (l.contains('should')) return 'should-statements';
    if (l.contains('label')) return 'labeling';
    if (l.contains('personalization')) return 'personalization';
    return null;
  }
}

List<CbtLearnSection> _genericSections({
  required String explanation,
  required String example,
  required String stressImpact,
  required String reflection,
  required String reframe,
}) {
  return [
    CbtLearnSection(heading: 'Simple explanation', body: explanation),
    CbtLearnSection(heading: 'Example', body: example),
    CbtLearnSection(heading: 'Why it increases stress', body: stressImpact),
    CbtLearnSection(heading: 'Reflection questions', body: reflection),
    CbtLearnSection(heading: 'Balanced reframe', body: reframe),
  ];
}
