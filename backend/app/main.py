from fastapi import FastAPI
from .schemas import (
    DistortionAnalysis,
    EmotionAnalysis,
    JournalAnalyzeRequest,
    JournalAnalyzeResponse,
    ResponseLayers,
    RiskAssessment,
    StructuredReframe,
    UiFlags,
)
from .services.distortion_service import (
    DISTORTION_DESC_MAP,
    DistortionService,
    certainty_feedback,
)
from .services.emotion_service import EmotionService
from .services.cbt_engine import CbtEngine
from .services.reframe_pipeline import ReframeInput, build_reframe_pipeline

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

DISTORTION_RESPONSE_MAP = {
    "all-or-nothing thinking": {
        "definition": "Viewing situations in extremes (success or failure, good or bad).",
        "insight_suffix": "viewing things as total success or total failure.",
        "prompts": [
            "Is there a middle ground?",
            "What would partial success look like?",
            "Are you using absolute words like 'always' or 'never'?",
        ],
        "reframe": "This situation may not be perfect, but it does not mean it is a total failure.",
    },
    "overgeneralization": {
        "definition": "Drawing broad conclusions from a single event.",
        "insight_suffix": "treating one difficult moment like a permanent pattern.",
        "prompts": [
            "Is this one event defining everything?",
            "Have there been exceptions to this pattern?",
            "What evidence shows this is not always true?",
        ],
        "reframe": "This was one experience, not a permanent pattern.",
    },
    "mental filter": {
        "definition": "Focusing only on negative details while ignoring positives.",
        "insight_suffix": "zooming in on negatives while positives fade into the background.",
        "prompts": [
            "What positive aspects might you be overlooking?",
            "What went even slightly well?",
            "Would someone else see this differently?",
        ],
        "reframe": "There may be challenges here, but that is not the whole picture.",
    },
    "disqualifying the positive": {
        "definition": "Rejecting positive experiences by saying they do not count.",
        "insight_suffix": "dismissing real positives before they can support perspective.",
        "prompts": [
            "Why might this positive feedback be valid?",
            "What would it mean if this success truly counted?",
            "Are you dismissing something good too quickly?",
        ],
        "reframe": "It is reasonable to acknowledge this positive outcome.",
    },
    "jumping to conclusions": {
        "definition": "Making assumptions without sufficient evidence.",
        "insight_suffix": "filling in gaps quickly without enough evidence.",
        "prompts": [
            "What facts do you actually have?",
            "Are there alternative explanations?",
            "What might you be assuming?",
        ],
        "reframe": "I may not have enough evidence to be certain about this.",
    },
    "mind reading": {
        "definition": "Assuming you know what others are thinking.",
        "insight_suffix": "assuming others see you negatively without direct proof.",
        "prompts": [
            "What proof do you have of this?",
            "Could there be another explanation?",
            "Have they actually said this?",
        ],
        "reframe": "I do not truly know what others are thinking.",
    },
    "catastrophizing": {
        "definition": "Expecting the worst possible outcome.",
        "insight_suffix": "making uncertainty feel like certain disaster.",
        "prompts": [
            "What is the realistic probability of the worst outcome?",
            "If it happened, how would you cope?",
            "What is a more likely outcome?",
        ],
        "reframe": "This situation is stressful, but the worst-case scenario is not guaranteed.",
    },
    "magnification / catastrophizing": {
        "definition": "Expecting the worst possible outcome.",
        "insight_suffix": "making uncertainty feel like certain disaster.",
        "prompts": [
            "What is the realistic probability of the worst outcome?",
            "If it happened, how would you cope?",
            "What is a more likely outcome?",
        ],
        "reframe": "This situation is stressful, but the worst-case scenario is not guaranteed.",
    },
    "emotional reasoning": {
        "definition": "Believing something must be true because it feels true.",
        "insight_suffix": "treating intense feelings as proof of facts.",
        "prompts": [
            "Does feeling this way automatically make it fact?",
            "What objective evidence exists?",
            "Could emotions be influencing perception?",
        ],
        "reframe": "Feelings are important, but they are not always facts.",
    },
    "should statements": {
        "definition": "Using rigid rules about how things should be.",
        "insight_suffix": "turning preferences into strict inner rules.",
        "prompts": [
            "Is this rule flexible or rigid?",
            "What would happen if you softened this expectation?",
            "Are you being too strict with yourself?",
        ],
        "reframe": "It might be more helpful to prefer rather than demand.",
    },
    "labeling": {
        "definition": "Attaching a global negative label to yourself or others.",
        "insight_suffix": "attaching a harsh global label based on one situation.",
        "prompts": [
            "Does one behavior define your entire identity?",
            "What specific action occurred instead of the label?",
            "Would you describe a friend this way?",
        ],
        "reframe": "One mistake does not define who I am.",
    },
    "personalization": {
        "definition": "Taking responsibility for events outside your control.",
        "insight_suffix": "taking blame for outcomes shaped by many factors.",
        "prompts": [
            "What factors were outside your control?",
            "Are you assuming blame too quickly?",
            "Could other explanations exist?",
        ],
        "reframe": "I may not be solely responsible for this outcome.",
    },
}

GENERAL_PROMPTS = [
    "What evidence supports this thought?",
    "What evidence challenges it?",
    "Is there another possible explanation?",
]


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


def _coaching_tone(*, emotion_intensity: float, distortion_confidence: float) -> str:
    """Conversation style for UI copy: calm under high load, direct when confidence is high."""
    if emotion_intensity >= 7.0:
        return "gentle"
    if distortion_confidence >= 0.7 and emotion_intensity < 4.5:
        return "direct"
    return "balanced"


def _intensity_band(value: float) -> str:
    if value >= 7.0:
        return "high"
    if value >= 4.0:
        return "moderate"
    return "low"


def _resolve_distortion_guidance(
    *, distortion_label: str, confidence: float
) -> tuple[str, list[str], str, str]:
    """Rule-based mapping with confidence guard to prevent over-specific feedback."""
    key = distortion_label.strip().lower()
    if confidence >= 0.65 and key in DISTORTION_RESPONSE_MAP:
        data = DISTORTION_RESPONSE_MAP[key]
        return (
            data["definition"],
            data["prompts"],
            data["reframe"],
            f'This pattern may resemble "{distortion_label}" - {data["insight_suffix"]}',
        )
    return (
        "A thinking pattern may be adding emotional pressure right now.",
        GENERAL_PROMPTS,
        "This is difficult, but there may be more than one way to see this situation.",
        "This pattern can increase emotional pressure by making one moment define everything.",
    )


def _emotional_support_message(*, emotion_label: str, intensity_band: str) -> str | None:
    emotion = emotion_label.lower()
    if intensity_band == "high":
        return (
            "This sounds like a high emotional load. It is okay to slow down first - "
            "you do not need to solve everything at once."
        )
    if "sad" in emotion or "depress" in emotion or "hopeless" in emotion:
        return (
            "Low mood can make thoughts feel absolute. Try one small caring action for yourself, "
            "then return to this reflection."
        )
    return None


def _select_breathing_plan(
    *, emotion_label: str, emotion_intensity: float, risk_level: str
) -> tuple[bool, str | None, str | None]:
    """Returns suggest flag + technique title + guided steps."""
    e = emotion_label.lower()
    high = emotion_intensity >= 7.0 or risk_level in ("moderate", "high")

    if not high and all(k not in e for k in ("fear", "anxiety", "sad", "anger", "stress")):
        return (False, None, None)

    if "anger" in e:
        return (
            True,
            "Calm reset - Extended exhale breathing",
            "Inhale 4 seconds through the nose, then exhale slowly for 6 seconds. "
            "Repeat for 60 seconds.",
        )
    if "sad" in e or "depress" in e:
        return (
            True,
            "Calm reset - 4-7-8 breathing",
            "Inhale 4s, hold 7s, exhale 8s. Complete 3 to 4 rounds.",
        )
    if emotion_intensity >= 8.5:
        return (
            True,
            "Calm reset - Physiological sigh",
            "Take a deep inhale, then a second short inhale, then a long slow exhale. "
            "Repeat for about 1 minute.",
        )
    return (
        True,
        "Calm reset - Box breathing",
        "Inhale 4s, hold 4s, exhale 4s, hold 4s. Continue for 60 seconds.",
    )


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/analyze/journal", response_model=JournalAnalyzeResponse)
def analyze_journal(payload: JournalAnalyzeRequest) -> JournalAnalyzeResponse:
    distortion = distortion_service.classify(payload.text)
    emotion = emotion_service.classify(payload.text)
    cbt = cbt_engine.run(distortion.label, distortion.confidence, emotion.label)
    certainty, feedback_type = certainty_feedback(distortion.confidence)
    model_intensity = round(max(0.0, min(10.0, emotion.confidence * 10.0)), 2)
    emotion_intensity = model_intensity
    if payload.user_reported_intensity is not None:
        emotion_intensity = round(
            max(model_intensity, float(payload.user_reported_intensity)), 2
        )
    risk_score = _risk_score(payload.text)
    risk_level = _risk_level(risk_score)
    suggest_breathing, breathing_title, breathing_steps = _select_breathing_plan(
        emotion_label=emotion.label,
        emotion_intensity=emotion_intensity,
        risk_level=risk_level,
    )
    micro_title, micro_prompt = _micro_intervention(
        emotion_label=emotion.label,
        emotion_intensity=emotion_intensity,
        distortion_label=distortion.label,
        distortion_confidence=distortion.confidence,
    )
    if breathing_title:
        micro_title = breathing_title
    if breathing_steps:
        micro_prompt = breathing_steps
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
    coaching_tone = _coaching_tone(
        emotion_intensity=emotion_intensity,
        distortion_confidence=distortion.confidence,
    )
    plant_name, plant_description = _split_plant(cbt.plant_suggestion)
    pattern_awareness, cognitive_prompts, _mapped_reframe, insight_line = _resolve_distortion_guidance(
        distortion_label=distortion.label,
        confidence=distortion.confidence,
    )
    reframe = build_reframe_pipeline(
        ReframeInput(
            text=payload.text,
            emotion_label=emotion.label,
            distortion_label=distortion.label,
            distortion_confidence=distortion.confidence,
            risk_level=risk_level,
        )
    )
    intensity_band = _intensity_band(emotion_intensity)
    emotional_support_message = _emotional_support_message(
        emotion_label=emotion.label,
        intensity_band=intensity_band,
    )

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
            breathing_technique=breathing_steps
            or "Inhale 4s, hold 4s, exhale 4s, hold 4s for 60 seconds.",
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
            coaching_tone="gentle",
            intensity_band="high",
            distortion_insight_line=(
                "Your safety matters most right now. We can return to thought patterns after you feel more supported."
            ),
            emotional_support_message=emotional_support_message,
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
                insight_line=(
                    "Your safety matters most right now. We can return to thought patterns after you feel more supported."
                ),
            ),
            risk_assessment=RiskAssessment(
                risk_level=risk_level,
                escalation_required=True,
            ),
            structured_reframe=StructuredReframe(
                composed="Before reframing deeply, prioritize immediate support and grounding.",
                event_summary=reframe.event_summary,
                core_beliefs=reframe.core_beliefs,
                logic_line=reframe.distortion_logic_line,
                balanced_alternative=reframe.balanced_alternative,
                behavioral_prompt="Prioritize safety and contact support before cognitive reframing.",
                generation_mode=reframe.generation_mode,
                validation_errors=reframe.validation_errors,
                fallback_reason=reframe.fallback_reason,
                policy_version=reframe.policy_version,
            ),
            response_layers=ResponseLayers(
                validation="It makes sense that this feels overwhelming right now.",
                pattern_awareness=pattern_awareness,
                cognitive_expansion_prompts=cognitive_prompts,
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
        reframe_guidance=reframe.reframe_text,
        coping_exercise_title=cbt.coping_exercise_title,
        coping_exercise_description=cbt.coping_exercise_description,
        plant_suggestion=cbt.plant_suggestion,
        plant_image_url=cbt.plant_image_url,
        plant_reference_url=cbt.plant_reference_url,
        suggest_breathing=suggest_breathing,
        breathing_technique=breathing_steps or cbt.breathing_technique,
        mood_label=emotion.label,
        emotion_confidence=emotion.confidence,
        emotion_intensity=emotion_intensity,
        stress_level=stress_level,
        detected_distortion_label=distortion.label,
        distortion_description=pattern_awareness,
        confidence=distortion.confidence,
        distortion_label_id=distortion.label_id,
        certainty=certainty,
        feedback_type=feedback_type,
        coaching_tone=coaching_tone,
        intensity_band=intensity_band,
        distortion_insight_line=reframe.distortion_logic_line or insight_line,
        emotional_support_message=emotional_support_message,
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
            insight_line=reframe.distortion_logic_line or insight_line,
        ),
        risk_assessment=RiskAssessment(
            risk_level=risk_level,
            escalation_required=False,
        ),
        structured_reframe=StructuredReframe(
            composed=reframe.reframe_text,
            event_summary=reframe.event_summary,
            core_beliefs=reframe.core_beliefs,
            logic_line=reframe.distortion_logic_line,
            balanced_alternative=reframe.balanced_alternative,
            behavioral_prompt=reframe.behavioral_shift_prompt,
            generation_mode=reframe.generation_mode,
            validation_errors=reframe.validation_errors,
            fallback_reason=reframe.fallback_reason,
            policy_version=reframe.policy_version,
        ),
        response_layers=ResponseLayers(
            validation=cbt.emotional_acknowledgment,
            pattern_awareness=pattern_awareness,
            cognitive_expansion_prompts=cognitive_prompts,
            regulation_suggestion=micro_prompt,
            cbt_therapy_technique=cbt.cbt_technique,
            plant_suggestion_name=plant_name,
            plant_suggestion_description=plant_description,
            plant_image_url=cbt.plant_image_url,
        ),
        ui_flags=UiFlags(
            show_breathing_exercise=suggest_breathing,
            show_reframe_builder=True,
            show_escalation_resources=False,
        ),
    )
