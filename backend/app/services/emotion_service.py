from __future__ import annotations

import logging
import re
from dataclasses import dataclass

from ..config import load_settings

logger = logging.getLogger(__name__)


@dataclass
class EmotionResult:
    label: str
    confidence: float


def _normalize_hf_label(raw: str) -> str:
    """Map Hugging Face labels to your 7-class emotion set."""
    r = raw.strip().lower()
    r = re.sub(r"^label_?\d+$", "neutral", r)
    if not r:
        return "neutral"

    if r in ("anger", "angry", "rage"):
        return "anger"
    if r in ("disgust",):
        return "disgust"
    if r in ("fear", "anxiety", "nervousness"):
        return "fear"
    if r in ("joy", "happiness", "happy", "love", "admiration", "optimism"):
        return "joy"
    if r in ("sadness", "sad", "grief"):
        return "sadness"
    if r in ("surprise",):
        return "surprise"
    return "neutral"


class EmotionService:
    """Pretrained Hugging Face text-classification model (default: English emotion DistilRoBERTa)."""

    def __init__(self) -> None:
        self._settings = load_settings()
        self._pipe = None
        self._load_attempted = False
        self._load_error: str | None = None

    def _ensure_pipeline(self) -> None:
        if self._load_attempted:
            return
        self._load_attempted = True
        if self._settings.emotion_use_mock:
            logger.info("EmotionService: EMOTION_USE_MOCK set — using heuristics.")
            return
        try:
            from transformers import pipeline

            self._pipe = pipeline(
                "text-classification",
                model=self._settings.emotion_hf_model,
                top_k=1,
                truncation=True,
                max_length=512,
                device=-1,
            )
            logger.info("EmotionService: loaded %s", self._settings.emotion_hf_model)
        except Exception as e:
            self._load_error = str(e)
            self._pipe = None
            logger.exception("EmotionService: failed to load pipeline: %s", e)

    def _hf_classify(self, text: str) -> EmotionResult:
        assert self._pipe is not None
        batch = self._pipe(text[:4000])
        top = batch[0] if batch else {"label": "neutral", "score": 0.0}
        raw = str(top.get("label", "neutral"))
        score = float(top.get("score", 0.0))
        return EmotionResult(label=_normalize_hf_label(raw), confidence=score)

    def _heuristic(self, text: str) -> EmotionResult:
        lower = text.lower()
        if any(k in lower for k in ["anxious", "worry", "stress", "scared", "nervous"]):
            return EmotionResult("fear", 0.74)
        if any(k in lower for k in ["sad", "down", "hopeless"]):
            return EmotionResult("sadness", 0.72)
        if any(k in lower for k in ["angry", "frustrated", "furious"]):
            return EmotionResult("anger", 0.70)
        if any(k in lower for k in ["happy", "grateful", "excited"]):
            return EmotionResult("joy", 0.78)
        if any(k in lower for k in ["surprised", "shocked"]):
            return EmotionResult("surprise", 0.66)
        if any(k in lower for k in ["gross", "disgusted"]):
            return EmotionResult("disgust", 0.66)
        return EmotionResult("neutral", 0.60)

    def classify(self, text: str) -> EmotionResult:
        if not text.strip():
            return EmotionResult("neutral", 0.0)

        self._ensure_pipeline()
        if self._pipe is not None:
            try:
                return self._hf_classify(text.strip())
            except Exception as e:
                logger.exception("EmotionService: inference error, falling back: %s", e)
        return self._heuristic(text)
