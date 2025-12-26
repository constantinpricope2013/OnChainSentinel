from flask import Flask, request
from vertexai.generative_models import GenerativeModel

app = Flask(__name__)
model = GenerativeModel("gemini-1.5-flash")

@app.route("/classify", methods=["POST"])
def classify():
    features = request.json.get("features")
    prompt = f"Given behavioral features {features}, label SAFE or DANGER."
    result = model.generate_content(prompt)
    text = result.text.strip().upper()
    if "DANGER" in text:
        return "DANGER"
    return "SAFE"
