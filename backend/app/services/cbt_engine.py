from dataclasses import dataclass

from .plant_database import suggestion_meta_for_emotion


@dataclass
class CbtOutput:
    distortion_explanation: str
    emotional_acknowledgment: str
    intervention_mode: str
    cbt_technique: str
    reframe_guidance: str
    coping_exercise_title: str
    coping_exercise_description: str
    plant_suggestion: str
    plant_image_url: str | None
    plant_reference_url: str | None
    suggest_breathing: bool
    breathing_technique: str | None


class CbtEngine:
    _DIRECT_REFRAME_MAP = {
        "catastrophizing": "I notice you are predicting the worst outcome as certain. What is the most likely realistic outcome?",
        "all-or-nothing thinking": "This thought sounds very black-and-white. What would a balanced middle-ground view look like?",
        "overgeneralization": "This may be one painful event, not the whole pattern. Can you find one clear exception?",
        "mental filter": "You may be focusing mostly on the negative detail. What neutral or positive facts are also true?",
        "disqualifying the positive": "A positive part may be getting dismissed. What small positive outcome still counts?",
        "jumping to conclusions": "This may be a fast conclusion. What evidence supports it, and what evidence does not?",
        "mind reading": "You might be assuming what others think. What direct evidence do you have?",
        "emotional reasoning": "Your feelings matter, and they are real. What facts support or challenge this thought?",
        "should statements": "This sounds like a strict rule for yourself. Could you rephrase it as a flexible preference?",
        "labeling": "Instead of a global label, try describing one behavior or moment. What specifically happened?",
        "personalization": "You may be taking too much responsibility. What other factors also contributed?",
    }

    _GENTLE_REFRAME_MAP = {
        "catastrophizing": "I notice you are imagining the worst. Could you consider a more realistic outcome?",
        "all-or-nothing thinking": "It looks like this feels all bad or all good. Is there a possible middle ground?",
        "overgeneralization": "This feels broad right now. Could this be true for this moment rather than always?",
        "mental filter": "It seems the negative part stands out strongly. Can you notice one neutral or positive detail too?",
        "disqualifying the positive": "Can you notice one positive thing that counts, even if it feels small?",
        "jumping to conclusions": "It seems you may be filling in missing information. What evidence do you have so far?",
        "mind reading": "You might be assuming what others think. What evidence do you have?",
        "emotional reasoning": "The feeling is valid. Could we also check what the facts are saying?",
        "should statements": "This sounds like a 'should'. Could you try a gentler phrase like 'I would prefer'?",
        "labeling": "This sounds harsh toward yourself. Could you describe the event without using a label?",
        "personalization": "You may be blaming yourself heavily. What parts were outside your control?",
    }

    def _normalize_distortion_key(self, distortion_label: str) -> str:
        d = distortion_label.strip().lower()
        aliases = {
            "all-or-nothing": "all-or-nothing thinking",
            "magnification / catastrophizing": "catastrophizing",
            "magnification": "catastrophizing",
        }
        return aliases.get(d, d)

    def _plant_by_emotion(self, emotion: str) -> str:
        meta = suggestion_meta_for_emotion(emotion)
        return f"{meta.name} - {meta.description}"

    def _acknowledge(self, emotion: str) -> str:
        e = emotion.lower()
        if "anxiety" in e:
            return "It makes sense that this feels overwhelming right now."
        if "sad" in e:
            return "Thank you for sharing this. Feeling low can be heavy."
        if "anger" in e:
            return "Your frustration is valid and worth understanding carefully."
        if "joy" in e or "calm" in e:
            return "It is good to notice moments that feel lighter or steadier."
        return "Thank you for expressing your thoughts honestly."

    def run(self, distortion_label: str, confidence: float, emotion_label: str) -> CbtOutput:
        distortion_key = self._normalize_distortion_key(distortion_label)
        mode = (
            "Direct CBT correction"
            if confidence > 0.70
            else "Reflective questioning"
            if confidence >= 0.50
            else "Emotional validation"
        )

        explanation = f"Detected pattern: {distortion_label}."
        technique = "Cognitive restructuring"
        reframe = self._DIRECT_REFRAME_MAP.get(
            distortion_key,
            "Ask: What evidence supports this thought and what evidence suggests a balanced alternative?",
        )
        exercise_title = "Guided reflection"
        exercise_desc = "Write assumption, evidence-for, evidence-against, then a balanced thought."

        if mode == "Direct CBT correction":
            exercise_title = "CBT correction"
            exercise_desc = "Apply the suggested reframe directly and write one realistic action step."
        elif mode == "Reflective questioning":
            reframe = self._GENTLE_REFRAME_MAP.get(
                distortion_key,
                "Could you explore one alternative interpretation of this thought?",
            )
            exercise_title = "Gentle reflection"
            exercise_desc = "Write one gentle question about this thought and one balanced response."
        elif mode == "Emotional validation":
            technique = "Validation-first support"
            gentle = self._GENTLE_REFRAME_MAP.get(
                distortion_key,
                "Could you explore one gentle alternative perspective when ready?",
            )
            reframe = (
                "Your feelings are valid. Take a pause and notice them first. "
                f"When you are ready, consider this gentle prompt: {gentle}"
            )
            exercise_title = "Validation pause"
            exercise_desc = "Name the feeling, breathe for 60 seconds, and write one self-compassionate sentence."

        el = emotion_label.lower()
        high_stress = any(x in el for x in ("anxiety", "fear", "stress", "angry", "anger"))
        # Optional multimodal tailoring: emotion + distortion nudge.
        if ("fear" in el or "anxiety" in el) and distortion_key == "catastrophizing":
            reframe = "Your worry is understandable. What is the most likely outcome realistically?"
        elif "sad" in el and distortion_key == "all-or-nothing thinking":
            reframe = "It is okay to feel down. Can you spot one small success today?"
        plant_meta = suggestion_meta_for_emotion(emotion_label)
        return CbtOutput(
            distortion_explanation=explanation,
            emotional_acknowledgment=self._acknowledge(emotion_label),
            intervention_mode=mode,
            cbt_technique=technique,
            reframe_guidance=reframe,
            coping_exercise_title=exercise_title,
            coping_exercise_description=exercise_desc,
            plant_suggestion=f"{plant_meta.name} - {plant_meta.description}",
            plant_image_url=plant_meta.image_url,
            plant_reference_url=plant_meta.reference_url,
            suggest_breathing=high_stress,
            breathing_technique="4-7-8 breathing: inhale 4s, hold 7s, exhale 8s. Repeat twice." if high_stress else None,
        )
