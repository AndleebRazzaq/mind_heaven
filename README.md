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

## Clean Architecture + Riverpod

The app now follows a clean, replaceable setup:

- `lib/domain/repositories/` - repository contracts
- `lib/data/repositories/` - repository implementations
- `lib/data/remote/` - API data sources
- `lib/core/network/` - API client
- `lib/app/app_providers.dart` - dependency providers overridden at app startup
- `lib/presentation/providers/` - Riverpod controller/state pairs

Current Riverpod providers:
- `journalControllerProvider` - journal analysis state and actions
- `insightsControllerProvider` - analytics/insights state and actions

### Riverpod state flow

State management is implemented with `flutter_riverpod` `NotifierProvider`s and immutable state snapshots:

- **UI (Screens):** renders state and dispatches intents (`analyze`, `load`)
- **Riverpod controller:** state holder and event handler (`loading`, `error`, `data`)
- **Repository:** business/data orchestration
- **Data source:** local or remote API implementation

This keeps the AI and analytics flows testable without passing mutable `ChangeNotifier` objects through the widget tree.

## FastAPI Backend Integration

Backend lives in `backend/` with:

- `app/main.py` - API entrypoint
- `app/services/distortion_service.py` - loads **your** fine-tuned model from `DISTORTION_MODEL_DIR` (Transformers layout); outputs **class id**, **label**, **confidence**
- `app/services/emotion_service.py` - **Hugging Face** pretrained text-classification (`EMOTION_HF_MODEL`, default English emotion DistilRoBERTa)
- `app/services/cbt_engine.py` + `plant_database.py` - rule-based intervention copy
- `app/schemas.py` - request/response contracts (includes optional `distortion_label_id`)

Keeping backend in a separate `backend/` folder is a **good and production-friendly approach**:
- clear separation of concerns (mobile vs API)
- independent deployment and scaling
- easier model replacement and backend experiments
- cleaner CI/CD pipelines for app and server

### Run backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install torch
pip install -r requirements.txt
set DISTORTION_MODEL_DIR=D:\path\to\your\model
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

For quick UI testing without weights: `set DISTORTION_USE_MOCK=1` and `set EMOTION_USE_MOCK=1`.

### Flutter <-> FastAPI wiring

- API base URL is in `lib/core/config/app_config.dart`
- HTTP client is `lib/core/network/api_client.dart`
- Journal endpoint client is `lib/data/remote/journal_remote_data_source.dart`
- Switch local->remote model use in `lib/main.dart`:
  - `useRemote: false` (local mocked/model-ready flow)
  - `useRemote: true` (FastAPI mode)

### Deploy backend

Docker:

```bash
cd backend
docker build -t mind-heaven-api .
docker run -p 8000:8000 mind-heaven-api
```

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
- `docs/BACKEND_INTEGRATION_DEPLOYMENT.md`
