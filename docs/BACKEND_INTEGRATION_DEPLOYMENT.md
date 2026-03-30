# FastAPI — Integration, Models, and Deployment

## 1. Backend layout

```text
backend/
  app/
    main.py
    schemas.py
    config.py
    services/
      distortion_service.py    # Your trained model (Transformers folder)
      emotion_service.py       # Hugging Face pretrained pipeline
      cbt_engine.py
      plant_database.py
  requirements.txt
  Dockerfile
```

---

## 2. Distortion classifier (your trained model)

**Expected format:** A directory loadable by `AutoModelForSequenceClassification.from_pretrained(dir)`:

- `config.json`, tokenizer files, weights (`model.safetensors` or `pytorch_model.bin`).

**Numeric labels:** Inference uses **argmax** over logits and **softmax** for **confidence**. The integer id is returned as `distortion_label_id` in the API.

**Human-readable name:** From (in order):

1. `DISTORTION_LABEL_MAP_PATH` JSON, or  
2. `<model_dir>/distortion_label_map.json`, or  
3. `id2label` inside the model `config.json`.

Recommended map location: `<model_dir>/distortion_label_map.json`.

**Environment:**

```bash
set DISTORTION_MODEL_DIR=D:\path\to\your\export
set DISTORTION_LABEL_MAP_PATH=D:\optional\override\map.json
set DISTORTION_USE_MOCK=1
```

`DISTORTION_USE_MOCK=1` skips loading and uses heuristics (useful on laptops without weights).

---

## 3. Emotion classifier (Hugging Face)

**Default model:** `j-hartmann/emotion-english-distilroberta-base`

**Override:**

```bash
set EMOTION_HF_MODEL=SamLowe/roberta-base-go_emotions
set EMOTION_USE_MOCK=1
```

First request may download weights (ensure disk and network). For containers, set `HF_HOME` to a cached volume if desired.

---

## 4. API contract

**`POST /analyze/journal`**

Request:

```json
{ "text": "I always fail and this will be a disaster." }
```

Response (subset): `distortion_explanation`, `mood_label`, `emotion_confidence`, `detected_distortion_label`, `confidence`, **`distortion_label_id`**, `stress_level`, `plant_suggestion`, …

Maps to Flutter `CBTIntervention` in `lib/data/remote/journal_remote_data_source.dart`.

---

## 5. Run locally

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install torch
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

On Linux/Docker, prefer CPU wheels:

```bash
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```

The `Dockerfile` installs CPU `torch` before the rest of `requirements.txt`.

---

## 6. Flutter wiring

- Base URL: `lib/core/config/app_config.dart` (`API_BASE_URL` via `--dart-define`)
- Client: `lib/core/network/api_client.dart`
- Remote journal: `lib/data/remote/journal_remote_data_source.dart`
- Toggle: `lib/main.dart` → `useRemote: true` for API mode

**Device URLs:**

- Android emulator → host: `http://10.0.2.2:8000`
- iOS simulator: `http://localhost:8000`
- Physical device: `http://<PC_LAN_IP>:8000`

---

## 7. Docker

```bash
cd backend
docker build -t mind-heaven-api .
docker run -p 8000:8000 ^
  -e DISTORTION_MODEL_DIR=/models/distortion ^
  -v D:\your\models:/models ^
  mind-heaven-api
```

Mount your model directory and set `DISTORTION_MODEL_DIR` inside the container.

---

## 8. Cloud deploy

Render / Railway / Fly.io / Azure / AWS: build from `backend/Dockerfile`, set env vars, then:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-api-host
```

---

## 9. Implementation details

See **`docs/IMPLEMENTATION_GUIDE.md`** for label-map editing, plant DB alignment, and evaluation notes.
