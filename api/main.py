from flask import Flask, jsonify
from pymongo import MongoClient
import os

app = Flask(__name__)
client = MongoClient(os.environ["MONGO_URI"])
col = client["onchain"]["address_risk"]

@app.route("/address/<addr>")
def get_addr(addr):
    doc = col.find_one({"address": addr})
    if not doc:
        return jsonify({"address": addr, "risk": "UNKNOWN"})
    return jsonify({"address": addr, "risk": doc["risk"]})
