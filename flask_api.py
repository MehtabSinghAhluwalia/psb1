from flask import Flask, request, jsonify
import joblib
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load the trained model
model = joblib.load("savings_recommendation_model.pkl")

@app.route('/predict', methods=['POST'])
def predict_savings():
    data = request.get_json()
    income = data.get('income')
    expenses = data.get('expenses')
    goal_amount = data.get('goal_amount')
    months_to_goal = data.get('months_to_goal')
    X = [[income, expenses, goal_amount, months_to_goal]]
    prediction = model.predict(X)[0]
    return jsonify({'recommended_saving': prediction})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True) 