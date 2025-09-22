from flask import Flask, request, jsonify
import math

app = Flask(__name__)

@app.route('/convert', methods=['GET'])
def convert():
    lbs_str = request.args.get('lbs')
    if lbs_str is None:
        return jsonify({"error": "Query param lbs is required and must be a number"}), 400
    
    try:
        lbs = float(lbs_str)
    except ValueError:
        return jsonify({"error": "Query param lbs is required and must be a number"}), 400
    
    if not math.isfinite(lbs) or lbs < 0:
        return jsonify({"error": "lbs must be a non-negative, finite number"}), 422
    
    kg = round(lbs * 0.45359237, 3)
    return jsonify({
        "lbs": lbs,
        "kg": kg,
        "formula": "kg = lbs * 0.45359237"
    })