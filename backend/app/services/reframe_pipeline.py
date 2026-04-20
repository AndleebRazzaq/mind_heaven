from __future__ import annotations

import os
import re
from dataclasses import dataclass


@dataclass(frozen=True)
class ReframeInput:
    text: str
    emotion_label: str
    distortion_label: str
    distortion_confidence: float
    risk_level: str


@dataclass(frozen=True)
class ExtractionOutput:
    event_summary: str
    core_beliefs: list[str]
    claim_type: str


@dataclass(frozen=True)
class LogicBlock:
    key: str
    distortion_logic_line: str
    challenge_prompt: str
    balanced_frame: str
    action_template: str


@dataclass(frozen=True)
class TemplateDraft:
    validation_line: str
    challenge_line: str
    balanced_alternative: str
    behavioral_shift_prompt: str


@dataclass(frozen=True)
class ValidationReport:
    passed: bool
    errors: list[str]


@dataclass(frozen=True)
class ReframePipelineOutput:
    event_summary: str
    core_beliefs: list[str]
    distortion_logic_line: str
    balanced_alternative: str
    behavioral_shift_prompt: str
    reframe_text: str
    generation_mode: str
    validation_errors: list[str]
    fallback_reason: str | None
    policy_version: str


_POLICY_VERSION = "reframe_policy_v2"

_LOGIC_REGISTRY: dict[str, LogicBlock] = {
    "all-or-nothing thinking": LogicBlock(
        key="all-or-nothing thinking",
        distortion_logic_line="An experience can be difficult without being a total failure.",
        challenge_prompt="Is there a middle-ground interpretation between perfect and useless?",
        balanced_frame="This moment matters, but it does not define my full ability or value.",
        action_template="Identify one part that went acceptably and one part to improve next time.",
    ),
    "overgeneralization": LogicBlock(
        key="overgeneralization",
        distortion_logic_line="One event does not establish a permanent life pattern.",
        challenge_prompt="What evidence shows this was one instance rather than always true?",
        balanced_frame="This setback is one data point, not my future trajectory.",
        action_template="Write one concrete adjustment for the next similar situation.",
    ),
    "mind reading": LogicBlock(
        key="mind reading",
        distortion_logic_line="Assumptions about others are not the same as verified evidence.",
        challenge_prompt="What has actually been said or observed, versus inferred?",
        balanced_frame="I may feel judged, but I do not have proof of others' conclusions.",
        action_template="Check one assumption directly or gather one objective signal.",
    ),
    "catastrophizing": LogicBlock(
        key="catastrophizing",
        distortion_logic_line="Worst-case possibilities are not the same as most-likely outcomes.",
        challenge_prompt="What is the most realistic outcome, and how would I cope if needed?",
        balanced_frame="This feels serious, but disaster is not guaranteed and I can respond step by step.",
        action_template="Define one immediate action that lowers risk or improves control.",
    ),
    "labeling": LogicBlock(
        key="labeling",
        distortion_logic_line="A specific behavior should not be converted into a global identity label.",
        challenge_prompt="What happened behaviorally, without using identity-level labels?",
        balanced_frame="I had a difficult performance moment, not proof that I am useless.",
        action_template="Replace one harsh label with a specific, actionable description.",
    ),
}

_GENERIC_LOGIC = LogicBlock(
    key="generic",
    distortion_logic_line="A stressed mind can produce thoughts that feel final even when they are partial.",
    challenge_prompt="What facts support this thought, and what facts point to an alternative view?",
    balanced_frame="This is hard, but there may be a more accurate and useful way to view it.",
    action_template="Take one small practical step that aligns with the balanced view.",
)


def _split_sentences(text: str) -> list[str]:
    parts = re.split(r"[.!?]+", text)
    return [p.strip() for p in parts if p.strip()]


def _extract_event_summary(text: str) -> str:
    sentences = _split_sentences(text)
    if not sentences:
        return "A difficult moment occurred."
    first = sentences[0]
    return first[0].upper() + first[1:] if len(first) > 1 else first.upper()


def _extract_core_beliefs(text: str) -> tuple[list[str], str]:
    lower = text.lower()
    beliefs: list[str] = []
    claim_type = "general"
    patterns = [
        (r"\bi am ([^.!?]+)", "identity"),
        (r"\bi'm ([^.!?]+)", "identity"),
        (r"\bi will never ([^.!?]+)", "future"),
        (r"\bi will ([^.!?]+)", "future"),
        (r"\beveryone (?:must )?think[s]? ([^.!?]+)", "social_assumption"),
    ]
    for pattern, ctype in patterns:
        matches = re.findall(pattern, lower)
        for m in matches:
            cleaned = m.strip(" ,")
            if cleaned:
                beliefs.append(cleaned)
                claim_type = ctype
    if not beliefs:
        sentences = _split_sentences(text)
        if len(sentences) >= 2:
            beliefs.append(sentences[-1].strip())
        elif sentences:
            beliefs.append(sentences[0].strip())
    # De-duplicate while preserving order.
    seen: set[str] = set()
    uniq = []
    for b in beliefs:
        if b not in seen:
            seen.add(b)
            uniq.append(b)
    return uniq[:3], claim_type


def _resolve_logic_block(distortion_label: str) -> LogicBlock:
    key = distortion_label.strip().lower()
    aliases = {
        "magnification / catastrophizing": "catastrophizing",
        "magnification": "catastrophizing",
        "jumping to conclusions": "mind reading",
    }
    normalized = aliases.get(key, key)
    return _LOGIC_REGISTRY.get(normalized, _GENERIC_LOGIC)


def _build_validation_line(emotion_label: str, event_summary: str) -> str:
    emotion = emotion_label.strip().lower() or "upset"
    return f"It makes sense you felt {emotion} after: {event_summary}."


def _build_template_draft(
    extraction: ExtractionOutput, logic: LogicBlock, emotion_label: str
) -> TemplateDraft:
    validation_line = _build_validation_line(emotion_label, extraction.event_summary)
    belief_tail = ""
    if extraction.core_beliefs:
        belief_tail = f' The thought "{extraction.core_beliefs[0]}" may feel true right now,'
    challenge_line = (
        f"{logic.distortion_logic_line}{belief_tail} but it is worth testing against evidence. "
        f"{logic.challenge_prompt}"
    )
    return TemplateDraft(
        validation_line=validation_line,
        challenge_line=challenge_line,
        balanced_alternative=logic.balanced_frame,
        behavioral_shift_prompt=logic.action_template,
    )


def _compose_reframe_text(draft: TemplateDraft) -> str:
    return (
        f"{draft.validation_line} {draft.challenge_line} "
        f"Balanced thought: {draft.balanced_alternative} "
        f"Next step: {draft.behavioral_shift_prompt}"
    ).strip()


def _refine_with_llm_hook(text: str) -> tuple[str, bool]:
    """Placeholder LLM refinement hook.

    Keeps implementation deterministic unless REFRAME_LLM_ENABLED=1.
    """
    enabled = os.environ.get("REFRAME_LLM_ENABLED", "").lower() in ("1", "true", "yes", "on")
    if not enabled:
        return text, False
    # Constrained lightweight rewrite: wording polish only.
    refined = re.sub(r"\s+", " ", text).strip()
    refined = refined.replace("it is worth testing against evidence", "it helps to test this with evidence")
    return refined, True


def _validate_reframe(
    text: str, extraction: ExtractionOutput, risk_level: str
) -> ValidationReport:
    errors: list[str] = []
    word_count = len(text.split())
    if word_count > 120:
        errors.append("too_long")
    if extraction.event_summary and extraction.event_summary.split()[0].lower() not in text.lower():
        errors.append("missing_event_reference")
    lower = text.lower()
    if "balanced thought:" not in lower:
        errors.append("missing_balanced_thought_marker")
    if "next step:" not in lower:
        errors.append("missing_action_prompt")
    if any(token in lower for token in ("always hopeless", "never improve", "completely useless")):
        errors.append("contains_absolute_harmful_language")
    if risk_level in ("moderate", "high"):
        # Safety flow takes priority; refrain from producing a strict reframe.
        errors.append("safety_override_expected")
    return ValidationReport(passed=len(errors) == 0, errors=errors)


def build_reframe_pipeline(payload: ReframeInput) -> ReframePipelineOutput:
    event_summary = _extract_event_summary(payload.text)
    core_beliefs, claim_type = _extract_core_beliefs(payload.text)
    extraction = ExtractionOutput(
        event_summary=event_summary,
        core_beliefs=core_beliefs,
        claim_type=claim_type,
    )
    logic = _resolve_logic_block(payload.distortion_label)
    draft = _build_template_draft(extraction, logic, payload.emotion_label)
    candidate = _compose_reframe_text(draft)
    refined, used_refine = _refine_with_llm_hook(candidate)
    report = _validate_reframe(refined, extraction, payload.risk_level)

    generation_mode = "template_plus_llm" if used_refine else "template_only"
    fallback_reason: str | None = None
    final_text = refined
    if not report.passed:
        # Deterministic fallback: canonical draft.
        final_text = candidate
        fallback_reason = ",".join(report.errors)
        generation_mode = "fallback_template"

    return ReframePipelineOutput(
        event_summary=event_summary,
        core_beliefs=core_beliefs,
        distortion_logic_line=logic.distortion_logic_line,
        balanced_alternative=draft.balanced_alternative,
        behavioral_shift_prompt=draft.behavioral_shift_prompt,
        reframe_text=final_text,
        generation_mode=generation_mode,
        validation_errors=report.errors if not report.passed else [],
        fallback_reason=fallback_reason,
        policy_version=_POLICY_VERSION,
    )
