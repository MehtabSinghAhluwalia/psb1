import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib

# Load enhanced dataset
csv_file = 'enhanced_phishing_dataset.csv'
df = pd.read_csv(csv_file)

# Feature columns for training (add/remove as needed)
feature_cols = [
    'URLLength', 'DomainLength', 'subdomain_count', 'suspicious_subdomain',
    'punycode', 'unicode_trick', 'brand_similarity',
    'special_characters', 'suspicious_keywords_found', 'shortener_score'
]

# Fallback for column names if needed
for col in feature_cols:
    if col not in df.columns:
        print(f"Warning: Column {col} not found in dataset.")

X = df[feature_cols].fillna(0)
y = df['label']

# Train model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)

# Save model
joblib.dump(model, 'phishing_model.pkl')
print('Trained model saved as phishing_model.pkl') 