"""Emotion -> indoor plant suggestions with short, non-clinical descriptions.

Sources are general horticulture references; suggestions are wellness-supportive only.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class PlantSuggestion:
    name: str
    description: str
    image_url: str
    reference_url: str


DEFAULT_PLANT = PlantSuggestion(
    name="Pothos",
    description="Low-maintenance indoor vine that adapts to typical room light.",
    image_url="https://upload.wikimedia.org/wikipedia/commons/4/4a/Epipremnum_aureum_31082012.jpg",
    reference_url="https://en.wikipedia.org/wiki/Epipremnum_aureum",
)

EMOTION_TO_PLANT: dict[str, PlantSuggestion] = {
    "anger": PlantSuggestion(
        name="Snake Plant",
        description="Resilient indoor plant with upright form; easy-care and drought tolerant.",
        image_url="https://upload.wikimedia.org/wikipedia/commons/0/01/Sansevieria_trifasciata.jpg",
        reference_url="https://en.wikipedia.org/wiki/Dracaena_trifasciata",
    ),
    "disgust": PlantSuggestion(
        name="ZZ Plant",
        description="Glossy foliage, robust in low-to-medium light, and forgiving watering needs.",
        image_url="https://upload.wikimedia.org/wikipedia/commons/f/f1/Zamioculcas_zamiifolia.jpg",
        reference_url="https://en.wikipedia.org/wiki/Zamioculcas",
    ),
    "fear": PlantSuggestion(
        name="Lavender",
        description="Aromatic plant often used in calm-focused spaces; prefers bright light.",
        image_url="https://upload.wikimedia.org/wikipedia/commons/7/7e/Lavandula_angustifolia_002.JPG",
        reference_url="https://en.wikipedia.org/wiki/Lavandula",
    ),
    "joy": PlantSuggestion(
        name="Aloe Vera",
        description="Bright-space succulent with simple care and strong indoor popularity.",
        image_url="https://upload.wikimedia.org/wikipedia/commons/c/c2/Aloe_vera_flower_inset.png",
        reference_url="https://en.wikipedia.org/wiki/Aloe_vera",
    ),
    "neutral": DEFAULT_PLANT,
    "sadness": PlantSuggestion(
        name="Peace Lily",
        description="Shade-tolerant flowering houseplant with soft foliage and white blooms.",
        image_url="https://upload.wikimedia.org/wikipedia/commons/4/4c/Spathiphyllum_cochlearispathum_RTBG.jpg",
        reference_url="https://en.wikipedia.org/wiki/Spathiphyllum",
    ),
    "surprise": PlantSuggestion(
        name="Pothos",
        description="Fast-growing vine that is beginner-friendly and adaptable indoors.",
        image_url="https://upload.wikimedia.org/wikipedia/commons/4/4a/Epipremnum_aureum_31082012.jpg",
        reference_url="https://en.wikipedia.org/wiki/Epipremnum_aureum",
    ),
}


def suggestion_for_emotion(mood_label: str | None) -> str:
    m = (mood_label or "").strip().lower()
    plant = EMOTION_TO_PLANT.get(m, DEFAULT_PLANT)
    return f"{plant.name} - {plant.description}"


def suggestion_meta_for_emotion(mood_label: str | None) -> PlantSuggestion:
    m = (mood_label or "").strip().lower()
    return EMOTION_TO_PLANT.get(m, DEFAULT_PLANT)
