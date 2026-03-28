from dataclasses import dataclass


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
    suggest_breathing: bool
    breathing_technique: str | None


class CbtEngine:
    def _plant_by_emotion(self, emotion: str) -> str:
        e = emotion.lower()
        if "anxiety" in e:
            return "Lavender - associated with calming sensory environments."
        if "sad" in e:
            return "Peace Lily - often linked with soothing indoor ambience."
        if "anger" in e:
            return "Snake Plant - grounding presence and easy maintenance."
        if "fatigue" in e or "tired" in e:
            return "Rosemary - associated with alertness support."
        return "Pothos - low-maintenance greenery that supports a calm space."

    def _acknowledge(self, emotion: str) -> str:
        e = emotion.lower()
        if "anxiety" in e:
            return "It makes sense that this feels overwhelming right now."
        if "sad" in e:
            return "Thank you for sharing this. Feeling low can be heavy."
        if "anger" in e:
            return "Your frustration is valid and worth understanding carefully."
        return "Thank you for expressing your thoughts honestly."

    def run(self, distortion_label: str, confidence: float, emotion_label: str) -> CbtOutput:
        mode = (
            "Direct CBT correction"
            if confidence > 0.70
            else "Reflective questioning"
            if confidence >= 0.50
            else "Emotional validation"
        )

        explanation = f"Detected pattern: {distortion_label}."
        technique = "Cognitive restructuring"
        reframe = "Ask: What evidence supports this thought and what evidence suggests a balanced alternative?"
        exercise_title = "Guided reflection"
        exercise_desc = "Write assumption, evidence-for, evidence-against, then a balanced thought."

        if mode == "Direct CBT correction":
            exercise_title = "CBT correction"
            exercise_desc = "Apply the suggested reframe directly and write one realistic action step."
        elif mode == "Emotional validation":
            technique = "Validation-first support"
            reframe = "Your feelings are valid. Pause first before challenging thoughts."
            exercise_title = "Validation pause"
            exercise_desc = "Name the feeling, breathe for 60 seconds, and write one self-compassionate sentence."

        high_stress = "anxiety" in emotion_label.lower()
        return CbtOutput(
            distortion_explanation=explanation,
            emotional_acknowledgment=self._acknowledge(emotion_label),
            intervention_mode=mode,
            cbt_technique=technique,
            reframe_guidance=reframe,
            coping_exercise_title=exercise_title,
            coping_exercise_description=exercise_desc,
            plant_suggestion=self._plant_by_emotion(emotion_label),
            suggest_breathing=high_stress,
            breathing_technique="4-7-8 breathing: inhale 4s, hold 7s, exhale 8s. Repeat twice." if high_stress else None,
        )
