from __future__ import annotations

import json
import logging
from dataclasses import dataclass
from pathlib import Path

from ..config import load_settings

logger = logging.getLogger(__name__)

DISTORTION_DESC_MAP: dict[str, str] = {
    "All-or-Nothing Thinking": "Seeing things in black-and-white categories, ignoring the middle ground.",
    "Overgeneralization": "Taking one event and assuming it applies to everything.",
    "Mental Filter": "Focusing only on the negative aspects, ignoring positives.",
    "Disqualifying the Positive": "Rejecting positive experiences by insisting they do not count.",
    "Jumping to Conclusions": "Making assumptions without evidence.",
    "Mind Reading": "Assuming you know what others think without confirmation.",
    "Catastrophizing": "Expecting the worst possible outcome.",
    "Emotional Reasoning": "Believing feelings reflect facts.",
    "Should Statements": "Having rigid rules about how you or others should behave.",
    "Labeling": "Attaching a negative label to yourself or others.",
    "Personalization": "Blaming yourself for events outside your control.",
    "Uncertain pattern": "No strong distortion pattern was confidently identified.",
}


@dataclass
class DistortionResult:
    """Classifier output: human-readable label, softmax confidence, and numeric class id."""

    label: str
    confidence: float
    label_id: int | None = None


def certainty_feedback(confidence: float) -> tuple[str, str]:
    """Map classifier confidence to certainty band and intervention style."""
    if confidence >= 0.70:
        return ("Certain", "Direct CBT Correction")
    if confidence >= 0.50:
        return ("Likely", "Reflective Questioning")
    return ("Unclear", "Emotional Validation / General Coping")


def _load_id_to_label(map_path: Path, model_labels: dict | None) -> dict[int, str]:
    if map_path.is_file():
        with open(map_path, encoding="utf-8") as f:
            data = json.load(f)
        raw = data.get("label_map", data)
        out: dict[int, str] = {}
        for k, v in raw.items():
            if str(k).startswith("_"):
                continue
            try:
                out[int(k)] = str(v)
            except (TypeError, ValueError):
                continue
        if out:
            return out
    if model_labels:
        return {int(k): str(v) for k, v in model_labels.items()}
    return {}


class DistortionService:
    """Loads a fine-tuned Transformers sequence classifier from a folder; maps argmax id → label."""

    def __init__(self) -> None:
        self._settings = load_settings()
        self._tokenizer = None
        self._model = None
        self._id_to_label: dict[int, str] = {}
        self._load_attempted = False
        self._load_error: str | None = None

    def _resolve_map_path(self, model_dir: Path) -> Path:
        env = self._settings.distortion_label_map_path
        if env:
            return Path(env)
        return model_dir / "distortion_label_map.json"

    def _ensure_model(self) -> None:
        if self._load_attempted:
            return
        self._load_attempted = True
        if self._settings.distortion_use_mock:
            logger.info("DistortionService: DISTORTION_USE_MOCK set — using heuristics.")
            return
        raw_dir = self._settings.distortion_model_dir
        if not raw_dir:
            logger.info("DistortionService: DISTORTION_MODEL_DIR unset — using heuristics.")
            return
        model_dir = Path(raw_dir)
        if not model_dir.is_dir() or not (model_dir / "config.json").is_file():
            self._load_error = f"Not a Transformers model folder: {model_dir}"
            logger.warning("DistortionService: %s", self._load_error)
            return
        try:
            import torch
            from transformers import AutoModelForSequenceClassification, AutoTokenizer

            self._tokenizer = AutoTokenizer.from_pretrained(str(model_dir))
            self._model = AutoModelForSequenceClassification.from_pretrained(str(model_dir))
            self._model.eval()

            cfg_labels = getattr(self._model.config, "id2label", None) or {}
            map_path = self._resolve_map_path(model_dir)
            self._id_to_label = _load_id_to_label(map_path, cfg_labels if cfg_labels else None)
            if not self._id_to_label and cfg_labels:
                self._id_to_label = {int(k): str(v) for k, v in cfg_labels.items()}
            logger.info(
                "DistortionService: loaded model from %s (%d labels).",
                model_dir,
                len(self._id_to_label),
            )
        except Exception as e:
            self._load_error = str(e)
            self._tokenizer = None
            self._model = None
            self._id_to_label = {}
            logger.exception("DistortionService: failed to load model: %s", e)

    def _infer(self, text: str) -> DistortionResult:
        import torch

        assert self._tokenizer is not None and self._model is not None
        inputs = self._tokenizer(
            text,
            return_tensors="pt",
            truncation=True,
            max_length=512,
            padding=True,
        )
        with torch.no_grad():
            logits = self._model(**inputs).logits
        probs = torch.softmax(logits, dim=-1)[0]
        conf, pred = torch.max(probs, dim=-1)
        idx = int(pred.item())
        conf_f = float(conf.item())
        label = self._id_to_label.get(idx)
        if label is None:
            label = f"Class_{idx}"
        return DistortionResult(label=label, confidence=conf_f, label_id=idx)

    def _heuristic(self, text: str) -> DistortionResult:
        lower = text.lower()
        if any(k in lower for k in ["disaster", "catastroph", "terrible"]):
            return DistortionResult("Magnification / Catastrophizing", 0.82, label_id=None)
        if any(k in lower for k in ["always", "never", "everyone"]):
            return DistortionResult("Overgeneralization", 0.79, label_id=None)
        if any(k in lower for k in ["they think", "mind reading"]):
            return DistortionResult("Jumping to Conclusions", 0.71, label_id=None)
        if any(k in lower for k in ["my fault", "because of me"]):
            return DistortionResult("Personalization", 0.74, label_id=None)
        return DistortionResult("Uncertain pattern", 0.45, label_id=None)

    def classify(self, text: str) -> DistortionResult:
        stripped = text.strip()
        if not stripped:
            return DistortionResult("Uncertain pattern", 0.0, label_id=None)

        self._ensure_model()
        if self._model is not None and self._tokenizer is not None:
            try:
                return self._infer(stripped)
            except Exception as e:
                logger.exception("DistortionService: inference error, falling back: %s", e)
        return self._heuristic(stripped)
