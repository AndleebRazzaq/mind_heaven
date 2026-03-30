from pydantic import BaseModel, Field
from typing import Optional


class JournalAnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1)


class EmotionAnalysis(BaseModel):
    detected_emotion: str
    confidence: float
    intensity_estimate: float


class DistortionAnalysis(BaseModel):
    detected_pattern: str
    confidence: float
    confidence_level: str
    combined_confidence: float


class RiskAssessment(BaseModel):
    risk_level: str
    escalation_required: bool


class ResponseLayers(BaseModel):
    validation: str
    pattern_awareness: str
    cognitive_expansion_prompts: list[str]
    balanced_reframe_suggestion: str
    regulation_suggestion: Optional[str] = None
    cbt_therapy_technique: Optional[str] = None
    plant_suggestion_name: Optional[str] = None
    plant_suggestion_description: Optional[str] = None
    plant_image_url: Optional[str] = None


class UiFlags(BaseModel):
    show_breathing_exercise: bool
    show_reframe_builder: bool
    show_escalation_resources: bool


class JournalAnalyzeResponse(BaseModel):
    distortion_explanation: str
    emotional_acknowledgment: str
    intervention_mode: str
    cbt_technique: str
    reframe_guidance: str
    coping_exercise_title: str
    coping_exercise_description: str
    plant_suggestion: str
    plant_image_url: Optional[str] = None
    plant_reference_url: Optional[str] = None
    suggest_breathing: bool
    breathing_technique: Optional[str] = None
    mood_label: Optional[str] = None
    emotion_confidence: Optional[float] = None
    stress_level: Optional[float] = None
    detected_distortion_label: Optional[str] = None
    distortion_description: Optional[str] = None
    confidence: Optional[float] = None
    distortion_label_id: Optional[int] = None
    certainty: Optional[str] = None
    feedback_type: Optional[str] = None
    emotion_intensity: Optional[float] = None  # 0-10 scale
    micro_intervention_title: Optional[str] = None
    micro_intervention_prompt: Optional[str] = None
    risk_score: Optional[float] = None
    risk_level: Optional[str] = None
    safety_override: bool = False
    safety_message: Optional[str] = None
    emotion_analysis: Optional[EmotionAnalysis] = None
    distortion_analysis: Optional[DistortionAnalysis] = None
    risk_assessment: Optional[RiskAssessment] = None
    response_layers: Optional[ResponseLayers] = None
    ui_flags: Optional[UiFlags] = None
