"""Environment-driven settings for model paths and Hugging Face IDs."""

from __future__ import annotations

import os
from dataclasses import dataclass


def _truthy(name: str, default: str = "") -> bool:
    return os.environ.get(name, default).lower() in ("1", "true", "yes", "on")


@dataclass(frozen=True)
class Settings:
    """Distortion: local fine-tuned folder (Transformers layout) + JSON id→label map.
    Emotion: pretrained Hugging Face model id (downloaded on first use unless mock).
    """

    distortion_model_dir: str | None
    distortion_label_map_path: str | None
    distortion_use_mock: bool
    emotion_hf_model: str
    emotion_use_mock: bool


def load_settings() -> Settings:
    return Settings(
        distortion_model_dir=os.environ.get("DISTORTION_MODEL_DIR") or "cbt_distortion_model",
        distortion_label_map_path=os.environ.get("DISTORTION_LABEL_MAP_PATH") or None,
        distortion_use_mock=_truthy("DISTORTION_USE_MOCK"),
        emotion_hf_model=os.environ.get(
            "EMOTION_HF_MODEL",
            "j-hartmann/emotion-english-distilroberta-base",
        ),
        emotion_use_mock=_truthy("EMOTION_USE_MOCK"),
    )
