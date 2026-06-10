from flask import Blueprint, request
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash

from ..extensions import db
from ..models import User, Profile

bp = Blueprint("auth", __name__, url_prefix="/auth")


@bp.post("/register")
def register():
    data = request.get_json(silent=True) or {}

    email = (data.get("email") or "").strip().lower()
    password = data.get("password") or ""

    display_name = data.get("displayName")
    username = data.get("username")
    phone = data.get("phone")
    avatar_url = data.get("avatarUrl")

    if not email or not password:
        return {"message": "email and password are required"}, 400

    if User.query.filter_by(email=email).first():
        return {"message": "email already exists"}, 409

    user = User(email=email, password_hash=generate_password_hash(password))
    db.session.add(user)
    db.session.flush()

    profile = Profile(
        user_id=user.id,
        display_name=display_name,
        username=username,
        phone=phone,
        avatar_url=avatar_url,
    )
    db.session.add(profile)
    db.session.commit()

    token = create_access_token(identity=str(user.id))
    return {
        "token": token,
        "user": {"id": user.id, "email": user.email},
        "profile": {
            "displayName": profile.display_name,
            "username": profile.username,
            "phone": profile.phone,
            "avatarUrl": profile.avatar_url,
        },
    }, 201


@bp.post("/login")
def login():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    password = data.get("password") or ""

    user = User.query.filter_by(email=email).first()
    if not user or not check_password_hash(user.password_hash, password):
        return {"message": "invalid credentials"}, 401

    profile = getattr(user, "profile", None)

    token = create_access_token(identity=str(user.id))
    return {
        "token": token,
        "user": {"id": user.id, "email": user.email},
        "profile": None if not profile else {
            "displayName": profile.display_name,
            "username": profile.username,
            "phone": profile.phone,
            "avatarUrl": profile.avatar_url,
        },
    }, 200


@bp.get("/me")
@jwt_required()
def me():
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    if not user:
        return {"message": "user not found"}, 404

    profile = getattr(user, "profile", None)

    return {
        "user": {"id": user.id, "email": user.email},
        "profile": None if not profile else {
            "displayName": profile.display_name,
            "username": profile.username,
            "phone": profile.phone,
            "avatarUrl": profile.avatar_url,
        },
    }, 200
