from flask import Blueprint, request, jsonify
import json
import os
import uuid
import re
import bcrypt
from datetime import datetime, timezone

auth_bp = Blueprint("auth", __name__)

USERS_FILE = "users.json"
PROFILES_FILE = "profiles.json"

EMAIL_REGEX = r"^[^@]+@[^@]+\.[^@]+$"
INVALID_JSON_ERROR = "Invalid JSON"


# -----------------------------------------
# SAFE JSON HELPERS
# -----------------------------------------

def load_json(file):

    if not os.path.exists(file):
        return {}

    try:
        with open(file, "r") as f:
            return json.load(f)
    except Exception:
        return {}


def save_json(file, data):

    tmp = file + ".tmp"

    with open(tmp, "w") as f:
        json.dump(data, f, indent=2)

    os.replace(tmp, file)


# -----------------------------------------
# STANDARD RESPONSE
# -----------------------------------------

def ok(data=None):
    return jsonify({"success": True, "data": data})


def error(message, code=400):
    return jsonify({"success": False, "error": message}), code


# -----------------------------------------
# PASSWORD HASH
# -----------------------------------------

def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def check_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed.encode())


# -----------------------------------------
# REGISTER
# -----------------------------------------

@auth_bp.route("/register", methods=["POST"])
def register():

    body = request.get_json()

    if not body:
        return error(INVALID_JSON_ERROR)

    email = body.get("email")
    password = body.get("password")

    if not email or not password:
        return error("Email and password required")

    if not re.match(EMAIL_REGEX, email):
        return error("Invalid email format")

    if len(password) < 6:
        return error("Password must be at least 6 characters")

    users = load_json(USERS_FILE)

    for u in users.values():
        if u["email"].lower() == email.lower():
            return error("Email already registered", 409)

    user_id = str(uuid.uuid4())

    users[user_id] = {
        "userId": user_id,
        "email": email,
        "password": hash_password(password),
        "createdAt": datetime.now(timezone.utc).isoformat()
    }

    save_json(USERS_FILE, users)

    return ok({"userId": user_id})


# -----------------------------------------
# LOGIN
# -----------------------------------------

@auth_bp.route("/login", methods=["POST"])
def login():

    body = request.get_json()

    if not body:
        return error(INVALID_JSON_ERROR)

    email = body.get("email")
    password = body.get("password")

    users = load_json(USERS_FILE)

    for user in users.values():

        if user["email"].lower() == email.lower():

            if check_password(password, user["password"]):

                return ok({
                    "userId": user["userId"]
                })

            return error("Invalid credentials", 401)

    return error("Invalid credentials", 401)


# -----------------------------------------
# PROFILE VALIDATION
# -----------------------------------------

def normalize_profile(data):

    try:

        return {
            "userId": data["userId"],
            "name": data.get("name", ""),
            "date": data.get("date", datetime.now(timezone.utc).isoformat()),
            "username": data.get("username", ""),
            "phone": data.get("phone", ""),
            "country": data.get("country", ""),
            "city": data.get("city", ""),
            "job": data.get("job", ""),
            "weight": float(data.get("weight", 0)),
            "height": float(data.get("height", 0)),
            "gender": data.get("gender", ""),
            "maritalStatus": data.get("maritalStatus", ""),
            "hasInsurance": bool(data.get("hasInsurance", False)),
            "updatedAt": datetime.now(timezone.utc).isoformat()
        }

    except Exception:
        return None


# -----------------------------------------
# SAVE PROFILE
# -----------------------------------------

@auth_bp.route("/profile/save", methods=["POST"])
def save_profile():

    body = request.get_json()

    if not body:
        return error(INVALID_JSON_ERROR)

    profile = normalize_profile(body)

    if not profile:
        return error("Invalid profile data")

    profiles = load_json(PROFILES_FILE)

    profiles[profile["userId"]] = profile

    save_json(PROFILES_FILE, profiles)

    return ok()


# -----------------------------------------
# GET PROFILE
# -----------------------------------------

@auth_bp.route("/profile/<user_id>", methods=["GET"])
def get_profile(user_id):

    profiles = load_json(PROFILES_FILE)

    profile = profiles.get(user_id)

    if not profile:
        return error("Profile not found", 404)

    return ok(profile)


# -----------------------------------------
# UPDATE PROFILE
# -----------------------------------------

@auth_bp.route("/profile/update", methods=["POST"])
def update_profile():

    body = request.get_json()

    if not body:
        return error(INVALID_JSON_ERROR)

    user_id = body.get("userId")

    profiles = load_json(PROFILES_FILE)

    if user_id not in profiles:
        return error("Profile not found", 404)

    updated = normalize_profile(body)

    if not updated:
        return error("Invalid profile data")

    profiles[user_id] = updated

    save_json(PROFILES_FILE, profiles)

    return ok()