# Mind Heaven – FYP Idea Flow & Structure

## Problem
Support **preventive mental wellness** through emotion awareness, self-reflection, and structured CBT-based coping in a single mobile app.

## Core Idea Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│  Check-In       │     │  CBT Journal      │     │  Analytics          │
│  (Text / Voice) │     │  (Text only)      │     │  (Charts & Trends)   │
└────────┬────────┘     └────────┬──────────┘     └──────────┬──────────┘
         │                       │                            │
         ▼                       ▼                            ▼
   Stress + Mood            Distortion                  Weekly / Monthly
   Detection                Classification               Emotion Trends
         │                       │                            │
         ▼                       ▼                            │
   Micro-Intervention       CBT Reframe +                    │
   (e.g. breathing)         Plant Suggestion                  │
         │                       │                            │
         └───────────────────────┴────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │  AI Companion (Chatbot) │
                    │  Light emotional chat  │
                    └────────────────────────┘
```

## Screen-by-Screen Strategy

| Screen        | Input        | Processing (to implement)        | Output                          |
|---------------|-------------|-----------------------------------|---------------------------------|
| **Check-In**  | Text / Voice| NLP mood + ML voice stress        | Mood label, stress %, suggestion|
| **Journal**   | Text only   | Distortion classification model   | Distortion type, reframe, plant |
| **Analytics** | Stored data | Aggregation over time            | Weekly chart, emotion distribution |
| **Companion** | Text chat   | Simple NLU / rules or API        | Short supportive replies        |

## Academic Angles (for examiners)

- **CBT framework**: In-app Methodology section (info icon) describes theory, flow, algorithm, metrics, confusion matrix.
- **NLP pipeline**: Journal → vectorize → classify distortion → reframe; Check-In → text/voice → emotion + stress.
- **Evaluation**: Classification accuracy, F1, confusion matrix for emotion/distortion; user metrics (engagement, satisfaction).
- **Behavior-based intervention**: Micro-interventions and reframes are tied to detected state (stress level, distortion type).

## Tech Stack (current)

- **Flutter** (mobile UI)
- **speech_to_text** (voice input for Check-In)
- **fl_chart** (analytics charts)
- **Placeholder logic** for NLP/ML (keyword + rules); replace with trained models and/or APIs.

## Next Steps for Full FYP

1. Train or integrate **emotion** and **distortion** classifiers (e.g. BERT, SVM on TF-IDF).
2. Add **voice stress** model (audio features → stress score).
3. Persist **mood entries** and **journal entries** (e.g. SQLite, Firebase).
4. Populate **Analytics** from real stored data.
5. Run **evaluation**: label test set, report confusion matrix and F1; optional user study.
