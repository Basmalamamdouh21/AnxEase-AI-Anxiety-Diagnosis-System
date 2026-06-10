from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from ..extensions import db
from ..models import MoodEntry

bp = Blueprint("moods", __name__, url_prefix="/moods")


@bp.post("")
@jwt_required()
def add_mood():
    user_id = int(get_jwt_identity())
    data = request.get_json(silent=True) or {}

    mood = data.get("mood")
    note = data.get("note")

    if mood is None:
        return {"message": "mood is required"}, 400

    try:
        mood_int = int(mood)
    except Exception:
        return {"message": "mood must be an integer"}, 400

    entry = MoodEntry(user_id=user_id, mood=mood_int, note=note)
    db.session.add(entry)
    db.session.commit()

    return {
        "id": entry.id,
        "mood": entry.mood,
        "note": entry.note,
        "createdAt": entry.created_at.isoformat(),
    }, 201


@bp.get("")
@jwt_required()
def list_moods():
    user_id = int(get_jwt_identity())
    # latest first
    rows = (
        MoodEntry.query.filter_by(user_id=user_id)
        .order_by(MoodEntry.created_at.desc())
        .all()
    )

    return {
        "items": [
            {
                "id": r.id,
                "mood": r.mood,
                "note": r.note,
                "createdAt": r.created_at.isoformat(),
            }
            for r in rows
        ]
    }, 200
