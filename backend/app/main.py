from fastapi import FastAPI
from pydantic import BaseModel
from app.utils import (
    predict_emotion,
    predict_distortion,
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

        # 3. Return structured JSON
        is_negative = emotion["emotion_group"] in ["stress", "low_mood", "anxiety"]
        return {
            "emotion": emotion,
            "distortion": distortion,
            "show_breathing": emotion["emotion_group"] == "anxiety" and emotion["intensity"] >= 70,
            "show_emergency": is_negative and emotion["intensity"] >= 90,
            "ai_response": ai_output
        }
    except Exception as e:
        print(f"[API ERROR] {str(e)}")
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
