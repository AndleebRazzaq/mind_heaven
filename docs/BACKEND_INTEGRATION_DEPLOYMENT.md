# FastAPI — Integration, Models, and Deployment

## 1. Backend Layout

```text
backend/
  app/
    main.py           # API entrypoint (Port 8001)
    schemas.py        # Pydantic models
    utils.py          # AI utility functions & Ollama pipeline
    services/
      distortion_service.py      # Fine-tuned DistilBERT
      emotion_service.py         # GoEmotions model
      emotional_state_mapper.py   # Label → Human-readable state
      context_detector.py        # Context analysis
      reframe_pipeline.py        # LLM orchestration
  requirements.txt
```

---

## 2. LLM Integration (Ollama)

The backend uses **Ollama** for generative CBT reframing.

### Setup
1.  Install [Ollama](https://ollama.com/).
2.  Pull the required model: `ollama pull llama3.2:1b`.
3.  Ensure the Ollama server is running (usually at `http://localhost:11434`).

### Environment Variables
- `OLLAMA_URL`: URL for the Ollama API (Default: `http://localhost:11434/api/generate`).
- `OLLAMA_MODEL`: The model name to use (Default: `llama3.2:1b`).

---

## 3. Classification Models

### Distortion Classifier
- **Model:** Fine-tuned DistilBERT.
- **Location:** `backend/models/cbt_distortion_model_impr`.
- **Loading:** Uses `AutoModelForSequenceClassification` from Transformers.

### Emotion Classifier
- **Model:** Pretrained GoEmotions DistilRoBERTa.
- **Location:** `backend/models/emotion_goemotions_model`.

---

## 4. API Contract

### **`POST /analyze`**

**Request:**
```json
{
  "text": "I feel so nervous about my presentation tomorrow, I'm sure I'll fail."
}
```

**Response:**
```json
{
  "emotion": {
    "raw_label": "nervousness",
    "emotion_group": "anxiety",
    "context": "performance",
    "intensity": 85,
    "intensity_label": "Very High",
    "final_label": "Performance Stress",
    "confidence": 0.8542
  },
  "distortion": {
    "label": "fortune-telling",
    "confidence": 0.7231
  },
  "show_breathing": true,
  "show_emergency": false,
  "ai_response": {
    "insight": "You seem concerned about meeting expectations or doing well.",
    "pattern_explanation": "Fortune-telling involves predicting a negative outcome without considering more likely possibilities.",
    "reframe": "While it's natural to feel nervous, your past successes show you are capable. One presentation doesn't define your entire worth.",
    "action": "Try practicing your presentation once more in a comfortable environment.",
    "plant": "Plant Suggestion: You seem to experience nervousness—consider keeping a Peace Lily nearby."
  }
}
```

---

## 5. Local Execution

1.  **Activate Virtual Env:**
    ```bash
    cd backend
    .venv\Scripts\activate
    ```
2.  **Run with Uvicorn:**
    ```bash
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
    ```

---

## 6. Flutter Integration

- **Endpoint:** `http://<HOST>:8001/analyze`
- **Android Emulator:** Use `http://10.0.2.2:8001/analyze`.
- **Configuration:** Managed in `lib/core/config/app_config.dart`.
- **Toggle:** Set `useRemote: true` in `JournalRepositoryImpl` (usually in `bootstrap.dart`).

---

## 7. Troubleshooting

- **Ollama Error:** Ensure the Ollama service is running and the model is pulled.
- **Connection Refused:** Check the port (8001) and host IP.
- **CORS Issues:** The backend includes CORSMiddleware; ensure the request origin is allowed if testing from web.
- **Model Paths:** Verify the `models/` directory exists inside `backend/` and contains the required weight folders.
