# Mind Heaven FastAPI Backend

## Run locally

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Open:
- Health: `http://localhost:8000/health`
- Swagger: `http://localhost:8000/docs`

## Docker

```bash
cd backend
docker build -t mind-heaven-api .
docker run -p 8000:8000 mind-heaven-api
```

## Model Replacement Points

- `app/services/distortion_service.py` → replace with fine-tuned DistilBERT/BERT inference
- `app/services/emotion_service.py` → replace with pretrained emotion model
- `app/services/cbt_engine.py` → keep rule-based mapping for safety and theoretical alignment

## Flutter Integration

The app calls:

- `POST /analyze/journal`

Request:

```json
{ "text": "I always fail and this will be a disaster." }
```

Response fields map directly to Flutter `CBTIntervention`.

To use API in Flutter, set repository `useRemote: true` in `main.dart`.
