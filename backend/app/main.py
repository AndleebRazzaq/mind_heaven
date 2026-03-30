from fastapi import FastAPI
from .schemas import (
    DistortionAnalysis,
    EmotionAnalysis,
    JournalAnalyzeRequest,
    JournalAnalyzeResponse,
    ResponseLayers,
    RiskAssessment,
    UiFlags,
)
from .services.distortion_service import (
    DISTORTION_DESC_MAP,
    DistortionService,
    certainty_feedback,
)
from .services.emotion_service import EmotionService
from .services.cbt_engine import CbtEngine

app = FastAPI(title="Mind Heaven API", version="1.0.0")

distortion_service = DistortionService()
emotion_service = EmotionService()
cbt_engine = CbtEngine()

RISK_KEYWORDS_HIGH = (
    "kill myself",
    "end my life",
    "suicide",
    "self harm",
    "self-harm",
    "want to die",
    "better off dead",
    "no reason to live",
)
RISK_KEYWORDS_MED = (
    "hopeless",
    "can't go on",
    "cannot go on",
    "worthless",
    "numb",
    "empty",
    "trapped",
    "give up",
)


def _risk_score(text: str) -> float:
    lower = text.lower()
    score = 0.0
    for k in RISK_KEYWORDS_HIGH:
        if k in lower:
            score += 0.65
    for k in RISK_KEYWORDS_MED:
        if k in lower:
            score += 0.2
    return min(score, 1.0)


def _risk_level(score: float) -> str:
    if score >= 0.7:
        return "high"
    if score >= 0.35:
        return "moderate"
    return "low"


def _micro_intervention(
    *,
    emotion_label: str,
    emotion_intensity: float,
    distortion_label: str,
    distortion_confidence: float,
) -> tuple[str | None, str | None]:
    """Layer 4: body-first regulation cue when emotional load is elevated."""
    high_emotion = emotion_intensity > 7.0
    catastrophizing = "catastroph" in distortion_label.lower()
    low_conf_high_emotion = distortion_confidence < 0.5 and emotion_intensity >= 6.5

    if high_emotion or catastrophizing or low_conf_high_emotion:
        if "fear" in emotion_label.lower() or "anxiety" in emotion_label.lower():
            return (
                "30-second breathing cue",
                "Let's pause for one slow breath together before we look at this differently. "
                "Inhale 4s, hold 2s, exhale 6s for 3 rounds.",
            )
        if "anger" in emotion_label.lower():
            return (
                "Grounding prompt",
                "Notice 5 things you can see, 4 you can feel, 3 you can hear. "
                "This helps your body settle before reframing.",
            )
        return (
            "Self-compassion prompt",
            "This feels heavy right now. Place a hand on your chest and say: "
            "\"I am struggling, and I can still be kind to myself in this moment.\"",
        )
    return (None, None)


def _split_plant(plant_text: str) -> tuple[str, str]:
    parts = plant_text.split(" - ", 1)
    if len(parts) == 2:
        return parts[0].strip(), parts[1].strip()
    return plant_text.strip(), ""


def _confidence_level(conf: float) -> str:
    if conf >= 0.7:
        return "high"
    if conf >= 0.5:
        return "moderate"
    return "low"


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/analyze/journal", response_model=JournalAnalyzeResponse)
def analyze_journal(payload: JournalAnalyzeRequest) -> JournalAnalyzeResponse:
    distortion = distortion_service.classify(payload.text)
    emotion = emotion_service.classify(payload.text)
    cbt = cbt_engine.run(distortion.label, distortion.confidence, emotion.label)
    certainty, feedback_type = certainty_feedback(distortion.confidence)
    emotion_intensity = round(max(0.0, min(10.0, emotion.confidence * 10.0)), 2)
    micro_title, micro_prompt = _micro_intervention(
        emotion_label=emotion.label,
        emotion_intensity=emotion_intensity,
        distortion_label=distortion.label,
        distortion_confidence=distortion.confidence,
    )
    risk_score = _risk_score(payload.text)
    risk_level = _risk_level(risk_score)
    safety_override = risk_level in ("moderate", "high")
    safety_message = None
    if safety_override:
        safety_message = (
            "It sounds like you're going through something very heavy. "
            "You do not have to handle this alone. Consider contacting a trusted person "
            "or local mental health/crisis support right now."
        )

    el = emotion.label.lower()
    if "anxiety" in el or "fear" in el:
        stress_level = 0.78
    elif "anger" in el or "sad" in el:
        stress_level = 0.68
    elif "joy" in el or "calm" in el:
        stress_level = 0.35
    else:
        stress_level = 0.48

    combined_confidence = round((0.6 * distortion.confidence) + (0.4 * emotion.confidence), 4)
    confidence_level = _confidence_level(distortion.confidence)
    plant_name, plant_description = _split_plant(cbt.plant_suggestion)
    pattern_awareness = (
        DISTORTION_DESC_MAP.get(distortion.label)
        or "This thought may include a cognitive pattern worth exploring gently."
    )
    cognitive_prompts = [
        "What evidence supports this thought?",
        "Is there another possible explanation?",
        "How likely is this outcome realistically?",
    ]

    # Layer 5 safety override: supportive + encourage human support
    if safety_override:
        return JournalAnalyzeResponse(
            distortion_explanation=cbt.distortion_explanation,
            emotional_acknowledgment=(
                "Thank you for sharing this. Your safety and support matter most right now."
            ),
            intervention_mode="Safety escalation support",
            cbt_technique="Stabilization and support seeking",
            reframe_guidance=(
                "Before reframing thoughts, focus on immediate support and grounding. "
                "Reach out to a trusted person or crisis resource in your area."
            ),
            coping_exercise_title=micro_title or "Immediate grounding",
            coping_exercise_description=micro_prompt
            or "Take one slow breath, place both feet on the ground, and name one person you can contact now.",
            plant_suggestion=cbt.plant_suggestion,
            plant_image_url=cbt.plant_image_url,
            plant_reference_url=cbt.plant_reference_url,
            suggest_breathing=True,
            breathing_technique="4-7-8 breathing: inhale 4s, hold 7s, exhale 8s. Repeat twice.",
            mood_label=emotion.label,
            emotion_confidence=emotion.confidence,
            emotion_intensity=emotion_intensity,
            stress_level=max(stress_level, 0.8),
            detected_distortion_label=distortion.label,
            distortion_description=DISTORTION_DESC_MAP.get(distortion.label),
            confidence=distortion.confidence,
            distortion_label_id=distortion.label_id,
            certainty=certainty,
            feedback_type=feedback_type,
            micro_intervention_title=micro_title,
            micro_intervention_prompt=micro_prompt,
            risk_score=risk_score,
            risk_level=risk_level,
            safety_override=True,
            safety_message=safety_message,
            emotion_analysis=EmotionAnalysis(
                detected_emotion=emotion.label,
                confidence=emotion.confidence,
                intensity_estimate=emotion_intensity,
            ),
            distortion_analysis=DistortionAnalysis(
                detected_pattern=distortion.label,
                confidence=distortion.confidence,
                confidence_level=confidence_level,
                combined_confidence=combined_confidence,
            ),
            risk_assessment=RiskAssessment(
                risk_level=risk_level,
                escalation_required=True,
            ),
            response_layers=ResponseLayers(
                validation="It makes sense that this feels overwhelming right now.",
                pattern_awareness=pattern_awareness,
                cognitive_expansion_prompts=cognitive_prompts,
                balanced_reframe_suggestion=(
                    "Before reframing deeply, prioritize immediate support and grounding."
                ),
                regulation_suggestion=micro_prompt,
                cbt_therapy_technique="Stabilization and support seeking",
                plant_suggestion_name=plant_name,
                plant_suggestion_description=plant_description,
                plant_image_url=cbt.plant_image_url,
            ),
            ui_flags=UiFlags(
                show_breathing_exercise=True,
                show_reframe_builder=True,
                show_escalation_resources=True,
            ),
        )

    return JournalAnalyzeResponse(
        distortion_explanation=cbt.distortion_explanation,
        emotional_acknowledgment=cbt.emotional_acknowledgment,
        intervention_mode=cbt.intervention_mode,
        cbt_technique=cbt.cbt_technique,
        reframe_guidance=cbt.reframe_guidance,
        coping_exercise_title=cbt.coping_exercise_title,
        coping_exercise_description=cbt.coping_exercise_description,
        plant_suggestion=cbt.plant_suggestion,
        plant_image_url=cbt.plant_image_url,
        plant_reference_url=cbt.plant_reference_url,
        suggest_breathing=cbt.suggest_breathing,
        breathing_technique=cbt.breathing_technique,
        mood_label=emotion.label,
        emotion_confidence=emotion.confidence,
        emotion_intensity=emotion_intensity,
        stress_level=stress_level,
        detected_distortion_label=distortion.label,
        distortion_description=DISTORTION_DESC_MAP.get(distortion.label),
        confidence=distortion.confidence,
        distortion_label_id=distortion.label_id,
        certainty=certainty,
        feedback_type=feedback_type,
        micro_intervention_title=micro_title,
        micro_intervention_prompt=micro_prompt,
        risk_score=risk_score,
        risk_level=risk_level,
        safety_override=False,
        safety_message=safety_message,
        emotion_analysis=EmotionAnalysis(
            detected_emotion=emotion.label,
            confidence=emotion.confidence,
            intensity_estimate=emotion_intensity,
        ),
        distortion_analysis=DistortionAnalysis(
            detected_pattern=distortion.label,
            confidence=distortion.confidence,
            confidence_level=confidence_level,
            combined_confidence=combined_confidence,
        ),
        risk_assessment=RiskAssessment(
            risk_level=risk_level,
            escalation_required=False,
        ),
        response_layers=ResponseLayers(
            validation=cbt.emotional_acknowledgment,
            pattern_awareness=pattern_awareness,
            cognitive_expansion_prompts=cognitive_prompts,
            balanced_reframe_suggestion=cbt.reframe_guidance,
            regulation_suggestion=micro_prompt,
            cbt_therapy_technique=cbt.cbt_technique,
            plant_suggestion_name=plant_name,
            plant_suggestion_description=plant_description,
            plant_image_url=cbt.plant_image_url,
        ),
        ui_flags=UiFlags(
            show_breathing_exercise=cbt.suggest_breathing,
            show_reframe_builder=True,
            show_escalation_resources=False,
        ),
    )
