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

## Clean Architecture + Provider

The app now follows a clean, replaceable setup:

- `lib/domain/repositories/` - repository contracts
- `lib/data/repositories/` - repository implementations
- `lib/data/remote/` - API data sources
- `lib/core/network/` - API client
- `lib/presentation/providers/` - `ChangeNotifier` state management

Current providers:
- `JournalProvider` - journal analysis state
- `InsightsProvider` - analytics/insights state

### Provider used in a BLoC-style way

State management is implemented with `Provider + ChangeNotifier`, but structured similar to BLoC responsibilities:

- **UI (Screens):** renders state and dispatches intents (`analyze`, `load`)
- **Provider:** state holder and event handler (`loading`, `error`, `data`)
- **Repository:** business/data orchestration
- **Data source:** local or remote API implementation

So you get BLoC-like separation without extra BLoC boilerplate.

## FastAPI Backend Integration

Backend lives in `backend/` with:

- `app/main.py` - API entrypoint
- `app/services/` - replaceable model/services layer
- `app/schemas.py` - request/response contracts

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
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

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
