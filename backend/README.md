# Mind Heaven FastAPI Backend

Journal analysis API: **distortion** (your fine-tuned Transformers folder, numeric id + confidence), **emotion** (Hugging Face pretrained), then rule-based **CBT** + plant line.

## Run locally

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install torch
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- Health: `http://localhost:8000/health`
- Swagger: `http://localhost:8000/docs`

## Model configuration

| Variable | Description |
|----------|-------------|
| `DISTORTION_MODEL_DIR` | Path to exported Transformers model (`config.json` + weights + tokenizer) |
| `DISTORTION_LABEL_MAP_PATH` | Optional JSON: index → display string (or place `distortion_label_map.json` inside your model folder) |
| `DISTORTION_USE_MOCK` | Set to `1` to use keyword heuristics (no model load) |
| `EMOTION_HF_MODEL` | Default `j-hartmann/emotion-english-distilroberta-base` |
| `EMOTION_USE_MOCK` | Set to `1` to skip Hugging Face download |

Response includes `distortion_label_id` (class index) and `confidence` (softmax for that class).

## Docker

```bash
docker build -t mind-heaven-api .
docker run -p 8000:8000 mind-heaven-api
```

Image installs **CPU** PyTorch first to keep size reasonable.

## Flutter

`POST /analyze/journal` → `JournalRemoteDataSource` → `CBTIntervention`. Enable with `useRemote: true` in `lib/main.dart`.

Full notes: `docs/BACKEND_INTEGRATION_DEPLOYMENT.md`, `docs/IMPLEMENTATION_GUIDE.md`.
