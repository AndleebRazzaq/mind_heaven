from fastapi import FastAPI
from .schemas import JournalAnalyzeRequest, JournalAnalyzeResponse
from .services.distortion_service import DistortionService
from .services.emotion_service import EmotionService
from .services.cbt_engine import CbtEngine

app = FastAPI(title="Mind Heaven API", version="1.0.0")

distortion_service = DistortionService()
emotion_service = EmotionService()
cbt_engine = CbtEngine()


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/analyze/journal", response_model=JournalAnalyzeResponse)
def analyze_journal(payload: JournalAnalyzeRequest) -> JournalAnalyzeResponse:
    distortion = distortion_service.classify(payload.text)
    emotion = emotion_service.classify(payload.text)
    cbt = cbt_engine.run(distortion.label, distortion.confidence, emotion.label)

    stress_level = 0.75 if emotion.label.lower() == "anxiety" else 0.45

    return JournalAnalyzeResponse(
        distortion_explanation=cbt.distortion_explanation,
        emotional_acknowledgment=cbt.emotional_acknowledgment,
        intervention_mode=cbt.intervention_mode,
        cbt_technique=cbt.cbt_technique,
        reframe_guidance=cbt.reframe_guidance,
        coping_exercise_title=cbt.coping_exercise_title,
        coping_exercise_description=cbt.coping_exercise_description,
        plant_suggestion=cbt.plant_suggestion,
        suggest_breathing=cbt.suggest_breathing,
        breathing_technique=cbt.breathing_technique,
        mood_label=emotion.label,
        emotion_confidence=emotion.confidence,
        stress_level=stress_level,
        detected_distortion_label=distortion.label,
        confidence=distortion.confidence,
    )
