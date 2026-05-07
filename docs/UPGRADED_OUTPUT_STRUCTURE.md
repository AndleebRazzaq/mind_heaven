# 🧠 Upgraded AI Journal Output Structure - Implementation Guide

## Overview

This document describes the **NEW intelligent output structure** for Mind Heaven's AI Journal feature. Instead of showing raw ML labels, the app now translates emotions into **human-readable emotional states** with context awareness.

---

## 🔄 The Transformation Pipeline

```
Journal Text
    ↓
Emotion Model (raw label)
    ↓
Emotion Group Mapping (anxiety, stress, low_mood, positive, neutral)
    ↓
Context Detection (social, performance, health, general)
    ↓
Emotional State Mapper (human-readable state + subtitle)
    ↓
CBT Distortion Detection
    ↓
LLM Reframing
    ↓
UI Rendering (NEW UPGRADED OUTPUT)
```

---

## 📱 NEW OUTPUT STRUCTURE

### Before (Old):
```
Mood: confusion
```

### After (New):
```
EMOTIONAL STATE
Decision Anxiety

Subtitle: You seem mentally overwhelmed while trying to make the "right" choice.

PATTERN
All-or-Nothing Thinking

Explanation: Your thoughts may be treating this situation as completely right or completely wrong.

REFRAME
A difficult decision doesn't require a perfect answer. You can make thoughtful choices without needing absolute certainty.

[Breathing card - if stress ≥ 70%]
[Plant suggestion]
[Intensity indicator]
```

---

## 🧠 1. Emotional State Mapping

### Core Mapping Logic

**Location:** `backend/app/services/emotional_state_mapper.py`

Maps raw emotions + context → human-readable emotional states:

| Raw Emotion | Context | Emotional State | Subtitle |
|---|---|---|---|
| confusion | general | Decision Anxiety | You seem mentally overwhelmed while trying to make the "right" choice. |
| fear | social | Social Anxiety | You seem worried about others' judgments or how you're being perceived. |
| nervousness | performance | Performance Stress | You seem concerned about meeting expectations or doing well. |
| sadness | general | Emotional Exhaustion | You seem depleted and struggling right now. |
| anger | performance | Work Pressure | You seem under pressure to perform and meet demands. |

### The Intelligence Layer

This mapping is the **KEY DIFFERENTIATOR** that makes your app feel premium:

- ✅ **NOT raw ML labels** (avoid: confusion, nervousness, fear)
- ✅ **Context-aware** (same emotion + different context = different state)
- ✅ **Human language** (feels like talking to a therapist, not a robot)

---

## 🌍 2. Context Detection

### Detection Keywords

**Location:** `backend/app/services/context_detector.py`

The system detects 4 contexts:

1. **Social Context**
   - Keywords: friend, people, relationship, dating, judged, embarrassed, rejected, alone
   
2. **Performance Context**
   - Keywords: exam, test, work, deadline, presentation, grade, fail, achievement
   
3. **Health Context**
   - Keywords: sick, pain, hospital, doctor, symptom, physical, mental health, anxiety
   
4. **General Context**
   - Default when no specific context is detected

### How It Works

The detector analyzes your journal text and counts keyword matches. The context with the highest count wins:

```python
social_count = sum(1 for keyword in SOCIAL_KEYWORDS if keyword in text.lower())
performance_count = sum(1 for keyword in PERFORMANCE_KEYWORDS if keyword in text.lower())
health_count = sum(1 for keyword in HEALTH_KEYWORDS if keyword in text.lower())
# Return context with max count
```

---

## 📊 3. Intensity Levels

### Intensity Bands

```
0–30%:   Low        (Green)
31–60%:  Moderate   (Orange)
61–85%:  High       (Orange-Red)
86–100%: Very High  (Red)
```

### Display

- **Subtle indicator** at bottom of output
- Shows label + visual progress bar
- Non-clinical, human-friendly language

---

## 🫁 4. Dynamic Breathing Card

### When It Shows

Only appears when **emotional intensity ≥ 70%**

```python
show_breathing = intensity >= 70
```

### Card Content

- **Title:** "Pause & Reset"
- **Message:** "Your stress level seems elevated right now. Try one slow breathing cycle before continuing."
- **Animated breathing orb** (scales 0.8 → 1.0 over 6 seconds)
- **Technique:** 4-4-6 breathing (inhale 4s, hold 4s, exhale 6s)

### UI Implementation

Location: `lib/screens/reframe_output_screen.dart` - `_buildBreathingCard()`

```dart
if (widget.intervention.showBreathing) ...[
  // Build card
]
```

---

## 🌱 5. Plant Suggestions (Refined)

### New Format

Old: "Plant Suggestion: A Lucky Bamboo may help create a calmer and clearer space."

New: "🌱 A Lucky Bamboo may help create a calmer and clearer space."

### Plant Database

**Location:** `backend/app/services/emotional_state_mapper.py` - `PLANT_SUGGESTIONS`

Mapping by emotion group:

```python
"anxiety": {
    "name": "Lucky Bamboo",
    "description": "may help create a calmer and clearer space"
},
"stress": {
    "name": "Jasmine",
    "description": "can soothe your immediate environment"
},
"low_mood": {
    "name": "Aloe Vera",
    "description": "offers a gentle, healing presence"
},
"positive": {
    "name": "Sunflower",
    "description": "helps maintain your bright energy"
},
"neutral": {
    "name": "Spider Plant",
    "description": "encourages steady, quiet growth"
}
```

---

## 🔄 Backend API Response

### New `/analyze` Endpoint

**Location:** `backend/app/main.py`

```json
{
  "emotion": {
    "raw_label": "confusion",
    "emotional_state": "Decision Anxiety",
    "emotional_state_subtitle": "You seem mentally overwhelmed while trying to make the 'right' choice.",
    "intensity": 65,
    "intensity_label": "High",
    "emotion_group": "anxiety",
    "context": "general",
    "confidence": 0.85
  },
  "distortion": {
    "label": "all-or-nothing thinking",
    "confidence": 0.72
  },
  "show_breathing": true,
  "ai_response": {
    "insight": "You seem mentally overwhelmed...",
    "pattern": "Your thoughts may be treating...",
    "reframe": "A difficult decision doesn't require...",
    "action": "Try taking one small step...",
    "plant": "🌱 A Lucky Bamboo may help..."
  }
}
```

---

## 🎯 Flutter Model & Parsing

### Updated CBTIntervention Fields

**Location:** `lib/models/cbt_intervention.dart`

New fields added:

```dart
final String? emotionalState;              // "Decision Anxiety"
final String? emotionalStateSubtitle;      // "You seem mentally overwhelmed..."
final String? intensityLabel;              // "High"
final String? emotionContext;              // "general"
final bool showBreathing;                  // true if intensity >= 70
```

### API Response Parsing

**Location:** `lib/data/remote/journal_remote_data_source.dart`

Maps backend JSON → Flutter model:

```dart
return CBTIntervention(
  emotionalState: emotion['emotional_state'],
  emotionalStateSubtitle: emotion['emotional_state_subtitle'],
  intensityLabel: emotion['intensity_label'],
  emotionContext: emotion['context'],
  showBreathing: data['show_breathing'],
  // ... other fields
);
```

---

## 📱 UI Rendering

### New Screen Layout

**Location:** `lib/screens/reframe_output_screen.dart`

```
┌─────────────────────────────────────────┐
│ AI Journal                          [✕]  │
├─────────────────────────────────────────┤
│ Mon, May 7 - 2:45 PM                    │
│                                          │
│ EMOTIONAL STATE                          │
│ Decision Anxiety                         │
│ You seem mentally overwhelmed while     │
│ trying to make the "right" choice.      │
│                                          │
│ PATTERN                                  │
│ All-or-Nothing Thinking                 │
│ Your thoughts may be treating this...   │
│                                          │
│ REFRAME                                  │
│ ┌──────────────────────────────────┐   │
│ │ A difficult decision doesn't     │   │
│ │ require a perfect answer...      │   │
│ └──────────────────────────────────┘   │
│                                          │
│ PAUSE & RESET          [IF INTENSITY≥70]│
│ ┌──────────────────────────────────┐   │
│ │ Your stress level seems elevated  │   │
│ │        [Breathing Orb 🫁]        │   │
│ │ 4-4-6 Breathing: Inhale • Hold  │   │
│ └──────────────────────────────────┘   │
│                                          │
│ 🌱 A Lucky Bamboo may help create    │
│    a calmer and clearer space.         │
│                                          │
│ Emotional Intensity • High ▓▓▓░░       │
│                                          │
│  [I feel more grounded button]          │
└─────────────────────────────────────────┘
```

---

## 🧪 Testing Guide

### 1. Test Emotional State Mapping

**Test Case:** Submit journal entry with specific keywords

```
Entry: "I have an exam tomorrow and I'm so nervous about it."

Expected Output:
- Raw Emotion: nervousness
- Context: performance
- Emotional State: "Performance Stress"
- Subtitle: "You seem concerned about meeting expectations or doing well."
```

### 2. Test Context Detection

Test various contexts:

| Text | Expected Context |
|---|---|
| "My friend rejected me" | social |
| "I failed my test" | performance |
| "I'm worried about my health" | health |
| "I feel overwhelmed" | general |

### 3. Test Breathing Card

**Test Case:** Submit high-stress entry (intensity ≥ 70%)

```
Entry: "Everything is falling apart, I'm panicking and can't think clearly!"

Expected:
- intensity >= 70
- showBreathing = true
- Breathing card displays with animated orb
```

### 4. Test Intensity Indicator

Verify color changes with intensity:

- Low (< 30%): Green
- Moderate (31–60%): Orange
- High (61–85%): Orange-Red
- Very High (86–100%): Red

---

## 🚀 Running the System

### Backend

```bash
cd backend
python -m pip install -r requirements.txt
python run_backend.ps1
# or
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend

```bash
cd ..
flutter pub get
flutter run
```

### Enable Remote API

In `lib/main.dart`:

```dart
// Set useRemote to true to use the backend API
const useRemote = true;
```

---

## 📝 Files Modified

1. **Backend:**
   - `backend/app/services/emotional_state_mapper.py` - NEW
   - `backend/app/services/context_detector.py` - NEW
   - `backend/app/utils.py` - Updated `predict_emotion()`, `get_plant_suggestion()`
   - `backend/app/main.py` - Updated `/analyze` endpoint response

2. **Flutter:**
   - `lib/models/cbt_intervention.dart` - Added 5 new fields
   - `lib/data/remote/journal_remote_data_source.dart` - Maps new API fields
   - `lib/screens/reframe_output_screen.dart` - Complete redesign

---

## 🎓 Design Principles

1. **Human First:** Never expose raw ML labels directly
2. **Context Matters:** Same emotion + different context = different state
3. **Therapeutic Tone:** Feels like talking to a therapist, not a robot
4. **Visual Hierarchy:** Emotional State is PRIMARY, intensity is SUBTLE
5. **Gradual Complexity:** Show breathing only when needed (>= 70%)
6. **Premium Feel:** Refined, intentional, minimal but meaningful

---

## ✨ Key Differentiators

| Feature | Before | After |
|---------|--------|-------|
| Mood Display | "confusion" | "Decision Anxiety" |
| Context | Ignored | Detected & used |
| Breathing Support | Always/Never | Dynamic based on intensity |
| Intensity | Raw % | Human-readable band + visual |
| Plant Suggestion | Long text | Short, softer phrasing |
| Overall Feel | Clinical | Therapeutic |

---

## 📞 Support & Next Steps

- Test all flows end-to-end
- Validate LLM reframe quality with new emotional states
- Gather user feedback on emotional state accuracy
- Consider A/B testing vs. old design

---

Generated: May 7, 2026
Version: 1.0 - Upgraded Emotional State Output
