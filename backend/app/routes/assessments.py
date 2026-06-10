from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from ..extensions import db
from ..models import Assessment

bp = Blueprint("assessments", __name__, url_prefix="/assessments")


@bp.post("")
@jwt_required()
def create_assessment():
    user_id = int(get_jwt_identity())
    data = request.get_json(silent=True) or {}

    payload = data.get("payload")
    analysis = data.get("analysis")  # optional now (Flutter can send it)

    if payload is None:
        return {"message": "payload is required"}, 400
    if not isinstance(payload, dict):
        return {"message": "payload must be an object (JSON)"}, 400
    if analysis is not None and not isinstance(analysis, dict):
        return {"message": "analysis must be an object (JSON) if provided"}, 400

    row = Assessment(user_id=user_id, payload=payload, analysis=analysis)
    db.session.add(row)
    db.session.commit()

    return {
        "id": row.id,
        "createdAt": row.created_at.isoformat(),
        "payload": row.payload,
        "analysis": row.analysis,
    }, 201


@bp.get("/latest")
@jwt_required()
def latest_assessment():
    user_id = int(get_jwt_identity())
    row = (
        Assessment.query.filter_by(user_id=user_id)
        .order_by(Assessment.created_at.desc())
        .first()
    )

    if not row:
        return {"assessment": None}, 200

    return {
        "assessment": {
            "id": row.id,
            "createdAt": row.created_at.isoformat(),
            "payload": row.payload,
            "analysis": row.analysis,
        }
    }, 200


@bp.get("")
@jwt_required()
def list_assessments():
    user_id = int(get_jwt_identity())
    limit = request.args.get("limit", "20")
    try:
        limit_i = max(1, min(100, int(limit)))
    except Exception:
        limit_i = 20

    rows = (
        Assessment.query.filter_by(user_id=user_id)
        .order_by(Assessment.created_at.desc())
        .limit(limit_i)
        .all()
    )

    return {
        "items": [
            {
                "id": r.id,
                "createdAt": r.created_at.isoformat(),
                "payload": r.payload,
                "analysis": r.analysis,
            }
            for r in rows
        ]
    }, 200
