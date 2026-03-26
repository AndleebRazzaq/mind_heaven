# CBT-Based Emotion-Aware AI Journal & Stress Detection — System Architecture

## 1. Core Concept

This application is a **CBT-based multimodal mental wellness system** that:

- Detects **mood** and **stress** from **text** and **voice**
- Uses **NLP** for cognitive distortion detection and emotion classification
- Uses **voice-based stress detection** (audio features)
- Applies **structured CBT intervention mapping** (rule-based, not free-form AI)
- Delivers **coping exercises**, **plant suggestions**, and **breathing techniques**

It is **preventive**, **AI-driven**, and **psychologically structured** — not a generic chatbot.

---

## 2. Three-Layer Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        LAYER 3: INTERVENTION LAYER                           │
│  • Explanation of distortion  • Reframed thought  • CBT exercise             │
│  • Plant recommendation       • Breathing (if high stress)                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
                                        │ outputs
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LAYER 2: CBT LOGIC ENGINE (Rule-Based)                  │
│  Distortion → CBT Technique → Coping Exercise  (structured mapping table)   │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
                                        │ distortion, emotion, stress
┌─────────────────────────────────────────────────────────────────────────────┐
│                      LAYER 1: DETECTION LAYER (AI Models)                   │
│  Journal: Cognitive Distortion Classifier + Emotion Classifier (text only)  │
│  Check-In: Text→Emotion + Voice→Stress → Weighted Fusion (70% text, 30% voice)│
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
                                        │ text, voice
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER INPUT                                      │
│  Journal Screen: text only  │  Check-In Screen: text + voice                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Layer 1 — Detection Layer

### 3.1 Journal Screen (Text-Only)

| Component | Role | Implementation path |
|-----------|------|---------------------|
| **Cognitive Distortion Classifier** | Predicts distortion type + confidence | Fine-tuned DistilBERT (or equivalent) on 1000–1500 labeled samples. **App**: mock/API stub until model is deployed. |
| **Emotion Classifier** | Predicts emotional tone (e.g. anxiety, sadness) | Same pipeline or separate model. **App**: mock returns emotion label + confidence. |

**Output example:** `Distortion: Catastrophizing`, `Emotion: Anxiety`, `Confidence: 87%`

Semantic understanding is required — not keyword matching — for production.

### 3.2 Check-In Screen (Multimodal)

| Input | Model | Output |
|-------|--------|--------|
| **Text** | Emotion classifier | Mood label + confidence |
| **Voice** | Stress classifier (e.g. MFCC + CNN/LSTM) | Stress score (e.g. 0–1) |
| **Fusion** | Weighted combination | **70% text, 30% voice** → final stress level + mood |

Voice is used for **stress intensity only**, not for cognitive distortion.

**Output example:** `Stress Level: High`, `Mood: Anxious`

### 3.3 Fusion Formula (Check-In)

```
stress_final = 0.7 * stress_from_text + 0.3 * stress_from_voice
mood_final   = mood_from_text  (voice can modulate stress only)
```

---

## 4. Layer 2 — CBT Logic Engine (Rule-Based)

This is the **psychological core**. All therapeutic content is driven by a **fixed mapping table**, not free-form generation.

### 4.1 Mapping Structure

| Distortion | CBT Technique | Coping Exercise |
|------------|----------------|-----------------|
| Catastrophizing | Evidence examination | Write 3 realistic outcomes |
| Overgeneralization | Reframing | Identify exceptions |
| Mind Reading | Cognitive restructuring | Ask for proof |
| ... | ... | ... |

### 4.2 Design Principles

- **Clinical alignment** with CBT theory
- **Structured intervention** — same distortion → same technique family
- **Controlled response** — no random or unvalidated AI text

The engine takes **distortion type** (and optionally **stress level**) and returns:

- CBT technique name
- Reframe guidance text
- Structured coping exercise
- Plant suggestion (environmental psychology)
- Whether to suggest breathing (e.g. if stress is high)

---

## 5. Layer 3 — Intervention Layer

From Layer 2 output and stress level, the app presents:

1. **Explanation** of the detected distortion
2. **Reframed thought** guidance
3. **Structured CBT exercise** (e.g. “Write 3 realistic outcomes”)
4. **Plant recommendation** (e.g. lavender for calming)
5. **Breathing technique** (e.g. 4-7-8) **if stress is high**

Example: **Distortion = Catastrophizing**, **Stress = High**

→ Explain distortion → Reframe → Journaling exercise → Lavender suggestion → 4-7-8 breathing

---

## 6. Model Strategy (Academic)

| Aspect | Choice | Rationale |
|--------|--------|-----------|
| **Distortion / Emotion** | Supervised ML; fine-tune DistilBERT | Balance of quality and feasibility for FYP |
| **Dataset** | 1000–1500 labeled samples | Sufficient for evaluation and thesis |
| **Evaluation** | Accuracy, F1-score, confusion matrix | Standard and defensible |
| **CBT content** | Rule-based mapping | Keeps therapy theoretically consistent and publishable |

**Hybrid architecture:** **AI for detection**, **rules for therapy**.

---

## 7. Application Structure (Screens)

```
Splash → Onboarding → Login / Sign-Up → Main App (Bottom Nav)
```

| Screen | Role |
|--------|------|
| **Check-In** | Text + voice → emotion + stress (fusion) → intervention (mood + stress + breathing if high) |
| **Journal** | Text → distortion + emotion → CBT engine → full intervention (explanation, reframe, exercise, plant, breathing if needed) |
| **Analytics** | Weekly mood trends, stress averages, most frequent distortion, emotional improvement |
| **Profile** | User and app settings |

---

## 8. Data Flow Summary

**Journal:**  
`User text` → **Detection (distortion + emotion)** → **CBT Engine (technique + exercise + plant)** → **Intervention (explanation, reframe, exercise, plant, breathing)** → UI.

**Check-In:**  
`User text + voice` → **Text emotion** + **Voice stress** → **Fusion (70/30)** → **Intervention (mood, stress, breathing if high)** → UI.

**Analytics:**  
Stored **check-ins** and **journal entries** → aggregate by week → mood trends, stress averages, top distortion, improvement metrics → Dashboard UI.

---

## 9. File Layout (App)

```
lib/
├── main.dart
├── core/
│   ├── detection/           # Layer 1
│   │   ├── emotion_classifier.dart
│   │   ├── distortion_classifier.dart
│   │   ├── voice_stress_detector.dart
│   │   └── fusion_service.dart
│   ├── cbt_engine/          # Layer 2
│   │   └── cbt_mapping.dart
│   └── intervention/        # Layer 3
│       └── intervention_builder.dart
├── models/
│   ├── emotion_type.dart
│   ├── journal_entry.dart   # DistortionType enum + JournalEntry
│   ├── cbt_intervention.dart
│   ├── mood_entry.dart
│   └── check_in_result.dart
├── services/
│   ├── analytics_service.dart
│   └── storage_service.dart
└── screens/
    ├── splash_screen.dart
    ├── onboarding_screen.dart
    ├── welcome_screen.dart
    ├── auth_screen.dart
    ├── home_shell.dart
    ├── dashboard_screen.dart
    ├── check_in_screen.dart
    ├── journal_screen.dart
    ├── analytics_screen.dart
    ├── profile_screen.dart
    └── methodology_screen.dart
```

## 10. App Model (Data Flow)

- **Check-In:** User text/voice → `FusionService.fuse()` (70% text, 30% voice) → `InterventionBuilder.buildForCheckIn()` → `CBTIntervention` (mood, stress, reframe, breathing if high, plant) → UI; `MoodEntry` saved via `StorageService`.
- **Journal:** User text → `InterventionBuilder.buildForJournal()` (calls `DistortionClassifier`, `EmotionClassifier`, `CBTMapping.getIntervention()`) → `JournalInterventionResult` (intervention + distortion + emotion) → UI; `JournalEntry` saved via `StorageService`.
- **Analytics:** `StorageService` (check-ins + journal entries) → `AnalyticsService` (weekly trend, average stress, top distortion, improvement) → Dashboard UI.

This document is the single source of truth for the **system architecture** and the **3-layer + app structure** of the project.
