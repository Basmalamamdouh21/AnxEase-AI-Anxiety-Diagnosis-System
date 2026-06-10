from datetime import datetime
from .extensions import db


class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)


class Profile(db.Model):
    __tablename__ = "profiles"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey(
        "users.id"), unique=True, nullable=False, index=True)

    display_name = db.Column(db.String(150), nullable=True)
    username = db.Column(db.String(150), nullable=True)
    phone = db.Column(db.String(50), nullable=True)
    avatar_url = db.Column(db.Text, nullable=True)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow,
                           onupdate=datetime.utcnow, nullable=False)

    user = db.relationship(
        "User", backref=db.backref("profile", uselist=False))


class MoodEntry(db.Model):
    __tablename__ = "mood_entries"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey(
        "users.id"), nullable=False, index=True)

    mood = db.Column(db.Integer, nullable=False)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False, index=True)

    note = db.Column(db.Text, nullable=True)

    user = db.relationship(
        "User", backref=db.backref("mood_entries", lazy=True))


class Assessment(db.Model):
    __tablename__ = "assessments"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey(
        "users.id"), nullable=False, index=True)

    # store answers / inputs (dynamic)
    payload = db.Column(db.JSON, nullable=False)

    # store computed results (dynamic: scores, labels, flags)
    analysis = db.Column(db.JSON, nullable=True)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False, index=True)

    user = db.relationship(
        "User", backref=db.backref("assessments", lazy=True))


class QuestionFlow(db.Model):
    __tablename__ = "question_flows"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey(
        "users.id"), unique=True, nullable=False, index=True)

    payload = db.Column(db.JSON, nullable=False, default=dict)

    created_at = db.Column(
        db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow,
                           onupdate=datetime.utcnow, nullable=False)

    user = db.relationship("User", backref=db.backref(
        "question_flow", uselist=False))
