from fastapi import FastAPI
from pydantic import BaseModel
from app.utils import (
    predict_emotion,
    predict_distortion,
    map_intensity,
    get_ai_response
)

app = FastAPI(title="Mind Heaven Reframed API")

class TextRequest(BaseModel):
    text: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/analyze")
def analyze(request: TextRequest):
    text = request.text.strip()
    if not text:
        return {"error": "Text is empty"}

    try:
        # 1. Run Models
        emotion = predict_emotion(text)
        distortion = predict_distortion(text)

        # 2. Generate AI Response via LLM (Ollama)
        ai_output = get_ai_response(
            text, 
            emotion, 
            distortion["label"]
        )

        # 3. Return upgraded structured JSON with emotional state
        return {
            "emotion": {
                "raw_label": emotion["label"],
                "emotional_state": emotion["emotional_state"],
                "emotional_state_subtitle": emotion["emotional_state_subtitle"],
                "intensity": emotion["intensity"],
                "intensity_label": emotion["intensity_label"],
                "emotion_group": emotion["emotion_group"],
                "context": emotion["context"],
                "confidence": emotion["confidence"],
            },
            "distortion": distortion,
            "show_breathing": emotion["show_breathing"],
            "ai_response": ai_output
        }
    except Exception as e:
        print(f"[API ERROR] {str(e)}")
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
