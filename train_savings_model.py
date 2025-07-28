import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
import joblib

# Example data (expand this with real or synthetic data for better results)
data = {
    'income': [50000, 60000, 70000, 80000, 90000],
    'expenses': [30000, 35000, 40000, 45000, 50000],
    'goal_amount': [100000, 150000, 200000, 250000, 300000],
    'months_to_goal': [12, 18, 24, 30, 36],
    'recommended_saving': [8333, 8333, 8333, 8333, 8333]  # goal_amount / months_to_goal
}

df = pd.DataFrame(data)

X = df[['income', 'expenses', 'goal_amount', 'months_to_goal']]
y = df['recommended_saving']

model = LinearRegression()
model.fit(X, y)

# Save the model to a file
joblib.dump(model, 'savings_recommendation_model.pkl')

print("Model trained and saved as 'savings_recommendation_model.pkl'")