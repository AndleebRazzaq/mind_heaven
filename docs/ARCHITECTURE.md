# Mind Heaven — System Architecture (Current)

## 1. Core concept

Mind Heaven is a **CBT-based, journal-first** mental wellness app that:

- Detects **cognitive distortions** and **emotional tone** from **journal text**
- Applies a **rule-based CBT mapping** (confidence-aware safety modes)
- Delivers a structured intervention card (explanation, reframe, exercise, optional breathing, **plant suggestion**)

**AI for detection, rules for therapy** — not a generic chatbot.

---

## 2. Three-layer architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LAYER 3: INTERVENTION LAYER (Flutter / API)              │
│  Explanation • Reframe • Exercise • Plant suggestion • Breathing (optional) │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
┌─────────────────────────────────────────────────────────────────────────────┐
│                  LAYER 2: CBT LOGIC ENGINE (Rule-based, deterministic)        │
│  Flutter: cbt_mapping.dart  │  API: cbt_engine.py                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LAYER 1: DETECTION (ML)                                  │
│  Distortion: fine-tuned classifier (numeric label + confidence)              │
│  Emotion: pretrained Hugging Face text-classification (label + confidence)    │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
┌─────────────────────────────────────────────────────────────────────────────┐
│                     USER INPUT — Journal text only                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Layer 1 — Detection

### Journal (text)

| Output | Source (typical) |
|--------|-------------------|
| Distortion **label**, **confidence**, optional **class id** | Your trained model (API) or mock heuristics (local) |
| Emotion **label**, **confidence** | Hugging Face pretrained model (API) or mock (local) |

Semantic classification is the target for production; mocks exist for UI development without GPUs.

---

## 4. Layer 2 — CBT engine

- **Flutter:** Full distortion-type table in `lib/core/cbt_engine/cbt_mapping.dart` (`DistortionType` enum).
- **API:** `backend/app/services/cbt_engine.py` produces API-safe structured text using distortion label + confidence + emotion.

Principles: clinical alignment, fixed mappings, no uncontrolled generative therapy text.

---

## 5. Layer 3 — Intervention

Combines detection outputs + CBT row into a single **`CBTIntervention`** (and journal persistence). Plant lines come from **`PlantSuggestionDatabase`** (app) / **`plant_database.py`** (backend).

---

## 6. Application navigation

```
Splash → Onboarding → Welcome → Auth → Main App (bottom navigation)
```

| Tab | Role |
|-----|------|
| **Journal** | Text → analysis → intervention → save entry |
| **Insights** | Analytics from stored journal entries |
| **Learn CBT** | Educational content |
| **Profile** | Settings / profile |

---

## 7. Clean architecture (Flutter)

```
lib/
├── main.dart
├── domain/repositories/       # JournalRepository contract
├── data/
│   ├── repositories/          # JournalRepositoryImpl (local vs remote)
│   └── remote/                # JournalRemoteDataSource → FastAPI
├── presentation/providers/     # JournalProvider, InsightsProvider
├── core/
│   ├── config/                 # API_BASE_URL (dart-define)
│   ├── network/                # ApiClient
│   ├── detection/              # Local mock classifiers (optional / dev)
│   ├── cbt_engine/             # cbt_mapping.dart, plant_suggestion_database.dart
│   └── intervention/         # intervention_builder.dart
├── models/
├── services/                   # storage, analytics
└── screens/
```

**Backend (separate deployable):**

```
backend/app/
├── main.py
├── schemas.py
├── config.py
└── services/
    ├── distortion_service.py   # Transformers folder + id→label map
    ├── emotion_service.py      # Hugging Face pipeline
    ├── cbt_engine.py
    └── plant_database.py
```

---

## 8. Data flow summary

**Journal (local):**  
Text → `InterventionBuilder` → mock distortion/emotion → `CBTMapping.getIntervention` → UI → `StorageService`.

**Journal (remote):**  
Text → `POST /analyze/journal` → JSON → `CBTIntervention` → UI → `StorageService`.

**Insights:**  
Stored entries → `AnalyticsService` → `InsightsProvider` → UI.

---

## 9. Model strategy (academic)

| Component | Approach |
|-----------|----------|
| **Distortion** | Your fine-tuned classifier; outputs class index + probability |
| **Emotion** | Published pretrained HF model + light label normalization |
| **CBT content** | Rule-based; defensible and consistent |

This document reflects the **current** codebase (journal-first, optional FastAPI, no multimodal check-in in app).
