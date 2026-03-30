# Implementation Guide — Mind Heaven (Current Build)

This guide matches the **journal-first** Flutter app, the **FastAPI** backend in `backend/`, and how **your trained distortion model** and a **Hugging Face emotion model** plug in.

---

## 1. System overview

| Piece | Role |
|--------|------|
| **Flutter app** | UI, local rule-based CBT (`cbt_mapping.dart`) when `useRemote: false`; optional HTTP analysis when `useRemote: true`. |
| **FastAPI backend** | Loads distortion classifier from disk, emotion model from Hugging Face (or mocks), runs rule-based `CbtEngine`, returns JSON for `CBTIntervention`. |
| **Plant suggestions** | Small lookup tables: `lib/core/cbt_engine/plant_suggestion_database.dart` (app) and `backend/app/services/plant_database.py` (API) — keep emotion keys in sync when you add new labels. |

---

## 2. Layer 1 — Detection

### 2.1 Cognitive distortion (your trained model)

**Output:** numeric class id (argmax) + **confidence** (softmax probability for that class).

**Backend wiring:**

1. Export or copy your fine-tuned model as a **Hugging Face Transformers** folder (must include at least `config.json`, tokenizer files, and weights such as `model.safetensors` or `pytorch_model.bin`).
2. Point the API at that folder:

   ```bash
   set DISTORTION_MODEL_DIR=D:\path\to\your\distortion_model
   ```

3. **Label map:** Your checkpoint outputs class indices `0 … N-1`. Map each index to the **same human-readable strings** you want in the API and thesis (and that align with your CBT copy).

   - Either add `distortion_label_map.json` **inside** the model folder, **or** set:

     ```bash
     set DISTORTION_LABEL_MAP_PATH=D:\path\to\distortion_label_map.json
     ```

   - Format (create `<model_dir>/distortion_label_map.json`):

     ```json
     {
       "label_map": {
         "0": "Magnification / Catastrophizing",
         "1": "Overgeneralization"
       }
     }
     ```

   If the model’s `config.json` already contains a correct `id2label`, you can omit the JSON; the service will use `id2label` when no map file is present.

4. **Response fields:** `detected_distortion_label`, `confidence`, and `distortion_label_id` (integer class id).

**Development without weights:**

```bash
set DISTORTION_USE_MOCK=1
```

Uses lightweight keyword heuristics (no Transformers load).

**Flutter (local path):** `lib/core/detection/distortion_classifier.dart` remains a mock/heuristic implementation for on-device demos; production distortion ML is expected **via API** when `useRemote: true`.

### 2.2 Emotion (pretrained Hugging Face)

**Backend default:** `j-hartmann/emotion-english-distilroberta-base` (English, 7-way: anger, disgust, fear, joy, neutral, sadness, surprise).

**Configure:**

```bash
set EMOTION_HF_MODEL=j-hartmann/emotion-english-distilroberta-base
```

Or swap for another `transformers`-compatible **text-classification** model (set env to the Hub id or a local path). Raw labels are normalized in `emotion_service.py` to your 7-class set (`anger`, `disgust`, `fear`, `joy`, `neutral`, `sadness`, `surprise`) for plants and Insights.

**Offline / CI:**

```bash
set EMOTION_USE_MOCK=1
```

---

## 3. Layer 2 — CBT logic engine (rule-based)

**Flutter (full table):** `lib/core/cbt_engine/cbt_mapping.dart` — distortion enum → explanation, technique, reframe, exercise; confidence bands (>70%, 50–70%, <50%).

**Backend:** `backend/app/services/cbt_engine.py` — simplified, confidence-aware copy for API responses; uses the same **plant** strings as `plant_database.py`.

Keep therapeutic text **curated** (no free-form LLM generation) for consistency and FYP defense.

---

## 4. Layer 3 — Intervention

**Flutter:** `lib/core/intervention/intervention_builder.dart` combines Layer 1 + 2 into `JournalInterventionResult` / `CBTIntervention`.

**Remote:** The API returns a ready-made `CBTIntervention`-shaped JSON; `JournalRemoteDataSource` maps fields including optional `distortion_label_id`.

---

## 5. Journal flow (implemented)

1. User submits text.
2. Distortion + emotion classification (local pipeline **or** `POST /analyze/journal`).
3. CBT mapping + intervention object.
4. Persist `JournalEntry` (and labels) for **Insights**.

There is **no** check-in / voice / fusion path in the current app build; Insights are **journal-only**.

---

## 6. Analytics (Insights)

**Implementation:** `lib/services/analytics_service.dart` + `InsightsProvider`.

**Stored signals:** timestamps, mood labels, distortion types, derived stress where applicable.

**Metrics:** weekly mood trend, average stress, most frequent distortion, improvement summary.

---

## 7. Model evaluation (FYP)

For **distortion** (your trained classifier):

1. Hold out a test set; report **accuracy**, **macro F1**, per-class metrics, **confusion matrix**.
2. Document label indices ↔ names (same as `distortion_label_map.json`).

For **emotion** (pretrained):

1. Cite the published model; optional: evaluate on a small in-domain sample for a “usage” note.

**CBT engine:** Rule-based — no ML metrics; justify by design and clinical framing.

---

## 8. Quick reference — environment variables

| Variable | Purpose |
|----------|---------|
| `DISTORTION_MODEL_DIR` | Path to Transformers model folder |
| `DISTORTION_LABEL_MAP_PATH` | Optional JSON path for id → label |
| `DISTORTION_USE_MOCK` | `1` = skip model, use heuristics |
| `EMOTION_HF_MODEL` | Hugging Face model id or local path |
| `EMOTION_USE_MOCK` | `1` = skip HF, use heuristics |

See also `docs/BACKEND_INTEGRATION_DEPLOYMENT.md` and `backend/README.md`.

---

## 9. Keeping plant copy aligned

When you change emotion labels or add Hub models with new classes:

1. Update `_normalize_hf_label` in `backend/app/services/emotion_service.py` if needed.
2. Update `plant_suggestion_database.dart` and `plant_database.py` with the same substring keys for matching.

This guide is the operational companion to `docs/ARCHITECTURE.md` and `docs/FYP_IDEA_FLOW.md`.
