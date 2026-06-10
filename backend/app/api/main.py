from flask import Flask
from auth import auth_bp
from ai import ai_bp

app = Flask(__name__)

# register modules
app.register_blueprint(auth_bp)
app.register_blueprint(ai_bp)

@app.route("/")
def home():
    return {"status": "Anxease backend running"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)