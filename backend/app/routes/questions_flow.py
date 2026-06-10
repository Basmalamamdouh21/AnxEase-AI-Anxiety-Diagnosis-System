from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from ..extensions import db
from ..models import QuestionFlow

bp = Blueprint("questions_flow", __name__, url_prefix="/questions-flow")


@bp.get("")
@jwt_required()
def get_flow():
    user_id = int(get_jwt_identity())
    flow = QuestionFlow.query.filter_by(user_id=user_id).first()
    if not flow:
        return {"flow": None}, 200

    return {
        "flow": {
            "payload": flow.payload,
            "updatedAt": flow.updated_at.isoformat(),
        }
    }, 200


@bp.put("")
@jwt_required()
def upsert_flow():
    user_id = int(get_jwt_identity())
    data = request.get_json(silent=True) or {}

    payload = data.get("payload")
    if payload is None or not isinstance(payload, dict):
        return {"message": "payload (object) is required"}, 400

    flow = QuestionFlow.query.filter_by(user_id=user_id).first()
    if not flow:
        flow = QuestionFlow(user_id=user_id, payload=payload)
        db.session.add(flow)
    else:
        flow.payload = payload

    db.session.commit()

    return {
        "flow": {
            "payload": flow.payload,
            "updatedAt": flow.updated_at.isoformat(),
        }
    }, 200


@bp.delete("")
@jwt_required()
def delete_flow():
    user_id = int(get_jwt_identity())
    flow = QuestionFlow.query.filter_by(user_id=user_id).first()
    if not flow:
        return {"message": "nothing to delete"}, 200

    db.session.delete(flow)
    db.session.commit()
    return {"message": "deleted"}, 200
