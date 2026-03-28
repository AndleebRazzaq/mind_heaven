from dataclasses import dataclass


@dataclass
class DistortionResult:
    label: str
    confidence: float


class DistortionService:
    """
    Replace this with your fine-tuned DistilBERT/BERT model.
    """

    def classify(self, text: str) -> DistortionResult:
        lower = text.lower()
        if any(k in lower for k in ["disaster", "catastroph", "terrible"]):
            return DistortionResult("Catastrophizing / Magnification", 0.82)
        if any(k in lower for k in ["always", "never", "everyone"]):
            return DistortionResult("Overgeneralization", 0.79)
        if any(k in lower for k in ["they think", "mind reading"]):
            return DistortionResult("Mind Reading / Jumping to Conclusions", 0.71)
        if any(k in lower for k in ["my fault", "because of me"]):
            return DistortionResult("Personalization", 0.74)
        return DistortionResult("Uncertain pattern", 0.45)
