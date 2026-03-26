# Mind Heaven

A **CBT-based AI journaling and cognitive distortion detection** Flutter application.

Mind Heaven is designed as a **preventive mental wellness** system that analyzes journal text to detect cognitive distortions and emotional tone, then provides structured CBT interventions with confidence-aware safety logic.

## Core Features

- **Journal-first AI analysis**
  - Distortion detection (transformer-ready architecture)
  - Emotion detection (context signal)
- **Structured CBT intervention**
  - Distortion explanation
  - Emotional acknowledgment
  - CBT technique + reframe
  - Coping exercise
- **Confidence-aware safety modes**
  - Direct CBT correction (`>70%`)
  - Reflective questioning (`50–70%`)
  - Emotional validation (`<50%`)
- **Environmental support module**
  - Emotion-based plant suggestions (non-medical wellness support)
- **Insights dashboard** (journal-driven)
  - Weekly mood trend
  - Average stress (derived from journal emotions)
  - Most frequent distortion
  - Improvement trend
- **Learn CBT section**
  - Distortion education and reframing guidance

## App Flow

Splash → Onboarding → Welcome → Login/Sign-Up → Main App

Main App Tabs:
1. **Journal**
2. **Insights**
3. **Learn CBT**
4. **Profile**

## Architecture (3 Layers)

### Layer 1: Detection Layer
- Cognitive Distortion Classifier (DistilBERT/BERT ready)
- Emotion Classifier (pretrained-model ready)

### Layer 2: CBT Logic Engine
- Rule-based Distortion → CBT Technique → Exercise mapping
- Confidence-aware response safety logic

### Layer 3: Intervention Layer
- Structured feedback object delivered to UI
- Includes environmental suggestion and optional calming guidance

## Project Structure

```text
lib/
  core/
    detection/
    cbt_engine/
    intervention/
  models/
  services/
  screens/
```

## Run Locally

```bash
flutter pub get
flutter run
```

## Implementation Notes

- Current repository includes mock/model-ready interfaces for detection.
- Replace mock classifiers with backend/API or on-device model inference.
- Keep CBT rule engine deterministic for therapeutic consistency and academic defensibility.

## Academic Positioning

This project is:

- Preventive, not diagnostic
- AI-driven but clinically structured
- Technically feasible for FYP
- Defendable through model metrics (Accuracy, Macro F1, Confusion Matrix)

## Documentation

See:

- `docs/FYP_IDEA_FLOW.md`
- `docs/ARCHITECTURE.md`
- `docs/IMPLEMENTATION_GUIDE.md`
