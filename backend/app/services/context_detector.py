"""
Context Detection
Analyzes journal text to detect context (social, performance, health, general)
"""

import re
from typing import Literal


class ContextDetector:
    """Detects contextual themes in journal text."""

    SOCIAL_KEYWORDS = {
        "friend",
        "people",
        "social",
        "talk",
        "conversation",
        "dating",
        "relationship",
        "partner",
        "family",
        "brother",
        "sister",
        "parent",
        "mom",
        "dad",
        "group",
        "crowd",
        "party",
        "meeting",
        "colleague",
        "coworker",
        "boss",
        "judgment",
        "judge",
        "criticized",
        "embarrass",
        "alone",
        "lonely",
        "isolation",
        "rejected",
        "excluded",
        "left out",
    }

    PERFORMANCE_KEYWORDS = {
        "exam",
        "test",
        "work",
        "job",
        "presentation",
        "task",
        "deadline",
        "project",
        "deadline",
        "performance",
        "grade",
        "score",
        "fail",
        "success",
        "competition",
        "compete",
        "win",
        "lose",
        "achieve",
        "goal",
        "pressure",
        "expectation",
        "standard",
        "perfect",
        "accomplish",
        "mistake",
        "error",
        "achievement",
    }

    HEALTH_KEYWORDS = {
        "sick",
        "illness",
        "disease",
        "health",
        "doctor",
        "hospital",
        "pain",
        "hurt",
        "injury",
        "symptom",
        "medical",
        "diagnosis",
        "treatment",
        "medicine",
        "drug",
        "therapy",
        "physical",
        "body",
        "mental health",
        "anxious",
        "panic",
        "heart",
        "breath",
        "chest",
        "head",
        "dizzy",
    }

    @staticmethod
    def detect_context(
        text: str,
    ) -> Literal["social", "performance", "health", "general"]:
        """
        Detect the primary context from journal text.

        Returns:
            social | performance | health | general
        """
        text_lower = text.lower()

        # Count keyword matches
        social_count = sum(1 for kw in ContextDetector.SOCIAL_KEYWORDS if kw in text_lower)
        performance_count = sum(
            1 for kw in ContextDetector.PERFORMANCE_KEYWORDS if kw in text_lower
        )
        health_count = sum(1 for kw in ContextDetector.HEALTH_KEYWORDS if kw in text_lower)

        # Return context with highest count
        counts = {
            "social": social_count,
            "performance": performance_count,
            "health": health_count,
        }

        max_count = max(counts.values())
        if max_count == 0:
            return "general"

        # Return the context with highest count
        for context, count in counts.items():
            if count == max_count:
                return context  # type: ignore

        return "general"
