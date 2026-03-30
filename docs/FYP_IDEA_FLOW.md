# Mind Heaven – Final FYP Idea Flow (Refined)

## Project Title
**CBT-Based AI Journaling & Cognitive Distortion Detection System**

## Core Concept
Mind Heaven is a **journal-first, CBT-based mental wellness application** that analyzes user-written text to detect:

- **Cognitive distortions**
- **Emotional tone**

The app then returns a **structured, rule-based CBT intervention**, plus a supportive **environmental mood module** (plant suggestion) inspired by environmental psychology.

> This is not a generic chatbot. It is a psychologically grounded, structured AI feedback system.

---

## Why This Design Works

- CBT requires identifying and restructuring cognitive distortions.
- Emotional tone helps contextualize psychological state.
- Confidence-aware response logic improves safety and interpretability.
- Rule-based intervention keeps therapeutic behavior controlled and academically defendable.
- Environmental suggestion (plants) is a supportive, non-clinical wellness feature.

This makes the project:

- Preventive (not diagnostic)
- AI-driven
- Psychologically structured
- Academically defensible
- Feasible for FYP implementation

---

## 3-Layer Architecture

### Layer 1 – Detection Layer (AI)
**Input:** Journal text only

1. **Cognitive Distortion Classifier (main contribution)**
   - Your fine-tuned transformer (exported as a Hugging Face–compatible folder)
   - Multi-class classification: **numeric class id** (argmax) + **confidence** (softmax); id→name via `distortion_label_map.json` or model `id2label`
   - Backend exposes `distortion_label_id`, `detected_distortion_label`, and `confidence`

2. **Emotion Classifier (context model)**
   - Pretrained Hugging Face text-classification model (default: `j-hartmann/emotion-english-distilroberta-base`)
   - Output: normalized emotion label + confidence for UI, plants, and Insights

**Example output:**
- Distortion: Magnification / Catastrophizing (82%), label id `0`
- Emotion: Anxiety (74%)

---

### Layer 2 – CBT Logic Engine (Rule-Based)
**Input:** Distortion + confidence (+ emotion context)

**Distortion → Technique → Exercise mapping** (fixed rules)

- Catastrophizing → Evidence Examination → Guided Reality Testing
- Overgeneralization → Cognitive Reframing → Identify Exceptions
- Mind Reading → Cognitive Restructuring → Ask for Evidence
- Personalization → Responsibility Pie → Attribution Rebalance

**Confidence-aware safety logic:**
- `confidence > 70%` → Direct CBT correction
- `50% to 70%` → Reflective questioning
- `< 50%` → Emotional validation only

This ensures safe, clinically aligned, controlled intervention behavior.

---

### Layer 3 – Intervention + Environmental Support
The app provides a structured result card with:

- Distortion explanation
- Emotional acknowledgment
- Intervention mode (safety mode)
- CBT technique and reframing
- Coping exercise
- Plant suggestion (environmental support)

**Emotion → plant examples**
- Anxiety → Lavender
- Sadness → Peace Lily
- Anger → Snake Plant
- Fatigue → Rosemary

No medical claims are made; plants are supportive environmental suggestions.

---

## App Navigation (Current Refined Flow)

Splash → Onboarding → Welcome → Login/Sign-Up → Main App (Bottom Navigation)

Main tabs:
1. **Journal** (core AI+CBT screen)
2. **Insights** (journal-driven analytics)
3. **Learn CBT** (educational content)
4. **Profile**

---

## Journal Screen Flow (Implemented)

1. User writes journal text
2. Distortion + emotion detection
3. Confidence-aware CBT mapping
4. Structured intervention displayed
5. Journal entry stored for analytics

---

## Insights Screen (Implemented)
Insights are now **fully journal-driven**:

- Weekly mood trend
- Average stress (derived from journal emotion labels)
- Most frequent distortion
- Improvement trend over time

No dependency on check-in stress records.

---

## Evaluation Strategy (FYP)
For distortion/emotion models:

- Accuracy
- Macro F1
- Per-class F1
- Confusion matrix
- Train/test split documentation

This supports research credibility and viva defense.

---

## Final Positioning
Mind Heaven is a **CBT-based AI journaling system** that combines transformer-based detection of cognitive distortions and emotional tone with a structured rule-based intervention engine and an environmental support module, delivering safe, preventive mental wellness guidance with measurable behavioral analytics.
