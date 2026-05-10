import os
import json
import torch
import torch.nn.functional as F
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import requests
from dotenv import load_dotenv

load_dotenv()

DEVICE = torch.device("cpu")
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Paths
emotion_path = os.path.join(BASE_DIR, "models", "emotion_goemotions_model")
cbt_path = os.path.join(BASE_DIR, "models", "cbt_distortion_model_impr")

# Models
emotion_tokenizer = AutoTokenizer.from_pretrained(emotion_path)
emotion_model = AutoModelForSequenceClassification.from_pretrained(emotion_path)
emotion_model.to(DEVICE)
emotion_model.eval()

cbt_tokenizer = AutoTokenizer.from_pretrained(cbt_path)
cbt_model = AutoModelForSequenceClassification.from_pretrained(cbt_path)
cbt_model.to(DEVICE)
cbt_model.eval()

# Emotion Labels
label_names = [
    "admiration","amusement","anger","annoyance","approval","caring",
    "confusion","curiosity","desire","disappointment","disapproval",
    "disgust","embarrassment","excitement","fear","gratitude","grief",
    "joy","love","nervousness","optimism","pride","realization",
    "relief","remorse","sadness","surprise","neutral"
]
emotion_model.config.id2label = {i: label for i, label in enumerate(label_names)}

# CBT Labels
distortion_label_path = os.path.join(cbt_path, "distortion_label_map.json")
if not os.path.exists(distortion_label_path):
    distortion_label_path = os.path.join(cbt_path, "distortion_lable_map.json")

with open(distortion_label_path) as f:
    distortion_map = json.load(f)
if "label_map" in distortion_map:
    distortion_map = distortion_map["label_map"]
cbt_model.config.id2label = {int(k): v for k, v in distortion_map.items()}

# Ollama Settings
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2:1b")

SYSTEM_PROMPT = """
You are a calm, supportive CBT-based journaling assistant.
Your goal is to help the user feel understood, identify the thinking pattern, gently reframe and suggest a small helpful action, and one indoor plant according to mood.

Rules:
- Be non-judgmental and empathetic
- Do NOT diagnose or label the user
- Keep responses short, clear, and supportive
- Use simple, human language
- Output STRICT JSON only
"""

# 1. Context Definitions
SOCIAL_CONTEXT = ["people", "presentation", "class", "meeting", "talk", "crowd", "friend", "social", "party"]
PERFORMANCE_CONTEXT = ["exam", "test", "deadline", "assignment", "work", "job", "interview", "performance", "score"]
HEALTH_CONTEXT = ["health", "sick", "body", "pain", "hospital", "doctor", "weight", "sleep", "tired"]

def map_emotion_group(label):
    if label in ["fear", "nervousness", "confusion"]:
        return "anxiety"
    elif label in ["anger", "annoyance", "disappointment", "disapproval", "disgust"]:
        return "stress"
    elif label in ["sadness", "grief", "remorse", "embarrassment"]:
        return "low_mood"
    elif label in ["joy", "gratitude", "love", "relief", "optimism", "pride", "excitement", "admiration", "approval", "caring"]:
        return "positive"
    return "neutral"

def detect_context(text):
    text = text.lower()
    if any(word in text for word in SOCIAL_CONTEXT):
        return "social"
    elif any(word in text for word in PERFORMANCE_CONTEXT):
        return "performance"
    elif any(word in text for word in HEALTH_CONTEXT):
        return "health"
    return "general"

def get_intensity_label(intensity):
    if intensity < 40: return "Mild"
    if intensity < 70: return "Moderate"
    if intensity < 85: return "High"
    return "Very High"

def predict_emotion(text):
    inputs = emotion_tokenizer(text, return_tensors="pt", truncation=True, padding=True).to(DEVICE)
    with torch.no_grad():
        logits = emotion_model(**inputs).logits
    probs = F.softmax(logits, dim=1)
    confidence, idx = torch.max(probs, dim=1)
    
    label = emotion_model.config.id2label.get(idx.item(), "neutral")
    conf_val = round(confidence.item(), 4)
    intensity = int(conf_val * 100)
    
    emotion_group = map_emotion_group(label)
    context = detect_context(text)
    intensity_label = get_intensity_label(intensity)
    
    # Final label combination (Human-readable "Emotional State")
    if emotion_group == "anxiety":
        final_label = f"{context.capitalize()} Anxiety" if context != "general" else "Anxiety"
    elif emotion_group == "low_mood":
        final_label = f"{context.capitalize()} Low Mood" if context != "general" else "Emotional Exhaustion"
    elif emotion_group == "stress":
        final_label = f"{context.capitalize()} Stress" if context != "general" else "Stress"
    elif emotion_group == "positive":
        final_label = f"{context.capitalize()} Positive Shift" if context != "general" else label.capitalize()
    else:
        final_label = label.capitalize()

    return {
        "raw_label": label,
        "emotion_group": emotion_group,
        "context": context,
        "intensity": intensity,
        "intensity_label": intensity_label,
        "final_label": final_label,
        "confidence": conf_val
    }

def get_plant_suggestion(emotion_group, raw_label):
    mapping = {
        "anxiety": "Peace Lily nearby to help create a calmer and clearer space",
        "stress": "Jasmine plant nearby to help soothe and refresh your environment",
        "low_mood": "Aloe Vera plant nearby to help bring a sense of healing and renewal",
        "positive": "bright Sunflower nearby to help maintain your positive energy",
        "neutral": "Spider Plant nearby for steady, grounded growth"
    }
    plant_text = mapping.get(emotion_group, "Lucky Bamboo nearby to bring focus and clarity")
    return f"Plant Suggestion: You seem to experience {raw_label}—consider keeping a {plant_text}."

def predict_distortion(text):
    inputs = cbt_tokenizer(text, return_tensors="pt", truncation=True, padding=True).to(DEVICE)
    with torch.no_grad():
        logits = cbt_model(**inputs).logits
    probs = F.softmax(logits, dim=1)
    confidence, idx = torch.max(probs, dim=1)
    return {"label": cbt_model.config.id2label.get(idx.item(), "none"), "confidence": round(confidence.item(), 4)}

def extract_json(text):
    text = text.strip()
    if "```json" in text:
        text = text.split("```json")[1].split("```")[0].strip()
    elif "```" in text:
        text = text.split("```")[1].split("```")[0].strip()
    start = text.find('{')
    end = text.rfind('}')
    if start != -1 and end != -1:
        text = text[start:end+1]
    return json.loads(text)

def get_ai_response(text, emotion_data, distortion):
    intensity = emotion_data["intensity"]
    final_label = emotion_data["final_label"]
    
    stress_instruction = "Priority: Grounding and safety. Keep it extra calming." if intensity >= 70 else "Focus: Perspective-shift and reflection."
    
    prompt = f"""
    User: "{text}"
    Detected: Emotional State={final_label} ({intensity}%), Pattern={distortion}
    
    Task: Return JSON with these fields:
    - "insight": EXACTLY one short sentence explaining what the user may be experiencing emotionally. Must validate their feelings without sounding robotic. (e.g., "You seem mentally overwhelmed while trying to make the 'right' choice.")
    - "pattern_explanation": EXACTLY one line explaining the {distortion} pattern (e.g. define the pattern strictly in one line).
    - "reframe": A realistic, CBT-aligned balanced alternative thought in 3-4 lines.
    - "action": One small, concrete helpful step.
    
    Rules:
    - "insight" MUST be one line only.
    - "pattern_explanation" MUST be exactly one line.
    - "reframe" MUST be 3-4 lines long.
    - {stress_instruction}
    """
    
    try:
        response = requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "prompt": f"{SYSTEM_PROMPT}\n\n{prompt}",
                "stream": False,
                "format": "json"
            },
            timeout=120
        )
        response.raise_for_status()
        ai_data = extract_json(response.json()["response"])
        # Inject the mapped plant suggestion
        ai_data["plant"] = get_plant_suggestion(emotion_data["emotion_group"], emotion_data["raw_label"])
        return ai_data
    except Exception as e:
        print(f"[LLM ERROR] {str(e)}")
        return {
            "insight": f"You seem to be navigating some {final_label.lower()} right now.",
            "pattern_explanation": f"It's common for our minds to use {distortion} when we feel under pressure.",
            "reframe": "Try to look at this from a balanced perspective, one small step at a time.",
            "action": "Take a moment to simply observe your surroundings.",
            "plant": get_plant_suggestion(emotion_data["emotion_group"], emotion_data["raw_label"])
        }
