from fastapi import FastAPI
from pydantic import BaseModel
import joblib

# Load the trained model
model = joblib.load("savings_recommendation_model.pkl")

app = FastAPI()

class UserInput(BaseModel):
    income: float
    expenses: float
    goal_amount: float
    months_to_goal: float

@app.post("/predict")
def predict_savings(data: UserInput):
    X = [[data.income, data.expenses, data.goal_amount, data.months_to_goal]]
    prediction = model.predict(X)[0]
    return {"recommended_saving": prediction} 