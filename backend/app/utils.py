import os
import json
import torch
import torch.nn.functional as F
from transformers import AutoTokenizer, AutoModelForSequenceClassification

DEVICE = torch.device("cpu")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# ==============================
# PATHS
# ==============================

emotion_path = os.path.join(BASE_DIR, "models", "emotion_goemotions_model")
cbt_path = os.path.join(BASE_DIR, "models", "cbt_distortion_model_impr")

# ==============================
# LOAD MODELS
# ==============================

emotion_tokenizer = AutoTokenizer.from_pretrained(emotion_path)
emotion_model = AutoModelForSequenceClassification.from_pretrained(emotion_path)
emotion_model.to(DEVICE)
emotion_model.eval()

cbt_tokenizer = AutoTokenizer.from_pretrained(cbt_path)
cbt_model = AutoModelForSequenceClassification.from_pretrained(cbt_path)
cbt_model.to(DEVICE)
cbt_model.eval()

# =========================================================
# 🔥 FIX 1 — EMOTION LABEL NAMES
# =========================================================

label_names = [
    "admiration","amusement","anger","annoyance","approval","caring",
    "confusion","curiosity","desire","disappointment","disapproval",
    "disgust","embarrassment","excitement","fear","gratitude","grief",
    "joy","love","nervousness","optimism","pride","realization",
    "relief","remorse","sadness","surprise","neutral"
]

id2label = {i: label for i, label in enumerate(label_names)}
label2id = {label: i for i, label in enumerate(label_names)}

emotion_model.config.id2label = id2label
emotion_model.config.label2id = label2id

# =========================================================
# 🔥 FIX 2 — LOAD CBT LABEL MAP (SAFE)
# =========================================================

distortion_label_path = os.path.join(cbt_path, "distortion_label_map.json")
if not os.path.exists(distortion_label_path):
    distortion_label_path = os.path.join(cbt_path, "distortion_lable_map.json")

with open(distortion_label_path) as f:
    distortion_map = json.load(f)

# ✅ Handle wrapped JSON structure
if isinstance(distortion_map, dict) and "label_map" in distortion_map:
    distortion_map = distortion_map["label_map"]

# ✅ Safe conversion
id2label_cbt = {}
for k, v in distortion_map.items():
    try:
        id2label_cbt[int(k)] = v
    except ValueError:
        print(f"[WARNING] Skipping invalid key in label map: {k}")

cbt_model.config.id2label = id2label_cbt

# ==============================
# EMOTION PREDICTION
# ==============================

def predict_emotion(text: str):
    inputs = emotion_tokenizer(
        text,
        return_tensors="pt",
        truncation=True,
        padding=True
    ).to(DEVICE)

    with torch.no_grad():
        logits = emotion_model(**inputs).logits

    probs = F.softmax(logits, dim=1)
    confidence, idx = torch.max(probs, dim=1)

    label = emotion_model.config.id2label.get(idx.item(), "unknown")

    return {
        "label": label,
        "confidence": round(confidence.item(), 4)
    }

# ==============================
# CBT DISTORTION PREDICTION
# ==============================

def predict_distortion(text: str):
    inputs = cbt_tokenizer(
        text,
        return_tensors="pt",
        truncation=True,
        padding=True
    ).to(DEVICE)

    with torch.no_grad():
        logits = cbt_model(**inputs).logits

    probs = F.softmax(logits, dim=1)
    confidence, idx = torch.max(probs, dim=1)

    label = cbt_model.config.id2label.get(idx.item(), "unknown")

    return {
        "label": label,
        "confidence": round(confidence.item(), 4)
    }

# ==============================
# INTENSITY MAPPING (0-100)
# ==============================

def map_intensity(confidence: float):
    """Scale confidence (0–1) → intensity (0–100)"""
    return int(confidence * 100)

# ==============================
# LLM LAYER (Ollama / Local Llama 3)
# ==============================

import requests
from dotenv import load_dotenv

load_dotenv()

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3")

SYSTEM_PROMPT = """
You are a calm, supportive CBT-based journaling assistant.

Your role is to help users understand their thoughts and gently guide them toward more balanced thinking.

Rules:
- Be non-judgmental and empathetic
- Do NOT diagnose or label the user
- Do NOT use harsh or absolute language
- Keep responses short, clear, and supportive
- Use simple, human language, not clinical or academic
- Focus on reflection, not advice-giving
- Normalize emotions without reinforcing negative beliefs
- Do NOT ask questions
- Output STRICT JSON only

Your goal is:
Help the user feel understood, identify the thinking pattern, gently reframe, and suggest a small helpful action.
"""

# ==============================
# PROMPT BUILDER
# ==============================

def build_prompt(text, emotion, intensity, distortion):
    """Build a CBT-style prompt with stress-level guidance."""

    if intensity >= 70:
        stress_instruction = """
Additional Instruction:
The user appears to be experiencing high emotional intensity.

- Keep the response extra calming
- Prioritize grounding and safety
- Suggest a simple breathing or grounding exercise
- Keep language very gentle and slow-paced
"""
    else:
        stress_instruction = """
Additional Instruction:
The user is not in high distress.

- Focus more on reflection and awareness
- Encourage balanced thinking
- Suggest a journaling or perspective-shift action
"""

    return f"""
User Journal Entry:
"{text}"

Detected Emotion: {emotion} ({intensity}% intensity)
Detected Thinking Pattern: {distortion}

Instructions:
Analyze the journal and return a CBT-style response in JSON format.

Guidelines:
1. Start by gently reflecting the user's emotion
2. Briefly explain the thinking pattern in simple terms
3. Offer a balanced reframe, not overly positive, just realistic
4. Suggest ONE small actionable step
5. Suggest a calming plant based on the user's emotional state in one short sentence

Important:
- Keep tone calm and supportive
- Avoid absolute words like "always" and "never"
- Do not invalidate the user's feelings
- Keep each response concise, 1-2 sentences max per field

Safety:
If the user expresses extreme distress, hopelessness, or self-harm thoughts:
- Do NOT provide analysis
- Respond with supportive language
- Encourage seeking help from a trusted person or professional

{stress_instruction}

Return ONLY JSON:

{{
  "insight": "",
  "pattern": "",
  "reframe": "",
  "action": "",
  "plant": ""
}}
"""

# ==============================
# LLM CALL
# ==============================

def generate_ai_response(prompt):
    """Call local Ollama model and parse JSON response"""
    
    try:
        full_prompt = f"{SYSTEM_PROMPT}\n\n{prompt}"
        response = requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "prompt": full_prompt,
                "stream": False,
                "format": "json",
                "options": {
                    "temperature": 0.6,
                    "num_predict": 500
                }
            },
            timeout=120
        )
        response.raise_for_status()

        content = response.json()["response"].strip()
        return json.loads(content)
    
    except Exception as e:
        print(f"[LLM ERROR] {str(e)}")
        return {
            "insight": "It seems like you're going through something difficult.",
            "pattern": "Your thoughts may feel overwhelming.",
            "reframe": "This situation may be more manageable than it feels.",
            "action": "Taking a short break or stepping outside might help.",
            "plant": "A peace lily can help create a calming environment."
        }
