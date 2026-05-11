# Mind Heaven — System Architecture (Current)

## 1. Core concept

Mind Heaven is a **CBT-based, journal-first** mental wellness app that:

- Detects **cognitive distortions** and **emotional tone** from **journal text**
- Applies a **human-readable mapping** for emotional states and context
- Delivers a structured intervention card (personalized insight, pattern explanation, reframe, action, **plant suggestion**, and optional **breathing exercise**)

**AI for detection and structured generation** — leveraging local LLMs for therapeutic reframing.

---

## 2. Three-layer Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LAYER 3: INTERVENTION LAYER (LLM / Flutter)              │
│  Personalized Insight • Balanced Reframe • Action Step • Plant Suggestion     │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
┌─────────────────────────────────────────────────────────────────────────────┐
│                  LAYER 2: MAPPING & CONTEXT (Semantic Translation)           │
│  Transforms raw labels into human-friendly "Emotional States" (e.g. Decision Anxiety) │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
┌─────────────────────────────────────────────────────────────────────────────┐
│                     LAYER 1: DETECTION (ML)                                  │
│  Distortion: Fine-tuned DistilBERT classifier                                │
│  Emotion: Pretrained GoEmotions model                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ▲
┌─────────────────────────────────────────────────────────────────────────────┐
│                     USER INPUT — Journal text only                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Layer 1 — Detection (ML)

The system uses two specialized models for initial analysis:

| Component | Model Type | Output |
|-----------|------------|--------|
| **Distortion** | Fine-tuned DistilBERT | Label (e.g. 'all-or-nothing') + Confidence |
| **Emotion** | GoEmotions DistilRoBERTa | Raw Label (e.g. 'nervousness') + Confidence |

---

## 4. Layer 2 — Mapping & Context

Raw detection results are passed through a mapping engine to make them user-friendly:

- **Context Detection:** Analyzes text for keywords related to **Social**, **Performance**, or **Health** contexts.
- **Emotional State Mapping:** Combines raw emotion + context to produce states like "Social Anxiety" or "Work Pressure".
- **Safety Logic:** Determines if a **Breathing Exercise** card should be shown (Intensity ≥ 70%).

---

## 5. Layer 3 — Intervention (LLM)

The mapped states and detected distortions are fed into a local LLM (**Ollama / Llama 3.2**) to generate the final intervention:

- **Insight:** A single sentence validating the user's feelings.
- **Pattern Explanation:** A one-line clinical explanation of the detected distortion.
- **Reframe:** A 3-4 line CBT-aligned balanced alternative thought.
- **Action:** A small, concrete step the user can take.
- **Plant Suggestion:** Injected based on the emotional group.

---

## 6. Clean Architecture (Flutter)

The Flutter app follows a modified clean architecture using the **Provider** package for state management.

```
lib/
├── app/
│   ├── bootstrap.dart          # Dependency injection & initialization
│   └── app.dart               # MultiProvider & MaterialApp setup
├── domain/repositories/        # Repository contracts
├── data/
│   ├── repositories/           # Repository implementations (Remote/Local toggle)
│   └── remote/                 # FastAPI data source
├── presentation/providers/      # ChangeNotifier providers (Journal, Insights)
├── core/
│   ├── config/                  # API config
│   ├── mapping/                 # Local mapping logic (if fallback used)
│   └── network/                 # ApiClient
├── services/                    # Auth, Storage, Analytics, Firebase
└── screens/                     # UI implementation
```

---

## 7. Backend Architecture (FastAPI)

The backend is organized into services for modularity:

```
backend/app/
├── main.py                     # Entrypoint & API routes
├── utils.py                    # Shared AI utilities (Ollama calls, extraction)
└── services/
    ├── distortion_service.py   # Distortion model loading & prediction
    ├── emotion_service.py      # Emotion model loading & prediction
    ├── emotional_state_mapper.py # Raw → Human-readable state mapping
    ├── context_detector.py     # Context keyword analysis
    └── reframe_pipeline.py     # Orchestrates the LLM response generation
```

---

## 8. Data Flow Summary

1.  **User submits journal** text.
2.  **FastAPI** receives text, runs **Layer 1** (ML models).
3.  Results passed to **Layer 2** for context mapping and state translation.
4.  Mapped data + text sent to **Layer 3** (Ollama) with a structured prompt.
5.  **Ollama** returns JSON; FastAPI injects plant suggestion and breathing flag.
6.  **Flutter** receives the final object, saves it to **Firestore/Local Storage**, and displays the **Reframe Output Screen**.

---

## 9. Academic Positioning

- **Clinically Rooted:** Uses established CBT distortions as the foundation.
- **Modern AI:** Combines specialized classification (fast/cheap) with generative LLMs (rich/personalized).
- **Safety-First:** Uses deterministic mapping for emotional states to ensure therapeutic consistency.
