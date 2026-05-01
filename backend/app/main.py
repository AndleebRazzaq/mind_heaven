from fastapi import FastAPI
from pydantic import BaseModel
from .utils import (
    predict_emotion,
    predict_distortion,
    map_intensity,
    build_prompt,
    generate_ai_response
)

app = FastAPI(title="Reframed AI API")

# ==============================
# REQUEST FORMAT
# ==============================

class TextRequest(BaseModel):
    text: str

# ==============================
# MAIN ENDPOINT — /analyze
# ==============================

@app.post("/analyze")
def analyze(request: TextRequest):
    """
    Analyze journal text and return:
    - Emotion + intensity (0-100)
    - Distortion pattern
    - AI-generated insight, pattern, reframe, action
    - Breathing flag (intensity >= 70)
    """
    
    text = request.text.strip()
    
    if not text:
        return {"error": "Text cannot be empty"}
    
    # ==============================
    # STEP 1: RUN MODELS
    # ==============================
    
    emotion = predict_emotion(text)
    distortion = predict_distortion(text)
    
    intensity = map_intensity(emotion["confidence"])
    
    # ==============================
    # STEP 2: RULE LOGIC
    # ==============================
    
    show_breathing = intensity >= 70
    
    # ==============================
    # STEP 3: PROMPT + LLM
    # ==============================
    
    prompt = build_prompt(
        text,
        emotion["label"],
        intensity,
        distortion["label"]
    )
    
    ai_output = generate_ai_response(prompt)
    
    # ==============================
    # STEP 4: FINAL RESPONSE
    # ==============================
    
    return {
        "emotion": emotion,
        "intensity": intensity,
        "distortion": distortion,
        "show_breathing": show_breathing,
        "ai_response": {
            "insight": ai_output.get("insight", ""),
            "pattern": ai_output.get("pattern", ""),
            "reframe": ai_output.get("reframe", ""),
            "action": ai_output.get("action", ""),
            "plant": ai_output.get("plant", "")
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
