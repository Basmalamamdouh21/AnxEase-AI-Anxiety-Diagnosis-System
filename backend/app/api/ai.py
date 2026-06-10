import os
import json
from datetime import datetime, timezone
import re
from flask import Blueprint, request, jsonify
from openai import OpenAI


ai_bp = Blueprint("ai", __name__)

# =====================================
# OPENROUTER CLIENT
# =====================================

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.getenv("OPENROUTER_API_KEY"),
)

MODEL = "openrouter/free"

# =====================================
# FILE STORAGE
# =====================================

DATA_FILE = "assessments.json"
CHAT_FILE = "chat_history.json"
PROFILES_FILE = "profiles.json"

MAX_RECENT_MESSAGES = 8
SUMMARIZE_AFTER = 16

ERROR_NO_ASSESSMENT = "No assessment found"


# =====================================
# FILE HELPERS
# =====================================

def load_profiles():
    if not os.path.exists(PROFILES_FILE):
        return {}

    try:
        with open(PROFILES_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return {}

def load_db():
    if not os.path.exists(DATA_FILE):
        return {}
    with open(DATA_FILE, "r") as f:
        return json.load(f)


def save_db(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)


def load_chat():
    if not os.path.exists(CHAT_FILE):
        return {}

    try:
        with open(CHAT_FILE, "r") as f:
            content = f.read().strip()

            if not content:
                return {}

            return json.loads(content)

    except Exception:
        return {}


def save_chat(data):
    with open(CHAT_FILE, "w") as f:
        json.dump(data, f, indent=2)


# =====================================
# DATA HELPERS
# =====================================

def get_latest_assessment(user_id):

    db = load_db()

    if user_id not in db or not db[user_id]:
        return None

    return db[user_id][-1]


def save_assessment(user_id, entry):

    db = load_db()

    db.setdefault(user_id, []).append(entry)

    save_db(db)

def get_user_location(user_id):

    profiles = load_profiles()

    profile = profiles.get(user_id)

    if not profile:
        return {"country": "", "city": ""}

    return {
        "country": profile.get("country", ""),
        "city": profile.get("city", "")
    }

# =====================================
# PROMPTS
# =====================================

SYSTEM_PROMPT = """
You are a clinical anxiety triage and treatment planning AI used in a medical-grade mental health platform.

Your role is to:

1. Analyze patient answers.
2. Identify symptoms and risk factors.
3. Apply structured diagnostic logic.
4. Calculate anxiety severity.
5. Generate a detailed evidence-based treatment plan.

You must behave like a structured clinical reasoning engine.

--------------------------------------------
CRITICAL OUTPUT RULES
--------------------------------------------

1. Output MUST be valid JSON.
2. NEVER include text outside JSON.
3. NEVER omit fields from the schema.
4. If information is missing use empty arrays.
5. Do NOT hallucinate facts that are not supported by answers.
6. Treatments must contain detailed step-by-step explanations, not just titles.

--------------------------------------------
STEP-BY-STEP CLINICAL REASONING PROCESS
--------------------------------------------

You must internally perform the following steps:

STEP 1 — Extract Symptoms
Identify symptoms based on patient answers such as:

• persistent worry
• panic attacks
• social avoidance
• intrusive thoughts
• repetitive behaviors
• fatigue
• sleep disruption
• concentration problems
• emotional distress
• isolation

STEP 2 — Identify Risk Factors
Risk factors may include:

• family history of anxiety
• trauma history
• early life stress
• strict parenting
• chronic stress
• caffeine or stimulant use
• poor sleep
• poor nutrition

STEP 3 — Apply Diagnostic Rules

Use the following diagnostic mapping:

Generalized Anxiety Disorder
IF excessive worry AND symptoms lasting ≥6 months

Panic Disorder
IF recurrent unexpected panic attacks

Social Anxiety Disorder
IF fear of negative judgment AND avoidance of social interaction

Agoraphobia
IF avoidance of public places due to fear of inability to escape

Specific Phobia
IF intense fear triggered by specific object or situation

STEP 4 — Severity Scoring

Calculate anxietyScore from 0–100 using:

symptom frequency
symptom duration
avoidance behaviors
panic attacks
daily functioning impairment
sleep disruption
stress levels

Severity classification:

0–24 Mild  
25–49 Moderate  
50–74 Severe  
75–100 Critical

STEP 5 — Generate Treatment Protocol

You MUST generate a detailed evidence-based treatment plan using CBT principles.

Treatments must include:

• explanation of the therapy
• step-by-step instructions
• how often the technique should be practiced
• expected benefit
• examples of how to perform the technique

Avoid short titles like "mindfulness" without explanation.

Example format:

"deep breathing exercises": [
  "Sit comfortably and place one hand on the chest and one on the stomach.",
  "Inhale slowly through the nose for 4 seconds.",
  "Hold the breath for 4 seconds.",
  "Exhale slowly through the mouth for 6 seconds.",
  "Repeat for 5–10 minutes twice daily."
]

STEP 6 — Medication Education

Provide educational information about medication classes used for anxiety treatment.

Never prescribe medication.

Explain:

• how the medication works
• when it is typically used
• possible side effects
• safety considerations

--------------------------------------------
OUTPUT JSON STRUCTURE
--------------------------------------------

Return the following schema exactly:

{
 "severity": "Mild | Moderate | Severe | Critical",

 "diagnosis": "primary suspected anxiety disorder",

 "anxietyScore": number,

 "symptoms": [],

 "riskFactors": [],

 "therapy": {
   "recommendedTechniques": {
      "techniqueName": [
         "detailed step",
         "detailed step",
         "expected benefits"
      ]
   },

   "lifestyleChanges": {
      "changeName": [
         "step",
         "step",
         "benefit"
      ]
   },

   "copingStrategies": {
      "strategyName": [
         "step",
         "step",
         "step"
      ]
   }
 },

 "medication": {
   "education": {
      "SSRI": [
         "how it works",
         "when used",
         "possible side effects"
      ],
      "SNRI": [],
      "Beta Blockers": [],
      "Buspirone": [],
      "Benzodiazepines": []
   },

   "notes": "Medication information is educational only. Patients must consult a licensed psychiatrist before using medication."
 },

 "adherence": number
}

adherence must be between 0 and 1, where 0 means no adherence and 1 means full adherence to the treatment plan.

--------------------------------------------
QUALITY REQUIREMENTS
--------------------------------------------

The therapy section must include:

• clear instructions
• behavioral techniques
• psychological explanation
• frequency of practice
• expected outcome

The final output must be clinically structured, professional, and actionable.
"""

CHAT_SYSTEM_PROMPT = """
You are a conversational AI assistant inside a mental health and wellbeing platform.

Your personality should feel similar to a friendly therapist combined with a knowledgeable health guide.

You can respond to ANY user message including casual conversation, questions, emotional statements, or random thoughts.

Your goal is to naturally guide conversations toward:

• emotional wellbeing
• stress management
• mental health
• healthy habits
• psychology
• medical wellbeing
• lifestyle factors that affect health

You may also answer general questions, but whenever possible relate them to health, wellbeing, psychology, or human behavior.

--------------------------------------------------

COMMUNICATION STYLE

Your tone should be:

empathetic
warm
human-like
thoughtful
supportive
natural

Avoid sounding robotic or scripted.

Responses should feel conversational like ChatGPT, not like a strict medical system.

--------------------------------------------------

MEDICAL SAFETY

You MUST NOT:

• diagnose diseases
• prescribe medication
• provide drug dosages

You MAY:

• explain medical concepts
• discuss mental health topics
• provide coping strategies
• give educational health information

Always remind the user to consult professionals for medical decisions when appropriate.

--------------------------------------------------

CRISIS DETECTION

If the user expresses:

• suicidal thoughts
• self harm intent
• feeling unable to continue living
• extreme hopelessness

Then:

Set "emotion": "Crisis"
Set "crisis": true

Respond with compassionate support and encourage contacting a professional or trusted person.

--------------------------------------------------

EMOTION CLASSIFICATION

Classify the user's emotional state:

Stable
Moderate Stress
High Anxiety
Depressed Mood
Crisis

--------------------------------------------------

OUTPUT FORMAT

Return JSON only with the following schema:
{
 "response": "natural conversational reply",
 "emotion": "Stable | Moderate Stress | High Anxiety | Depressed Mood | Crisis",
 "crisis": true or false
}

Never output text outside JSON.
"""

SUMMARY_PROMPT = """
You are a clinical therapy documentation assistant.

Summarize a therapy conversation.

Focus on:

emotional concerns
symptoms mentioned
coping strategies provided

Return JSON:

{
 "summary": "concise clinical summary"
}

Return JSON only.
"""

THERAPY_SYSTEM_PROMPT = """
You are a clinical psychologist generating a structured CBT treatment protocol for an anxiety therapy platform.

The therapy must be based on the patient's diagnosis, symptoms, and risk factors.

DIAGNOSTIC KNOWLEDGE

Use the following logic:

Excessive worry ≥6 months → Generalized Anxiety Disorder
Recurrent panic attacks → Panic Disorder
Fear of social judgement → Social Anxiety
Avoidance of public places → Agoraphobia
Immediate fear of specific object → Specific Phobia

Risk factors may include:

family history
childhood trauma
early life stress
chronic psychological stress
sleep disruption
poor nutrition
substance use

Treatment must adapt to these factors.

--------------------------------------------

THERAPY REQUIREMENTS

Generate a complete CBT program including:

1. Treatment overview
2. Primary goals
3. Step-by-step intervention plan
4. Daily exercises
5. Weekly therapy modules
6. Cognitive restructuring techniques
7. Exposure therapy protocol (if applicable)
8. Stress management plan
9. Lifestyle adjustments
10. Relapse prevention plan
11. Expected recovery timeline

--------------------------------------------

OUTPUT JSON SCHEMA

{
 "therapyPlan": {
   "diagnosisFocus": "",
   "treatmentOverview": "",
   "primaryGoals": [],
   "stepByStepTreatment": [
      {
        "phase": "",
        "description": "",
        "techniques": [],
        "expectedOutcome": ""
      }
   ],
   "dailyExercises": [],
   "weeklyModules": [],
   "cognitiveTechniques": [],
   "exposureTherapy": [],
   "stressManagement": [],
   "lifestyleAdjustments": [],
   "relapsePrevention": [],
   "expectedRecoveryTimeline": ""
 }
}

STRICT RULES

Return JSON only.
Never omit fields.
If not applicable return empty arrays.
"""

MEDICATION_SYSTEM_PROMPT = """
You are a psychiatrist generating structured medication education for anxiety disorders.

Use the patient's diagnosis and symptoms to explain medication categories used in clinical practice.

IMPORTANT

Do NOT prescribe medication.
Do NOT provide dosage instructions.
Only provide educational information.

--------------------------------------------

Medication classes used in anxiety treatment:

SSRIs
SNRIs
Beta blockers
Buspirone
Benzodiazepines (short term use only)

--------------------------------------------

OUTPUT JSON SCHEMA

{
 "medicationPlan": {
   "diagnosisFocus": "",
   "treatmentOverview": "",
   "medicationCategories": [
      {
        "category": "",
        "howItWorks": "",
        "whenUsed": "",
        "commonExamples": [],
        "possibleSideEffects": []
      }
   ],
   "monitoringRecommendations": [],
   "safetyConsiderations": [],
   "consultDoctorMessage": ""
 }
}

RULES

Return JSON only.
Never omit fields.
"""

# =====================================
# JSON SAFETY
# =====================================

def safe_json_parse(content):

    if not content:
        return None

    # direct parse
    try:
        return json.loads(content)
    except Exception:
        pass

    # remove markdown blocks
    content = content.replace("```json", "").replace("```", "")

    # extract json object
    match = re.search(r"\{[\s\S]*\}", content)

    if match:
        try:
            return json.loads(match.group())
        except Exception:
            pass

    return None

def validate_assessment_schema(data):

    default = {
        "severity": "Moderate",
        "diagnosis": "Anxiety symptoms detected",
        "anxietyScore": 40,
        "symptoms": [],
        "riskFactors": [],
        "therapy": {
            "recommendedTechniques": [],
            "lifestyleChanges": [],
            "copingStrategies": []
        },
        "medication": {
            "education": [],
            "notes": "informational only"
        },
        "adherence": 50
    }

    if not isinstance(data, dict):
        return default

    for key in default:
        if key not in data:
            data[key] = default[key]

    return data


def validate_chat_schema(data):

    if not isinstance(data, dict):
        return {
            "response": "I'm here with you. Tell me what's on your mind.",
            "emotion": "Stable",
            "crisis": False
        }

    if "response" not in data:
        data["response"] = "I'm listening. Tell me more."

    if "emotion" not in data:
        data["emotion"] = "Stable"

    if "crisis" not in data:
        data["crisis"] = False

    return data

def validate_therapy_schema(data):

    default = {
        "therapyPlan": {
            "primaryGoals": [],
            "recommendedTechniques": [],
            "dailyPractices": [],
            "weeklyExercises": [],
            "lifestyleAdjustments": [],
            "copingStrategies": [],
            "expectedOutcomes": []
        }
    }

    if not isinstance(data, dict):
        return default

    if "therapyPlan" not in data:
        return default

    for key in default["therapyPlan"]:
        if key not in data["therapyPlan"]:
            data["therapyPlan"][key] = []

    return data


def validate_medication_schema(data):

    default = {
        "medicationEducation": {
            "possibleCategories": [],
            "howTheyHelp": [],
            "commonSideEffects": [],
            "safetyNotes": [],
            "consultDoctorMessage": "Consult a licensed psychiatrist before taking any medication."
        }
    }

    if not isinstance(data, dict):
        return default

    if "medicationEducation" not in data:
        return default

    for key in default["medicationEducation"]:
        if key not in data["medicationEducation"]:
            data["medicationEducation"][key] = []

    return data

# =====================================
# MESSAGE BUILDER
# =====================================

def build_messages(answers):

    prompt = f"""
Medical answers:
{json.dumps(answers.get("medical", {}))}

Anxiety answers:
{json.dumps(answers.get("anxiety", {}))}

Mental answers:
{json.dumps(answers.get("mental", {}))}
"""

    return [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": prompt}
    ]


# =====================================
# AI CALL
# =====================================

def call_ai(messages):

    try:
        completion = client.chat.completions.create(
            model=MODEL,
            messages=messages,
            temperature=0.7,
            top_p=0.9,
            response_format={"type": "json_object"},  # FORCE JSON
            extra_headers={
                "HTTP-Referer": "https://anxease.app",
                "X-OpenRouter-Title": "Anxease"
            }
        )

        content = completion.choices[0].message.content

        parsed = safe_json_parse(content)

        if parsed is None:
            print("JSON PARSE FAILED:", content)

        return parsed

    except Exception as e:
        print("AI ERROR:", e)
        return None
# =====================================
# SUMMARIZE CHAT
# =====================================

def summarize_history(history, previous_summary):

    text = "\n".join([f'{m["role"]}: {m["content"]}' for m in history])

    messages = [
        {"role": "system", "content": SUMMARY_PROMPT},
        {"role": "user", "content": f"Previous summary:\n{previous_summary}\n\nConversation:\n{text}"}
    ]

    result = call_ai(messages)

    if not result:
        return previous_summary

    return result.get("summary", previous_summary)

def compress_history(history, summary):

    if len(history) <= SUMMARIZE_AFTER:
        return history, summary

    old_messages = history[:-MAX_RECENT_MESSAGES]
    recent_messages = history[-MAX_RECENT_MESSAGES:]

    new_summary = summarize_history(old_messages, summary)

    return recent_messages, new_summary

# =====================================
# ANALYZE ASSESSMENT
# =====================================

@ai_bp.route("/assessment/analyze", methods=["POST"])
def analyze():

    body = request.json
    user_id = body["userId"]

    messages = build_messages(body)

    analysis = call_ai(messages)

    analysis = validate_assessment_schema(analysis)

    entry = {
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "answers": body,
        "analysis": analysis
    }

    save_assessment(user_id, entry)

    return jsonify(analysis)


# =====================================
# REGENERATE ANALYSIS
# =====================================

@ai_bp.route("/assessment/analyze/<user_id>", methods=["POST"])
def regenerate_analysis(user_id):

    latest = get_latest_assessment(user_id)

    if not latest:
        return jsonify({"error": ERROR_NO_ASSESSMENT}), 404

    answers = latest["answers"]

    messages = build_messages(answers)

    analysis = call_ai(messages)

    analysis = validate_assessment_schema(analysis)

    latest["analysis"] = analysis

    db = load_db()
    db[user_id][-1] = latest
    save_db(db)

    return jsonify(analysis)


# =====================================
# LATEST ASSESSMENT
# =====================================

@ai_bp.route("/assessment/latest/<user_id>", methods=["GET"])
def latest(user_id):

    latest = get_latest_assessment(user_id)

    return jsonify(latest)


# ================================
# THERAPY PLAN
# ================================
@ai_bp.route("/treatment/therapy/<user_id>", methods=["GET"])
def therapy_plan(user_id):

    latest = get_latest_assessment(user_id)

    if not latest:
        return jsonify({"error": ERROR_NO_ASSESSMENT}), 404

    prompt = f"""
Patient answers:
{json.dumps(latest["answers"], indent=2)}

Clinical analysis:
{json.dumps(latest["analysis"], indent=2)}

Generate a full CBT treatment protocol tailored to this patient.
"""

    messages = [
        {"role": "system", "content": THERAPY_SYSTEM_PROMPT},
        {"role": "user", "content": prompt}
    ]

    therapy = call_ai(messages)

    therapy = validate_therapy_schema(therapy)

    return jsonify(therapy)

# ================================
# MEDICATION PLAN
# ================================
@ai_bp.route("/treatment/medication/<user_id>", methods=["GET"])
def medication_plan(user_id):

    latest = get_latest_assessment(user_id)

    if not latest:
        return jsonify({"error": ERROR_NO_ASSESSMENT}), 404

    prompt = f"""
Patient answers:
{json.dumps(latest["answers"], indent=2)}

Diagnosis and analysis:
{json.dumps(latest["analysis"], indent=2)}

Generate structured medication education for this patient.
"""

    messages = [
        {"role": "system", "content": MEDICATION_SYSTEM_PROMPT},
        {"role": "user", "content": prompt}
    ]

    medication = call_ai(messages)

    medication = validate_medication_schema(medication)

    return jsonify(medication)

# =====================================
# CHATBOT
# =====================================

@ai_bp.route("/chat", methods=["POST"])
def chat():
    body = request.json
    user_id = body["userId"]
    message = body["message"]
    chat_id = body.get("chatId", "default")

    location = get_user_location(user_id)
    country = location.get("country", "")
    city = location.get("city", "")

    latest = get_latest_assessment(user_id)

    if not latest:
        return jsonify({"error": ERROR_NO_ASSESSMENT}), 404

    chat_db = load_chat()

    # -----------------------------
    # Initialize user storage
    # -----------------------------
    if user_id not in chat_db:
        chat_db[user_id] = {"chats": {}}

    user_chats = chat_db[user_id]["chats"]

    # -----------------------------
    # Initialize chat thread
    # -----------------------------
    if chat_id not in user_chats:
        user_chats[chat_id] = {
            "summary": "",
            "messages": []
        }

    chat_data = user_chats[chat_id]

    summary = chat_data["summary"]
    history = chat_data["messages"]

    # -----------------------------
    # Summarization
    # -----------------------------
    history, summary = compress_history(history, summary)

    # -----------------------------
    # Context
    # -----------------------------
    context = f"""
Conversation memory summary:
{summary}

Patient analysis:
{json.dumps(latest["analysis"])}

Patient location:
Country: {country if country else "Unknown"}
City: {city if city else "Unknown"}
"""

    messages = [
        {"role": "system", "content": CHAT_SYSTEM_PROMPT},
        {"role": "system", "content": context},
        *history,
        {"role": "user", "content": message}
    ]

    result = call_ai(messages)

    if result is None:
        result = {
            "response": "I'm here with you. What would you like to talk about?",
            "emotion": "Stable",
            "crisis": False
        }

    result = validate_chat_schema(result)

    # -----------------------------
    # Save history
    # -----------------------------
    history.append({"role": "user", "content": message})
    history.append({"role": "assistant", "content": result["response"]})

    user_chats[chat_id] = {
        "summary": summary,
        "messages": history
    }

    chat_db[user_id]["chats"] = user_chats

    save_chat(chat_db)

    return jsonify(result)

@ai_bp.route("/chat/new/<user_id>", methods=["POST"])
def new_chat(user_id):

    chat_db = load_chat()

    if user_id not in chat_db:
        chat_db[user_id] = {"chats": {}}

    chat_id = str(int(datetime.now().timestamp() * 1000))

    chat_db[user_id]["chats"][chat_id] = {
        "summary": "",
        "messages": []
    }

    save_chat(chat_db)

    return jsonify({"chatId": chat_id})

@ai_bp.route("/chat/list/<user_id>", methods=["GET"])
def list_chats(user_id):

    chat_db = load_chat()

    if user_id not in chat_db:
        return jsonify([])

    chats = chat_db[user_id]["chats"]

    result = []

    for cid, data in chats.items():

        title = "New Chat"

        for msg in data["messages"]:
            if msg["role"] == "user":
                title = msg["content"][:40]
                break

        result.append({
            "chatId": cid,
            "title": title
        })

    result.sort(key=lambda x: x["chatId"], reverse=True)

    return jsonify(result)

@ai_bp.route("/chat/messages/<user_id>/<chat_id>", methods=["GET"])
def chat_messages(user_id, chat_id):

    chat_db = load_chat()

    if user_id not in chat_db:
        return jsonify([])

    chats = chat_db[user_id]["chats"]

    if chat_id not in chats:
        return jsonify([])

    return jsonify(chats[chat_id]["messages"])

@ai_bp.route("/chat/delete/<user_id>/<chat_id>", methods=["DELETE"])
def delete_chat(user_id, chat_id):

    chat_db = load_chat()

    if user_id not in chat_db:
        return jsonify({"status": "ok"})

    chats = chat_db[user_id].get("chats", {})

    if chat_id in chats:
        del chats[chat_id]

    chat_db[user_id]["chats"] = chats

    save_chat(chat_db)

    return jsonify({"status": "deleted"})