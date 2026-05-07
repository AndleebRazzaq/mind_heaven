"""
Emotional State Mapper
Translates raw ML emotion labels + intensity + context into human-readable emotional states.
This is the INTELLIGENCE LAYER that makes the app feel premium vs. raw mood detection.
"""

from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class EmotionalStateOutput:
    """Upgraded emotional state output with context awareness."""
    raw_emotion: str  # Original ML label (e.g., "confusion")
    emotional_state: str  # Human-readable state (e.g., "Decision Anxiety")
    subtitle: str  # Context-aware insight subtitle
    intensity: int  # 0-100
    intensity_label: str  # Low, Moderate, High, Very High
    emotion_group: str  # anxiety, stress, low_mood, positive, neutral
    context: str  # social, performance, health, general
    show_breathing: bool  # True if intensity >= 70


class EmotionalStateMapper:
    """Maps raw emotions → context-aware human states."""

    # ============================================
    # EMOTIONAL STATE MAPPING
    # ============================================
    # Format: (emotion_group, context) → (emotional_state, subtitle)

    EMOTIONAL_STATE_MAP = {
        # ANXIETY STATES
        ("anxiety", "social"): (
            "Social Anxiety",
            "You seem worried about others' judgments or how you're being perceived.",
        ),
        ("anxiety", "performance"): (
            "Performance Stress",
            "You seem concerned about meeting expectations or doing well.",
        ),
        ("anxiety", "health"): (
            "Health Anxiety",
            "You seem worried about your physical well-being or health.",
        ),
        ("anxiety", "general"): (
            "Decision Anxiety",
            "You seem mentally overwhelmed while trying to make the right choice.",
        ),
        # STRESS STATES
        ("stress", "performance"): (
            "Work Pressure",
            "You seem under pressure to perform and meet demands.",
        ),
        ("stress", "social"): (
            "Social Stress",
            "You seem stressed by social situations or relationships.",
        ),
        ("stress", "health"): (
            "Health-Related Stress",
            "You seem stressed about health or physical concerns.",
        ),
        ("stress", "general"): (
            "Emotional Overwhelm",
            "You seem overwhelmed by multiple things at once.",
        ),
        # LOW MOOD STATES
        ("low_mood", "social"): (
            "Social Disappointment",
            "You seem let down by relationships or social situations.",
        ),
        ("low_mood", "performance"): (
            "Performance Disappointment",
            "You seem discouraged about how things turned out.",
        ),
        ("low_mood", "health"): (
            "Emotional Exhaustion",
            "You seem drained and worn down by health concerns.",
        ),
        ("low_mood", "general"): (
            "Emotional Exhaustion",
            "You seem depleted and struggling right now.",
        ),
        # POSITIVE STATES
        ("positive", "general"): (
            "Positive Energy",
            "You seem to be experiencing positive emotions right now.",
        ),
        # NEUTRAL STATES
        ("neutral", "general"): (
            "Neutral Mindset",
            "You seem grounded and balanced in your thinking.",
        ),
    }

    # ============================================
    # INTENSITY LABELS
    # ============================================
    INTENSITY_BANDS = {
        (0, 30): "Low",
        (31, 60): "Moderate",
        (61, 85): "High",
        (86, 100): "Very High",
    }

    # ============================================
    # PLANT SUGGESTIONS BY EMOTION GROUP
    # ============================================
    PLANT_SUGGESTIONS = {
        "anxiety": {
            "name": "Lucky Bamboo",
            "description": "may help create a calmer and clearer space",
        },
        "stress": {
            "name": "Jasmine",
            "description": "can soothe your immediate environment",
        },
        "low_mood": {
            "name": "Aloe Vera",
            "description": "offers a gentle, healing presence",
        },
        "positive": {
            "name": "Sunflower",
            "description": "helps maintain your bright energy",
        },
        "neutral": {
            "name": "Spider Plant",
            "description": "encourages steady, quiet growth",
        },
    }

    @staticmethod
    def get_intensity_label(intensity: int) -> str:
        """Map intensity (0-100) to human-readable label."""
        for (low, high), label in EmotionalStateMapper.INTENSITY_BANDS.items():
            if low <= intensity <= high:
                return label
        return "Unknown"

    @staticmethod
    def get_plant_suggestion(emotion_group: str) -> dict:
        """Get plant suggestion for emotion group."""
        return EmotionalStateMapper.PLANT_SUGGESTIONS.get(
            emotion_group,
            {
                "name": "Peace Lily",
                "description": "brings quiet comfort and support",
            },
        )

    @staticmethod
    def map_to_emotional_state(
        raw_emotion: str,
        intensity: int,
        emotion_group: str,
        context: str,
    ) -> EmotionalStateOutput:
        """
        Main mapping function: convert raw emotion to human-readable emotional state.

        Args:
            raw_emotion: Original ML label (e.g., "confusion", "sadness")
            intensity: Confidence score 0-100
            emotion_group: Group classification (anxiety, stress, low_mood, positive, neutral)
            context: Context detection (social, performance, health, general)

        Returns:
            EmotionalStateOutput with human-readable state + subtitle
        """
        # Look up in mapping
        key = (emotion_group, context)
        if key in EmotionalStateMapper.EMOTIONAL_STATE_MAP:
            emotional_state, subtitle = EmotionalStateMapper.EMOTIONAL_STATE_MAP[key]
        else:
            # Fallback: use capitalized raw emotion
            emotional_state = raw_emotion.capitalize()
            subtitle = f"You seem to be experiencing {emotional_state.lower()} right now."

        intensity_label = EmotionalStateMapper.get_intensity_label(intensity)
        show_breathing = intensity >= 70

        return EmotionalStateOutput(
            raw_emotion=raw_emotion,
            emotional_state=emotional_state,
            subtitle=subtitle,
            intensity=intensity,
            intensity_label=intensity_label,
            emotion_group=emotion_group,
            context=context,
            show_breathing=show_breathing,
        )
