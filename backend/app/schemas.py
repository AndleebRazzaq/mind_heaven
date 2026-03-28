from pydantic import BaseModel, Field
from typing import Optional


class JournalAnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1)


class JournalAnalyzeResponse(BaseModel):
    distortion_explanation: str
    emotional_acknowledgment: str
    intervention_mode: str
    cbt_technique: str
    reframe_guidance: str
    coping_exercise_title: str
    coping_exercise_description: str
    plant_suggestion: str
    suggest_breathing: bool
    breathing_technique: Optional[str] = None
    mood_label: Optional[str] = None
    emotion_confidence: Optional[float] = None
    stress_level: Optional[float] = None
    detected_distortion_label: Optional[str] = None
    confidence: Optional[float] = None
