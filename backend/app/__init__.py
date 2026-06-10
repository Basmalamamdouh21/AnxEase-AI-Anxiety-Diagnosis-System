import os
from flask import Flask
from dotenv import load_dotenv

from .extensions import db, migrate, jwt
from .routes.auth import bp as auth_bp
from .routes.profile import bp as profile_bp
from .routes.moods import bp as moods_bp
from .routes.assessments import bp as assessments_bp
from .routes.questions_flow import bp as questions_flow_bp


def create_app():
    load_dotenv()

    app = Flask(__name__)

    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret")
    app.config["JWT_SECRET_KEY"] = os.getenv(
        "JWT_SECRET_KEY", "dev-jwt-secret-please-change")
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv(
        "DATABASE_URL", "sqlite:///anxease.db")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)

    from . import models

    @app.get("/")
    def home():
        return {"message": "Anxease API is running"}, 200

    @app.get("/health")
    def health():
        return {"status": "ok"}, 200

    app.register_blueprint(auth_bp)
    app.register_blueprint(profile_bp)
    app.register_blueprint(moods_bp)
    app.register_blueprint(assessments_bp)
    app.register_blueprint(questions_flow_bp)
    return app
