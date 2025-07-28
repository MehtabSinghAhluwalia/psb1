import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import joblib

# Load your exported data
# Update the path if needed
DATA_PATH = '/Users/apple/Documents/goal_training_data.json'
MODEL_PATH = 'goal_feasibility_model.pkl'

df = pd.read_json(DATA_PATH)

# Feature selection
X = df[['income', 'total_loans', 'total_investments', 'goal_amount', 'goal_priority', 'goal_time_months']]
y = df['achieved']

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluate
print('Test accuracy:', model.score(X_test, y_test))

# Save model
joblib.dump(model, MODEL_PATH)
print(f'Model saved as {MODEL_PATH}') 