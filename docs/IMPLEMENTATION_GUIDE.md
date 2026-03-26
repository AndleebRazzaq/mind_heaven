# Implementation Guide — CBT Emotion-Aware App

Step-by-step instructions for each part of the system.

---

## 1. Layer 1 — Detection Layer

### 1.1 Cognitive Distortion Classifier (Journal)

**Goal:** From journal text, output a distortion type and confidence.

**Current app:** Mock in `lib/core/detection/distortion_classifier.dart` that uses heuristics/keywords. Replace with:

1. **Dataset:** Collect or use existing labeled data (e.g. 1000–1500 samples) with labels: `catastrophizing`, `overgeneralization`, `mind_reading`, `all_or_nothing`, etc.
2. **Model:** Fine-tune **DistilBERT** (or similar) for multi-class classification.
3. **Export:** TensorFlow Lite / PyTorch Mobile or deploy as REST API.
4. **In app:** Replace mock with API call or on-device inference; parse result into `DistortionType` and confidence.

**Interface to keep:**  
`Future<DistortionResult> classify(String text)`  
where `DistortionResult` has `distortionType` and `confidence`.

### 1.2 Emotion Classifier

**Goal:** From text (journal or check-in), output emotion label (e.g. anxiety, sadness, calm) and confidence.

**Current app:** Mock in `lib/core/detection/emotion_classifier.dart`. Replace with:

1. **Dataset:** Labeled sentences with emotions (e.g. 500+ samples).
2. **Model:** Fine-tuned transformer or small BERT head.
3. **In app:** Same as distortion — API or on-device; return `EmotionType` + confidence.

**Interface:**  
`Future<EmotionResult> classify(String text)`  
with `emotionType` and `confidence`.

### 1.3 Voice Stress Detector (Check-In)

**Goal:** From voice recording, output a stress score (e.g. 0–1).

**Current app:** Mock in `lib/core/detection/voice_stress_detector.dart` (no real audio yet). Replace with:

1. **Features:** Extract **MFCC** (and optionally pitch, energy) from audio.
2. **Model:** Train **CNN** or **LSTM** on labeled stress data (e.g. low/medium/high).
3. **In app:** Record audio → send to backend or run on-device → get stress score.

**Interface:**  
`Future<double> getStressFromAudio(String audioPathOrBytes)`  
returns 0.0–1.0.

### 1.4 Fusion (Check-In Only)

**Goal:** Combine text-based emotion/stress and voice-based stress.

**Implementation:**  
In `lib/core/detection/fusion_service.dart`:

- `stress_final = 0.7 * stress_from_text + 0.3 * stress_from_voice`
- `mood_final = mood_from_text` (voice does not change mood label)

Use `stress_final` to decide “high stress” (e.g. > 0.6) for suggesting breathing in the intervention layer.

---

## 2. Layer 2 — CBT Logic Engine

**Goal:** Map distortion (and optionally stress) to a single, consistent CBT response.

**Implementation:**  
`lib/core/cbt_engine/cbt_mapping.dart` (or similar) contains a **static table**:

- **Input:** `DistortionType` (+ optional `StressLevel`).
- **Output:**  
  - CBT technique name  
  - Reframe text  
  - Coping exercise title + description  
  - Plant suggestion  
  - Whether to suggest breathing (e.g. if stress is high).

**Instructions:**

1. Define all supported distortion types in code (enum or constants).
2. For each type, add one row: technique, reframe, exercise, plant.
3. In the same module, add a function:  
   `CBTIntervention getIntervention(DistortionType d, {bool highStress})`  
   that returns the row + a “suggest breathing” flag when `highStress` is true.
4. Do **not** generate reframes or exercises with AI; keep them fixed strings for clinical consistency.

---

## 3. Layer 3 — Intervention Layer

**Goal:** Build the final user-facing response (explanation, reframe, exercise, plant, breathing).

**Implementation:**  
`lib/core/intervention/intervention_builder.dart` (or similar):

- **Input:**  
  - From Layer 1: distortion (and confidence), emotion, stress level.  
  - From Layer 2: technique, reframe, exercise, plant, “suggest breathing”.
- **Output:** A single **intervention object** or structured text for the UI.

**Instructions:**

1. Take distortion explanation from a fixed string or table (e.g. “Catastrophizing means…”).
2. Take reframe and exercise from Layer 2.
3. Add plant recommendation from Layer 2.
4. If “suggest breathing” is true, append 4-7-8 (or other) breathing instructions.
5. Return one DTO (e.g. `CBTIntervention`) so the UI only renders this object.

---

## 4. Journal Screen Flow

1. User submits **text**.
2. Call **distortion classifier** and **emotion classifier** (Layer 1).
3. Call **CBT engine** with detected distortion (Layer 2).
4. Call **intervention builder** with Layer 1 + Layer 2 outputs (Layer 3).
5. Display: explanation, reframe, exercise, plant; if high stress, show breathing.
6. **Persist** entry (and distortion/emotion) for analytics.

---

## 5. Check-In Screen Flow

1. User enters **text** and/or **voice**.
2. **Text** → emotion classifier (+ optional text-based stress).
3. **Voice** → voice stress detector (when implemented).
4. **Fusion:** `stress_final = 0.7 * text_stress + 0.3 * voice_stress`; mood = text mood.
5. **Intervention:** Show mood + stress; if stress high, show breathing. (No distortion mapping on check-in.)
6. **Persist** check-in (mood, stress) for analytics.

---

## 6. Analytics

**Data to store (per check-in / journal):**

- Timestamp  
- For check-in: mood, stress level  
- For journal: distortion type, emotion, stress if derived  

**Metrics to compute:**

- **Weekly mood trend:** Count or average mood per day/week.
- **Stress average:** Mean stress over last 7 or 30 days.
- **Most frequent distortion:** Mode of distortion types in journal entries.
- **Emotional improvement:** e.g. compare first half vs second half of the period (e.g. stress down, “calm” mood up).

**Implementation:**  
Use `AnalyticsService` that reads from local storage (or backend) and exposes:  
`weeklyMoodTrend()`, `averageStress()`, `topDistortion()`, `improvementSummary()`.

---

## 7. Evaluation (Models)

For **distortion** and **emotion** classifiers:

1. Hold out a test set (e.g. 20%).
2. Compute **accuracy**, **macro F1**, **per-class precision/recall**.
3. Build **confusion matrix** (rows = true class, columns = predicted).
4. Document in thesis/report; optionally show a summary in the app (e.g. in Methodology/Info screen).

**CBT engine:** No ML evaluation; it is rule-based and validated by design.

---

## 8. Replacing Mocks with Real Models

| Component | Replace in file | With |
|-----------|-----------------|------|
| Distortion | `distortion_classifier.dart` | HTTP client to your API or TFLite/ONNX runner |
| Emotion | `emotion_classifier.dart` | Same as above |
| Voice stress | `voice_stress_detector.dart` | Audio upload to API or on-device model |
| Fusion | Keep formula in `fusion_service.dart`; feed real text/voice scores |

Keep the **same interfaces** (e.g. `classify(String text)`, `getStressFromAudio(...)`) so the rest of the app (CBT engine, intervention, UI) stays unchanged.

---

This guide covers **every major implementation step** and how it fits into the **architecture** in `ARCHITECTURE.md`.
