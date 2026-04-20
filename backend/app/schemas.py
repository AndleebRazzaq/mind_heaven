from pydantic import BaseModel, Field
from typing import Optional


class JournalAnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1)
    user_reported_intensity: Optional[float] = Field(
        default=None,
        ge=1.0,
        le=10.0,
        description="Optional 1–10: how intense this feels to the user; merged with model estimate for guidance.",
    )


class EmotionAnalysis(BaseModel):
    detected_emotion: str
    confidence: float
    intensity_estimate: float


class DistortionAnalysis(BaseModel):
    detected_pattern: str
    confidence: float
    confidence_level: str
    combined_confidence: float
    insight_line: Optional[str] = Field(
        default=None,
        description="Short line linking the detected pattern to the user's experience.",
    )


class RiskAssessment(BaseModel):
    risk_level: str
    escalation_required: bool


class StructuredReframe(BaseModel):
    """All cognitive-reframe output in one place (no duplicate top-level fields)."""

    composed: str = Field(
        ...,
        description="Full reframe paragraph for UI (validation + challenge + balanced + next step).",
    )
    event_summary: Optional[str] = None
    core_beliefs: list[str] = Field(default_factory=list)
    logic_line: Optional[str] = None
    balanced_alternative: Optional[str] = None
    behavioral_prompt: Optional[str] = None
    generation_mode: str = "template_only"
    validation_errors: list[str] = Field(default_factory=list)
    fallback_reason: Optional[str] = None
    policy_version: str = "reframe_policy_v2"


class ResponseLayers(BaseModel):
    """UI copy layers without repeating structured_reframe content."""

    validation: str
    pattern_awareness: str
    cognitive_expansion_prompts: list[str]
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
    # Core CBT copy (legacy shape kept compact)
    distortion_explanation: str
    emotional_acknowledgment: str
    intervention_mode: str
    cbt_technique: str
    reframe_guidance: str
    distortion_insight_line: Optional[str] = None
    coping_exercise_title: str
    coping_exercise_description: str
    plant_suggestion: str
    plant_image_url: Optional[str] = None
    plant_reference_url: Optional[str] = None
    suggest_breathing: bool
    breathing_technique: Optional[str] = None
    # Quick-scan fields (mirrors nested analysis for lightweight clients)
    mood_label: Optional[str] = None
    emotion_confidence: Optional[float] = None
    stress_level: Optional[float] = None
    detected_distortion_label: Optional[str] = None
    distortion_description: Optional[str] = None
    confidence: Optional[float] = None
    distortion_label_id: Optional[int] = None
    certainty: Optional[str] = None
    feedback_type: Optional[str] = None
    coaching_tone: Optional[str] = None
    emotion_intensity: Optional[float] = None
    intensity_band: Optional[str] = None
    emotional_support_message: Optional[str] = None
    micro_intervention_title: Optional[str] = None
    micro_intervention_prompt: Optional[str] = None
    risk_score: Optional[float] = None
    risk_level: Optional[str] = None
    safety_override: bool = False
    safety_message: Optional[str] = None
    # Nested bundles
    structured_reframe: StructuredReframe
    emotion_analysis: Optional[EmotionAnalysis] = None
    distortion_analysis: Optional[DistortionAnalysis] = None
    risk_assessment: Optional[RiskAssessment] = None
    response_layers: Optional[ResponseLayers] = None
    ui_flags: Optional[UiFlags] = None
