from dataclasses import dataclass


@dataclass
class EmotionResult:
    label: str
    confidence: float


class EmotionService:
    """
    Replace this with:
    - a HuggingFace GoEmotions model
    - OR your own deployed classifier
    """

    def classify(self, text: str) -> EmotionResult:
        lower = text.lower()
        if any(k in lower for k in ["anxious", "worry", "stress"]):
            return EmotionResult("Anxiety", 0.74)
        if any(k in lower for k in ["sad", "down", "hopeless"]):
            return EmotionResult("Sadness", 0.72)
        if any(k in lower for k in ["angry", "frustrated"]):
            return EmotionResult("Anger", 0.70)
        if any(k in lower for k in ["calm", "peaceful"]):
            return EmotionResult("Calm", 0.78)
        return EmotionResult("Reflective", 0.60)
