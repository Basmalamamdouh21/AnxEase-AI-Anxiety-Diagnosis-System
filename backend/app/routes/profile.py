from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from ..extensions import db
from ..models import Profile

bp = Blueprint("profile", __name__, url_prefix="/profile")


@bp.get("")
@jwt_required()
def get_profile():
    user_id = int(get_jwt_identity())
    profile = Profile.query.filter_by(user_id=user_id).first()
    if not profile:
        return {"profile": None}, 200

    return {
        "profile": {
            "displayName": profile.display_name,
            "username": profile.username,
            "phone": profile.phone,
            "avatarUrl": profile.avatar_url,
        }
    }, 200


@bp.put("")
@jwt_required()
def update_profile():
    user_id = int(get_jwt_identity())
    data = request.get_json(silent=True) or {}

    profile = Profile.query.filter_by(user_id=user_id).first()
    if not profile:
        return {"message": "profile not found"}, 404

    # allow partial updates
    if "displayName" in data:
        profile.display_name = data.get("displayName")
    if "username" in data:
        profile.username = data.get("username")
    if "phone" in data:
        profile.phone = data.get("phone")
    if "avatarUrl" in data:
        profile.avatar_url = data.get("avatarUrl")

    db.session.commit()

    return {
        "profile": {
            "displayName": profile.display_name,
            "username": profile.username,
            "phone": profile.phone,
            "avatarUrl": profile.avatar_url,
        }
    }, 200
