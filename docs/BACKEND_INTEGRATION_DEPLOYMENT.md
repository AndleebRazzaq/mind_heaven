# FastAPI Integration and Deployment Guide

## 1) Backend structure

```text
backend/
  app/
    main.py
    schemas.py
    services/
      distortion_service.py
      emotion_service.py
      cbt_engine.py
  requirements.txt
  Dockerfile
```

`services/` is intentionally replaceable:
- swap `distortion_service.py` with your fine-tuned DistilBERT/BERT inference
- swap `emotion_service.py` with your pretrained emotion model
- keep `cbt_engine.py` rule-based for safety/theory alignment

## 2) Run backend locally

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Check:
- `GET /health`
- Swagger docs: `http://localhost:8000/docs`

## 3) Flutter integration points

- Base URL: `lib/core/config/app_config.dart`
- HTTP client: `lib/core/network/api_client.dart`
- Journal endpoint integration: `lib/data/remote/journal_remote_data_source.dart`
- Repository switch (local/mock vs remote/api): `lib/main.dart`

In `main.dart`:
- `useRemote: false` -> local model-ready logic
- `useRemote: true` -> FastAPI endpoint

## 4) Android emulator / real device URL notes

- Android emulator to local machine:
  - `http://10.0.2.2:8000`
- iOS simulator:
  - `http://localhost:8000`
- Physical device:
  - `http://<YOUR_PC_LOCAL_IP>:8000`

## 5) Deploy backend with Docker

```bash
cd backend
docker build -t mind-heaven-api .
docker run -p 8000:8000 mind-heaven-api
```

## 6) Cloud deployment options

- Render / Railway / Fly.io / Azure App Service / AWS ECS
- After deploy, set `API_BASE_URL` at build/run:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api-domain
```

or for release builds:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-api-domain
```
